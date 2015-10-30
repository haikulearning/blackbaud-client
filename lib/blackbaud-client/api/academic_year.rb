module Blackbaud
  class AcademicYear < BlackbaudObject
    attr_accessor(:description, :ea7_academic_year_id, :end_date, :school_id, :school_name, :sessions, :short_description, :start_date, :links)

    def initialize(options)

      options.fetch(:values)["sessions"].map! {|s| Blackbaud::Session.new(values: s)} if options.fetch(:values)["sessions"]

      ["start_date", "end_date"].each do |date|
        send("#{date}=".intern, format_date(options.fetch(:values)["#{date}"]))
        options.fetch(:values).delete("#{date}")
      end

      super
    end

    def connection_string
      "academic_years/#{self.ea7_academic_year_id}"
    end

    def terms
      self.sessions.inject([]) {|r, s| r + s.terms}
    end

  end
end