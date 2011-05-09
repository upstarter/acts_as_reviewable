require 'spec_helper'

describe ActsAsReviewable do
  it "should be valid" do
    ActsAsReviewable.should be_a(Module)
  end
end