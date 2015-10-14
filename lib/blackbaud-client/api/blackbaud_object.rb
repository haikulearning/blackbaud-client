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

    def to_hash(keys)
      ivs = keys ? (instance_variables & keys) : instance_variables
      ivs -= [:@client]
      Hash[*
        ivs.map { |v|
        [v.to_s[1..-1].to_sym, instance_variable_get(v)]
      }.flatten]
    end
    
    def to_json(*args)
      JSON.generate(to_hash)  
    end
    
    alias_method :to_h, :to_hash
    
  end
end