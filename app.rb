require 'rubygems'
require 'sinatra'
require "sinatra/reloader"
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/my.db")

APP_VERSION = '0.0.1'

class Quote
  include DataMapper::Resource
  property :id , Serial
  property :quote, String
  property :created_at, DateTime
end

DataMapper.finalize

Quote.auto_upgrade!

get '/' do
  # get the latest 20 posts
  @quotes = Quote.all(:order => [ :id.desc ], :limit => 20)
  erb :index
end

post '/search' do
  @quotes = Quote.all(:quote.like => "%#{params[:query]}%")
  erb :index
end

post '/new' do
  q = Quote.create(:quote => "#{params[:new]}", :created_at => Time.now)
  @quotes = Quote.all(:order => [ :id.desc ], :limit => 20)
  erb :index
end

get '/:id' do
  q = Quote.get(params[:id])
  if q.nil? then
    "Quote not found"
  else
    "Quote #{params[:id]}<br>#{q.quote}"
  end
end

get '/delete/:id' do
  q = Quote.get(params[:id])
  if q.nil? then
    "Quote not found"
  else
    q.destroy
    @quotes = Quote.all(:order => [ :id.desc ], :limit => 20)
    erb :index
  end
end

