require 'blackbaud-client/connector.rb'
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
require 'blackbaud-client/api/term.rb'
require 'blackbaud-client/api/code_table_entry.rb'
require 'blackbaud-client/api/attendance_code.rb'
require 'blackbaud-client/api/attendance_record.rb'
require 'blackbaud-client/api/attendance_by_day_record.rb'
require 'blackbaud-client/api/attendance_by_class_record.rb'
require 'blackbaud-client/api/grade.rb'
require 'blackbaud-client/api/marking_column.rb'
require 'blackbaud-client/api/translation_table.rb'
require 'blackbaud-client/api/translation_table_entry.rb'
require 'hmac-sha1'
require 'cgi'
require 'base64'
require 'json'
require 'rest-client'
require 'date'

module Blackbaud
  class Client
    attr_accessor(:connector)
    def initialize(options)
      @connector = Blackbaud::Connector.new(options[:url], options[:save_request_data_to])
      auth_params = {
        :database_key => options[:database_key],
        :database_number => options[:database_number],
        :vendor_id => options[:vendor_id],
        :vendor_key => options[:vendor_key]
      }.to_json
      @connector.token = get_token(auth_params)
    end

    def get_token(auth_params)
      results = @connector.post('/security/access_token', auth_params)
      results["token"]
    end

    def get_academic_years(id)
      results = @connector.get("schedule/#{id}/academic_years")
      # results["academic_years"].collect {|year| Blackbaud::AcademicYear.new(year)}
      create_blackbaud_objects(Blackbaud::AcademicYear, results["academic_years"])
    end

    def get_contact_types
      results = @connector.get("global/code_tables/phone%20type")
      create_blackbaud_objects(Blackbaud::CodeTableEntry, results["table_entries"])
    end

    def get_relationships
      results = @connector.get("global/code_tables/relationship")
      create_blackbaud_objects(Blackbaud::CodeTableEntry, results["table_entries"])
    end

    def get_person(id, filter_opts={})
      filters = {}
      filters["contact.type_id"] = filter_opts[:contact_types]
      filters["relation.relationship_code_id"] = filter_opts[:relationships]
      results = @connector.get("person/people/#{id}", filters)
      create_blackbaud_object(Blackbaud::Person, results["people"].first)
    end

    # Return an Array of Person records
    #
    # Available filter_opts:
    # * :contact_types: An Array of id values that correspond to code_table table_entry records from the "phone type" code_table
    # * :relationships: An Array of id values that correspond to code_table table_entry records from the "relationship" code_table
    def get_people(scope, filter_opts={})
      filters = {}
      filters["contact.type_id"] = filter_opts[:contact_types]
      filters["relation.relationship_code_id"] = filter_opts[:relationships]

      results = @connector.get("person/#{scope.connection_string}/people", filters)["people"].first

      {
        'faculty'   => Blackbaud::Person::USER_TYPE[:faculty],
        'students'  => Blackbaud::Person::USER_TYPE[:student],
      }.each do |response_key, type_id|
        if results[response_key].is_a?(Enumerable)
          results[response_key].each{|person| person['type'] = type_id}
        end
      end
      create_blackbaud_objects(Blackbaud::Person, results['faculty'] + results['students'])
    end

    def get_classes(scope)
      results = @connector.get("schedule/#{scope.connection_string}/classes")
      create_blackbaud_objects(Blackbaud::Class, results["classes"])
    end

    def get_class(id)
      results = @connector.get("schedule/classes/#{id}")
      create_blackbaud_object(Blackbaud::Class, results["classes"].first)
    end

    def get_code_tables
      results = @connector.get("global/code_tables")
      create_blackbaud_objects(Blackbaud::CodeTable, results["code_tables"])
    end

    def get_code_table_entries(code_table)
      results = @connector.get("global/code_tables/#{code_table.id}")
      create_blackbaud_objects(Blackbaud::CodeTableEntry, results["table_entries"])
    end

    def get_static_code_tables(id)
      results = @connector.get("global/static_code_tables/#{id}")
      create_blackbaud_objects(Blackbaud::CodeTableEntry, results["table_entries"])
    end

    def get_attendance_codes
      results = @connector.get("attendance/codes")
      create_blackbaud_objects(Blackbaud::AttendanceCode, results["attendance_codes"])
    end

    def get_attendance_by_class(ea7_class_id, start_date, end_date = nil)
      results = @connector.get("attendance/class/#{ea7_class_id}/#{format_date(start_date)}/#{format_date(end_date)}")
      create_blackbaud_objects(Blackbaud::AttendanceByClassRecord, results["attendance_by_class_records"])
    end

    def get_attendance_by_day(ea7_class_id, start_date, end_date = nil)
      results = @connector.get("attendance/day/#{ea7_class_id}/#{start_date}/#{end_date}")
      create_blackbaud_objects(Blackbaud::AttendanceByDayRecord, results["attendance_by_day_records"])
    end

    def get_class_marking_columns(class_id)
      results = @connector.get("grade/classes/#{class_id}/marking_columns")
      results["class_marking_columns"].each{|column| column["ea7_class_id"] = class_id}
      create_blackbaud_objects(Blackbaud::MarkingColumn, results["class_marking_columns"])
    end

    def get_grades(class_id, marking_column_id)
      results = @connector.get("grade/classes/#{class_id}/marking_columns/#{marking_column_id}/grades")
      create_blackbaud_objects(Blackbaud::Grade, results["grades"])
    end

    def get_faweb_grades(class_id, marking_column_id)
      results = @connector.get("faweb_grade/classes/#{class_id}/marking_columns/#{marking_column_id}/grades")
      create_blackbaud_objects(Blackbaud::Grade, results["faweb_grades"])
    end

    def get_translation_tables(id=nil)
      results = @connector.get("grade/translation_tables/#{id}")
      create_blackbaud_objects(Blackbaud::TranslationTable, results["translation_tables"])
    end

    def post_grades(grades)
      results = @connector.post('/grade/class', grades)
      create_blackbaud_objects(Blackbaud::Grade, results["grades"])
    end

    # These are for backwards compatiobilty with version <=0.1.4.  Remove them before v 1.0.
    alias_method :academic_years, :get_academic_years
    alias_method :contact_types, :get_contact_types
    alias_method :relationships, :get_relationships
    alias_method :person, :get_person
    alias_method :people, :get_people
    alias_method :classes, :get_classes
    alias_method :class, :get_class
    alias_method :code_tables, :get_code_tables
    alias_method :code_table_entries, :get_code_table_entries
    alias_method :static_code_tables, :get_static_code_tables
    alias_method :attendance_codes, :get_attendance_codes
    alias_method :attendance_by_class, :get_attendance_by_class
    alias_method :attendance_by_day, :get_attendance_by_day
    alias_method :class_marking_columns, :get_class_marking_columns
    alias_method :grades, :get_grades
    alias_method :faweb_grades, :get_faweb_grades
    alias_method :translation_tables, :get_translation_tables

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

    def format_date(date)
      return unless date
      date = DateTime.parse(date) if date.is_a?(String)
      date.strftime("%F")
    end

  end
end
