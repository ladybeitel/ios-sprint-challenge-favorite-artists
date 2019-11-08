//
//  CDBFavArtistController.m
//  FavoriteArtist
//
//  Created by Ciara Beitel on 11/8/19.
//  Copyright © 2019 Ciara Beitel. All rights reserved.
//

#import "CDBFavArtistController.h"
#import "CDBFavArtist.h"

@interface CDBFavArtistController ()

@property NSMutableArray *internalFavArtists;

@end

@implementation CDBFavArtistController

- (NSArray *) favArtists {
    return self.internalFavArtists;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _internalFavArtists = [[NSMutableArray alloc] init];
    }
    return self;
}

static NSString *const baseURLString = @"https://theaudiodb.com/api/v1/json/1/search.php?s=";

- (void)searchForFavArtists:(NSString *)searchTerm completion:(void (^)(NSError *error))completion {
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:baseURL resolvingAgainstBaseURL:YES];
    NSURLQueryItem *searchItem = [NSURLQueryItem queryItemWithName:@"search" value:searchTerm];
    [components setQueryItems: @[searchItem]];
    
    NSURL *url = [components URL];
    NSLog(@"URL: %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"Search results");

        if (error) {
            completion(error);
            return;
        }
        
        NSError *jsonError = nil;
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) {
            completion(nil);
            return;
        }
        
        if (![json isKindOfClass:[NSDictionary class]]) {
            NSLog(@"JSON was not a dictionary as expected.");
            completion([[NSError alloc] init]);
        }
        
        NSArray *fetchedData = json[@"artists"];
        NSMutableArray *fetchedArtists = [[NSMutableArray alloc] init];
        
        for (NSDictionary *artistDictionary in fetchedData) {
            CDBFavArtist *favArtist = [[CDBFavArtist alloc] initWithDictionary:artistDictionary];
            [fetchedArtists addObject:favArtist];
        }
        
        self.internalFavArtists = fetchedArtists;
        completion(nil);
        
    }];
    [dataTask resume];
}

@end