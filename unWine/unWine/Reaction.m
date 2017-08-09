//
//  Reaction.m
//  unWine
//
//  Created by Bryce Boesen on 12/2/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "Reaction.h"

@implementation Reaction
@dynamic user, wine, newsfeed, type;

+ (NSArray<ReactionObject *> *)reactions {
    static NSMutableArray *_reactions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _reactions = [[NSMutableArray alloc] init];
        [_reactions insertObject:[ReactionObject type:ReactionType5Aweful
                                                react:@"😞"
                                           descriptor:@"Awful"]
                         atIndex:ReactionType5Aweful];
        [_reactions insertObject:[ReactionObject type:ReactionType4Bad
                                                react:@"🙁"
                                           descriptor:@"Bad"]
                         atIndex:ReactionType4Bad];
        [_reactions insertObject:[ReactionObject type:ReactionType3Okay
                                                react:@"😐"
                                           descriptor:@"Okay"]
                         atIndex:ReactionType3Okay];
        [_reactions insertObject:[ReactionObject type:ReactionType2Good
                                                react:@"🙂"
                                           descriptor:@"Good"]
                         atIndex:ReactionType2Good];
        [_reactions insertObject:[ReactionObject type:ReactionType1Great
                                                react:@"😍"
                                           descriptor:@"Great"]
                         atIndex:ReactionType1Great];
    });
    
    return _reactions;
}

+ (NSString *)parseClassName {
    return @"Reaction";
}

- (BOOL)isNewsFeedReaction {
    return self.newsfeed != nil;
}

- (ReactionType)getReactionType {
    if([self objectForKey:@"type"] == nil || [self.type isKindOfClass:[NSNull class]])
        return (ReactionType)(self.type = @(ReactionType0None));
        
    return (ReactionType)self.type;
}

- (ReactionObject *)getReactionObject {
    return [Reaction getReactionObject:[self getReactionType]];
}

+ (ReactionObject *)getReactionObject:(ReactionType)type {
    return type != ReactionType0None ? [[self reactions] objectAtIndex:type] : nil;
}

+ (BFTask *)reactionsFromObjects:(NSArray<NSString *> *)objectIds {
    PFQuery *query = [Reaction query];
    [query includeKey:@"user"];
    [query includeKey:@"newsfeed"];
    [query includeKey:@"wine"];
    [query whereKey:@"objectId" containedIn:objectIds];
    
    return [query findObjectsInBackground];
}

@end

@implementation ReactionObject

+ (instancetype)type:(ReactionType)type react:(NSString *)react descriptor:(NSString *)descriptor {
    ReactionObject *obj = [[ReactionObject alloc] init];
    obj.type = type;
    obj.react = react;
    obj.descriptor = descriptor;
    return obj;
}

@end

@implementation ReactionView
@synthesize reactionButton = _reactionButton, descLabel = _descLabel, quantityLabel = _quantityLabel;

static NSInteger labelHeight = 14;
static NSInteger viewBuffer = 4;

+ (instancetype)reactWithFrame:(CGRect)frame type:(ReactionType)type {
    ReactionView *react = [[ReactionView alloc] initWithFrame:frame];
    react.type = type;
    
    ReactionObject *obj = [Reaction getReactionObject:type];
    [react.layer setCornerRadius:10.f];
    /*[react.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [react.layer setShadowColor:[UIColor blackColor].CGColor];
    [react.layer setShadowOpacity:1];
    [react.layer setShadowRadius:3.0];
    [react.layer setShadowOffset:CGSizeMake(0, 0)];*/
    
    react.descLabel = [[UILabel alloc] initWithFrame:(CGRect){0, viewBuffer, {frame.size.width, labelHeight}}];
    [react.descLabel setTextAlignment:NSTextAlignmentCenter];
    [react.descLabel setTextColor:UNWINE_GRAY];
    [react.descLabel setText:(obj ? obj.descriptor : @"")];
    [react.descLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:12]];
    react.descLabel.adjustsFontSizeToFitWidth = YES;
    react.descLabel.minimumScaleFactor = .5;
    [react addSubview:react.descLabel];
    
    react.reactionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [react.reactionButton setFrame:(CGRect){0, labelHeight + viewBuffer * 2, {frame.size.width, frame.size.height - labelHeight * 2 - viewBuffer * 4}}];
    [react.reactionButton setTitle:(obj ? obj.react : @"") forState:UIControlStateNormal];
    [react.reactionButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:48]];
    react.reactionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    react.reactionButton.titleLabel.minimumScaleFactor = .25;
    [react addSubview:react.reactionButton];
    [react.reactionButton addTarget:react action:@selector(reactionPressed) forControlEvents:UIControlEventTouchUpInside];
    
    react.quantityLabel = [[UILabel alloc] initWithFrame:(CGRect){0, frame.size.height - labelHeight - viewBuffer * 2, {frame.size.width, labelHeight + viewBuffer * 2}}];
    [react.quantityLabel setTextAlignment:NSTextAlignmentCenter];
    [react.quantityLabel setTextColor:UNWINE_GRAY];
    [react.quantityLabel setText:@""];
    [react.quantityLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:12]];
    react.quantityLabel.adjustsFontSizeToFitWidth = YES;
    react.quantityLabel.minimumScaleFactor = .5;
    [react addSubview:react.quantityLabel];
    
    return react;
}

- (void)reactionPressed {
    if(self.delegate)
        [self.delegate reactionPressed:self.type];
}

- (void)setReactionSize:(NSInteger)fontSize {
    [self.reactionButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:fontSize]];
}

- (void)setReaction:(ReactionType)type {
    self.type = type;
    
    ReactionObject *obj = [Reaction getReactionObject:type];
    [self.descLabel setText:(obj ? obj.descriptor : @"")];
    [self.reactionButton setTitle:(obj ? obj.react : @"") forState:UIControlStateNormal];
}

- (void)updateQuantity:(BFTask *)task {
    [task continueWithBlock:^id(BFTask *task) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_quantityLabel setText:[NSString stringWithFormat:@"+"]];
        });
        return nil;
    }];
}

@end
