Sequel.migration do
  change do
    alter_table(:feedbacks) do
      add_column :checked, FalseClass, :default => false
    end
  end
end
