require 'sinatra/base'
require 'redis'
require 'date'
require 'action_view'
require 'json'
require "sinatra/jsonp"

class IsPennsylvaniaAvenueOpen < Sinatra::Base

  include ActionView::Helpers::DateHelper
  helpers Sinatra::Jsonp
  enable :json_pretty

  configure do
    uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://127.0.0.1:16379")
    @@redis = Redis.new(:host => uri.host, :port => uri.port,:password => uri.password)
  end

  def redis
    @@redis
  end

  def closed?
    @closed ||= redis.get("closed") == "true"
  end

  def timestamp
    @timestamp ||= Time.at(redis.get("timestamp").to_i)
  end

  post "/update" do
    redis.set "closed", !closed?
    redis.set "timestamp", Time.now.to_i
    redirect "/"
  end

  get "/" do
    halt erb :index, :locals => { :closed => closed?, :timestamp => time_ago_in_words(timestamp) }
  end

  get "/api" do
    jsonp({:closed => closed?, :timestamp => timestamp})
  end
end
