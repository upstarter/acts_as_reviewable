# ActsAsReviewable

Reviews for any AR model with multi-dimensional ratings, review commentary, and info-graphics.

## ActsAsReviewable -   concept version.

_Rails: Make an ActiveRecord resource ratable/reviewable  (rating + comment) across multiple dimensions with infographics._

## Why another rating/review-plugin?

Existing plugins rate on one dimension and provide basic analytics and no charting.

* Don't do assumptions that your rater/reviewer model is *User*. Relying on polymorphic assocation completely, so your reviewer can be...*anymodel*.
* Make any model act as a Review model.
* Don't make assumptions about what rating scale you wanna have, how the rating scale should be divided, or average rating rounding precision. The 1-5 scale is 80% of the cases, but there's no real reason or overhead to support any scale. To sum it up: Scale can consist negative and/or positive range or explicit integer/float values...and you won't even notice the difference on the outside. See the examples! =)
* Possible to submit additional custom attributes while rating, such as *title* and *body* to make up a "review" instead of just a "rating". Feel free.
* Finders implemented using scopes, i.e.. less code smell.
* Information graphics provided as an optional extension to the plugin.
* Transparently supports column-caching expensive calculations for the reviewable model. Will simply be turned on if these fields exists - otherwise fallback with an optimized DB hit instead.

## Installation

*Gem:*

<pre>gem install acts_as_reviewable</pre>

for rails 3, in your Gemfile:

<pre>gem 'acts_as_reviewable'</pre>

# Usage

## 1. Generate migration:

<pre>$ rails generate acts_as_reviewable_migration</pre>

Generates *db/migrations/{timestamp}_acts_as_reviewable_migration* with:

<pre>
class ActsAsReviewableMigration < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.references  :reviewable,    :polymorphic => true

      t.references  :reviewer,      :polymorphic => true

      t.float       :rating
      t.text        :comment

      #
      # Custom fields go here...
      #
      # t.string      :title
      # t.string      :intention
      # ...
      #

      t.timestamps
    end

    add_index :reviews, :reviewer_id
    add_index :reviews, :reviewer_type
    add_index :reviews, [:reviewer_id, :reviewer_type]
    add_index :reviews, [:reviewable_id, :reviewable_type]
  end

  def self.down
    drop_table :reviews
  end
end
</pre>

## 2. Make your model reviewable:

<pre>
class Post < ActiveRecord::Base
  acts_as_reviewable :scale => 0..5
end
</pre>

or, with explicit reviewer (or reviewers):

<pre>
class Book < ActiveRecord::Base
  # Setup associations for the reviewer class(es) automatically, and specify an explicit scale instead.
  acts_as_reviewable :by => [:users, :authers], :scale => 0..5
end
</pre>

## 3. ...and here we go:

Examples:

<pre>
Review.destroy_all # just in case...
@post = Post.first
@user = User.first

@post.review!(:by => @user, :rating => 2)  # new reviewer (type: object) => create
@post.review!(:by => @user, :rating => 5)  # same reviewer (type: object) => update

@post.total_reviews   # => 1
@post.average_rating  # => 5.0

@post.total_reviews   # => 2
@post.average_rating  # => 3.5

@post.review!(:by => @user, :rating => nil, :body => "Lorem ipsum...")  # same reviewer (type: IP) => update

@post.total_reviews   # => 2
@post.average_rating  # => 2.0, i.e. don't count nil (a.k.a. "no opinion")

@post.unreview!(:by => @user)  # delete existing review (type: User) => destroy

@post.total_reviews   # => 1
@post.average_rating  # => 2.0

@post.reviews       # => reviews on @post
@post.reviewers     # => reviewers that reviewed @post
@user.reviews       # => reviews by @user
@user.reviewables   # => reviewable objects that got reviewed by @user

# TODO: A few more samples...

# etc...
</pre>

# Mixin Arguments

The *acts_as_reviewable* mixin takes some hash arguments for customization:

*Basic*

* *:by* - the reviewer model(s), e.g. User, Account, etc. (accepts either symbol or class, i.e. *User* <=> *:user* <=> *:users*, or an array of such if there are more than one reviewer model). The reviewer model will be setup for you. Note: Polymorhic, so it accepts any model. Default: *nil*.
* *:scale* / *:range* / *:values* - range, or array, of valid rating values. Default: *1..5*. Note: Negative values are allowed too, and a range of values are not required, i.e. [-1, 1] is valid as well as [1,3,5]. =)

