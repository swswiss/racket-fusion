class AddLikesCountToTweets < ActiveRecord::Migration[6.1]
  def up
    add_column :tweets, :likes_count, :integer, null: false, default: 0

    Tweet.find_each do |tweet|
      tweet.update! likes_count: tweet.likes.size
    end
  end

  def down
    remove_column :tweets, :likes_count
  end
end
