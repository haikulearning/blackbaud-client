module Blackbaud
  class Session < BlackbaudObject
    attr_accessor(:name, :ea7_session_id, :terms, :links)

    def initialize(values)
      values["terms"].map! {|t| Blackbaud::Term.new(t)} if values["terms"]
      super(values)
    end

  end
end