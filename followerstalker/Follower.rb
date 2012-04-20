#
#  Follower.rb
#  followerstalker
#
#  Created by Kevin Sheffield on 4/18/12.
#  Copyright 2012 None. All rights reserved.
#

class Follower
    attr_accessor :id, :handle, :twitter_id
    
    def self.load_followers_for_run(run_id)
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        followers = Array.new
        puts "loading followers"
        db.execute( "SELECT * from follower where run_id = ?", run_id ) do |row|
            temp_follower = Follower.new
            temp_follower.id = row["id"]
            temp_follower.twitter_id = row["twitter_id"]
            temp_follower.handle = row["handle"]
            followers << temp_follower
        end
        puts "done loading followers"
        db.close
        return followers
    end

    def self.load_removed_followers_for_run(run_id)
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        removed_followers = Array.new
        puts "loading removed followers"
        db.execute( "SELECT * from followerdelta where run_id = ? and is_new = 0", run_id ) do |row|
            temp_removed_follower = Follower.new
            temp_removed_follower.id = row["id"]
            temp_removed_follower.twitter_id = row["twitter_id"]
            temp_removed_follower.handle = row["handle"]
            new_followers << temp_removed_follower
        end
        puts "done loading removed followers"
        db.close
        return removed_followers
    end

    def self.load_new_followers_for_run(run_id)
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        new_followers = Array.new
        puts "loading new followers"
        db.execute( "SELECT * from followerdelta where run_id = ? and is_new = 1", run_id ) do |row|
            temp_new_follower = Follower.new
            temp_new_follower.id = row["id"]
            temp_new_follower.twitter_id = row["twitter_id"]
            temp_new_follower.handle = row["handle"]
            new_followers << temp_new_follower
        end
        puts "done loading new followers"
        db.close
        return new_followers
    end
end

