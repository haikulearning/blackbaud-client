module Blackbaud
  class Class < BlackbaudObject
    attr_accessor(:ea7_class_id, :course_id, :course_name, :section, :ea7_term_id, :ea7_term_name, :faculty, :students)

    def initialize(options)
      {
        'faculty'   => Blackbaud::Person::USER_TYPE[:faculty],
        'students'  => Blackbaud::Person::USER_TYPE[:student],
      }.each do |response_key, type_id|
        if options.fetch(:values)[response_key].is_a?(Enumerable)
          options.fetch(:values)[response_key].map! do |person|
            person['type'] = type_id
            Blackbaud::Person.new({values: person})
          end
        end
      end

      super
    end

    def marking_columns
      @client.class_marking_columns(self.ea7_class_id)
    end

  end
end