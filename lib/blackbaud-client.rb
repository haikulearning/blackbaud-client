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
require 'blackbaud-client/api/attendance_code.rb'
require 'blackbaud-client/api/attendance_record.rb'
require 'blackbaud-client/api/attendance_by_day_record.rb'
require 'blackbaud-client/api/attendance_by_class_record.rb'
require 'blackbaud-client/api/grade.rb'
require 'blackbaud-client/api/marking_column.rb'
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
      # results["academic_years"].collect {|year| Blackbaud::AcademicYear.new(year)}
      create_blackbaud_objects(Blackbaud::AcademicYear, results["academic_years"])
    end

    def contact_types
      results = connect("global/code_tables/phone%20type")
      create_blackbaud_objects(Blackbaud::CodeTableEntry, results["table_entries"])
    end

    def relationships
      results = connect("global/code_tables/relationship")
      create_blackbaud_objects(Blackbaud::CodeTableEntry, results["table_entries"])
    end

    def person(id, filter_opts={})
      filters = {}
      filters["contact.type_id"] = filter_opts[:contact_types]
      filters["relation.relationship_code_id"] = filter_opts[:relationships]

      results = connect("person/people/#{id}", filters)

      create_blackbaud_object(Blackbaud::Person, results["people"].first)
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

      results = connect("person/#{scope.connection_string}/people", filters ).people.first

      {
        'faculty'   => Blackbaud::Person::USER_TYPE[:faculty],
        'students'  => Blackbaud::Person::USER_TYPE[:student],
      }.each do |response_key, type_id|
        if results[response_key].is_a?(Enumerable)
          results[response_key].each{|person| person['type'] = type_id}
        end
      end
      create_blackbaud_object(Blackbaud::Person, results['factuly'] + results['students'])
    end

    def classes(scope)
      results = connect("schedule/#{scope.connection_string}/classes")
      create_blackbaud_objects(Blackbaud::Class, results["classes"])
    end

    def class(id)
      results = connect("schedule/classes/#{id}")
      create_blackbaud_object(Blackbaud::Class, results["classes"].first)
    end

    def code_tables
      results = connect("global/code_tables")
      create_blackbaud_objects(Blackbaud::CodeTable, results["code_tables"])
    end

    def code_table_entries(code_table)
      results = connect("global/code_tables/#{code_table.id}")
      create_blackbaud_objects(Blackbaud::TableEntry, results["table_entries"])
    end

    def static_code_tables(id)
      results = connect("global/static_code_tables/#{id}")
      create_blackbaud_objects(Blackbaud::TableEntry, results["table_entries"])
    end

    def attendance_codes
      results = connect("attendance/codes")
      create_blackbaud_objects(Blackbaud::AttendanceCode, results["attendance_codes"])
    end

    def attendance_by_class(ea7_class_id, start_date, end_date = nil)
      results = connect("attendance/class/#{ea7_class_id}/#{format_date(start_date)}/#{format_date(end_date)}")
      create_blackbaud_objects(Blackbaud::AttendanceByClassRecord, results["attendance_by_class_records"])
    end

    def attendance_by_day(ea7_class_id, start_date, end_date = nil)
      results = connect("attendance/day/#{ea7_class_id}/#{start_date}/#{end_date}")
      create_blackbaud_objects(Blackbaud::AttendanceByDayRecord, results["attendance_by_day_records"])
    end

    def class_marking_columns(class_id)
      results = connect("grade/classes/#{class_id}/marking_columns")
      results["class_marking_columns"].each{|column| column["ea7_class_id"] = class_id}
      create_blackbaud_objects(Blackbaud::MarkingColumn, results["class_marking_columns"])
    end

    def grades(class_id, marking_column_id)
      results = connect("grade/classes/#{class_id}/marking_columns/#{marking_column_id}/grades")
      create_blackbaud_objects(Blackbaud::Grade, results["grades"])
    end

    private

    def create_blackbaud_objects(klass, results)
      results = [results] if results.class == Hash
      ret = results.collect do |result|
        klass.new({values: result, client: self})
      end
      ret || []
    end

    def create_blackbaud_object(klass, result)
      klass.new({values: result, client: self})
    end


    def write_json_to_file(url, data)
      return unless data
      file = url.gsub( /\/|\\/, ':' ).match(/.{,250}$/).to_s + '.json'
      # file = /[^\/]*$/.match(url).to_s + '.json'
      file = File.expand_path(File.join(@save_request_data_to, file))
      FileUtils.mkdir_p @save_request_data_to
      File.open(file, 'w') { |f| f.write(JSON.pretty_unparse(JSON.parse(data)))}
    end

    def format_date(date)
      return unless date
      date = DateTime.parse(date) if date.is_a?(String)
      date.strftime("%F")
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