module Blackbaud
  class Grade < BlackbaudObject
    attr_accessor(:ea7_student_grade_id, :ea7_marking_column_id, :ea7_student_course_id, :ea7_translation_table_entry_id, :grade, :grade_type, :ea7_record_id, :name_for_display, :message)
  end
end