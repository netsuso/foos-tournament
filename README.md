# Foosball tournament organizer

This is a web interface and a set of command line tools to help organize a foosball
tournament. We currently use it at [Tuenti](http://www.tuenti.com/) to handle a
tournament for about 60 people.

It relates to the [Foosball instant replay](https://github.com/swehner/foos) project.

Barely working version, expect documentation and a demo soon.

# Installation

## Pre-requisites

1. ruby > v1.9.3
2. sqlite3
4. Gems:
   - sinatra
   - data_mapper
   - dm-sqlite-adapter
   - sqlite3

### Additional pre-requisites for Ubuntu

1. ruby-full package, instead of just ruby
2. libsqlite3-dev

## Preparing for the first execution

1. Make a copy of the file ```config.yaml.sample``` and rename it to ```config.yaml```
```
> cp config.yaml.sample config.yaml
```
2. Update the ```db_uri``` value to point to your data base
3. Generate the database and the first season
```
> cd <source-path>/dm
> ruby upgrade_model.rb
> cd ../bin
> ruby create_season.rb "<any season name>" --active
```

## Running the app

```
> ruby web_router.rb
```
