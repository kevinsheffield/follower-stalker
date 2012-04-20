#
#  Follower.rb
#  followerstalker
#
#  Created by Kevin Sheffield on 4/18/12.
#  Copyright 2012 None. All rights reserved.
#

class Follower
    attr_accessor :id, :handle, :twitter_id
    
    def self.create_new(run_id, twitter_id, handle)
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        
        db.execute( "INSERT into follower (twitter_id, handle, run_id) values (?,?,?)", twitter_id, handle, run_id ) 
        db.close
    end
    
    def self.create_new_delta_record(run_id, twitter_id, handle, is_new)
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true

        db.execute( "INSERT into followerdelta (twitter_id, handle, run_id, is_new) values (?,?,?,?)", twitter_id, handle, run_id, is_new ) 
        db.close    
    end
    
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

    def self.load_added_followers_for_run(run_id)
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

    def self.load_followers_in_run_a_not_run_b(a_run_id, b_run_id)
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        follower_delta = Array.new
        puts "loading follower delta between run " + a_run_id.to_s + " and run " + b_run_id.to_s
        db.execute( "SELECT * from follower where run_id = ? and twitter_id not in (select twitter_id from follower where run_id = ?)", a_run_id, b_run_id ) do |row|
            puts "finding some deltas!"
            temp_new_follower = Follower.new
            temp_new_follower.id = row["id"]
            temp_new_follower.twitter_id = row["twitter_id"]
            temp_new_follower.handle = row["handle"]
            follower_delta << temp_new_follower
        end
        puts "done loading follower delta between run " + a_run_id.to_s + " and run " + b_run_id.to_s
        db.close
        return follower_delta
    end
end

