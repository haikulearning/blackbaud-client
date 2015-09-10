module Blackbaud
  class AttendanceCode < BlackbaudObject
    attr_accessor(:ea7_attendance_code_id, :allow_daily_entry, :code_type, :code_type_desc, :description, :short_description)
  end
end