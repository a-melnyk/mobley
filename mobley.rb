require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'data_mapper'
require 'securerandom'
require 'openssl'
require 'base64'

configure :development do
  set :database, "sqlite3://#{Dir.pwd}/db/development.db"
end

configure :production do
  set :database, "sqlite3://#{Dir.pwd}/db/production.db"
end

configure :test do
  set :database, 'sqlite3::memory:'
end

configure do
  set :alg, 'aes-256-cbc'
  set :key, 'l3:x\@#W@Z9;1.WDhcAU*yM--FcFBJX'

  DataMapper.setup(:default, settings.database)
  require_relative 'models/message'
end

def cipher
  OpenSSL::Cipher::Cipher.new(settings.alg)
end

get '/' do
  # "Hello world, it's #{Time.now} at the server!"
  erb :create_message
end

post '/' do
  return 400 if params[:visits_to_live].to_i > 0 && params[:hours_to_live].to_i > 0

  id = SecureRandom.hex(16)
  value = params[:message]
  iv = cipher.random_iv

  c = cipher.encrypt
  c.key = Digest::SHA256.digest(settings.key)
  c.iv = iv
  value = Base64.encode64(c.update(value.to_s) + c.final)

  visits_to_live = params[:visits_to_live].to_i > 0 ? params[:visits_to_live].to_i : -1
  hours_to_live = params[:hours_to_live].to_i > 0 ? params[:hours_to_live].to_i : -1
  frontend_password = params[:password] == 'true' ? true : false

  Message.create(
    id: id,
    body: value,
    iv: Base64.encode64(iv),
    visits_to_live: visits_to_live,
    hours_to_live: hours_to_live,
    frontend_password: frontend_password
  )
  @url = url("/message/#{id}")
  erb :save_message
end

get '/message/:id' do
  begin
    @message = Message.load_message(params[:id])
    @message.decrypt!(settings.alg, settings.key)
    erb :show_message
  rescue
    404
  end
end

error 404 do
  '<h1>No such message</h1>' if request.path.start_with? '/message/'
end

get '/wipe' do
  Message.auto_migrate!
end
