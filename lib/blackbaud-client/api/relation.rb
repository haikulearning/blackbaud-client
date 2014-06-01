module Blackbaud
  class Relation < BlackbaudObject
    attr_accessor(:relationship_code_id, :relationship_code_value, :reciprocal_code_id, :reciprocal_code_value, :person)

    def initialize(values)
      if values["person"]
        values["person"] = Blackbaud::Person.new(values["person"], Blackbaud::Person::USER_TYPE[:undefined])
      end

      values.each do |k,v|
        send("#{k}=".intern, v)
      end
    end

  end
end