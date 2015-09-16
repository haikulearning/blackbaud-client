module Blackbaud
  class Person < BlackbaudObject
    attr_accessor(:ea7_record_id, :name_for_display, :type, :birth_date, :first_name, :import_id, :last_name, :record_type, :title, :suffix, :middle_name, :user_defined_id, :nickname, :contacts, :relations, :online_user_id, :deceased)

    USER_TYPE = {
     :faculty => 1,
     :student => 2,
     :undefined => nil,
    }

    def initialize(options)
      if options.fetch(:values)["bio"]
        options.fetch(:values)["bio"].each {|k, v| options.fetch(:values)[k] = v}
        options.fetch(:values).delete("bio")
      end

      if options.fetch(:values)["contact_info"]
        options.fetch(:values)["contacts"] = values["contact_info"].map {|c| Blackbaud::Contact.new({values: c})}
        options.fetch(:values).delete("contact_info")
      else
        options.fetch(:values)["contacts"] = []
      end

      if options.fetch(:values)["relations"]
        options.fetch(:values)["relations"].map! {|r| Blackbaud::Relation.new({values: r})}
      else
        options.fetch(:values)["relations"] = []
      end

      options.fetch(:values)["birth_date"] = format_date(options.fetch(:values)["birth_date"]) if options.fetch(:values)["birth_date"]

      super
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