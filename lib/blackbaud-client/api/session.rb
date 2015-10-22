module Blackbaud
  class Session < BlackbaudObject
    attr_accessor(:name, :ea7_session_id, :marking_columns, :terms, :track_schedule_changes, :beginning_track_date, :message, :links)


    def initialize(options)
      options.fetch(:values)["terms"].map! {|t| Blackbaud::Term.new({values: t})} if options.fetch(:values)["terms"]
      options.fetch(:values)["marking_columns"].map! {|t| Blackbaud::MarkingColumn.new({values: t})} if options.fetch(:values)["marking_columns"]
      super
    end

  end
end
