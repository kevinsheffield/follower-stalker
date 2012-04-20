#
#  Account.rb
#  followerstalker
#
#  Created by Kevin Sheffield on 4/19/12.
#  Copyright 2012 None. All rights reserved.
#

class Account
    attr_accessor :id, :handle, :runs
    
    def self.load_all()
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        accounts = Array.new
        db.execute( "SELECT * from account" ) do |row|
    
            temp_account = Account.new
            temp_account.id = row["id"]
            temp_account.handle = row["handle"]
            accounts << temp_account
        end

        db.close
        return accounts
    end

    def self.create_new(handle)
        db = SQLite3::Database.new(NSBundle.mainBundle.pathForResource("followerstalker", ofType:"sqlite"))
        db.results_as_hash = true
        db.execute( "INSERT into account (handle) values (?)", handle ) 
        db.close

    end
end
