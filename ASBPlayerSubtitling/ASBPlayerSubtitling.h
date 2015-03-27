//
//  ASBPlayerSubtitling.h
//  ASBPlayerSubtitling
//
//  Created by Philippe Converset on 25/03/2015.
//  Copyright (c) 2015 AutreSphere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ASBSubtitle : NSObject
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval stopTime;
@property (nonatomic, copy) NSString *text;
@end

@interface ASBPlayerSubtitling : NSObject

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) BOOL visible;

- (void)loadSubtitlesAtURL:(NSURL *)url error:(NSError **)error;
- (void)loadSRTContent:(NSString *)string error:(NSError **)error;
- (void)removeSubtitles;

- (ASBSubtitle *)lastSubtitleAtTime:(NSTimeInterval)time;

@end
