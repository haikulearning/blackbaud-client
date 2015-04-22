module Blackbaud
  class Relation < BlackbaudObject
    attr_accessor(:relationship_code_id, :relationship_code_value, :reciprocal_code_id, :reciprocal_code_value, :person, :emergency_contact)

    def initialize(values)
      values["person"] = Blackbaud::Person.new(values["person"], Blackbaud::Person::USER_TYPE[:undefined]) if values["person"]
      super(values)
    end

  end
end