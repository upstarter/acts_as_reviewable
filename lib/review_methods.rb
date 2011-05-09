module ActsAsReviewable
  # including this module into your Review model will give you finders and named scopes
  # useful for working with Reviews.
  # The named scopes are:
  # in_order: Returns reviews in the order they were created (created_at ASC).
  # recent: Returns reviews by how recently they were created (created_at DESC).
  # limit(N): Return no more than N reviews.
  module Review

    def self.included(review_model)
      review_model.extend Finders
      review_model.scope :in_order, review_model.order('created_at ASC')
      review_model.scope :recent, review_model.order('created_at DESC')

    end

    def is_review_type?(type)
      type.to_s == role.singularize.to_s
    end

    module Finders
      # Helper class method to lookup all reviews assigned
      # to all reviewable types for a given user.
      def find_reviews_by_user(user, role = "reviews")
        where(["user_id = ? and role = ?", user.id, role]).order("created_at DESC")
      end

      # Helper class method to look up all reviews for
      # reviewable class name and reviewable id.
      def find_reviews_for_reviewable(reviewable_str, reviewable_id, role = "reviews")
        where(["reviewable_type = ? and reviewable_id = ? and role = ?", reviewable_str, reviewable_id, role]).order("created_at DESC")
      end

      # Helper class method to look up a reviewable object
      # given the reviewable class name and id
      def find_reviewable(reviewable_str, reviewable_id)
        model = reviewable_str.constantize
        model.respond_to?(:find_reviews_for) ? model.find(reviewable_id) : nil
      end
    end
  end
end