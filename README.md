# Foosball tournament organizer

This is a web interface and a set of command line tools to help organize a foosball
tournament. We currently use it at [Tuenti](http://www.tuenti.com/) to handle a
tournament for about 60 people.

It relates to the [Foosball instant replay](https://github.com/swehner/foos) project.

Barely working version, expect documentation and a demo soon.

# Instalation

## Pre-requisites

1. ruby > v1.9.3
2. sqlite3
3. libsqlite3-dev
4. Gems:
   - sinatra
   - data_mapper
   - dm-sqlite-adapter
   - sqlite3

## Preparing for the first execution

```
> cd <source-path>/dm
> ruby upgrade_model.rb
> cd ../bin
> ruby create_season.rb <any season name>
```

## Running the app

```
> ruby web_router.rb
```
