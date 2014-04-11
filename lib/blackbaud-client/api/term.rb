module Blackbaud
  class Term < BlackbaudObject
    attr_accessor(:ea7_term_id, :name, :links)

    def initialize(values)

      values.each do |k,v|
        send("#{k}=".intern, v)
      end

    end

    def connection_string
      "terms/#{self.ea7_term_id}"
    end

  end
end