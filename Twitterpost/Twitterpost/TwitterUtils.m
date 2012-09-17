//
//  TwitterUtils.m
//  Twitterpost
//
//  Created by Eivind Bergstøl on 5/29/12.
//  Copyright (c) 2012 Bekk Consulting as. All rights reserved.
//

#import "TwitterUtils.h"
#import "TwitterUtilTweetDelegate.h"

@implementation TwitterUtils
@synthesize accountStore;
@synthesize account;
@synthesize loadDelegate;
@synthesize successCallback;
@synthesize errorCallback;

- (id) initWithDelegate:(id<TwitterUtilTweetDelegate>) loadDelegateObject
{
    self = [super init];
    self.loadDelegate = loadDelegateObject;
    return self;
}

-(void)tweet:(NSString *)theTweet
{
    [loadDelegate loadStarted];
    NSURL *updateUrl = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:theTweet, @"status", nil];
    
    TWRequest *request = [[TWRequest alloc] initWithURL:updateUrl parameters:params requestMethod:TWRequestMethodPOST];    
    request.account = self.account;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:NULL];        
        //NSLog(@"%@", dict);
        [(id)[self loadDelegate] performSelectorOnMainThread:@selector(loadFinished) withObject:nil waitUntilDone:YES];
    }];
}

- (void) getTweets: (id) delegate onSuccess:(SEL)successCallback onError:(SEL)errorCallback{
    // Now make an authenticated request to our endpoint
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"1" forKey:@"include_entities"];
    
    //  The endpoint that we wish to call
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json"];
    
    //  Build the request with our parameter 
    TWRequest *request = 
    [[TWRequest alloc] initWithURL:url 
                        parameters:params 
                     requestMethod:TWRequestMethodGET];
    
    // Attach the account object to this request
    [request setAccount:account];
    
    [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         if (!responseData) {
             // inspect the contents of error 
             NSLog(@"%@", error);
         } else {
             NSError *jsonError;
             NSArray *timeline = 
             [NSJSONSerialization 
              JSONObjectWithData:responseData 
              options:NSJSONReadingMutableLeaves 
              error:&jsonError];            
             if (timeline) {                          
                 // at this point, we have an object that we can parse
                 // NSLog(@"%@", timeline);
                [delegate performSelectorOnMainThread:successCallback withObject:timeline waitUntilDone:YES];
             } 
             else { 
                 // inspect the contents of jsonError
                 NSLog(@"%@", jsonError);
                [delegate performSelector:errorCallback];
             }
         }
     }];
}

@end
