# Imminence

Imminence manages sets of (somewhat) structured data for use elsewhere on GOV.UK. It's primarily used for geographical data such as lists of registry offices, test centres, and the like.

The data is structured as a set of Services which represent a distinct type of location. A Service can then have many Data Sets which are in turn collections of Places. Only one Data Set will be "active" at any given time.

Each data set is uploaded as a CSV file. A cron job takes care of geocoding the places within it. It can then be manually inspected or exported as CSV, JSON or KML so it can be tested using a variety of other tools.

There is a simple JSON API for integrating the data with other applications.

## Nomenclature

- **Services**: Represent a distinct type of location (e.g. Register Offices)
- **Data sets**: Services can have many data sets, which are collections of Places. Only one data set will be "active" at any given time.
- **Places**: Geocoded data of individual locations which belong to a data set.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

```sh
bundle exec rake
```

## Licence

[MIT License](LICENCE)

### Further documentation

- [Adding a new service](docs/adding-a-new-service.md)
