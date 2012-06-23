Sequel.migration do

  change do
    create_table(:users) do
      primary_key :id
      index :id
      String :account
      Fixnum :total_count, :default => 0
      TrueClass :active, :default => true
    end
    create_table(:errors) do
      primary_key :id
      index :id
      String :class
      String :msg
      Time :created_at
    end
    create_table(:fictions) do
      primary_key :id
      index :id
      String :name
      String :encode_url
    end
    create_table(:check_lists) do
      Integer :thread_id, :primary_key => true
      foreign_key :fiction_id, :fictions, :on_delete => :set_null
      String :thread_name
      Time :created_at
    end
    create_table(:subscriptions) do
      primary_key :id
      foreign_key :fiction_id, :fictions, :on_delete => :set_null
      foreign_key :user_id, :users, :on_delete => :set_null
      foreign_key :check_id, :check_lists, :on_delete => :set_null
      TrueClass :active, :default => true
    end
  end
end
