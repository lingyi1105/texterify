class AndroidTemplateData
  attr_accessor :data

  def initialize(data)
    @data = data
  end

  # Expose private binding() method.
  # rubocop:disable Naming/AccessorMethodName
  def get_binding
    binding
  end
  # rubocop:enable Naming/AccessorMethodName
end

class ExportConfig < ApplicationRecord
  include ExportHelper

  scope :order_by_name, -> { order(arel_table['name'].lower.asc) }

  validates :name, presence: true
  validates :file_path, presence: true
  validates :file_format, presence: true
  validate :no_duplicate_export_configs_for_project

  belongs_to :project
  has_many :translations, dependent: :destroy
  has_many :post_processing_rules, dependent: :destroy
  has_many :language_configs, dependent: :destroy
  has_many :releases, dependent: :destroy

  def latest_release
    releases.order('version DESC').first
  end

  def name=(name)
    self[:name] = name.strip
  end

  def file_path=(file_path)
    self[:file_path] = file_path.strip
  end

  def file_format=(file_format)
    self[:file_format] = file_format.strip
  end

  def filled_file_path(language)
    path = file_path

    if language.is_default && default_language_file_path.present?
      path = default_language_file_path
    end

    language_config_code = language_configs.find_by(language_id: language.id)

    # Use the language code from the language config if available.
    if language_config_code
      path = path.sub('{languageCode}', language_config_code.language_code)
    elsif language.language_code
      path = path.sub('{languageCode}', language.language_code.code)
    else
      path
    end

    language.country_code ? path.sub('{countryCode}', language.country_code.code) : path
  end

  def file(language, export_data, language_source = nil, export_data_source = nil)
    # stringify in case export_data has symbols in it
    export_data.deep_stringify_keys!
    export_data_source&.deep_stringify_keys!

    if file_format == 'json'
      json(language, export_data)
    elsif file_format == 'json-formatjs'
      json_formatjs(language, export_data)
    elsif file_format == 'typescript'
      typescript(language, export_data)
    elsif file_format == 'android'
      android(language, export_data)
    elsif file_format == 'ios'
      ios(language, export_data)
    elsif file_format == 'yaml'
      yaml(language, export_data)
    elsif file_format == 'rails'
      yaml(language, export_data, group_by_language_and_country_code: true)
    elsif file_format == 'toml'
      toml(language, export_data)
    elsif file_format == 'properties'
      properties(language, export_data)
    elsif file_format == 'po'
      po(language, export_data)
    elsif file_format == 'arb'
      arb(language, export_data)
    elsif file_format == 'xliff'
      xliff(language, export_data, language_source, export_data_source)
    else
      json(language, export_data)
    end
  end

  # Validates that there are no export configs with the same name for a project.
  def no_duplicate_export_configs_for_project
    project = Project.find(project_id)
    export_config = project.export_configs.find_by(name: name)

    if export_config.present?
      updating_export_config = export_config.id == id

      if !updating_export_config
        errors.add(:name, :taken)
      end
    end
  end

  private

  # Sets the value to the hash at the specified path.
  def deep_set(hash, value, *keys)
    hash.default_proc = proc { |h, k| h[k] = Hash.new(&h.default_proc) }

    keys[0...-1].inject(hash) do |acc, h|
      current_val = acc.public_send(:[], h)

      if current_val.is_a?(String) || current_val.nil?
        acc[h] = {}
      else
        current_val
      end
    end.public_send(:[]=, keys.last, value)
  end

  def json(language, export_data)
    language_file = Tempfile.new(language.id.to_s)
    converted_data = export_data

    # If the export config has a split_on specified split it.
    unless self.split_on.nil?
      converted_data = {}
      export_data.each do |key, value|
        splitted = key.split(self.split_on)
        deep_set(converted_data, value, *splitted)
      end
    end

    language_file.puts(JSON.pretty_generate(converted_data))
    language_file.close

    language_file
  end

  def json_formatjs(language, export_data)
    language_file = Tempfile.new(language.id.to_s)

    data = {}
    export_data.each do |key, value|
      data[key] = { defaultMessage: value, description: Key.find_by(name: key)&.description }
    end

    language_file.puts(JSON.pretty_generate(data))
    language_file.close

    language_file
  end

  def arb(language, export_data)
    language_file = Tempfile.new(language.id.to_s)

    data = {}
    export_data.each do |key, value|
      if value.is_a?(Hash)
        data[key] = value[:value]
        data["@#{key}"] = { description: Key.find_by(name: key)&.description }
      else
        data[key] = value
      end
    end

    language_file.puts(JSON.pretty_generate(data))
    language_file.close

    language_file
  end

  def typescript(language, export_data)
    language_file = Tempfile.new(language.id.to_s)
    language_file.print("const #{language.name.downcase} = ")
    language_file.puts("#{JSON.pretty_generate(export_data)};")
    language_file.puts
    language_file.puts("export { #{language.name.downcase} };")
    language_file.close

    language_file
  end

  def android(language, export_data)
    template = ERB.new(File.read('app/views/templates/android.xml.erb'))
    data =
      AndroidTemplateData.new(
        export_data.transform_values do |v|
          # https://developer.android.com/guide/topics/resources/string-resource#escaping_quotes
          # & and < must be escaped manually if necessary.
          v
            .gsub(/(?<!\\)'/, "\\\\'")
            .gsub(/(?<!\\)"/, '\\\\"')
            .gsub(/(?<!\\)@/, '\\\\@')
            .gsub(/(?<!\\)\?/, '\\\\?')
            .gsub(/&(?!amp;)/, '&amp;')
        end
      )
    output = template.result(data.get_binding)

    language_file = Tempfile.new(language.id.to_s)
    language_file.puts(output)
    language_file.close

    language_file
  end

  def xliff(language, export_data, language_source = nil, export_data_source = nil)
    builder =
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.xliff version: '1.2', xmlns: 'urn:oasis:names:tc:xliff:document:1.2' do
          xml.file original: 'Texterify API',
                   "source-language": language_source&.language_tag,
                   "target-language": language.language_tag do
            xml.body do
              export_data.each do |key, value|
                xml.send 'trans-unit', id: key do
                  if language_source && export_data_source
                    xml.source { xml.text export_data_source[key] }
                  end
                  xml.target { xml.text value }
                end
              end
            end
          end
        end
      end

    output = builder.to_xml

    language_file = Tempfile.new(language.id.to_s)
    language_file.puts(output)
    language_file.close

    language_file
  end

  def ios(language, export_data)
    language_file = Tempfile.new(language.id.to_s)
    export_data.each do |key, value|
      # Replace " with \" but don't escape \" again.
      escaped_value = value.gsub(/(?<!\\)"/, '\\"')
      language_file.puts("\"#{key}\" = \"#{escaped_value}\";")
    end
    language_file.close

    language_file
  end

  def yaml(language, export_data, group_by_language_and_country_code: false)
    language_file = Tempfile.new(language.id.to_s)
    data = {}

    if group_by_language_and_country_code
      data[language.language_tag] = export_data
    else
      data = export_data
    end

    yaml = YAML.dump(data)
    language_file.puts(yaml)
    language_file.close

    language_file
  end

  def toml(language, export_data)
    language_file = Tempfile.new(language.id.to_s)
    toml = TomlRB.dump(export_data)
    language_file.puts(toml)
    language_file.close

    language_file
  end

  def properties(language, export_data)
    language_file = Tempfile.new(language.id.to_s)
    properties = JavaProperties.generate(export_data)
    language_file.puts(properties)
    language_file.close

    language_file
  end

  def po(language, export_data)
    language_file = Tempfile.new(language.id.to_s)
    po = PoParser.parse_file(language_file)
    po_data = export_data.map { |k, v| { msgid: k, msgstr: v } }
    po << po_data
    language_file.puts(po)
    language_file.close

    language_file
  end
end
