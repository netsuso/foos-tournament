# Foosball tournament organizer

This is a web interface and a set of command line tools to help organize a foosball
tournament. We currently use it at [Tuenti](http://www.tuenti.com/) to handle a
tournament for about 60 people.

It relates to the [Foosball instant replay](https://github.com/swehner/foos) project.

# Running

We provide a docker-based build. So you just need to create the docker

`make docker`

and then run it

`make run`

Usually, when running the a docker tool with state you want it outside
the container. Here, the state is on the sqlite DB, so you can manually
create it and mount when running docker. You can do this with:

`make run_localdb`

If this doesn't work for you, you may need to change the sqlite file
permissions to give RW permissions to every user or fix it any other
way (like running docker with your uid).
