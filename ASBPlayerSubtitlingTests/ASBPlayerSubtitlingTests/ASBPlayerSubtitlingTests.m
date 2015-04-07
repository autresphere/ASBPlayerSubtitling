//
//  ASBPlayerSubtitlingTests.m
//  ASBPlayerSubtitlingTests
//
//  Created by Philippe Converset on 07/04/2015.
//  Copyright (c) 2015 AutreSphere. All rights reserved.
//

#import "ASBPlayerSubtitling.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSString * const kVideoPath = @"http://mirror.cessen.com/blender.org/peach/trailer/trailer_iphone.m4v";

@interface ASBPlayerSubtitlingTests : XCTestCase

@end

@implementation ASBPlayerSubtitlingTests

- (ASBPlayerSubtitling *)defaultSubtitling
{
    AVPlayer *player;
    NSURL *url;
    NSError *error;
    ASBPlayerSubtitling *subtitling;
    
    // Duration
    url = [NSURL URLWithString:kVideoPath];
    player = [AVPlayer playerWithURL:url];
    
    subtitling = [ASBPlayerSubtitling new];
    subtitling.player = player;
    
    url = [[NSBundle mainBundle] URLForResource:@"welcome" withExtension:@"srt"];
    [subtitling loadSubtitlesAtURL:url error:&error];
    XCTAssertNil(error);
    
    return subtitling;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNilURL
{
    ASBPlayerSubtitling *subtitling;
    NSError *error;
    
    subtitling = [ASBPlayerSubtitling new];
    [subtitling loadSubtitlesAtURL:nil error:&error];
    XCTAssertNotNil(error);
}

- (void)testLoadSubtitlesFromURL
{
    ASBPlayerSubtitling *subtitling;
    NSURL *url;
    NSError *error;
    
    subtitling = [ASBPlayerSubtitling new];
    url = [[NSBundle bundleForClass:[self class]] URLForResource:@"welcome" withExtension:@"srt"];
    XCTAssertNotNil(url);
    [subtitling loadSubtitlesAtURL:url error:&error];
    XCTAssertNil(error);
}

- (void)testLoadSeveralTitles
{
    ASBPlayerSubtitling *subtitling;
    NSError *error;
    NSString *content;
    ASBSubtitle *subtitle;
    
    subtitling = [ASBPlayerSubtitling new];
    content = @"1\n00:00:00,000 --> 00:00:03,000\nFirst\n\n2\n00:00:04,000 --> 00:00:05,000\nSecond";
    [subtitling loadSRTContent:content error:&error];
    XCTAssertNil(error);
    subtitle = [subtitling lastSubtitleAtTime:2];
    XCTAssert([subtitle.text isEqualToString:@"First"]);
    XCTAssert(subtitle.startTime == 0);
    XCTAssert(subtitle.stopTime == 3);
    
    subtitle = [subtitling lastSubtitleAtTime:5];
    XCTAssert([subtitle.text isEqualToString:@"Second"]);
    XCTAssert(subtitle.startTime == 4);
    XCTAssert(subtitle.stopTime == 5);
}

@end
