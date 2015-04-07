require "spec_helper"

describe "IsPennsylvaniaAvenueClosed::Helpers" do

  class TestHelper
    include ActionView::Helpers::DateHelper
    include IsPennsylvaniaAvenueClosed::Helpers
    extend  IsPennsylvaniaAvenueClosed::RedisHelper
  end

  include Rack::Test::Methods

  before(:each) do
    @helper = TestHelper.new
    TestHelper.init_redis!
  end

  it "exposes the redis class variable" do
    expect(@helper.redis.class).to eql(Redis)
  end

  it "knows if Penn Ave is closed" do
    @helper.redis.set "closed", true
    expect(@helper.closed?).to eql(true)
  end

  it "knows if Penn Ave is closed" do
    @helper.redis.set "closed", false
    expect(@helper.closed?).to eql(false)
  end

  it "knows the timestamp" do
    ts = Time.now.to_i
    @helper.redis.set "timestamp", ts
    expect(@helper.timestamp.to_i).to eql(ts)
  end

  it "toggles from open to closed" do
    @helper.redis.set "closed", false
    ts = Time.now.to_i
    @helper.redis.set "timestamp", ts
    sleep 1
    @helper.toggle!
    expect(@helper.closed?).to eql(true)
    expect(@helper.timestamp.to_i).to_not eql(ts)
  end

  it "toggles from closed to open" do
    @helper.redis.set "closed", true
    ts = Time.now.to_i
    @helper.redis.set "timestamp", ts
    sleep 1
    @helper.toggle!
    expect(@helper.closed?).to eql(false)
    expect(@helper.timestamp.to_i).to_not eql(ts)
  end

  it "creates the twitter client" do
    expect(@helper.twitter.class).to eql(Twitter::REST::Client)
  end

  it "tweets when open" do
    @helper.redis.set "closed", false
    stub = stub_request(:post, "https://api.twitter.com/1.1/statuses/update.json").
         with(:body => {"status"=>"A user is reporting Pennsylvania Avenue is OPEN http://www.ispennsylvaniaavenueclosed.com"}).
         to_return(:status => 200, :body => "", :headers => {})
    @helper.tweet!
    expect(stub).to have_been_requested
  end

  it "tweets when closed" do
    @helper.redis.set "closed", true
    stub = stub_request(:post, "https://api.twitter.com/1.1/statuses/update.json").
         with(:body => {"status"=>"A user is reporting Pennsylvania Avenue is CLOSED http://www.ispennsylvaniaavenueclosed.com"}).
         to_return(:status => 200, :body => "", :headers => {})
    @helper.tweet!
    expect(stub).to have_been_requested
  end
end
