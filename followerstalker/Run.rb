#
#  Run.rb
#  followerstalker
#
#  Created by Kevin Sheffield on 4/19/12.
#  Copyright 2012 None. All rights reserved.
#


class Run
    attr_accessor :id, :followers, :date_run, :account_id, :followers_removed, :followers_added, :followers_added_count, :followers_removed_count
    
    def self.create_new(account_handle, follower_list)
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        
        account_id = 1
        db.execute( "SELECT * from account where handle = ?", account_handle ) do |row|
            account_id = row["id"] 
        end
        
        db.execute( "INSERT into run (run_date, account_id) values (?,?)", DateTime.now.to_s, account_id ) 
        
        run_id = db.last_insert_row_id
        
        follower_list.each do |follower|
            Follower.create_new(run_id, follower.twitter_id, follower.handle)
        end
        db.close
        return Run.load(run_id)
    end

    def self.load(run_id)
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        run = Run.new
        puts "loading run by id"
        db.execute( "SELECT * from run where id = ?", run_id ) do |row|
            run.id = row["id"]
            run.date_run = row["run_date"]
            run.account_id = row["account_id"]
            run.followers_added_count = row["followers_added_count"]
            run.followers_removed_count = row["followers_removed_count"]
        end
        puts "done loading run by id"
        db.close
        return run
    end

    def self.load_by_account(account_handle)
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        runs = Array.new
        puts "loading runs"
        db.execute( "SELECT r.* from run r join account a on a.id = r.account_id where a.handle = ?", account_handle ) do |row|
            temp_run = Run.new
            temp_run.id = row["id"]
            temp_run.date_run = row["run_date"]
            temp_run.account_id = row["account_id"]
            temp_run.followers_added_count = row["followers_added_count"]
            temp_run.followers_removed_count = row["followers_removed_count"]
            runs << temp_run
        end
        puts "done loading runs"
        db.close
        return runs
    end

    def load_followers()
       self.followers = Follower.load_followers_for_run(self.id)
    end

    def load_follower_deltas()
        self.followers_removed = Follower.load_removed_followers_for_run(self.id)
        self.followers_added = Follower.load_added_followers_for_run(self.id)
    end

    def get_previous_run()
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        previous_run = Run.new
        puts "loading previous run"
        db.execute( "SELECT * from run where id < ? and account_id = ? order by id desc limit 1", self.id, self.account_id ) do |row|
            previous_run.id = row["id"]
            previous_run.date_run = row["run_date"]
            previous_run.account_id = row["account_id"]
        end
        puts "done loading previous run"
        db.close
        return previous_run
    end

    def compare_against_previous_run()
        self.load_followers()
        
        self.followers.each do |selffollower|
                puts "i got a follower!"
        end
        
        previous_run = get_previous_run()
        if previous_run.id.nil?
            previous_run.id = 0
        end
        
        #followers added will exist in this run but not the previous run
        self.followers_added = Follower.load_followers_in_run_a_not_run_b(self.id, previous_run.id)
        #followers removed will exist in the previous run but not this run
        self.followers_removed = Follower.load_followers_in_run_a_not_run_b(previous_run.id, self.id)
        
        #write followers added to sqlite
        self.followers_added.each do |follower_added|
           Follower.create_new_delta_record(self.id, follower_added.twitter_id, follower_added.handle, 1) 
        end
        
        #write followers removed to sqlite
        self.followers_removed.each do |follower_removed|
            Follower.create_new_delta_record(self.id, follower_removed.twitter_id, follower_removed.handle, 0) 
        end
        
        #write counts to sqlite
        self.update_run_comparisons(self.id, self.followers_added.length, self.followers_removed.length)
    end

    def update_run_comparisons(run_id, followers_added_count, followers_removed_count)
        puts "updating run " + run_id.to_s + " to have new = " + followers_added_count.to_s + " and removed = " + followers_removed_count.to_s
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        db.execute( "UPDATE run set followers_added_count = ?, followers_removed_count = ?, delta_processed = ? where id = ?", followers_added_count, followers_removed_count, 1, run_id ) 
        db.close
    end
end