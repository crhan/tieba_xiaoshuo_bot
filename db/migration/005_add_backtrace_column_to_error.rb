Sequel.migration do
  change do
    alter_table(:errors) do
      add_column :backtrace, String
    end
  end
end
