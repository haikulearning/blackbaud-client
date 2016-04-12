module Blackbaud
  class Client
    class Version
      MAJOR = 1
      MINOR = 0
      PATCH = 0
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
