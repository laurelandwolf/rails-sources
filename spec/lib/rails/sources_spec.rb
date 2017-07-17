require "spec_helper"

class ExampleSource < Rails::Sources
  private def connect
    {}
  end

  private def open?
    true
  end
end

RSpec.describe Rails::Sources do
  let(:source) { ExampleSource.establish }

  it "returns the connection value" do
    expect(source).to eq({})
  end
end
