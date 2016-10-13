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

  attr_accessor :raw_message

  def check_hours_to_live
    if hours_to_live > 0
      expire_date = created_at + (hours_to_live / 24.0)
      if DateTime.now > expire_date
        destroy
        return false
      end
    end
    true
  end

  def check_visits_to_live
    if visits_to_live.zero?
      destroy
      return false
    elsif visits_to_live > 0
      update(visits_to_live: visits_to_live - 1)
    end
    true
  end

  def cipher(alg)
    OpenSSL::Cipher::Cipher.new(alg)
  end

  def decrypt!(alg, key)
    c = cipher(alg).decrypt
    c.key = Digest::SHA256.digest(key)
    c.iv = Base64.decode64(iv)
    self.raw_message = c.update(Base64.decode64(body.to_s)) + c.final
  end

  def self.load_message(id)
    message = Message.get(id)
    message if message.check_hours_to_live && message.check_visits_to_live
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
