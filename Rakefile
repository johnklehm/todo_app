require 'bundler/setup'
require 'padrino-core/cli/rake'

PadrinoTasks.use(:database)
PadrinoTasks.use(:sequel)
PadrinoTasks.init


namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    require "sequel"
    Sequel.extension :migration
    db = Sequel.connect(ENV.fetch("DATABASE_URL"))
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, "db/migrate", target: args[:version].to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(db, "db/migrate")
    end
  end
end

namespace :db do
  desc "Create table because migrator is effed?"
  task :todo do
    require "sequel"
    db = Sequel.connect(ENV.fetch("DATABASE_URL"))
    puts "Creating todo_items"
    db.drop_table? :todo_items
    db.create_table :todo_items do
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
