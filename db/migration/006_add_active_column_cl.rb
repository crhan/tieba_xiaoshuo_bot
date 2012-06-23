Sequel.migration do
  change do
    alter_table(:check_lists) do
      add_column :active, TrueClass, :default => true
    end
  end
end
