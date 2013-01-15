## Smartkiosk: kiosk management software (server-side part)


### Documentation

Please visit [project wiki](https://github.com/roundlake/smartkiosk/wiki) for the documentation.

### Quick Start

Only Redis is required basically. Depending on the list of gateways you are going to use you may require different libraries available at your host machine. All the gems required by gateways are grouped into `group :gateways` at the `Gemfile` located at the root application directory. You can reduce this dependencies by simply commenting it out. This will accordingly disable depending gateways.

Server side of Smartkiosk is just a Rails application. Clone it, migrate it, seed it and you are ready to go.

### Kiosk API

API documentation is handled via apiary.io and is available at [http://docs.smartkiosk.apiary.io](http://docs.smartkiosk.apiary.io)