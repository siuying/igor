#import "ScanningIgorQueryParser.h"
#import "IgorQueryScanner.h"
#import "ScanningInstanceParser.h"
#import "ComplexMatcher.h"
#import "UniversalMatcher.h"

@implementation ScanningIgorQueryParser {
    id<IgorQueryScanner> scanner;
    id<InstanceChainParser> instanceChainParser;
    id<InstanceParser> instanceParser;
}

- (id<IgorQueryParser>)initWithQueryScanner:(id <IgorQueryScanner>)theScanner instanceParser:(id<InstanceParser>)theInstanceParser instanceChainParser:(id<InstanceChainParser>)theInstanceChainParser {
    if (self = [super init]) {
        scanner = theScanner;
        instanceParser = theInstanceParser;
        instanceChainParser = theInstanceChainParser;
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
        matcher = [ComplexMatcher matcherWithHead:matcher subject:[matcherChain objectAtIndex:i] ];
    }
    return matcher;
}

- (id <SubjectMatcher>)parseMatcherFromQuery:(NSString *)query {
    [scanner setQuery:query];
    NSMutableArray* head = [NSMutableArray array];
    NSMutableArray* tail = [NSMutableArray array];
    id<SubjectMatcher> subject;

    [instanceChainParser parseInstanceMatchersIntoArray:head];
    if ([scanner skipString:@"$"]) {
        subject = [instanceParser parseInstanceMatcher];
        NSLog(@"Found subject marker. Parsed subject %@", subject);
    } else {
        subject = [head lastObject];
        [head removeLastObject];
        NSLog(@"No subject marker. Stealing subject from head: %@", subject);
        NSLog(@"Head now contains %@", head);
    }
    if ([scanner skipWhiteSpace]) {
        NSLog(@"Found whitespace after subject. Parsing tail.");
        [instanceChainParser parseInstanceMatchersIntoArray:tail];
    }
    [scanner failIfNotAtEnd];
    return [ComplexMatcher matcherWithHead:[self subjectMatcherFromMatcherChain:head] subject:subject tail:[self subjectMatcherFromMatcherChain:tail]];
}

+ (id<IgorQueryParser>)parserWithScanner:(id <IgorQueryScanner>)scanner instanceParser:(id<InstanceParser>)instanceParser instanceChainParser:(id <InstanceChainParser>)instanceChainParser {
    return [[self alloc] initWithQueryScanner:scanner instanceParser:instanceParser instanceChainParser:instanceChainParser];
}


@end