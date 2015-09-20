require 'sinatra/base'
require 'redis'
require 'date'
require 'action_view'
require 'json'
require "sinatra/jsonp"
require 'coffee-script'
require 'tilt/erubis'
require 'tilt/coffee'
require 'twitter'
require 'dotenv'
require 'rack-google-analytics'
require 'addressable/uri'
require 'yaml'
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

  before do
    redirect url if settings.production? && request.host != config["domain"]
  end

  post "/update" do
    toggle!
    tweet!
    redirect "/"
  end

  get "/" do
    halt erb :index, :locals => {
      :closed      => closed?,
      :timestamp   => time_ago_in_words(timestamp),
      :title       => "#{config["title"]} #{closed? ? "Yes" : "No"}",
      :description => config["description"],
      :twitter     => config["twitter"],
      :url         => url,
      :repo        => config["repo"]
    }
  end

  get "/api" do
    jsonp({:closed => closed?, :timestamp => timestamp})
  end

  get "/script.js" do
    coffee :script
  end
end
