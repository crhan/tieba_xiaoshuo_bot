# coding: utf-8
module TiebaXiaoshuoBot
  class Error < Model::Base
    plugin :validation_helpers
    plugin :schema

    # primary_key :id
    # index :id
    # String :class
    # String :msg
    # Time :created_at
    # Time :updated_at

  end
  Error.set_dataset DB[:errors].order(:id)
end
