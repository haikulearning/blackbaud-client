module Blackbaud
  class Client
    class Version
      MAJOR = 0
      MINOR = 2
      PATCH = 2
      STRING = "#{MAJOR}.#{MINOR}.#{PATCH}"

      class << self
        def inspect
          STRING
        end
        alias_method :to_s, :inspect
      end
    end

    VERSION = Version::STRING
  end
end
