FROM ruby:2.5-alpine

# Install needed pkgs to build native sqlite and bcrypt gems
RUN apk update \
    && apk add sqlite sqlite-dev ruby-dev make gcc libc-dev \
    && rm -rf /var/cache/apk/*

# Throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN mv config.yml.docker config.yml && \
    cd dm && ./upgrade_model.rb && \
    cd ../bin && ./create_season.rb "Season" --active

CMD ["bundle", "exec", "ruby", "web_router.rb"]
