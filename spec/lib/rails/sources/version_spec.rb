require "spec_helper"

RSpec.describe Rails::Sources::VERSION do
  it "is a string" do
    expect(Rails::Sources::VERSION).to be_kind_of(String)
  end
end
