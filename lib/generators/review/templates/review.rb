class Review < ActiveRecord::Base

  include ActsAsReviewable::Review

  belongs_to :reviewable, :polymorphic => true
  belongs_to :reviewer, :polymorphic => true

  default_scope :order => 'created_at ASC'

  # NOTE: install the acts_as_votable plugin if you
  # want votes on reviews.
  #acts_as_voteable

end

