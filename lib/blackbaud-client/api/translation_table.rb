module Blackbaud
  class TranslationTable < BlackbaudObject
    attr_accessor(:ea7_translation_table_id, :highest_numeric_grade_allowed, :lowest_numeric_grade_allowed, :name, :translation_table_entries)
    alias_method :entries, :translation_table_entries

    def initialize(options)
      options.fetch(:values)["translation_table_entries"].map! {|e| Blackbaud::TranslationTableEntry.new({values: e})} if options.fetch(:values)["translation_table_entries"]
      super
    end

  end
end