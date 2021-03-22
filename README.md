 <p align="center">
  <a href="https://texterify.com/?utm_source=github&utm_medium=logo" target="_blank">
    <img src="https://raw.github.com/texterify/texterify/screenshots/logo.png?sanitize=true" alt="Texterify" height="72">
  </a>
</p>

[![Open Issues](https://img.shields.io/badge/website-texterify.com-blue.svg)](https://texterify.com)
[![Build & Push](https://github.com/texterify/texterify/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/texterify/texterify/actions)
[![Open Issues](https://img.shields.io/github/issues-raw/texterify/texterify.svg)](https://github.com/texterify/texterify/issues)
[![](https://img.shields.io/github/stars/texterify/texterify)](https://github.com/texterify/texterify)
[![](https://img.shields.io/docker/pulls/chrztoph/texterify)](https://hub.docker.com/r/chrztoph/texterify)

[Texterify](https://texterify.com) is a localization management platform which aims to make software localization as easy as possible. A very clean and user friendly interface makes it easy to use while providing full flexibility and powerful tools to perfectly integrate it into your workflow. Find out more at [texterify.com](https://texterify.com).

- Beautiful light and dark mode for every situation
- Built-in WYSIWYG HTML editor for easy rich content editing
- Language inheritance and post processing
- Flexible ways to export your translations
- Translation and activity history
- Collaboration features for teams
- Over the air translations for fast app translation updates
- Integrations for every situation
- Cloud and on-premise versions available

<p align="center">
  <img src="https://raw.github.com/texterify/texterify/screenshots/example_1.png" width="290">
  <img src="https://raw.github.com/texterify/texterify/screenshots/example_2.png" width="290">
  <img src="https://raw.github.com/texterify/texterify/screenshots/example_3.png" width="290">
</p>

## Table of contents

- [🚀 Getting started](#getting-started)
- [🛠️ Tools & Integrations](#tools-&-integrations)
- [👀 Troubleshooting](#troubleshooting)
- [🤝 Contributing](#contributing)
- [🔒 Security](#security)
- [📋 Changelog](#changelog)
- [📝 License](#license)

## 🚀 Getting started

If you want to try out Texterify you can sign up at [texterify.com](https://texterify.com) and use the cloud version of Texterify without having to setup anything yourself.

If you want to set it up yourself the easiest way to get the software up and running is by using the official [Docker image](https://hub.docker.com/r/chrztoph/texterify). We provide a `docker-compose` configuration for starting Texterify locally or on your server within seconds.

You only need to have `docker` and `docker-compose` installed.

The process of starting the application is the following:

```sh
# Clone the docker-compose configuration.
git clone https://github.com/texterify/texterify-docker-compose-setup.git
cd texterify-docker-compose-setup

# Generate a secret key for the app.
# Make sure to keep this private.
echo SECRET_KEY_BASE=`openssl rand -hex 64` > secrets.env

# Start the service.
docker volume create --name=texterify-database
docker volume create --name=texterify-assets
docker-compose up

# After everything has started create the database in another terminal.
docker-compose exec app bin/rails db:create db:migrate db:seed

# Service is now available at http://localhost.
```

This will install the latest version of the service available at the time of setting up.

## 🛠️ Tools & Integrations

We provide several different tools and integrations to make localization as easy as possible. If you are missing anything you would love to have create a ticket [here](https://github.com/texterify/texterify/issues) and let us know or tell us what you created and we will include it here.

- Texterify VSC Extension (https://github.com/texterify/texterify-vsc)
- Texterify CLI (https://github.com/texterify/texterify-cli)
- Texterify Android SDK (https://github.com/texterify/texterify-android)
- Texterify iOS SDK (https://github.com/texterify/texterify-ios)
- Texterify API Node (https://github.com/texterify/texterify-api-node)

## 👀 Troubleshooting

### Why is the watcher command failing randomly with exit code 137?

If you receive the error below try to increase the memory (e.g. `8 GB`) that docker can use. Webpacker unfortunately requires a lot of memory to compile all the assets.

```sh
> yarn start:watcher
...
Killed
error Command failed with exit code 137.
```

### After starting the server I get Webpacker::Manifest::MissingEntryError?

This usually happens when you start the development server for the first time and webpack has not yet compiled the required frontend assets and therefore some files can not be found. Run `yarn start` in a terminal and `yarn start:watcher` in another one and wait for the `yarn start:watcher` command to finish initial compilation (the terminal outputs `Compiled successfully`). Then reload the site. This can take some minutes initially.

## 🤝 Contributing

Want to help build Texterify?

We are happy about every help.

## 🔒 Security

Found a security issue? Please **don't** create an issue on GitHub. Instead send an email with your findings to [security@texterify.com](mailto:security@texterify.com) so a bugfix can be developed before the security flaw is publicly disclosed. We take security very seriously.

## 📋 Changelog

See [CHANGELOG](CHANGELOG) for changelog.

## 📝 License

See the [LICENSE](LICENSE) file for details.

You can find also more information at [https://texterify.com/pricing](https://texterify.com/pricing).
