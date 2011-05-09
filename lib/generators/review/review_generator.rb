require 'rails/generators/migration'

class ActsAsReviewableMigrationGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  desc "run this generator to create reviews"

  def self.source_root
    @_acts_as_reviewable_source_root ||= File.expand_path("../templates", __FILE__)
  end

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def create_model_file
    template "review.rb", "app/models/review.rb"
    migration_template "create_reviews.rb", "db/migrate/create_reviews.rb"
  end
end