class User < ApplicationRecord
  include DeviseTokenAuth::Concerns::User

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  validates :username, uniqueness: true, presence: true

  has_many :project_users, dependent: :delete_all
  has_many :user_projects, through: :project_users, source: :project

  has_many :organization_users, dependent: :delete_all
  has_many :organizations, through: :organization_users
  has_many :organization_projects, through: :organizations, source: :projects

  has_many :access_tokens, dependent: :destroy
  has_many :user_licenses, dependent: :destroy
  has_one_attached :image

  has_many :recently_viewed_projects, dependent: :destroy

  def projects
    Project.where(id: user_projects.pluck(:id) + organization_projects.pluck(:id))
  end

  def private_projects
    user_projects.where(organization_id: nil)
  end

  # Determines if an email confirmation is required after registration.
  def confirmation_required?
    ENV['EMAIL_CONFIRMATION_REQUIRED'] == 'true'
  end

  # Override Devise::Confirmable#after_confirmation
  def after_confirmation
    if Texterify.cloud?
      UserMailer.welcome(email, username).deliver_later
    end
  end

  def confirmed
    !confirmed_at.nil?
  end
end
