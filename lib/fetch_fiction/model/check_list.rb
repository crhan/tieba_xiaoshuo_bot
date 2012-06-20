class CheckList < Sequel::Model
  plugin :validation_helpers
  plugin :schema
  many_to_one :fiction

  unless table_exists?
    set_schema do
      primary_key :id
      foreign_key :fiction_id, :fictions
      String :thread_id
      String :thread_name
      Time :created_at
    end
    create_table
  end

  def validate
    validates_presence [:thread_id, :thread_name, :fiction_id]
  end

  def before_save
    self.created_at ||= Time.now
    super
  end
end
