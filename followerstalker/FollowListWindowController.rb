#
#  FollowListWindowController.rb
#  followerstalker
#
#  Created by Kevin Sheffield on 4/17/12.
#  Copyright 2012 None. All rights reserved.
#
require 'json'

require 'rubygems'
require 'sqlite3'

class FollowListWindowController < NSWindowController
    attr_accessor :titleLabel, :addAccountButton, :addAccountTextBox, :accountSelector, :addRunButton
    attr_writer :followerTableView
    
    def windowDidLoad
        super
        
        @followers = []
        @runs = []
        @followerTableView.dataSource = self
        @followerTableView.delegate = self
        
        loadAccountSelector()
        
    end
    
    def loadAccountSelector()
        accounts = Account.load_all()
        
        accountSelector.removeAllItems
        accountSelector.addItemsWithTitles(accounts.collect {|x| x.handle })
        
        if accounts.length > 0 
            loadRuns()
        end
    end
    
    def addAccountButton_Click(sender)
        puts "pushed it"
        Account.create_new(addAccountTextBox.stringValue)
        loadAccountSelector()
        loadRuns()
    end
    
    def accountSelectorPicked(sender)
        puts "account selected"
        loadRuns()
    end
    
    def loadRuns()
        puts accountSelector.selectedItem.title
        @runs = Array.new
        @runs = Run.load_by_account(accountSelector.selectedItem.title)
        @followerTableView.reloadData
    end
    
    def addRunButton_click(sender)
        puts "lets add a run!"
        twitterWrapper = TwitterWrapper.new
        puts "in the rabbit hole"
        followersReturn = twitterWrapper.getFollowersByUser(accountSelector.selectedItem.title)
        #followersReturn = Array.new
        #follower_test = Follower.new
        #follower_test.twitter_id = 1
        #follower_test.handle = 'bob'
        #followersReturn << follower_test
        #follower_test = Follower.new
        #follower_test.twitter_id = 4
        #follower_test.handle = 'shannon'
        #followersReturn << follower_test
        puts "out of the rabbit hole"
        
        run = Run.create_new(accountSelector.selectedItem.title, followersReturn)
        
        puts "way past"
        
        run.compare_against_previous_run()
        
        
        loadRuns()
    end
    
    def windowWillClose(sender)
        NSApp.stopModal
    end
    
    
    #table view stuff
    
    def numberOfRowsInTableView(view)
        @runs.size
    end
    
    def size()
        @runs.size
    end
    
    def tableView(view, objectValueForTableColumn:column, row:index)
        run = @runs[index]
        case column.identifier
            when 'run_id'
                run.id.to_s + ':' + run.date_run.to_s
            when 'run_info'
                run.followers_added_count.to_s + ' followers added; ' + run.followers_removed_count.to_s + ' followers removed'
        end
    end
    
    def tableViewSelectionDidChange(notification)
        runDetailWindow = RunDetailWindowController.alloc.initWithWindowNibName("RunDetailWindow")
        runDetailWindow.run = @runs[@followerTableView.selectedRow]
        window = runDetailWindow.window
    end
    
end