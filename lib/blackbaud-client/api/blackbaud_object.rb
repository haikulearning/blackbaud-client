module Blackbaud
  class BlackbaudObject

    def initialize(values)
      values.each do |k,v|
        send("#{k}=".intern, v) if respond_to?("#{k}=".intern)
      end
    end

    def format_date(d)
      DateTime.parse(d)
    end

  end
end