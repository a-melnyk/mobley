# Structure of Message object
class Message
  include DataMapper::Resource

  property :id, String, key: true, unique_index: true
  property :body, Text, required: true
  property :created_at, DateTime
  property :iv, String
  property :visits_to_live, Integer
  property :hours_to_live, Integer
  property :frontend_password, Boolean, default: false
end

DataMapper.finalize
DataMapper.auto_upgrade!
