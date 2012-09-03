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

## Application Details

Imminence is a Ruby on Rails application backed by a MongoDB database.
