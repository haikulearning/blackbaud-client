module Blackbaud
  class CodeTableEntry < BlackbaudObject
    attr_accessor(:id, :name)

    def initialize(values)
      values.each do |k,v|
        send("#{k}=".intern, v)
      end
    end

  end
end