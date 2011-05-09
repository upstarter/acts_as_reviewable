  # in spec/generators/custom_model_spec.rb
  require 'spec_helper'

  describe :acts_as_reviewable do
    context "with no arguments or options" do
      it "should generate a help message" do
        subject.should output("A Help Message")
      end
      it "should generate a review model file" do
        subject.should generate("app/models/review.rb")
      end
    end

    context "with dimension arguments" do
      with_args :dim1, :dim2, :dim3

      it "should generate a model with the appropriate dimensions" do
        subject.should generate("app/models/review.rb") { |content|
      content.should =~ /class Review < ActiveRecord\:\:Base/
    }
      end
    end
  end