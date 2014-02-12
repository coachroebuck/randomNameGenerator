//
//  NameGeneratorApi.m
//  NameGenerator
//
//  Created by Mike Roebuck on 2/12/14.
//  Copyright (c) 2014 Mike Roebuck. All rights reserved.
//

#import "NameGeneratorApi.h"

NSString * const NameGeneratorBaseUrl = @"http://www.census.gov/genealogy/www/data/1990surnames";
NSString * const NameGeneratorMaleFirstNamesSubDirectory = @"/dist.male.first";
NSString * const NameGeneratorFemaleFirstNamesSubDirectory = @"/dist.female.first";
NSString * const NameGeneratorAllLastNamesSubDirectory = @"/dist.all.last";

@interface NameGeneratorApi () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSDictionary * responseData;

@property (nonatomic, strong) NSArray * maleFirstNames;

@property (nonatomic, strong) NSArray * femaleFirstNames;

@property (nonatomic, strong) NSArray * allLastNames;

@end

@implementation NameGeneratorApi

- (void) loadNamesFromCensus {
    NSMutableDictionary * dictionary = [NSMutableDictionary new];
    self.responseData = dictionary;
    [self loadMaleFirstNames];
    [self loadFemaleFirstNames];
    [self loadAllLastNames];
}

- (void) loadMaleFirstNames {
    self.maleFirstNames = [NSArray new];
    [self startConnectionWithString:[NSString stringWithFormat:@"%@%@", NameGeneratorBaseUrl, NameGeneratorMaleFirstNamesSubDirectory]];
}

- (void) loadFemaleFirstNames {
    self.femaleFirstNames = [NSArray new];
    [self startConnectionWithString:[NSString stringWithFormat:@"%@%@", NameGeneratorBaseUrl, NameGeneratorFemaleFirstNamesSubDirectory]];
}

- (void) loadAllLastNames {
    self.allLastNames = [NSArray new];
    [self startConnectionWithString:[NSString stringWithFormat:@"%@%@", NameGeneratorBaseUrl, NameGeneratorAllLastNamesSubDirectory]];
}

- (NSString *) generateMaleFirstName {
    return self.maleFirstNames[rand() % self.maleFirstNames.count];
}

- (NSString *) generateFemalFirstName {
    return self.femaleFirstNames[rand() % self.femaleFirstNames.count];
}

- (NSString *) generateLastName {
    return self.allLastNames[rand() % self.allLastNames.count];
}

- (void) startConnectionWithString:(NSString *) str {
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:str]];
    
    // Create url connection and fire request
    NSURLConnection * connection = [[NSURLConnection alloc]
                                    initWithRequest:request
                                    delegate:self startImmediately:NO];
    
    if (!connection) {
        // Release the receivedData object.
        self.responseData = nil;
        
        // Inform the user that the connection failed.
    }
    else
    {
        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                              forMode:NSDefaultRunLoopMode];
        [connection start];
        ;
    }
}

#pragma mark - NSURLConnectionDelegate Protocol

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    NSMutableDictionary * dictionary = [self.responseData mutableCopy];
    dictionary[connection.currentRequest.URL.absoluteString] = [NSData new];
    self.responseData = dictionary;
    NSLog(@"%s: url=%@", __FUNCTION__, connection.currentRequest.URL.absoluteString);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    NSMutableDictionary * dictionary = [self.responseData mutableCopy];
    NSMutableData * mutableData = [dictionary[connection.currentRequest.URL.absoluteString] mutableCopy];
    [mutableData appendData:data];
    dictionary[connection.currentRequest.URL.absoluteString] = mutableData;
    self.responseData = dictionary;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSMutableDictionary * dictionary = [self.responseData mutableCopy];
    NSString * key = connection.currentRequest.URL.absoluteString;
    NSData * data = [dictionary[key] mutableCopy];
    NSString * str = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    NSArray * records = [str componentsSeparatedByString:@"\n"];
    
    if ([key rangeOfString:NameGeneratorMaleFirstNamesSubDirectory].location != NSNotFound) {
        NSMutableArray * mutableArray = [self.maleFirstNames mutableCopy];
        
        for(NSString * nextRecord in records)
        {
            NSArray * columns = [nextRecord componentsSeparatedByString:@" "];
            [mutableArray addObject:columns[0]];
        }
        
        self.maleFirstNames = mutableArray;
    }
    else if ([key rangeOfString:NameGeneratorFemaleFirstNamesSubDirectory].location != NSNotFound) {
        NSMutableArray * mutableArray = [self.femaleFirstNames mutableCopy];
        
        for(NSString * nextRecord in records)
        {
            NSArray * columns = [nextRecord componentsSeparatedByString:@" "];
            [mutableArray addObject:columns[0]];
        }
        
        self.femaleFirstNames = mutableArray;
    }
    else if ([key rangeOfString:NameGeneratorAllLastNamesSubDirectory].location != NSNotFound) {
        NSMutableArray * mutableArray = [self.allLastNames mutableCopy];
        
        for(NSString * nextRecord in records)
        {
            NSArray * columns = [nextRecord componentsSeparatedByString:@" "];
            [mutableArray addObject:columns[0]];
        }
        
        self.allLastNames = mutableArray;
    }
    
    [dictionary removeObjectForKey:key];
    self.responseData = dictionary;
    
    NSLog(@"%s: url=%@", __FUNCTION__, connection.currentRequest.URL.absoluteString);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"%s: url=%@ Failed with error: %@", __FUNCTION__, connection.currentRequest.URL.absoluteString, error);
}

@end
