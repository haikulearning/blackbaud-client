module Blackbaud
  class CodeTable < BlackbaudObject
    attr_accessor(:_links, :id, :name, :links)

    def entries
      @client.code_table_entries(self)
    end

  end
end