module Blackbaud
  class BlackbaudObject

    attr_accessor :client

    def initialize(options)
      @client ||= options.delete(:client)

      options.fetch(:values).each do |k,v|
        send("#{k}=".intern, v) if respond_to?("#{k}=".intern)
      end
    rescue NoMethodError
      puts "NoMethodError: There is no method for one of the keys in your options: #{options}"
      return nil
    end

    def format_date(d)
      DateTime.parse(d)
    end

  end
end