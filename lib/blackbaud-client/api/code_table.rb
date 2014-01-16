module Blackbaud
  class CodeTable < BlackbaudObject
    attr_accessor(:_links, :id, :name, :links)

    def initialize(values)

      values.each do |k,v|
        send("#{k}=".intern, v)
      end
    end

  end
end