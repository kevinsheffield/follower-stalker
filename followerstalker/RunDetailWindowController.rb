#
#  RunDetailWindowController.rb
#  followerstalker
#
#  Created by Kevin Sheffield on 4/19/12.
#  Copyright 2012 None. All rights reserved.
#



class RunDetailWindowController < NSWindowController
    attr_accessor :titleLabel, :run
    
    def windowDidLoad
        super
        
        titleLabel.setStringValue "From the code!" + run.id.to_s        
    end
    
end
