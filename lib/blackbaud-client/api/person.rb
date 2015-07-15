module Blackbaud
  class Person < BlackbaudObject
    attr_accessor(:ea7_record_id, :name_for_display, :type, :birth_date, :first_name, :import_id, :last_name, :record_type, :title, :suffix, :middle_name, :user_defined_id, :nickname, :contacts, :relations, :online_user_id, :deceased)

    USER_TYPE = {
     :faculty => 1,
     :student => 2,
     :undefined => nil,
    }

    def initialize(values, type_id)
      values["type"] = type_id

      if values["bio"]
        values["bio"].each {|k, v| values[k] = v}
        values.delete("bio")
      end

      if values["contact_info"]
        values["contacts"] = values["contact_info"].map {|c| Blackbaud::Contact.new(c)}
        values.delete("contact_info")
      else
        values["contacts"] = []
      end

      if values["relations"]
        values["relations"].map! {|r| Blackbaud::Relation.new(r)}
      else
        values["relations"] = []
      end

      values["birth_date"] = format_date(values["birth_date"]) if values["birth_date"]

      super(values)
    end

    def faculty?
      type == USER_TYPE[:faculty]
    end

    def student?
      type == USER_TYPE[:student]
    end

    def undefined_type?
      type == USER_TYPE[:undefined]
    end

  end
end