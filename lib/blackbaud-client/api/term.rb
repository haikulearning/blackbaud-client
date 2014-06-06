module Blackbaud
  class Term < BlackbaudObject
    attr_accessor(:ea7_term_id, :name, :links)

    def connection_string
      "terms/#{self.ea7_term_id}"
    end

  end
end