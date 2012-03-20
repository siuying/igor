//
//  PredicateMatcher.m
//  igor
//
//  Created by Dale Emery on 11/30/11.
//  Copyright (c) 2011 Dale H. Emery. All rights reserved.
//

#import "PredicateMatcher.h"

@implementation PredicateMatcher {
    NSPredicate* predicate;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"[PredicateMatcher:[predicate:%@]]", predicate];
}

-(PredicateMatcher*) initWithPredicateExpression:(NSString*)expression {
    if(self = [super init]) {        
        predicate = [NSPredicate predicateWithFormat:expression];
    }
    return self;
}

-(BOOL) matchesView:(UIView*)view {
    @try {
        return [predicate evaluateWithObject:view];
    }
    @catch (NSException* e) {
        return NO;
    }
}

-(NSString*) matchExpression {
    return [predicate predicateFormat];
}

+(PredicateMatcher*) withPredicateExpression:(NSString*)expression {
    return [[PredicateMatcher alloc] initWithPredicateExpression:expression];
}

@end
