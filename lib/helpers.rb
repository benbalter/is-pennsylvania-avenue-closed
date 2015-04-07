class IsPennsylvaniaAvenueClosed < Sinatra::Base
  module Helpers
    def redis
      IsPennsylvaniaAvenueClosed::RedisHelper.class_variable_get(:@@redis)
    end

    def toggle!
      redis.set "closed", !closed?
      redis.set "timestamp", Time.now.to_i
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
      return if Sinatra::Base.development?
      twitter.update "A user is reporting Pennsylvania Avenue is #{closed? ? "CLOSED" : "OPEN"} http://www.ispennsylvaniaavenueclosed.com"
    rescue
      nil
    end

    def closed?
      redis.get("closed") == "true"
    end

    def timestamp
      Time.at(redis.get("timestamp").to_i)
    end
  end
end
