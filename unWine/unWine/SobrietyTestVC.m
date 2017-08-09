//
//  ViewController.m
//  Sobriety
//
//  Created by Bryce Boesen on 8/11/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "SobrietyTestVC.h"
#import "NSDate+CurrentDateString.h"
#import "ParseSubclasses.h"
#define ALPHABET @"AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz"

@interface SobrietyTestVC ()

@end

@implementation SobrietyTestVC {
    UIColor *forBack, *forText;
    u_int32_t epsilon;
    BOOL alpha;
    CGFloat timer;
    NSInteger lowest, difficulty, current, failed;
    NSString *ANS;
    CGRect questionFrame, answerFrame, scoreFrame, levelFrame, highscoreFrame;
    BOOL needsQuestion, started;
    UIView *keyboard;
    bool canPop;
    NSTimer *myTimer;
    UIButton *bragOffer;
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    if ([[UIScreen mainScreen] bounds].size.height != 568.0f) {
        NSArray *elements = [_lview subviews];
        for(id object in elements) {
            UIView *v = ((UIView *)object);
            v.frame = CGRectMake(X2(v), Y2(v) - v.tag, WIDTH(v), HEIGHT(v));
        }
    }
    questionFrame = _question.frame;
    answerFrame = _answer.frame;
    scoreFrame = _score.frame;
    levelFrame = _level.frame;
    highscoreFrame = _highscore.frame;
    
    _answer.keyboardAppearance = UIKeyboardAppearanceDark;
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopTimer];
}

- (void)startTimer {
    myTimer = [NSTimer scheduledTimerWithTimeInterval: .10 target: self
                                             selector: @selector(update:)
                                             userInfo: nil repeats: YES];
    [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopTimer {
    [myTimer invalidate];
    myTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unwinewhitelogo22.png"]];
    self.navigationItem.titleView = imageView;
    
    forBack = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    forText = [self invert:forBack];
    
    needsQuestion = true;
    started = false;
    canPop = true;
    
    questionFrame = _question.frame;
    answerFrame = _answer.frame;
    scoreFrame = _score.frame;
    levelFrame = _level.frame;
    highscoreFrame = _highscore.frame;
    
    _failure.alpha = 0;
    _question.alpha = 0;
    _answer.alpha = 0;
    _highscore.alpha = 0;
    _time.alpha = 0;
    _score.alpha = 0;
    _level.alpha = 0;
    
    _answer.tintColor = [UIColor clearColor];
    _answer.delegate = self;
    _answer.autocorrectionType = UITextAutocorrectionTypeNo;
    
    User *user = [User currentUser];
    _currentHighscore = (user.highscores[[_fTitle lowercaseString]] != nil)? [user.highscores[[_fTitle lowercaseString]] integerValue] : 0;
    [_highscore setText:[NSString stringWithFormat:@"Highscore: %li", (long)_currentHighscore]];
    
    bragOffer = [UIButton buttonWithType:UIButtonTypeSystem];
    bragOffer.backgroundColor = UNWINE_RED;
    bragOffer.tintColor = [UIColor whiteColor];
    [bragOffer setFrame:CGRectMake(SEMIWIDTH(self.view) - 120, answerFrame.origin.y, 240, 60)];
    [bragOffer setTitle:@"You beat your highscore!\n   Wanna brag about it?" forState:UIControlStateNormal];
    bragOffer.titleLabel.numberOfLines = 0;
    [bragOffer.titleLabel sizeToFit];
    bragOffer.alpha = 0;
    
    UITapGestureRecognizer *registerGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushNewsFeed:)];
    [bragOffer addGestureRecognizer:registerGesture];
    [self.view addSubview:bragOffer];
    
    difficulty = 0;
    _fTitle = @"Sobriety Test";
    
    // Track Opens
    [Analytics trackSobrietyGameOpens];
}

