//
//  ViewController.m
//  Example
//
//  Created by Philippe Converset on 25/03/2015.
//  Copyright (c) 2015 AutreSphere. All rights reserved.
//

#import "ViewController.h"
#import "ASBPlayerSubtitling.h"
#import <AVFoundation/AVFoundation.h>
#import <ASBPlayerScrubbing/ASBPlayerScrubbing.h>

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIView *playerView;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (strong, nonatomic) IBOutlet ASBPlayerScrubbing *scrubbing;
@property (strong, nonatomic) IBOutlet ASBPlayerSubtitling *subtitling;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupPlayer];
    [self setupSlider];
}

- (void)setupPlayer
{
    AVPlayer *player;
    NSURL *url;
    NSURL *subtitlesURL;
    NSError *error;
    
    url = [NSURL URLWithString:@"http://mirror.cessen.com/blender.org/peach/trailer/trailer_iphone.m4v"];
    
    player = [AVPlayer playerWithURL:url];
    
    self.playerLayer = [AVPlayerLayer layer];
    self.playerLayer.contentsGravity = kCAGravityResizeAspect;
    self.playerLayer.player = player;
    [self.playerView.layer addSublayer:self.playerLayer];
    
    [player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    
    self.scrubbing.player = player;
    
    subtitlesURL = [[NSBundle mainBundle] URLForResource:@"welcome" withExtension:@"srt"];
    self.subtitling.player = player;
    [self.subtitling loadSubtitlesAtURL:subtitlesURL error:&error];
    self.subtitling.containerView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    
    [player play];
}

- (void)setupSlider
{
    [self.slider setThumbImage:[UIImage imageNamed:@"sliderThumb"] forState:UIControlStateNormal];
}

- (void)viewDidLayoutSubviews
{
    self.playerLayer.frame = self.playerView.bounds;
}

#pragma mark - Actions
- (IBAction)switchTimeLabel:(id)sender
{
    self.remainingTimeLabel.hidden = !self.remainingTimeLabel.hidden;
    self.durationLabel.hidden = !self.remainingTimeLabel.hidden;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVPlayer *player = object;
    
    self.playPauseButton.selected = (player.rate != 0);
}
@end
