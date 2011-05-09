class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.string :title, :limit => 50, :default => ""
      t.text :review
      t.references :reviewable, :polymorphic => true
      t.references :user
      t.string :role, :default => "reviews"
      t.timestamps
    end

    add_index :comments, :reviewable_type
    add_index :comments, :reviewable_id
    add_index :comments, :user_id
  end

  def self.down
    drop_table :reviews
  end
end

