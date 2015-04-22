# Blackbaud Client
Ruby client for the Blackbaud API.

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

## Version History
### 0.1.3
- Added emergency_contact attribute to Relation.
- Various fixes and cleanup.

### 0.1.2
- Format JSON output for readability.

### 0.1.1
- Option to store raw JSON response data

### 0.1.0
- Initial Release