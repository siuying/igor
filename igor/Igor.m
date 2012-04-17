#import "Igor.h"
#import "QueryParser.h"
#import "TreeWalker.h"
#import "QueryScanner.h"
#import "StringQueryScanner.h"
#import "ChainParser.h"
#import "InstanceParser.h"
#import "ClassParser.h"
#import "PredicateParser.h"
#import "BranchParser.h"
#import "DescendantCombinatorParser.h"

@implementation Igor

@synthesize parser;


- (NSArray *)findViewsThatMatchMatcher:(id <Matcher>)matcher inTree:(UIView *)tree {
    NSMutableSet *matchingViews = [NSMutableSet set];
    void (^collectMatches)(UIView *) = ^(UIView *view) {
        if ([matcher matchesView:view]) {
            [matchingViews addObject:view];
        }
    };
    [TreeWalker walkTree:tree withVisitor:collectMatches];
    return [matchingViews allObjects];

}

- (NSArray *)findViewsThatMatchQuery:(NSString *)query inTree:(UIView *)tree {
    id <Matcher> matcher = [parser parseMatcherFromQuery:query];
    return [self findViewsThatMatchMatcher:matcher inTree:tree];
}

+ (Igor *)igor {
    id <QueryScanner> scanner = [StringQueryScanner new];
    id <PatternParser> classParser = [ClassParser parserWithScanner:scanner];
    id <PatternParser> predicateParser = [PredicateParser parserWithScanner:scanner];

    NSArray *simplePatternParsers = [NSArray arrayWithObjects:classParser, predicateParser, nil];
    id <PatternParser> instanceParser = [InstanceParser parserWithSimplePatternParsers:simplePatternParsers];

    NSArray *combinatorParsers = [NSArray arrayWithObject:[DescendantCombinatorParser parserWithScanner:scanner]];
    ChainParser *subjectChainParser = [ChainParser parserWithCombinatorParsers:combinatorParsers];
    id <PatternParser> branchParser = [BranchParser parserWithScanner:scanner subjectChainParser:subjectChainParser];
    NSArray *subjectParsers = [NSArray arrayWithObjects:instanceParser, branchParser, nil];
    subjectChainParser.subjectParsers = subjectParsers;

    id <IgorQueryParser> parser = [QueryParser parserWithScanner:scanner subjectChainParser:subjectChainParser];

    return [self igorWithParser:parser];
}

+ (Igor *)igorWithParser:(id <IgorQueryParser>)parser {
    return [[self alloc] initWithParser:parser];
}

- (Igor *)initWithParser:(id <IgorQueryParser>)theParser {
    self = [super init];
    if (self) {
        parser = theParser;
    }
    return self;
}

- (NSArray *)selectViewsWithSelector:(NSString *)query {
    UIView *tree = [[UIApplication sharedApplication] keyWindow];
    return [self findViewsThatMatchQuery:query inTree:tree];
}

@end
