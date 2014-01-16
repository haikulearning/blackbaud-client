# Clever::Ruby

Ruby bindings to the Blackbaud API.

## Usage

Create a Blackbaud API Client

    options = {
      :password => "pass",
      :key => "abcde",
      :username => "user",
      :database => "1"
      :url => "https://blackbaud.api.url.example/key/"
    }

    @client = Blackbaud::Client.new(options)