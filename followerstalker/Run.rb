#
#  Run.rb
#  followerstalker
#
#  Created by Kevin Sheffield on 4/19/12.
#  Copyright 2012 None. All rights reserved.
#


class Run
    attr_accessor :id, :followers, :date_run, :account_id
    
    def self.create_new(account_handle, follower_list)
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        
        account_id = 1
        db.execute( "SELECT * from account where handle = ?", account_handle ) do |row|
            account_id = row["id"] 
        end
        
        db.execute( "INSERT into run (runDate, accountid) values (?,?)", DateTime.now.to_s, account_id ) 
        
        run_id = db.last_insert_row_id
        
        follower_list.each do |follower|
            db.execute( "INSERT into follower (twitter_id, handle, run_id) values (?,?,?)", follower.id, follower.handle, run_id ) 
        end
        db.close
    end

    def self.load_by_account(account_handle)
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        runs = Array.new
        puts "loading runs"
        db.execute( "SELECT r.* from run r join account a on a.id = r.accountid where a.handle = ?", account_handle ) do |row|
            temp_run = Run.new
            temp_run.id = row["id"]
            temp_run.date_run = row["runDate"]
            temp_run.account_id = row["accountid"]
            runs << temp_run
        end
        puts "done loading runs"
        db.close
        return runs
    end

    def load_followers()
       followers = Follower.load_followers_for_run(self.id)
    end

    def compare_against_previous_run()
        previous_run = get_previous_run()
    end

    def get_previous_run()
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        previous_run = Run.new
        puts "loading previous run"
        db.execute( "SELECT * from run where id < ? and accountid = ? order by id desc limit 1", self.id, self.account_id ) do |row|
            previous_run.id = row["id"]
            previous_run.date_run = row["runDate"]
            previous_run.account_id = row["accountid"]
        end
        puts "done loading previous run"
        db.close
        return previous_run
    end
end