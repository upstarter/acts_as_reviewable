require 'active_record'

# ActsAsReviewable
module RapidFire
  module Acts #:nodoc:
    module Reviewable #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_reviewable(*args)
          review_roles = args.to_a.flatten.compact.map(&:to_sym)
          write_inheritable_attribute(:review_types, (review_roles.blank? ? [:reviews] : review_roles))
          class_inheritable_reader(:review_types)

          options = ((args.blank? or args[0].blank?) ? {} : args[0])

          if !review_roles.blank?
            review_roles.each do |role|
              has_many "#{role.to_s}_reviews".to_sym,
                {:class_name => "Review",
                  :as => :reviewable,
                  :dependent => :destroy,
                  :conditions => ["role = ?", role.to_s],
                  :before_add => Proc.new { |x, c| c.role = role.to_s }}
            end
          else
            has_many :reviews, {:as => :reviewable, :dependent => :destroy}
          end

          review_types.each do |role|
            method_name = (role == :reviews ? "reviews" : "#{role.to_s}_reviews").to_s
            class_eval %{
              def self.find_#{method_name}_for(obj)
              reviewable = self.base_class.name
              review.find_reviews_for_reviewable(reviewable, obj.id, "#{role.to_s}")
              end

              def self.find_#{method_name}_by_user(user)
              reviewable = self.base_class.name
              review.where(["user_id = ? and reviewable_type = ? and role = ?", user.id, reviewable, "#{role.to_s}"]).order("created_at DESC")
              end

              def #{method_name}_ordered_by_submitted
              review.find_reviews_for_reviewable(self.class.name, id, "#{role.to_s}")
              end

              def add_#{method_name.singularize}(review)
              review.role = "#{role.to_s}"
              #{method_name} << review
              end
              }

            include RapidFire::Acts::Reviewable::InstanceMethods
          end
        end # def acts_as_reviewable
      end # module ClassMethods

      module InstanceMethods

        
      end # module InstanceMethods
      
    end # module Reviewable
  end
end

ActiveRecord::Base.class_eval { include RapidFire::Acts::Reviewable }

