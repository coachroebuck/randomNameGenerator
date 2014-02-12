//
//  NameGeneratorApi.h
//  NameGenerator
//
//  Created by Mike Roebuck on 2/12/14.
//  Copyright (c) 2014 Mike Roebuck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NameGeneratorApi : NSObject

- (void) loadNamesFromCensus;


- (NSString *) generateMaleFirstName;

- (NSString *) generateFemalFirstName;

- (NSString *) generateLastName;

@end
