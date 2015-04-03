//
//  ASBPlayerSubtitling.m
//  ASBPlayerSubtitling
//
//  Created by Philippe Converset on 25/03/2015.
//  Copyright (c) 2015 AutreSphere. All rights reserved.
//

#import "ASBPlayerSubtitling.h"
#import <UIKit/UIKit.h>

@implementation ASBSubtitle
@end


@interface ASBPlayerSubtitling ()
@property (nonatomic, assign) id timeObserver;
@property (nonatomic, assign) CGFloat frameDuration;
@property (nonatomic, assign) CGFloat nbFramesPerSecond;
@property (nonatomic, strong) NSMutableArray *subtitles;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, copy) NSString *currentText;
@property (nonatomic, copy) NSString *cssStyle;
@end

@implementation ASBPlayerSubtitling

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    _visible = YES;
    self.queue = dispatch_queue_create("subtitling", NULL);
}

- (void)setPlayer:(AVPlayer *)player
{
    [self.player pause];
    [self removeTimeObserver];
    _player = player;
    
    self.nbFramesPerSecond = [ASBPlayerSubtitling nominalFrameRateForPlayer:self.player];
    self.frameDuration = 1/self.nbFramesPerSecond;
    self.label.text = @"";
    self.containerView.hidden = YES;
    [self setupTimeObserver];
    [self computeStyle];
}

- (void)loadSubtitlesAtURL:(NSURL *)url error:(NSError **)error
{
    NSError *localError;
    NSString *text;
    
    text = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&localError];
    if (localError == nil)
    {
        [self loadSRTContent:text error:&localError];
    }
    
    if(error != NULL)
    {
        *error = localError;
    }
}

- (void)computeStyle
{
    NSString *textAlign;
    NSString *color;
    
    textAlign = [self cssValueForTextAlignment:self.label.textAlignment];
    color = [self cssValueForColor:self.label.textColor];
    self.cssStyle = [NSString stringWithFormat:@"color: %@; font-size: %fpx; font-family: %@; text-align: %@", color, self.label.font.pointSize, self.label.font.familyName, textAlign];
}

- (NSString *)cssValueForTextAlignment:(NSTextAlignment)alignment
{
    switch (alignment)
    {
        case NSTextAlignmentLeft:
            return @"left";
            break;
            
        case NSTextAlignmentRight:
            return @"right";
            break;
            
        case NSTextAlignmentJustified:
            return @"justify";
            break;
            
        case NSTextAlignmentCenter:
        case NSTextAlignmentNatural:
            return @"center";
            break;
    }
}

- (NSString *)cssValueForColor:(UIColor *)color
{
    NSString *value;
    CGFloat red, green, blue;
    
    [color getRed:&red green:&green blue:&blue alpha:NULL];
    value = [NSString stringWithFormat:@"#%02X%02X%02X", (unsigned)round(red*255), (unsigned)round(green*255), (unsigned)round(blue*255)];
    
    return value;
}

- (void)removeSubtitles
{
    self.subtitles = nil;
    self.currentText = nil;
    [self updateLabel];
}

- (ASBSubtitle *)lastSubtitleAtTime:(NSTimeInterval)time
{
    ASBSubtitle *subtitle;
    NSMutableArray *candidates;
    
    candidates = [NSMutableArray new];
    for(ASBSubtitle *candidate in self.subtitles)
    {
        if(candidate.startTime <= time && candidate.stopTime >= time)
        {
            [candidates addObject:candidate];
        }
    }
    
    subtitle = candidates.lastObject;
    
    return subtitle;
}

- (void)setVisible:(BOOL)visible
{
    _visible = visible;
    self.label.hidden = !visible;
    self.containerView.hidden = !visible;
}

#pragma mark - Private
+ (CGFloat)nominalFrameRateForPlayer:(AVPlayer *)player
{
    AVAssetTrack *track = nil;
    NSArray *tracks;
    
    tracks = [player.currentItem.asset tracksWithMediaType:AVMediaTypeVideo];
    if(tracks.count > 0)
    {
        track = tracks[0];
    }
    
    return track.nominalFrameRate;
}

