require 'blackbaud-client/version.rb'
require 'blackbaud-client/api/blackbaud_object.rb'
require 'blackbaud-client/api/academic_year.rb'
require 'blackbaud-client/api/class.rb'
require 'blackbaud-client/api/code_table.rb'
require 'blackbaud-client/api/person.rb'
require 'blackbaud-client/api/contact.rb'
require 'blackbaud-client/api/relation.rb'
require 'blackbaud-client/api/session.rb'
require 'blackbaud-client/api/static_code_table.rb'
require 'blackbaud-client/api/table_entry.rb'
require 'blackbaud-client/api/term.rb'
require 'blackbaud-client/api/code_table_entry.rb'
require 'hmac-sha1'
require 'cgi'
require 'base64'
require 'json'
require 'rest-client'
require 'date'

module Blackbaud
  class Client

    def initialize(options)
      auth_params = {
        :database_key => options[:database_key],
        :database_number => options[:database_number],
        :vendor_id => options[:vendor_id],
        :vendor_key => options[:vendor_key]
      }.to_json
      @web_services_url = options[:url]
      @token = JSON.parse(RestClient.post (@web_services_url+'/security/access_token'), auth_params, {:content_type=>'application/json'})["token"]
      @save_request_data_to = options[:save_request_data_to]
    end

    def connect(endpoint, filters=nil)
      url = construct_url(@web_services_url, endpoint, filters)
      json = RestClient::Request.execute(:method=>'get', :url=>url)
      write_json_to_file(url, json) if @save_request_data_to
      JSON.parse(json)
    end

    def academic_years(id)
      results = connect("schedule/#{id}/academic_years")
      results["academic_years"].collect {|year| Blackbaud::AcademicYear.new(year)}
    end

    def contact_types
      results = connect("global/code_tables/phone%20type")
      results["table_entries"].collect {|entry| Blackbaud::CodeTableEntry.new(entry)}
    end

    def relationships
      results = connect("global/code_tables/relationship")
      results["table_entries"].collect {|entry| Blackbaud::CodeTableEntry.new(entry)}
    end

    # Return an Array of Person records
    #
    # Available filter_opts:
    # * :contact_types: An Array of id values that correspond to code_table table_entry records from the "phone type" code_table
    # * :relationships: An Array of id values that correspond to code_table table_entry records from the "relationship" code_table
    def people(scope, filter_opts={})
      filters = {}

      filters["contact.type_id"] = filter_opts[:contact_types]
      filters["relation.relationship_code_id"] = filter_opts[:relationships]

      results = connect("person/#{scope.connection_string}/people", filters )
      r = []

      {
        'faculty'   => Blackbaud::Person::USER_TYPE[:faculty],
        'students'  => Blackbaud::Person::USER_TYPE[:student],
      }.each do |response_key, type_id|
        ppl = results["people"].first[response_key]
        ppl = [] unless ppl.is_a?(Enumerable)
        ppl.each do |person|
          r << Blackbaud::Person.new(person, type_id)
        end
      end

      r
    end

    def classes(scope)
      results = connect("schedule/#{scope.connection_string}/classes")
      results["classes"].collect {|c| Blackbaud::Class.new(c)}
    end

    def code_tables
      results = connect("global/code_tables")
      results["code_tables"].collect {|table| Blackbaud::CodeTable.new(table)}
    end

    def code_table_entries(code_table)
      results = connect("global/code_tables/#{code_table.id}")
      results["table_entries"].collect {|entry| Blackbaud::TableEntry.new(entry)}
    end

    def static_code_tables(id)
      results = connect("global/static_code_tables/#{id}")
      results["table_entries"].collect {|c| Blackbaud::TableEntry.new(c)}
    end

    private

    def write_json_to_file(url, data)
      return unless data
      file = url.gsub( /\/|\\/, ':' ).match(/.{,250}$/).to_s + '.json'
      # file = /[^\/]*$/.match(url).to_s + '.json'
      file = File.expand_path(File.join(@save_request_data_to, file))
      FileUtils.mkdir_p @save_request_data_to
      File.open(file, 'w') { |f| f.write(data) }
    end

    def construct_url(web_services_url, endpoint, filters=nil)
      url = "#{web_services_url}/#{endpoint}?token=#{@token}"
      filters = Array(filters).map do |k,v|
        v = Array(v)
        "(#{k}%20eq%20#{v.join(',')})" if v && !v.join.empty?
      end

      url << "&filter=#{filters.join}"

      url
    end

  end
end