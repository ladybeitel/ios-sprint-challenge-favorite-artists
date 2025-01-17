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

@property (nonatomic) NSMutableArray *internalFavArtists;

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

static NSString *const baseURLString = @"https://theaudiodb.com/api/v1/json/1/search.php";

- (void)searchForFavArtist:(NSString *)searchTerm completion:(void (^)(CDBFavArtist *favArtist, NSError *error))completion {
    
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:baseURL resolvingAgainstBaseURL:YES];
    
    NSURLQueryItem *searchItem = [NSURLQueryItem queryItemWithName:@"s" value:searchTerm];
    [components setQueryItems: @[searchItem]];
    
    NSURL *url = [components URL];
    NSLog(@"URL: %@", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"Search results");

        if (error) {
            completion(nil, error);
            return;
        }
        
        if (data == nil) {
            NSLog(@"Data was nil");
            completion(nil, [[NSError alloc] init]);
            return;
        }
        
        NSError *jsonError = nil;
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) {
            completion(nil, jsonError);
            return;
        }
        
        if (![json isKindOfClass:[NSDictionary class]]) {
            NSLog(@"JSON was not a dictionary as expected.");
            completion(nil, [[NSError alloc] init]);
            return;
        }
        
        CDBFavArtist *artist = [[CDBFavArtist alloc] initWithDictionary:json];
        completion(artist, nil);
    }];
    [dataTask resume];
}

- (void)saveFavArtist:(CDBFavArtist *) favArtist {
    [self.internalFavArtists addObject:favArtist];
}

- (void)removeTask:(CDBFavArtist *)favArtist {
    [self.internalFavArtists removeObject:favArtist];
}

@end
