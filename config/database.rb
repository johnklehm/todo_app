database_url = ENV["DATABASE_URL"]
if database_url.empty?
	throw "Environment variable DATABASE_URL was empty."
end

Sequel::Model.plugin(:schema, :json_serializer)
Sequel::Model.raise_on_save_failure = false # Do not throw exceptions on failure
Sequel::Model.db = case Padrino.env
  when :development then Sequel.connect(database_url, :loggers => [logger])
  when :production  then Sequel.connect(database_url, :loggers => [logger])
  when :test        then Sequel.connect(database_url, :loggers => [logger])
end
