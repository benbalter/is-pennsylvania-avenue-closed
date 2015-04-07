require 'sinatra/base'
require 'redis'
require 'date'
require 'action_view'
require 'json'
require "sinatra/jsonp"
require 'coffee-script'
require 'twitter'
require 'dotenv'
require 'rack-google-analytics'
require_relative "helpers"
require_relative "redis_helper"

Dotenv.load

class IsPennsylvaniaAvenueClosed < Sinatra::Base

  include ActionView::Helpers::DateHelper
  include IsPennsylvaniaAvenueClosed::Helpers
  extend  IsPennsylvaniaAvenueClosed::RedisHelper

  helpers Sinatra::Jsonp
  enable :json_pretty

  set :protection, :except => :frame_options
  use Rack::GoogleAnalytics, :tracker => ENV["GA_TRACKER"]

  configure do
    init_redis!
  end

  post "/update" do
    toggle!
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
