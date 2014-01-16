module Blackbaud
  class Class < BlackbaudObject
    attr_accessor(:ea7_class_id, :course_id, :course_name, :section, :ea7_term_id, :ea7_term_name, :faculty, :students)

    def initialize(values)

      values["faculty"].map! {|s| Blackbaud::Person.new(s, 1)} if values["faculty"]
      values["students"].map! {|s| Blackbaud::Person.new(s, 2)} if values["students"]

      values.each do |k,v|
        send("#{k}=".intern, v)
      end
    end

  end
end