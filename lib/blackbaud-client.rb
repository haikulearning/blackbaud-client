require 'blackbaud-client/api/blackbaud_object.rb'
require 'blackbaud-client/api/academic_year.rb'
require 'blackbaud-client/api/class.rb'
require 'blackbaud-client/api/code_table.rb'
require 'blackbaud-client/api/person.rb'
require 'blackbaud-client/api/session.rb'
require 'blackbaud-client/api/static_code_table.rb'
require 'blackbaud-client/api/table_entry.rb'
require 'blackbaud-client/api/term.rb'
require 'blackbaud-client/api/contact_type.rb'
require 'blackbaud-client/api/contact.rb'
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

    end

    def construct_url(web_services_url, endpoint, filters=nil)
      @url = "#{web_services_url}/#{endpoint}?token=#{@token}"
      @url << "&filter=(#{filters})" if filters
    end

    def connect(endpoint, filters=nil)
      construct_url(@web_services_url, endpoint, filters)
      JSON.parse(RestClient::Request.execute(:method=>'get', :url=>@url))
    end

    def academic_years(id)
      results = connect("schedule/#{id}/academic_years")
      results["academic_years"].collect {|year| Blackbaud::AcademicYear.new(year)}
    end

    def contact_types
      results = connect("global/code_tables/phone%20type")
      results["table_entries"].collect {|ct| Blackbaud::ContactType.new(ct)}
    end

    def people(scope, contact_types)
      results = (scope.class == Blackbaud::Term ? term_people(scope, contact_types) : year_people(scope, contact_types))
      results["people"].first["faculty"].collect {|person| Blackbaud::Person.new(person, 1)} + results["people"].first["students"].collect {|person| Blackbaud::Person.new(person, 2)}
    end

    def year_people(year, contact_types)
      connect("person/academic_years/#{year.ea7_academic_year_id}/people", "contact.type_id%20eq%20#{contact_types.join(',')}" )
    end

    def term_people(term, contact_types)
      connect("person/terms/#{term.ea7_term_id}/people", "contact.type_id%20eq%20#{contact_types.join(',')}" )
    end

    def classes(year)
      results = connect("schedule/academic_years/#{year.ea7_academic_year_id}/classes")
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
  end
end