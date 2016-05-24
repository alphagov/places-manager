# Imminence

Imminence manages sets of (somewhat) structured data for use elsewhere on GOV.UK.
It's primarily used for geographical data such as lists of registry offices, test
centres, and the like.

The data is structured as a set of Services which represent a distinct type of
location. A Service can then have many Data Sets which are in turn collections of
Places. Only one Data Set will be "active" at any given time.

Each data set is uploaded as a CSV file. A cron job takes care of geocoding the
places within it. It can then be manually inspected or exported as CSV, JSON or KML
so it can be tested using a variety of other tools.

There is a simple JSON API for integrating the data with other applications.

## Nomenclature

- **Services**: Represent a distinct type of location (e.g. Register Offices)
- **Datasets**: Services can have many datasets, which are collections of Places. Only one Data Set will be "active" at any given time.
- **Places**: Geocoded data of individual locations which belong to a Dataset.

## Technical documentation

Imminence is a Ruby on Rails application backed by a MongoDB database.

### Dependencies

- [alphagov/mapit](https://github.com/alphagov/mapit) - provides postcode lookups

### Running the application

From within the app root directory:

`./startup.sh`

Note that you will have to have GOV.UK Mapit running locally.

In the GOV.UK DEV VM from the 'development' directory:

`bowl imminence`

Note that the app uses a local version of [GOV.UK Mapit](https://github.com/alphagov/mapit), therefore a valid dataset will have to be loaded for Mapit, otherwise postcode lookups will not succeed. This is part of the standard GOV.UK data replication steps.

### Running the test suite

`bundle exec rake`

`bundle exec govuk-lint-ruby app test lib`

## Licence

[MIT License](LICENCE)
