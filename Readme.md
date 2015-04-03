

Purpose
-------
ASBPlayerSubtitling is an Objective-C library for easily adding subtitle behavior to your AVPlayer on iOS.

Using ASBPlayerSubtitling requires only to link your player and a subtitle label to it. Then, you can load a subtitle file, ASBPlayerScrubbing will automatically show the subtitle for the current time.

For now, only SRT format is suported. SRT is the main subtitle file format.

If you use a container view to add border to your subtitle label, you must wire this container view to the corresponding ASBPlayerSubtitling outlet, such that the container view is hidden when no subtitle is shown.

![](https://github.com/autresphere/ASBPlayerSubtitling/raw/master/Screenshots/styling.jpg) 

Example
-------
See the contained example to get a sample of ASBPlayerSubtitling created with Interface Builder.

To build the example, you first need to run ```pod install``` from inside the ```Example``` directory.

![](https://github.com/autresphere/ASBPlayerSubtitling/raw/master/Screenshots/example1.jpg) 

Behavior class
--------------
ASBPlayerSubtitling is a **pure behavior** class, it does not come with any graphical component. 

This means you are supposed to already have your own ```AVPlayer``` and ```UILabel```.

As ASBPlayerSubtitling is a pure behavior, it is highly reusable whatever your UI is made of.

Features
--------
* Support full SRT format with styling (bold, italic, underline, text color)
* Update subtitle label depending on player time

Using
-----
Add `pod 'ASBPlayerSubtitling'` to your Podfile or copy ASBPlayerSubtitling.h and ASBPlayerSubtitling.m in your project.

You can either create a ASBPlayerSubtitling by code or inside Interface Builder.

Creating with Interface Builder
-------------------------------
Inside InterfaceBuilder, add an object to your nib or storyboard, and set its class to ```ASBPlayerSubtitling```. Create an outlet inside your ViewController which links to the ```ASBPlayerSubtitling``` object. Then link your label to the corresponding ```ASBPlayerSubtitling``` label outlet.

In your ViewController ```viewDidLoad``` method, you still need to set your player to the ```ASBPlayerSubtitling``` player property.
```objc
self.subtitling.player = player;
[self.subtitling loadSubtitlesAtURL:subtitlesURL error:nil];
```

NOTE: It is mandatory to creating an outlet inside your ViewController to keep track of the ```ASBPlayerSubtitling``` object. This ensures the object won't be released.

Creating by code
----------------
Simply create a ASBPlayerSubtitling and set your player and your label.
```objc
self.subtitling = [ASBPlayerSubtitling new];
self.subtitling.player = player;
self.subtitling.label = subtitleLabel;
[self.subtitling loadSubtitlesAtURL:subtitlesURL error:nil];
```

Supported iOS
-------------
iOS 7 and above.

ARC Compatibility
-----------------
ASBPlayerSubtitling requires ARC. If you wish to use ASBPlayerSubtitling in a non-ARC project, just add the -fobjc-arc compiler flag to the ASBPlayerSubtitling.m class. To do this, go to the Build Phases tab in your target settings, open the Compile Sources group, double-click ASBPlayerSubtitling.m in the list and type -fobjc-arc into the popover.

Todo
----
* Optimize subtitle search
* Support other subtitle formats

Recommended reading
-------------------
SRT format: http://www.visualsubsync.org/help/srt

If you want to known more about behaviors:
* Chris Eidhof on Intentions http://chris.eidhof.nl/posts/intentions.html
* Krzysztof Zabłocki on Behaviors http://www.objc.io/issue-13/behaviors.html

Licence
-------
ASBPlayerSubtitling is available under the MIT license.

Author
------
Philippe Converset, AutreSphere - pconverset@autresphere.com

[@Follow me on Twitter](http://twitter.com/autresphere)
