Sequel.migration do
  up do
    alter_table(:users) do
      add_unique_constraint :account
    end
  end

  down do
    alter_table(:users) do
      drop_constraint(:account, :type=>:unique)
    end
  end
end
