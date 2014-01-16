module Blackbaud
  class Person < BlackbaudObject
    attr_accessor(:ea7_record_id, :name_for_display, :type, :birth_date, :first_name, :import_id, :last_name, :record_type, :title, :suffix, :middle_name, :user_defined_id, :nickname)

    def initialize(values, type_id)

      values["type"] = type_id

      if values["bio"]
        values["bio"].each {|k, v| values[k] = v}
        values.delete("bio")
      end

      values["birth_date"] = format_date(values["birth_date"]) if values["birth_date"]

      values.each do |k,v|
        send("#{k}=".intern, v)
      end
    end

  end
end