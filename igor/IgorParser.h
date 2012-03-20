//
//  IgorParser.h
//  igor
//
//  Created by Dale Emery on 11/17/11.
//  Copyright (c) 2011 Dale H. Emery. All rights reserved.
//

#import "Igor.h"
#import "Parser.h"

@interface IgorParser : NSObject

-(id<Matcher>) parse:(NSString*) pattern;

@end
