#import "IgorQueryParser.h"
#import "IgorQueryScanner.h"
#import "InstanceParser.h"
#import "ComplexMatcher.h"
#import "UniversalMatcher.h"
#import "ClassParser.h"
#import "PredicateParser.h"

@implementation IgorQueryParser {
    id<IgorQueryScanner> scanner;
    id<InstanceChainParser> instanceChainParser;
    InstanceParser* instanceParser;
}

- (IgorQueryParser *)initWithQueryScanner:(id <IgorQueryScanner>)theScanner instanceChainParser:(id<InstanceChainParser>)theInstanceChainParser {
    if (self = [super init]) {
        scanner = theScanner;
        instanceChainParser = theInstanceChainParser;
        ClassParser *classParser = [ClassParser parser];
        PredicateParser *predicateParser = [PredicateParser parser];
        instanceParser = [InstanceParser parserWithClassParser:classParser predicateParser:predicateParser];
    }
    return self;
}

- (id <SubjectMatcher>)subjectMatcherFromMatcherChain:(NSArray *)matcherChain {
    if ([matcherChain count] == 0) {
        return [UniversalMatcher new];
    }
    if ([matcherChain count] == 1) {
        return [matcherChain lastObject];
    }
    id<SubjectMatcher> matcher = [matcherChain objectAtIndex:0];
    for (NSUInteger i = 1 ; i < [matcherChain count] ; i++) {
        matcher = [ComplexMatcher withHead:matcher subject:[matcherChain objectAtIndex:i] ];
    }
    return matcher;
}

- (id <SubjectMatcher>)parseMatcherFromQuery:(NSString *)query {
    [scanner setQuery:query];
    NSMutableArray* head = [NSMutableArray array];
    NSMutableArray* tail = [NSMutableArray array];
    id<SubjectMatcher> subject;

    [instanceChainParser parseInstanceMatchersFromQuery:scanner intoArray:head];
    if ([scanner skipString:@"$"]) {
        subject = [instanceParser parseInstanceMatcherFromQuery:scanner];
        NSLog(@"Found subject marker. Parsed subject %@", subject);
    } else {
        subject = [head lastObject];
        [head removeLastObject];
        NSLog(@"No subject marker. Stealing subject from head: %@", subject);
        NSLog(@"Head now contains %@", head);
    }
    if ([scanner skipWhiteSpace]) {
        NSLog(@"Found whitespace after subject. Parsing tail.");
        [instanceChainParser parseInstanceMatchersFromQuery:scanner intoArray:tail];
    }
    [scanner failIfNotAtEnd];
    return [ComplexMatcher withHead:[self subjectMatcherFromMatcherChain:head] subject:subject tail:[self subjectMatcherFromMatcherChain:tail]];
}

+ (IgorQueryParser *)withQueryScanner:(id <IgorQueryScanner>)scanner instanceChainParser:(id <InstanceChainParser>)instanceChainParser {
    return [[self alloc] initWithQueryScanner:scanner instanceChainParser:instanceChainParser];
}


@end
