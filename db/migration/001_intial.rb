Sequel.migration do
  transaction
  change do
    create_table? :users do
      primary_key :id
      index :id
      String :account
      Fixnum :total_count
    end

    create_table? :fictions do
      primary_key :id
      index :id
      String :name
      String :url
    end

    create_table? :check_lists do
      primary_key :id
      foreign_key :fiction_id, :fictions
      Time :created_at
    end

    create_table? :subscriptions do
      primary_key :id
      foreign_key :fiction_id, :fictions
      foreign_key :user_id, :users
      foreign_key :check_id, :check_lists
    end
  end
end
