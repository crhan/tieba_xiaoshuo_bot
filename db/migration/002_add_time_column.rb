Sequel.migration do
  change do
    alter_table(:users) do
      add_column :created_at, Time
      add_column :updated_at, Time
    end
    alter_table(:errors) do
      add_column :updated_at, Time
    end
    alter_table(:fictions) do
      add_column :created_at, Time
      add_column :updated_at, Time
    end
    alter_table(:subscriptions) do
      add_column :created_at, Time
      add_column :updated_at, Time
    end
    alter_table(:check_lists) do
      add_column :updated_at, Time
    end
  end
end