*Advanced*

* *:total_precision* - maximum number of digits for the average rating value. Default: *1*.
* *:step* - useful if you want to specify a custom step for each scale value within a range of values. Default: *1* for range of fixnum, auto-detected based on first value in range of float.
* *:steps* - similar to *:step* (they relate to each other), but instead of specifying a step you can specify how many steps you want. Default: auto-detected based on custom or default value *:step*.

# Aliases

To make the usage of IsReviewable a bit more generic (similar to other plugins you may use), there are two useful aliases for this purpose:

* *Review#owner*    <=>   *Review#reviewer*
* *Review#object*   <=>   *Review#reviewable*

Example:

<pre>
@post.reviews.first.owner == post.reviews.first.reviewer      # => true
@post.reviews.first.object == post.reviews.first.reviewable   # => true
</pre>

# Finders (Named Scopes)

ActsAsReviewable has plenty of useful finders implemented using scopes. Here they are:

## *Review*

*Order:*

* *in_order* - most recent reviews last (order by creation date).
* *most_recent* - most recent reviews first (opposite of *in_order* above).
* *lowest_rating* - reviews with lowest ratings first.
* *highest_rating* - reviews with highest ratings first.

*Filter:*

* *limit(<number_of_items>)* - maximum *<number_of_items>* reviews.
* *since(<created_at_datetime>)* - reviews created since *<created_at_datetime>*.
* *recent(<datetime_or_size>)* - if DateTime: reviews created since *<datetime_or_size>*, else if Fixnum: pick last *<datetime_or_size>* number of reviews.
* *between_dates(<from_date>, to_date)* - reviews created between two datetimes.
* *with_rating(<rating_value_or_range>)* - reviews with(in) rating value (or range) *<rating_value_or_range>*.
* *with_a_rating* - reviews with a rating value, i.e. not nil.
* *without_a_rating* - opposite of *with_a_rating* (above).
* *with_a_body* - reviews with a body/comment, i.e. not nil/blank.
* *without_a_body* - opposite of *with_a_body* (above).
* *complete* - reviews with both rating and comments, i.e. "full reviews" where.
* *of_reviewable_type(<reviewable_type>)* - reviews of *<reviewable_type>* type of reviewable models.
* *by_reviewer_type(<reviewer_type>)* - reviews of *<reviewer_type>* type of reviewer models.
* *on(<reviewable_object>)* - reviews on the reviewable object *<reviewable_object>* .
* *by(<reviewer_object>)* - reviews by the *<reviewer_object>* type of reviewer models.

## *Reviewable*

_TODO: Documentation on named scopes for Reviewable._

## *Reviewer*

_TODO: Documentation on named scopes for Reviewer._

## Examples using finders:

<pre>
@user = User.first
@post = Post.first

@post.reviews.recent(10)          # => [10 most recent reviews]
@post.reviews.recent(1.week.ago)  # => [reviews created since 1 week ago]

@post.reviews.with_rating(3.5..4.0)     # => [all reviews on @post with rating between 3.5 and 4.0]

@post.reviews.by_reviewer_type(:user)   # => [all reviews on @post by User-objects]
# ...or:
@post.reviews.by_reviewer_type(:users)  # => [all reviews on @post by User-objects]
# ...or:
@post.reviews.by_reviewer_type(User)    # => [all reviews on @post by User-objects]

@user.reviews.on(@post)  # => [all reviews by @user on @post]
@post.reviews.by(@user)  # => [all reviews by @user on @post] (equivalent with above)

Review.on(@post)  # => [all reviews on @user] <=> @post.reviews
Review.by(@user)  # => [all reviews by @user] <=> @user.reviews

</pre>

# Additional Methods

*Note:* See documentation (RDoc).

# Caching

If the visitable class table - in the sample above *Post* - contains a columns *cached_total_reviews* and *cached_average_rating*, then a cached value will be maintained within it for the number of reviews and the average rating the object have got.

Additional caching fields (to a reviewable model table):

