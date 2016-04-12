module Blackbaud
  class Relation < BlackbaudObject
    attr_accessor(:relationship_code_id, :relationship_code_value, :reciprocal_code_id, :reciprocal_code_value, :person, :emergency_contact, :allow_netclassroom_view, :can_view_report_cards, :lives_with)

    def initialize(options)
      options.fetch(:values)["person"] = Blackbaud::Person.new(values: options.fetch(:values)["person"]) if options.fetch(:values)["person"]
      super
    end

  end
end