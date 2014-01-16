module Blackbaud
  class StaticCodeTable < BlackbaudObject
    attr_accessor(:id, :name, :links)

    def initialize(values)

      values.each do |k,v|
        send("#{k}=".intern, v)
      end
    end

  end
end