<pre>
class AddActsAsReviewableToPostsMigration < ActiveRecord::Migration
  def self.up
    # Enable acts_as_reviewable-caching.
    add_column :posts, :cached_total_reviews, :integer
    add_column :posts, :cached_average_rating, :integer
  end

  def self.down
    remove_column :posts, :cached_total_reviews
    remove_column :posts, :cached_average_rating
  end
end
</pre>

# Example

## Controller

Depending on your implementation: You might - or might not - need a Controller, but for most cases where you only want to allow rating of something, a controller most probably is overkill. In the case of a review, this is how one cold look like (in this example, I'm using the excellent the "InheritedResources":http://github.com/josevalim/inherited_resources):

Example: *app/controllers/reviews_controller.rb*:

<pre>
class ReviewsController < InheritedResources::Base

  actions :create, :update, :destroy
  respond_to :js
  layout false

end
</pre>

..or in the more basic rating case - *app/controllers/posts_controller.rb*:

<pre>
class PostsController < InheritedResources::Base

  actions :all
  respond_to :html, :js
  layout false if request.format == :js

  def rate
    begin
      @post.review! :by => current_user, params.slice(:rating, :body)
    rescue
      flash[:error] = 'Not able to rate for some reason.'
    end
    respond_to do |format|
      format.html { redirect_to @post }
      format.js   # app/views/posts/rate.js.rjs
    end
  end

end
</pre>

## Routes

*config/routes.rb*

<pre>
resources :posts, :member => {:rate => :put}
</pre>

## Views

ActsAsReviewable comes with no view templates (etc.) because of already stated reasons, but basic rating mechanism is trivial to implement (in this example, I'm using HAML because I despise ERB):

Example: *app/views/posts/show.html.haml*

<pre>
%h1
  = @post.title
%p
  = @post.body
%p
  = "Your rating:"
  #rating_wrapper= render '/reviews/rating', :resource => @post
</pre>

Example: *app/views/reviews/_rating.html.haml*

<pre>
.rating
  - if resource.present? && resource.reviewable?
    - if reviewer.present?
      - current_rating = resource.review_by(reviewer).try(:rating)
      - resource.reviewable_scale.each do |rating|
        = link_to_remote "#{rating.to_i}", :url => rate_post_path(resource, :rating => rating.to_i), :method => :put, :html => {:class => "rate rated_#{rating.to_i}#{' current' if current_rating == rating}"}
      = link_to_remote "no opinion", :url => rate_post_path(resource, :rating => nil), :method => :put, :html => {:class => "rate rated_none#{' current' unless current_rating}"}
    - else # static rating
      - current_rating = resource.average_rating.round
      - resource.reviewable_scale.each do |rating|
        {:class => "rate rated_#{rating}#{' current' if current_rating == rating}"}
</pre>

## JavaScript/AJAX

<pre>
...
</pre>

Done! =)

# Additional Use Cases

## Like/Dislike

ActsAsReviewable is designed in such way that you as a developer are not locked to how traditional rating works. As an example, this is how you could implement like/dislike (like VoteFu) pattern using ActsAsReviewable:

Example:

<pre>
class Post < ActiveRecord::Base
  acts_as_reviewable :by => :users, :values => [0, 1]
end
</pre>

*Note:* *:values* is an alias for *:scale* for semantical reasons in cases like these.

# Dependencies

For testing: "rspec" and "sqlite3-ruby":http://gemcutter.org/gems/sqlite3-ruby.

# Notes

* Tested with Ruby 1.9.2 and Rails 3.0.5.
* Let me know if you find any bugs; not used in production yet so consider this a concept version.

# TODO

## Priority:

* bug: Accept , etc..
* documentation: A few more README-examples.
* feature: Useful finders for *Reviewable*.
* feature: Useful finders for *Reviewer*.
* testing: More thorough tests, especially for named scopes which is a bit tricky.

## Maybe:

# Related Links

...that might be of interest.

* "jQuery Star Rating":http://github.com/rathgar/jquery-star-rating/ - javascript star rating plugin for Rails on jQuery, if you don't want to do the rating widget on your own. It should be quite straightforward to customize the appearance of it for your needs too.

# License

Released under the MIT license.
Copyright (c) "Eric Steen":http://github.com/rubycoder1

This project rocks and uses MIT-LICENSE.