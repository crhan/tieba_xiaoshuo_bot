Sequel.migration do
  change do
    create_table(:feedbacks) do
      primary_key :id
      index:id
      foreign_key :reporter_id, :users, :on_delete => :set_null
      String :msg
      Time :created_at
      Time :updated_at
    end
  end
end
