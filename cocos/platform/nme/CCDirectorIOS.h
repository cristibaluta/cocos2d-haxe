/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
package cocos.platform.nme;

import cocos.CCDirector;

/** @typedef CC_eviceOrientation
 Possible device orientations
 */
enum CCDeviceOrientation {
	/// Device oriented vertically, home button on the bottom
	kCCDeviceOrientationPortrait = UIDeviceOrientationPortrait,	
	/// Device oriented vertically, home button on the top
    kCCDeviceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
	/// Device oriented horizontally, home button on the right
    kCCDeviceOrientationLandscapeLeft = UIDeviceOrientationLandscapeLeft,
	/// Device oriented horizontally, home button on the left
    kCCDeviceOrientationLandscapeRight = UIDeviceOrientationLandscapeRight,
	
	// Backward compatibility stuff
	CCDeviceOrientationPortrait = kCCDeviceOrientationPortrait,
	CCDeviceOrientationPortraitUpsideDown = kCCDeviceOrientationPortraitUpsideDown,
	CCDeviceOrientationLandscapeLeft = kCCDeviceOrientationLandscapeLeft,
	CCDeviceOrientationLandscapeRight = kCCDeviceOrientationLandscapeRight,
}

/** @typedef CC_irectorType
 Possible Director Types.
 @since v0.8.2
 */
enum CCDirectorType {
	/** Will use a Director that triggers the main loop from an NSTimer object
	 *
	 * Features and Limitations:
	 * - Integrates OK with UIKit objects
	 * - It the slowest director
	 * - The invertal update is customizable from 1 to 60
	 */
	kCCDirectorTypeNSTimer;
	
	/** will use a Director that triggers the main loop from a custom main loop.
	 *
	 * Features and Limitations:
	 * - Faster than NSTimer Director
	 * - It doesn't integrate well with UIKit objecgts
	 * - The interval update can't be customizable
	 */
	kCCDirectorTypeMainLoop;
	
	/** Will use a Director that triggers the main loop from a thread, but the main loop will be executed on the main thread.
	 *
	 * Features and Limitations:
	 * - Faster than NSTimer Director
	 * - It doesn't integrate well with UIKit objecgts
	 * - The interval update can't be customizable
	 */
	kCCDirectorTypeThreadMainLoop;
	
	/** Will use a Director that synchronizes timers with the refresh rate of the display.
	 *
	 * Features and Limitations:
	 * - Faster than NSTimer Director
	 * - Only available on 3.1+
	 * - Scheduled timers & drawing are synchronizes with the refresh rate of the display
	 * - Integrates OK with UIKit objects
	 * - The interval update can be 1/60, 1/30, 1/15
	 */	
	kCCDirectorTypeDisplayLink;
	
}
/** Default director is the NSTimer directory */
typedef kCCDirectorTypeDefault = kCCDirectorTypeNSTimer;


/** CCDirector extensions for iPhone
 */
@interface CCDirector (iOSExtension)

// rotates the screen if an orientation differnent than Portrait is used
-(void) applyOrientation;

/** Sets the device orientation.
 If the orientation is going to be controlled by an UIViewController, then the orientation should be Portrait
 */
public function setDeviceOrientation (orientation:CC_eviceOrientation) :Void

/** returns the device orientation */
-(CC_eviceOrientation) deviceOrientation;

/** The size in pixels of the surface. It could be different than the screen size.
 High-res devices might have a higher surface size than the screen size.
 In non High-res device the contentScale will be emulated.

 The recommend way to enable Retina Display is by using the "enableRetinaDisplay:(Bool)enabled" method.

 @since v0.99.4
 */
public function setContentScaleFactor (scaleFactor:Float) :Void

/** Will enable Retina Display on devices that supports it.
 It will enable Retina Display on iPhone4 and iPod Touch 4.
 It will return YES, if it could enabled it, otherwise it will return NO.
 
 This is the recommened way to enable Retina Display.
 @since v0.99.5
 */
public function enableRetinaDisplay (yes:Bool) :Bool {
	


/** returns the content scale factor */
-(Float) contentScaleFactor;
@end

@interface CCDirector (iOSExtensionClassMethods)


+(Bool) setDirectorType:(CC_irectorType) directorType;
@end

#pragma mark -
#pragma mark CCDirectorIOS

/** CCDirectorIOS: Base class of iOS directors
 @since v0.99.5
 */
@interface CCDirectorIOS : CCDirector
{
	/* orientation */
var deviceOrientation_ :CC_DeviceOrientation;
	
	/* contentScaleFactor could be simulated */
	var isContentScaleSupported_ :Bool;
	
}
@end


@interface CCDirectorFast : CCDirectorIOS
{
	var isRunning :Bool;
	
	var autoreleasePool :NSAutoreleasePool;
}
-(void) mainLoop;
@end


@interface CCDirectorFastThreaded : CCDirectorIOS
{
	var isRunning :Bool;	
}
-(void) mainLoop;
@end


@interface CCDirectorDisplayLink : CCDirectorIOS
{
	id displayLink;
}
public function mainLoop (sender:id) :Void
@end


@interface CCDirectorTimer : CCDirectorIOS
{
	var animationTimer :NSTimer;
}
-(void) mainLoop;
@end

// optimization. Should only be used to read it. Never to write it.
extern var __ccContentScaleFactor :Float;

#end // ios
