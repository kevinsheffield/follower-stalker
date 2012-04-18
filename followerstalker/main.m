//
//  main.m
//  followerstalker
//
//  Created by Kevin Sheffield on 4/17/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}
