require "spec_helper"

describe "IsPennsylvaniaAvenueClosed" do

  include Rack::Test::Methods
  include IsPennsylvaniaAvenueClosed::Helpers
  extend  IsPennsylvaniaAvenueClosed::RedisHelper

  def app
    IsPennsylvaniaAvenueClosed.new
  end

  it "displays the status when closed" do
    redis.set "closed", true
    get "/"
    expect(last_response.body).to match(/\<h1>Yes\<\/h1>/i)
    expect(last_response.body).to_not match(/\<h1>No\<\/h1>/i)
  end

  it "displays the status when open" do
    redis.set "closed", false
    get "/"
    expect(last_response.body).to match(/\<h1>No\<\/h1>/i)
    expect(last_response.body).to_not match(/\<h1>Yes\<\/h1>/i)
  end

  it "returns the coffeescript" do
    get "/script.js"
    expect(last_response.status).to eql(200)
  end

  it "returns the API" do
    ts = Time.now.to_i
    redis.set "closed", true
    redis.set "timestamp", ts

    get "/api"
    data = JSON.parse(last_response.body)
    expect(data["closed"]).to eql(true)
    expect(data["timestamp"]).to eql(Time.at(ts).to_s)
  end

  it "updates the status from closed to open" do
    stub = stub_request(:post, "https://api.twitter.com/1.1/statuses/update.json").
         with(:body => {"status"=>"A user is reporting Pennsylvania Avenue is OPEN"}).
         to_return(:status => 200, :body => "", :headers => {})

    redis.set "closed", true
    post "/update"

    expect(stub).to have_been_requested
    expect(redis.get("closed")).to eql("false")

    follow_redirect!

    expect(last_response.body).to match(/\<h1>No\<\/h1>/i)
    expect(last_response.body).to_not match(/\<h1>Yes\<\/h1>/i)
  end

  it "updates the status from open to closed" do
    stub = stub_request(:post, "https://api.twitter.com/1.1/statuses/update.json").
         with(:body => {"status"=>"A user is reporting Pennsylvania Avenue is CLOSED"}).
         to_return(:status => 200, :body => "", :headers => {})

    redis.set "closed", false
    post "/update"

    expect(stub).to have_been_requested
    expect(redis.get("closed")).to eql("true")

    follow_redirect!

    expect(last_response.body).to match(/\<h1>Yes\<\/h1>/i)
    expect(last_response.body).to_not match(/\<h1>No\<\/h1>/i)
  end


end