- (void)pushNewsFeed:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query whereKey:@"name" equalTo:[_fTitle capitalizedString]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *gameObject, NSError *error) {
        User *user = [User currentUser];
        PFObject *object = [PFObject objectWithClassName:@"NewsFeed"];
        
        object[@"Type"] = @"Game";
        object[@"Likes"] = @0;
        object[@"localDate"] = [NSDate getCurrentDateString];
        if(gameObject)
            object[@"gamePointer"] = gameObject; //[PFObject objectWithoutDataWithClassName:@"Games" objectId:@"0rKr2XdBQr"];
        object[@"authorPointer"] = user;
        object[@"savedScore"] = user.highscores[[_fTitle lowercaseString]];
        object[@"verified"] = [NSNumber numberWithBool:YES];
        [object saveInBackground];
        
        self.tabBarController.view.tag = REFRESH_NEWSFEED;
        self.navigationController.view.tag = 1;
        [self.navigationController popToRootViewControllerAnimated:NO];
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    if (textField == _answer) {
        NSUInteger newLength = [textField.text length] - range.length + [string length];
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        NSUInteger MAXLENGTH = 1;
        
        return (newLength <= MAXLENGTH || returnKey);
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _answer) {
        if([_answer.text isEqualToString:ANS] && ![_answer.text isEqual: @""]) {
            [self hideLabel:_time in:.2];
            _answer.text = ANS = @"";
            current += (int)timer + 1;
            difficulty++;
            failed = 0;
            [self next];
        } else if (![_answer.text isEqualToString:ANS]) {
            [self shake:_score];
            failed++;
            if(failed == 5)
                [self drop];
            current -= failed;
        }
        return NO;
    }
    return YES;
}

-(void)shake:(UILabel*) label {
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.1];
    [shake setRepeatCount:5];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(label.center.x - 5,label.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(label.center.x + 5, label.center.y)]];
    [label.layer addAnimation:shake forKey:@"position"];
}

- (UIColor *) invert:(UIColor *)color {
    const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
    
    UIColor *newColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
                                               green:(1.0 - componentColors[1])
                                                blue:(1.0 - componentColors[2])
                                               alpha:componentColors[3]];
    return newColor;
}

