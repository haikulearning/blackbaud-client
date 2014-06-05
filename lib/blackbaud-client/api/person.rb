module Blackbaud
  class Person < BlackbaudObject
    attr_accessor(:ea7_record_id, :name_for_display, :type, :birth_date, :first_name, :import_id, :last_name, :record_type, :title, :suffix, :middle_name, :user_defined_id, :nickname, :contacts, :relations)

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
      end

      if values["relations"]
        values["relations"].map! {|r| Blackbaud::Relation.new(r)}
      end

      values["birth_date"] = format_date(values["birth_date"]) if values["birth_date"]

      values.each do |k,v|
        send("#{k}=".intern, v)
      end
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