- (void)loadSRTContent:(NSString *)string error:(NSError **)error
{
    NSScanner *scanner;
    
    scanner = [NSScanner scannerWithString:string];
    self.subtitles = [NSMutableArray new];
    
    while (!scanner.isAtEnd)
    {
        ASBSubtitle *subtitle;
        NSInteger index;
        NSString *startString;
        NSString *endString;
        NSString *text = @"";
        NSString *line;
        BOOL endScanningText;
        
        scanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        [scanner scanInteger:&index];
        [scanner scanUpToString:@"-->" intoString:&startString];
        [scanner scanString:@"-->" intoString:NULL];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&endString];
        scanner.charactersToBeSkipped = nil;
        [scanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
        do {
            endScanningText = ![scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
            if(!endScanningText)
            {
                line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                text = [text stringByAppendingFormat:@"%@%@", (text.length > 0?@"\n":@""), line];
                [scanner scanUpToString:@"\n" intoString:NULL];
                [scanner scanString:@"\n" intoString:NULL];
            }
        } while (!endScanningText);
        
        subtitle = [ASBSubtitle new];
        subtitle.text = text;
        subtitle.startTime = [self timeFromString:startString];
        subtitle.stopTime = [self timeFromString:endString];
        subtitle.index = index;

        [self.subtitles addObject:subtitle];
    }

    if(error != NULL)
    {
        *error = nil;
    }
    [self setupTimeObserver];
}

- (NSTimeInterval)timeFromString:(NSString *)timeString
{
    NSScanner *scanner;
    NSInteger hours;
    NSInteger minutes;
    NSInteger seconds;
    NSInteger milliseconds;
    NSTimeInterval time;
    
    scanner = [NSScanner scannerWithString:timeString];
    
    [scanner scanInteger:&hours];
    [scanner scanString:@":" intoString:NULL];
    [scanner scanInteger:&minutes];
    [scanner scanString:@":" intoString:NULL];
    [scanner scanInteger:&seconds];
    [scanner scanString:@"," intoString:NULL];
    [scanner scanInteger:&milliseconds];
    
    time = hours*3600 + minutes*60 + seconds + milliseconds/1000.0;
    
    return time;
}

- (BOOL)isHTML:(NSString *)text
{
    NSRange range;
    
    range = [text rangeOfString:@"<"];
    
    return range.location != NSNotFound;
}

- (NSAttributedString *)attribuedStringFromHTMLText:(NSString *)text
{
    NSAttributedString *attributedString;
    NSDictionary *options;
    NSError *error;
    NSString *html;
    NSString *body;
    
    body = [text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"</br>"];
    body = [body stringByReplacingOccurrencesOfString:@"\n" withString:@"</br>"];
    html = [NSString stringWithFormat:@"<body style=\"%@\">%@</body>", self.cssStyle, body];
    
    options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)};
    
    attributedString = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:options
                                             documentAttributes:nil
                                                          error:&error];
    
    if(error != nil)
    {
        NSLog(@"%@", error);
    }
    
    return attributedString;
}

- (void)updateLabel
{
    if(self.currentText != nil)
    {
        if([self isHTML:self.currentText])
        {
            self.label.attributedText = [self attribuedStringFromHTMLText:self.currentText];
        }
        else
        {
            self.label.text = self.currentText;
        }
    }
    else
    {
        self.label.attributedText = nil;
        self.label.text = nil;
    }
    
    self.label.hidden = (self.currentText.length == 0) || !self.visible;
    self.containerView.hidden = self.label.hidden;
}

- (void)playerTimeChanged
{
    NSTimeInterval nbSecondsElapsed;
    ASBSubtitle *subtitle;
    
    if(self.player.currentItem == nil)
        return;
    
    nbSecondsElapsed = CMTimeGetSeconds(self.player.currentItem.currentTime);
    subtitle = [self lastSubtitleAtTime:nbSecondsElapsed];
    if(([subtitle.text isEqualToString:self.currentText]) || (subtitle.text == self.currentText))
        return;
    
    self.currentText = subtitle.text;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateLabel];
    });
}

#pragma Time Observer
- (void)removeTimeObserver
{
    if(self.timeObserver != nil)
    {
        [self.player removeTimeObserver:self.timeObserver];
    }
    self.timeObserver = nil;
}

- (void)setupTimeObserver
{
    __weak ASBPlayerSubtitling *weakSelf;
    
    if(self.timeObserver != nil)
        return;
    
    weakSelf = self;
    if(self.nbFramesPerSecond > 0)
    {
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(MAX(1/self.nbFramesPerSecond, 0.25), NSEC_PER_SEC)
                                                                      queue:self.queue
                                                                 usingBlock:^(CMTime time) {
                                                                     [weakSelf playerTimeChanged];
                                                                 }];
    }
}

@end
