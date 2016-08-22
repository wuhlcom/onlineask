class CreateFollowRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :follow_relationships do |t|
        t.integer :user_id
        t.integer :follower_id
      t.timestamps
    end
  end
end
