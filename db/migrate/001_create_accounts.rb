Sequel.migration do
  change do
    create_table :accounts do
      primary_key :id
      String :name
      String :surname
      String :email
      String :crypted_password
      String :role
    end
  end
end
