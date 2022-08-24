FROM ruby:2.6.3
MAINTAINER warren@travelershaven.com

RUN mkdir -p /app
WORKDIR /app

ENV BUNDLE_PATH /gems
RUN gem install bundler

COPY . ./

EXPOSE 3000
