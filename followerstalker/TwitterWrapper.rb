#
#  TwitterWrapper.rb
#  followerstalker
#
#  Created by Kevin Sheffield on 4/19/12.
#  Copyright 2012 None. All rights reserved.
#

class TwitterWrapper

    def getFollowersByUser(handle)
        @ids = Array.new
        @followers = Array.new
        puts "other side"
        fetch_paginated_friends(handle) do |friends|
            puts "Importing a batch of friends"
            get_twitter_friend_ids(friends)
        end
        
        load_twitter_friends_from_ids()
        
        puts "Import done"
        puts @followers.length.to_s + " followers found"
        return @followers
    end
    
    def fetch_paginated_friends(account, &block)
        cursor = '-1'
        until cursor == 0
            url_string = 
            "https://api.twitter.com/1/friends/ids.json?cursor=#{cursor}&screen_name=#{account}"
            url = NSURL.alloc.initWithString(url_string)
            json_friends   = NSMutableString.alloc.initWithContentsOfURL(url,
                                                                         encoding:NSUTF8StringEncoding,
                                                                         error:nil)
            friend_results = JSON.parse(json_friends)
            block.call(friend_results['ids'])
            cursor = friend_results['next_cursor']
        end
    end
    
    def get_twitter_friend_ids(friends)
        friends.each do |friend|
            @ids << friend.to_s
        end
    end
    
    def load_twitter_friends_from_ids()
        puts @ids.length.to_s + " in ids"
        aHundred = @ids.slice!(0,75)
        puts @ids.length.to_s + " in ids"
        while(aHundred.length > 0)
            id_string = aHundred.join(',')
            url_string = "https://api.twitter.com/1/users/lookup.json?user_id=#{id_string}&include_entities=false"
            puts url_string
            url = NSURL.alloc.initWithString(url_string)
            json_friends   = NSMutableString.alloc.initWithContentsOfURL(url,
                                                                         encoding:NSUTF8StringEncoding,
                                                                         error:nil)
            friend_results = JSON.parse(json_friends)
            
            #puts friend_results
            friend_results.each do |friend|
                #puts "let's see"
                #puts friend['id_str']
                new_follower = Follower.new
                new_follower.twitter_id = friend['id_str']
                new_follower.handle = friend['screen_name']
                
                @followers << new_follower
            end
            
            
            aHundred = @ids.slice!(0,75)
            puts @ids.length.to_s + " in ids"
        end
    end
    
end
