module Blackbaud
  class MarkingColumn < BlackbaudObject
    attr_accessor(:ea7_course_grading_info_grade_id, :description, :ea7_marking_column_id, :ea7_translation_table_id, :short_description, :values_allowed, :ea7_class_id)

    def grades
      @client.grades(self.ea7_class_id, self.ea7_marking_column_id)
    end

  end
end