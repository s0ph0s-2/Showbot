# Xana

A fuzzy IRC bot with a **web interface** for [XBN](https://xbn.fm).
Built on [cinch](https://github.com/cinchrb/cinch) and
[sinatra](http://www.sinatrarb.com/). Xana is a fork of JBot (by
[rikai](https://github.com/rikai)), which is itself a fork/evolution of
Showbot, built for 5by5.

## IRC Commands

To get a list of the available commands on your Xana instance, send it the
follwing message once it is connected to an IRC network:

```
!help
```

(Make sure your Xana is allowed to send private messages on the IRC network!)

## Setup and Customization

### Prerequisites

 * [RVM with Ruby 1.9.2 or Greater](https://rvm.io/)
 * [Bundler](http://gembundler.com/)
 * Git (for pulling down source from Github, alternately download a tarball)
 * SQLite3 (for development)
 * MySQL client developer bindings (for production)
 * MySQL or MariaDB (for production)
 * `libxslt1-dev` and `libxml2-dev`, for nokogiri

### Setup

These commands will get you setup to run the stable version of Showbot.

 * `git clone https://github.com/s0ph0s-2/Showbot.git`
 * `cd Showbot`
 * `bundle`
 * (Do the section below)
 * `foreman run rake db:migrate`

If you would like to run the development version of Showbot, use the following
commands instead:

 * `git clone https://github.com/s0ph0s-2/Showbot.git`
 * `cd Showbot`
 * `git checkout devel`
 * `bundle`
 * (Do the section below)
 * `foreman run rake db:migrate`

### Configuring Xana

For Xana to work correctly, you need to set up your `.env` file in the root of
the project. Start by copying the `.env.example` file to `.env` and edit
accordingly.

You also need to set up your `cinchize.yml` file. Copy `cinchize.yml.example` to
`cinchize.yml`, and edit accordingly. To deactivate a plugin, comment out all
lines related to that plugin in `cinchize.yml`. Don't forget to also update the
connection settings and your bot's name.

Lastly, you will need to create a `data.json` file. This file can be hosted by
Xana's web server by putting it into `public/`, or can be hosted externally by
setting the `DATA_JSON_URL` variable in `.env` to the URL. To learn more about
`data.json`, read up on its documentation in [`docs/dev/DATA.JSON.md`](https://github.com/rikai/Showbot/blob/master/docs/dev/DATA.JSON.md).

### Launching Showbot

**Website and the IRC Bot**

```
$ bundle exec foreman start -f Procfile.local
```

**Just the Website**

```
$ bundle exec foreman start web -f Procfile.local
```

**Just the IRC Bot**

```
$ bundle exec foreman start irc -f Procfile.local
```

### Modifying the CSS

Modifying [`showbot.scss`][showbot_scss] requires that you start the `rake sass:watch`
command. While this command is running, `public/showbot.css` will be
overwritten with any changes that are made in `showbot.scss`. This annoying
setup is necessary due to [Bourbon](https://github.com/thoughtbot/bourbon) not
working well outside of the Rails asset pipeline.

[showbot_scss]: https://github.com/s0ph0s-2/Showbot/blob/master/sass/showbot.scss

## Want to help out?

Check out our [CONTRIBUTING doc](https://github.com/s0ph0s-2/Showbot/blob/master/CONTRIBUTING.md)
to find out how to contribute to Xana.

## Special Thanks

 * Special thanks to Rikai for reverse-engineering the setup steps for someone
   setting up Showbot from scratch.
 * To [gouwens](https://github.com/gouwens) for implementing the clustered
   view.

## Xana on the Internets

[The Creation of Showbot](http://pileofturtles.com/2011/07/showbot/)

