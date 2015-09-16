module Blackbaud
  class Session < BlackbaudObject
    attr_accessor(:name, :ea7_session_id, :terms, :links)

    def initialize(options)
      options.fetch(:values)["terms"].map! {|t| Blackbaud::Term.new({values: t})} if options.fetch(:values)["terms"]
      super
    end

  end
end