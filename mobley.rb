require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'data_mapper'
require 'securerandom'

configure :development do
  set :database, "sqlite3://#{Dir.pwd}/db/development.db"
end

configure :production do
  set :database, 'postgres://pbczldlagazwow:YgrSwGbgURfYU8IHqjkhhrUsob@ec2-54-75-230-128.eu-west-1.compute.amazonaws.com/dc2hhm3s4vn2uv'
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

get '/' do
  erb :create_message
end

post '/' do
  return 400 if params[:visits_to_live].to_i > 0 && params[:hours_to_live].to_i > 0

  id = SecureRandom.hex(16)
  message = Message.new(
    id: id,
    raw_message: params[:message],
    visits_to_live: params[:visits_to_live].to_i > 0 ? params[:visits_to_live].to_i : -1,
    hours_to_live: params[:hours_to_live].to_i > 0 ? params[:hours_to_live].to_i : -1,
    frontend_password: params[:password] == 'true' ? true : false
  )
  message.encrypt!(settings.alg, settings.key)
  message.save
  @url = url "/message/#{id}"
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

error 400 do
  @url = url '/'
  erb :err400
end

error 404 do
  '<h1>No such message</h1>' if request.path.start_with? '/message/'
end

get '/wipe_sdf908734534eriu3y45jhk345g' do
  Message.auto_migrate!
end
