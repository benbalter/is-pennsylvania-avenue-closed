require 'sinatra/base'
require 'redis'
require 'date'
require 'action_view'
require 'json'
require "sinatra/jsonp"
require 'coffee-script'
require 'twitter'
require 'dotenv'

Dotenv.load

class IsPennsylvaniaAvenueClosed < Sinatra::Base

  include ActionView::Helpers::DateHelper
  helpers Sinatra::Jsonp
  enable :json_pretty
  set :protection, :except => :frame_options

  configure do
    uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://127.0.0.1:16379")
    @@redis = Redis.new(:host => uri.host, :port => uri.port,:password => uri.password)
  end

  def redis
    @@redis
  end

  def twitter
    @twitter ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end

  def tweet!
    return unless Sinatra::Base.production?
    twitter.update "A user is reporting Pennsylvania Avenue is #{closed? ? "CLOSED" : "OPEN"}"
  rescue
    nil
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
    tweet!
    redirect "/"
  end

  get "/" do
    halt erb :index, :locals => { :closed => closed?, :timestamp => time_ago_in_words(timestamp) }
  end

  get "/api" do
    jsonp({:closed => closed?, :timestamp => timestamp})
  end

  get "/script.js" do
    coffee :script
  end
end
