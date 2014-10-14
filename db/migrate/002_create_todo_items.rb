Sequel.migration do
  change do
    create_table :todo_items do
      primary_key :id
      foreign_key :account_id, :accounts
      String :content
      String :data_row
      String :data_col
      String :data_sizex
      String :data_sizey
      Timestamp :created_at
      Timestamp :updated_at
    end
  end
end
