# coding: utf-8
module TiebaXiaoshuoBot
  class Error < Sequel::Model
    plugin :validation_helpers
    plugin :schema

    unless table_exists?
      set_schema do
        primary_key :id
        index :id
        String :class
        String :msg
        Time :created_at
      end
      create_table
    end

    def before_save
      self.created_at ||= Time.now
      super
    end
  end
end
