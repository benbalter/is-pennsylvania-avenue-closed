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

  def redis_url
    @redis_url ||= URI.parse(ENV["REDISTOGO_URL"] || "redis://127.0.0.1:16379")
  end

  def redis
    @redis ||= Redis.new(
      :host     => redis_url.host,
      :port     => redis_url.port,
      :password => redis_url.password
    )
  end

  def set(value)
    redis.set "closed", value
    redis.set "timestamp", Time.now.to_i
  end

  def closed?
    redis.get("closed") == "true"
  end

  def timestamp
    Time.at(redis.get("timestamp").to_i)
  end

  post "/update" do
    set !closed?
    redirect "/"
  end

  get "/" do
    halt erb :index, :locals => { :closed => closed?, :timestamp => time_ago_in_words(timestamp) }
  end

  get "/api" do
    jsonp({
      :closed => closed?,
      :as_of  => timestamp
    })
  end
end
