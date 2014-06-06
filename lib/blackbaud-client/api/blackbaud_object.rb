module Blackbaud
  class BlackbaudObject

    def initialize(values)
      values.each do |k,v|
        if respond_to?("#{k}=".intern)
          send("#{k}=".intern, v)
        end
      end
    end

    def format_date(d)
      DateTime.parse(d)
    end

  end
end