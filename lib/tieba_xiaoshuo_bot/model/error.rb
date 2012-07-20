# coding: utf-8
module TiebaXiaoshuoBot
  class Error < Sequel::Model
    plugin :validation_helpers
    plugin :schema
    include BaseModel

    # primary_key :id
    # index :id
    # String :class
    # String :msg
    # String :backtrace
    # Time :created_at
    # Time :updated_at

  end
  Error.set_dataset DB[:errors].order(:id)
end
