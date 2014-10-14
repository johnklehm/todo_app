class TodoItem < Sequel::Model
  many_to_one :accounts

  plugin :validation_helpers
  plugin :json_serializer
  plugin :timestamps

  def validate
    validates_presence     :account_id
    validates_presence     :content
    validates_presence     :data_row
    validates_presence     :data_col
    validates_presence     :data_sizex
    validates_presence     :data_sizey
  end
end
