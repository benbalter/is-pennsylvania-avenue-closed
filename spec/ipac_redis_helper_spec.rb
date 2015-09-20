require "spec_helper"

describe "IsPennsylvaniaAvenueClosed::RedisHelper" do

  class TestHelper
    extend  IsPennsylvaniaAvenueClosed::RedisHelper
  end

  it "init's redis" do
    expect(TestHelper.init_redis!.class).to eql(Redis)
  end
  
end
