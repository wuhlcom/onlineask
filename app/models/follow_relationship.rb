class FollowRelationship < ApplicationRecord
  belongs_to :user
  belongs_to :follow_relationship, class_name: "User", foreign_key: "follower_id"
end

# == Schema Information
#
# Table name: follow_relationships
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  follower_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