- (UIColor *) alter:(UIColor *)color {
    const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
    CGFloat RGB[3] = { componentColors[0], componentColors[1], componentColors[2] };
    
    if((RGB[0] == 1 || RGB[0] == .75 || RGB[0] == .50 || RGB[0] == .25 || RGB[0] == 0) &&
       (RGB[1] == 1 || RGB[1] == .75 || RGB[1] == .50 || RGB[1] == .25 || RGB[1] == 0) &&
       (RGB[2] == 1 || RGB[2] == .75 || RGB[2] == .50 || RGB[2] == .25 || RGB[2] == 0)) {
        epsilon = (int)(arc4random() % 3);
        alpha = (RGB[epsilon] == 1);
        if(RGB[epsilon] == .25 || RGB[epsilon] == .50 || RGB[epsilon] == .75)
            alpha = [self randBool];
    }
    
    RGB[epsilon] = (alpha)? RGB[epsilon] - .01 : RGB[epsilon] + .01;
    UIColor *newColor = [[UIColor alloc] initWithRed:RGB[0] green:RGB[1] blue:RGB[2]
                                               alpha:componentColors[3]];
    return newColor;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!started) {
        [_answer becomeFirstResponder];
        [UIView animateWithDuration:.5 animations:^{
            _display.alpha = 0;
            bragOffer.alpha = 0;
            _textBox.alpha = 0;
            self.navigationController.navigationBarHidden = YES;
        } completion:^(BOOL finished) {
            [_display setText:@"What comes next?"];
            started = true;
            needsQuestion = true;
            [UIView animateWithDuration:.5 animations:^{
                _display.alpha = 1;
                _score.alpha = 1;
                _highscore.alpha = 1;
                _level.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }];
    } else {
        [UIView animateWithDuration:.5 animations:^{
            self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
        }];
    }
}

- (void) update:(NSTimer *) t {
    if(!started)
        return;
    
    forBack = [self alter:forBack];
    forText = [self invert:forBack];
    
    NSArray *elements = [_lview subviews];
    for(id object in elements) {
        if([object class] == [UILabel class]) {
            UILabel *label = ((UILabel *)object);
            label.textColor = forText;
            lowest = (HEIGHT(label) > lowest)? lowest : HEIGHT(label);
        }
    }
    _lview.backgroundColor = forBack;
    self.view.backgroundColor = _lview.backgroundColor;
    
    _time.text = [NSString stringWithFormat:@"%is", (int)timer + 1];
    if(_time.alpha == 1) {
        timer -= .10;
        if(timer <= 0)
            [self drop];
    }
    [_level setText:[NSString stringWithFormat:@"Level: %li", (long)(difficulty + 1)]];
    [_score setText:[NSString stringWithFormat:@"Score: %li", (long)current]];
    
    NSInteger dispHighscore = (current > _currentHighscore)? current : _currentHighscore;
    [_highscore setText:[NSString stringWithFormat:@"Highscore: %li", (long)dispHighscore]];
    if(![ANS isEqual: @""] && [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[ANS characterAtIndex:0]])
        [_answer setText:[_answer.text lowercaseString]];
    
    if(needsQuestion) {
        [self generate];
    }
}

- (void) generate {
    needsQuestion = NO;
    
    NSString *codex = ALPHABET;
    if(difficulty < 15)
        codex = [[codex componentsSeparatedByCharactersInSet:[NSCharacterSet lowercaseLetterCharacterSet]] componentsJoinedByString:@""];
    if(difficulty > 6 && difficulty < 15)
        codex = [self randomCaps:codex];
    _question.text = [self makePattern:codex];
    NSLog(@"Answer: %@", ANS);
    timer = 15;
    if(_question.alpha == 1)
        [self next];
    else
        [self raise];
}

- (NSString *) randomCaps:(NSString *)newAlpha {
    BOOL startWithA = [self randBool];
    for(NSUInteger i = 0; i < [newAlpha length]; i++)
        if((startWithA && i % 2 == 0) || (!startWithA && i % 2 == 1))
            newAlpha = [newAlpha stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:[[newAlpha substringWithRange:NSMakeRange(i, 1)] lowercaseString]];
    return newAlpha;
}

- (void) raise {
    _question.alpha = 1;
    _answer.alpha = 1;
    _question.frame = CGRectMake(X2(_question), HEIGHT(self.view), WIDTH(_question), HEIGHT(_question));
    _answer.frame = CGRectMake(X2(_answer), HEIGHT(self.view), WIDTH(_answer), HEIGHT(_answer));
    [UIView animateWithDuration:1.2 animations:^{
        _failure.alpha = 0;
        _question.frame = questionFrame;
        _answer.frame = answerFrame;
    } completion:^(BOOL finished) {
        [self showLabel:_time in:.5];
    }];
}

- (void) drop {
    [self hideLabel:_time in:.2];
    [_answer resignFirstResponder];
    [_display setText:@"Play Again?"];
    [[[self.tabBarController.tabBar items] objectAtIndex:4] setEnabled:NO];
    _failure.text = [NSString stringWithFormat:@"Answer: %@", ANS];
    
    [UIView animateWithDuration:.5 animations:^{
        _question.frame = CGRectMake(X2(_question), HEIGHT(self.view), WIDTH(_question), HEIGHT(_question));
        _answer.frame = CGRectMake(X2(_answer), HEIGHT(self.view), WIDTH(_answer), HEIGHT(_answer));
        self.navigationController.navigationBarHidden = NO;
        _failure.alpha = 1;
    } completion:^(BOOL finished) {
        //They lost, do something crazy
        NSString *message = @"";
        if(current < 0)
            message = @"You need to go lie down...";
        else if(current == 0)
            message = @"I guess you blacked out.";
        else if(current > 0 && current < 30)
            message = @"I'm not a cop, but you probably shouldn't drive tonight.";
        else if(current >= 30 && current < 60)
            message = @"My drunk grandmother could do better.";
        else if(current >= 60 && current < 90)
            message = @"Try harder maybe?";
        else if(current >= 90 && current < 120)
            message = @"Dare you to play again, bet you screw up again.";
        else if(current >= 200)
            message = @"You're too sober for this game, go get some wine and unWine.";
        else
            message = @"I tinhk yur'oe a drtiy chateer. If that didn't confuse you, you're not unWineing properly.";
        
        if(failed >= 5 && difficulty < 10)
            message = @"Alright you're either impatient or fucked up, either way I enjoy watching you fail.";
        if(failed >= 5 && difficulty >= 10 && difficulty < 18)
            message = @"Frustrated yet? It's only a game, try harder.";
        if(failed >= 5 && difficulty >= 18)
            message = @"Decent, but I highly doubt you can do better...";
        
        
        UIAlertView * alert =[[UIAlertView alloc] initWithTitle:@"Game Over"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        //alert.transform = CGAffineTransformTranslate(alert.transform, X2(alert), Y2(alert) / 2);
        
        //Add Plays
        User *user = [User currentUser];
        if(current > _currentHighscore) {
            user.highscores[[_fTitle lowercaseString]] = @(current);
            [self showLabel:bragOffer in:.1];
        }
        
        NSInteger i = [user.freeplays[[_fTitle lowercaseString]] integerValue];
        if(_count == -1 && i != -1) {
            user.freeplays[[_fTitle lowercaseString]] = @(-1);
            _purchased = YES;
        } else if(_count != -1 && i == -1) {
            user.freeplays[[_fTitle lowercaseString]] = @(0);
            i = 0;
        }
        if(i != -1) {
            if(i < -1) i = 0;
            user.freeplays[[_fTitle lowercaseString]] = @(i + 1);
        } else
            _purchased = YES;
        
        [user saveInBackground];
        
        started = false;
        _answer.text = ANS = @"";
        current = difficulty = failed = _question.alpha = _answer.alpha = 0;
        alert.tag = 1;
        
        NSLog(@"Status: %li - %@", (long)i, _purchased ? @"Yes" : @"No");
        if(!_purchased && i >= _count - 1) {
            alert.message = @"Thanks for playing! You've run out of free plays, purchase the game on the next page to keep playing!";
            alert.tag = 624;
        } else {
            alert.tag = 1;
        }
        [alert show];
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(canPop && alertView.tag == 624) {
        [[self navigationController] popViewControllerAnimated:YES];
        canPop = !canPop;
    }
    [[[self.tabBarController.tabBar items] objectAtIndex:4] setEnabled:YES];
}

- (void) next {
    if(X2(_question) == questionFrame.origin.x) {
        [UIView animateWithDuration:.8 animations:^{
            _question.frame = CGRectMake(X2(_question) - WIDTH(self.view), Y2(_question), WIDTH(_question), HEIGHT(_question));
            _answer.frame = CGRectMake(X2(_answer) - WIDTH(self.view), Y2(_answer), WIDTH(_answer), HEIGHT(_answer));
        } completion:^(BOOL finished) {
            _question.frame = CGRectMake(questionFrame.origin.x + WIDTH(self.view), Y2(_question), WIDTH(_question), HEIGHT(_question));
            _answer.frame = CGRectMake(answerFrame.origin.x + WIDTH(self.view), Y2(_answer), WIDTH(_answer), HEIGHT(_answer));
            needsQuestion = YES;
        }];
    } else {
        [UIView animateWithDuration:1.2 animations:^{
            _question.frame = questionFrame;
            _answer.frame = answerFrame;
        } completion:^(BOOL finished) {
            [self showLabel:_time in:.5];
        }];
    }
}

- (NSString *) makePattern:(NSString *)codex {
    u_int32_t length = (int)(arc4random() % 3) + 3;
    NSMutableString *ret = [[NSMutableString alloc] initWithCapacity:length];
    if(difficulty >= 10)
        length += 1;
    
    //if(difficulty < 6) {
    u_int32_t pat = (int)(arc4random() % ((difficulty / 3) + 1)) + 1;
    u_int32_t start = (int)(arc4random() % codex.length);
    codex = ([self randBool] && difficulty >= 6)? [self reverse:codex] : codex;
    NSLog(@"Specs: %@, %i, %i, %i, %i", codex, start, pat, length, difficulty);
    
    BOOL goRight = YES;
    NSInteger cursor = start;
    int limit = 0;
    while(ret.length <= length) {
        NSLog(@"Current: %@", ret);
        if(ret.length == length) {
            ANS = [codex substringWithRange:NSMakeRange(cursor, 1)];
            break;
        } else
            [ret appendString:[codex substringWithRange:NSMakeRange(cursor, 1)]];
        
        cursor = (goRight)? cursor + pat : cursor - pat;
        if(cursor >= codex.length) {
            if(!goRight)
                codex = [self reverse:codex];
            goRight = !goRight;
            
            if(limit > 3) {
                pat--;
                limit--;
            } else
                limit++;
            
            cursor = start;
            ret = [[NSMutableString alloc] initWithCapacity:length];
        }
    }
    //}
    return ret;
}

- (NSString *) reverse:(NSString *)flip {
    NSMutableString *reverseName = [[NSMutableString alloc] initWithCapacity:[flip length]];
    
    for(int i = [flip length] - 1; i >= 0; i--)
        [reverseName appendString:[flip substringWithRange:NSMakeRange(i, 1)]];
    
    return reverseName;
}

- (BOOL) randBool {
    u_int32_t randomNumber = (arc4random() % ((unsigned)RAND_MAX + 1));
    return (randomNumber % 2 == 0);
}

- (void) hideLabel:(UILabel *)label in:(CGFloat)t {
    [UIView animateWithDuration:t animations:^{ label.alpha = 0; } completion:nil];
}

- (void) showLabel:(UIView *)label in:(CGFloat)t {
    [UIView animateWithDuration:t animations:^{ label.alpha = 1; } completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
