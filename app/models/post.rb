class Post < ActiveRecord::Base
  attr_accessible :body, :title, :tags
  default_scope :order => 'created_at DESC'

  acts_as_taggable 
  #acts_as_taggable_on :location, :who

end
