module Blackbaud
  class Contact < BlackbaudObject
    attr_accessor(:type_id, :type_value, :value)

    def initialize(values)
      values.each do |k,v|
        send("#{k}=".intern, v)
      end
    end

  end
end