module Blackbaud
  class AttendanceRecord < BlackbaudObject
    attr_accessor(:ea7_record_id, :code, :date, :name_for_display, :ea7_attendance_code_id)

    def initialize(options)
      options.fetch(:values)
      self.date = format_date(options.fetch(:values)["date"])
      options.fetch(:values).delete(:date)
      super
    end

  end
end