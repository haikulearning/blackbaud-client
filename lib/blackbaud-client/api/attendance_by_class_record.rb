module Blackbaud
  class AttendanceByClassRecord < AttendanceRecord
    attr_accessor(:ea7_attendance_by_class_id, :ea7_class_meeting_id)
  end
end