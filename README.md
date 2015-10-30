[![Gem Version](https://badge.fury.io/rb/blackbaud-client.svg)](http://badge.fury.io/rb/blackbaud-client)
[![Code Climate](https://codeclimate.com/github/haikulearning/blackbaud-client/badges/gpa.svg)](https://codeclimate.com/github/haikulearning/blackbaud-client)
[![Build Status](https://secure.travis-ci.org/haikulearning/blackbaud-client.svg)](http://travis-ci.org/haikulearning/blackbaud-client)

# Blackbaud Client
Ruby client for the Blackbaud API.

## Usage

Create a Blackbaud API Client

    require 'blackbaud-client'

    options = {
      :database_key => "db_key",
      :database_number => 1,
      :vendor_id => 'vendor_id',
      :vendor_key => 'vendor_key',
      :url => "https://blackbaud-api-url.com"
    }

    @client = Blackbaud::Client.new(options)

## Version History

[See the change log](CHANGELOG.md)