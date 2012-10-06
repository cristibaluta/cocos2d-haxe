/** There are 4 types of Director.
 - kCCDirectorTypeNSTimer (default)
 - kCCDirectorTypeMainLoop
 - kCCDirectorTypeThreadMainLoop
 - kCCDirectorTypeDisplayLink
 
 Each Director has it's own benefits, limitations.
 If you are using SDK 3.1 or newer it is recommed to use the DisplayLink director
 
 This method should be called before any other call to the director.
 
 It will return NO if the director type is kCCDirectorTypeDisplayLink and the running SDK is < 3.1. Otherwise it will return YES.
 
 @since v0.8.2
 */
import CCDirector;
import CCTouchDelegateProtocol;
import CCTouchDispatcher;
import CCScheduler;
import CCActionManager;
import CCTextureCache;
import CCMacros;
import CCScene;
import CCLayer;

// support imports
using support.CGPointExtension;

#if CC_ENABLE_PROFILERS
import support.CCProfiling;
#end

enum CC_DeviceOrientation {
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
	/** Will use a Director that triggers the main loop from an Timer object
	 *
	 * Features and Limitations:
	 * - Integrates OK with UIKit objects
	 * - It the slowest director
	 * - The invertal update is customizable from 1 to 60
	 */
	kCCDirectorTypeTimer;
	
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
typedef kCCDirectorTypeDefault = kCCDirectorTypeTimer;


class CCDirectorNME extends CCDirector {

// Director - global variables (optimization)
static var __ccContentScaleFactor :Float = 1;
	
public static function defaultDirector () :Class<CCDirector>
{
	return CCDirectorTimer;
}

public static function setDirectorType ( type:CC_DirectorType ) :Bool
{
	if( type == kCCDirectorTypeDisplayLink ) {
		var reqSysVer :String = "10.0";
		var currSysVer :String = flash.system.Capabilities.version;
		
		if(Std.parseFloat(currSysVer) < Std.parseFloat(reqSysVer))
			return false;
	}
	switch (type) {
		case CCDirectorTypeNSTimer: CCDirectorTimer.sharedDirector();
		case CCDirectorTypeDisplayLink: CCDirectorDisplayLink.sharedDirector();
		case CCDirectorTypeMainLoop: CCDirectorFast.sharedDirector();
		case CCDirectorTypeThreadMainLoop: CCDirectorFastThreaded.sharedDirector();
		default: throw "Unknown director type";
	}
	
	return true;
}

override public function init () :CCDirector
{  
	super.init();
	
	// portrait mode default
	deviceOrientation_ = CCDeviceOrientationPortrait;
	
	__ccContentScaleFactor = 1;
	isContentScaleSupported_ = false;
	
	// running thread is main thread on iOS
	runningThread_ = NSThread.currentThread;
	
	return this;
}

override public function release () :Void
{	
	super.release();
}

//
// Draw the Scene
//
public function drawScene () :Void
{    
	/* calculate "global" dt */
	this.calculateDeltaTime;
	
	/* tick before glClear: issue #533 */
	if( ! isPaused_ ) {
		CCScheduler.sharedScheduler().tick(dt);	
	}
	
	//glClear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	
	/* to avoid flickr, nextScene MUST be here: after tick and before draw.
	 XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
	if( nextScene_ )
		this.setNextScene;
	
	//glPushMatrix();
	
	this.applyOrientation;
	
	// By default enable VertexArray, ColorArray, TextureCoordArray and Texture2D
	CC_ENABLE_DEFAULT_GL.STATES();
	
	/* draw the scene */
	runningScene_.visit();
	
	/* draw the notification node */
	notificationNode_.visit();

	if( displayFPS_ )
		this.showFPS;
	
#if CC_ENABLE_PROFILERS
	this.showProfilers;
#end
	
	CC_DISABLE_DEFAULT_GL.STATES();
	
	glPopMatrix();
	
	totalFrames_++;

	view_.swapBuffers;	
}

public function setProjection ( projection:CC_DirectorProjection )
{
	var size:CGSize = winSizeInPixels_;
	
/*	switch (projection) {
		case kCCDirectorProjection2D:
			glViewport(0, 0, size.width, size.height);
			glMatrixMode(GL.PROJECTION);
			glLoadIdentity();
			ccglOrtho(0, size.width, 0, size.height, -1024 * CCConfig.CC_CONTENT_SCALE_FACTOR, 1024 * CCConfig.CC_CONTENT_SCALE_FACTOR);
			glMatrixMode(GL.MODELVIEW);
			glLoadIdentity();
			break;
			
		case kCCDirectorProjection3D:
		{
			var zeye :float = this.getZEye;

			glViewport(0, 0, size.width, size.height);
			glMatrixMode(GL.PROJECTION);
			glLoadIdentity();
//			gluPerspective(60, (GLfloat)size.width/size.height, zeye-size.height/2, zeye+size.height/2 );
			gluPerspective(60, (GLfloat)size.width/size.height, 0.5, 1500);

			glMatrixMode(GL.MODELVIEW);	
			glLoadIdentity();
			gluLookAt( size.width/2, size.height/2, zeye,
					  size.width/2, size.height/2, 0,
					  0.0, 1.0, 0.0);
			break;
		}
			
		case kCCDirectorProjectionCustom:
			if( projectionDelegate_ )
				projectionDelegate_.updateProjection;
			break;
			
		default:
			trace("cocos2d: Director: unrecognized projecgtion");
			break;
	}*/
	
	projection_ = projection;
}

// Director Integration with a UIKit view

public function setView (view:Sprite)
{
	if( view != view_ ) {

		super.setView ( view );

		// set size
		winSizeInPixels_ = new CGSize(winSizeInPoints_.width * __ccContentScaleFactor, winSizeInPoints_.height *__ccContentScaleFactor);
		
		if( __ccContentScaleFactor != 1 )
			this.updateContentScaleFactor();
		
		var touchDispatcher :CCTouchDispatcher = CCTouchDispatcher.sharedDispatcher();
		view_.setTouchDelegate ( touchDispatcher );
		touchDispatcher.setDispatchEvents ( true );
	}
}

// Director - Retina Display

public function contentScaleFactor () :Float
{
	return __ccContentScaleFactor;
}

public function setContentScaleFactor ( scaleFactor:Float )
{
	if( scaleFactor != __ccContentScaleFactor ) {
		
		__ccContentScaleFactor = scaleFactor;
		winSizeInPixels_ = new CGSize( winSizeInPoints_.width * scaleFactor, winSizeInPoints_.height * scaleFactor );
		
		if( view_ )
			this.updateContentScaleFactor;
		
		// update projection
		this.setProjection ( projection_ );
	}
}

public function updateContentScaleFactor () :Void
{
	// Based on code snippet from: http://developer.apple.com/iphone/prerelease/library/snippets/sp2010/sp28.html
	if (Reflect.isFunction (view_.setContentScaleFactor))
	{			
		view_.setContentScaleFactor ( __ccContentScaleFactor );
		
		isContentScaleSupported_ = true;
	}
	else
		trace("cocos2d: 'setContentScaleFactor:' is not supported on this device");
}

public function enableRetinaDisplay ( enabled:Bool ) :Bool
{
	// Already enabled ?
	if( enabled && __ccContentScaleFactor == 2 )
		return true;
	
	// Already disabled
	if( ! enabled && __ccContentScaleFactor == 1 )
		return true;

	// setContentScaleFactor is not supported
	if (! Reflect.isFunction (view_.setContentScaleFactor) )
		return false;

	var newScale :Int = enabled ? 2 : 1;
	this.setContentScaleFactor ( newScale );
	
	return true;
}

// overriden, don't call super
public function reshapeProjection ( size:CGSize )
{
	winSizeInPoints_ = view_.bounds.size;
	winSizeInPixels_ = new CGSize (winSizeInPoints_.width * __ccContentScaleFactor, winSizeInPoints_.height * __ccContentScaleFactor);
	
	this.setProjection ( projection_ );
}

/*
public function convertToGL ( uiPoint:CGPoint ) :CGPoint
{
	s:CGSize = winSizeInPoints_;
	var newY :float = s.height - uiPoint.y;
	var newX :float = s.width - uiPoint.x;
	
	ret:CGPoint = new CGPoint(0,0);
	switch ( deviceOrientation_) {
		case CCDeviceOrientationPortrait:
			ret = new CGPoint ( uiPoint.x, newY );
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			ret = new CGPoint (newX, uiPoint.y);
			break;
		case CCDeviceOrientationLandscapeLeft:
			ret.x = uiPoint.y;
			ret.y = uiPoint.x;
			break;
		case CCDeviceOrientationLandscapeRight:
			ret.x = newY;
			ret.y = newX;
			break;
	}
	return ret;
}

public function convertToUI ( glPoint:CGPoint ) :CGPoint
{
	winSize:CGSize = winSizeInPoints_;
	var oppositeX :Int = winSize.width - glPoint.x;
	var oppositeY :Int = winSize.height - glPoint.y;
	uiPoint:CGPoint = new CGPoint(0,0);
	switch ( deviceOrientation_) {
		case CCDeviceOrientationPortrait:
			uiPoint = new CGPoint (glPoint.x, oppositeY);
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			uiPoint = new CGPoint (oppositeX, glPoint.y);
			break;
		case CCDeviceOrientationLandscapeLeft:
			uiPoint = new CGPoint (glPoint.y, glPoint.x);
			break;
		case CCDeviceOrientationLandscapeRight:
			// Can't use oppositeX/Y because x/y are flipped
			uiPoint = new CGPoint (winSize.width-glPoint.y, winSize.height-glPoint.x);
			break;
	}
	return uiPoint;
}*/

// get the current size of the glview
public function winSize () :CGSize
{
	var s:CGSize = winSizeInPoints_;
	
	if( deviceOrientation_ == CCDeviceOrientationLandscapeLeft || deviceOrientation_ == CCDeviceOrientationLandscapeRight ) {
		// swap x,y in landscape mode
		var tmp:CGSize = s;
		s.width = tmp.height;
		s.height = tmp.width;
	}
	return s;
}

public function winSizeInPixels () :CGSize
{
	var s:CGSize = this.winSize();
	
	s.width *= CCConfig.CC_CONTENT_SCALE_FACTOR;
	s.height *= CCConfig.CC_CONTENT_SCALE_FACTOR;
	
	return s;
}

public function deviceOrientation () :CC_DeviceOrientation
{
	return deviceOrientation_;
}

public function setDeviceOrientation (orientation:CC_DeviceOrientation) :Void
{
	if( deviceOrientation_ != orientation ) {
		deviceOrientation_ = orientation;
/*		switch( deviceOrientation_) {
			case CCDeviceOrientationPortrait:
				UIApplication.sharedApplication().setStatusBarOrientation: UIInterfaceOrientationPortrait animated ( false );
				break;
			case CCDeviceOrientationPortraitUpsideDown:
				UIApplication.sharedApplication().setStatusBarOrientation: UIInterfaceOrientationPortraitUpsideDown animated ( false );
				break;
			case CCDeviceOrientationLandscapeLeft:
				UIApplication.sharedApplication().setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated ( false );
				break;
			case CCDeviceOrientationLandscapeRight:
				UIApplication.sharedApplication().setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft animated ( false );
				break;
			default:
				trace("Director: Unknown device orientation");
				break;
		}*/
	}
}

public function applyOrientation () :Void
{	
	var s :CGSize = winSizeInPixels_;
	var w :Float = s.width / 2;
	var h :Float = s.height / 2;
	
	// XXX it's using hardcoded values.
	// What if the the screen size changes in the future?
	switch ( deviceOrientation_ ) {
		case CCDeviceOrientationPortrait:
			// nothing
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			// upside down
			glTranslatef(w,h,0);
			glRotatef(180,0,0,1);
			glTranslatef(-w,-h,0);
			break;
		case CCDeviceOrientationLandscapeRight:
			glTranslatef(w,h,0);
			glRotatef(90,0,0,1);
			glTranslatef(-h,-w,0);
			break;
		case CCDeviceOrientationLandscapeLeft:
			glTranslatef(w,h,0);
			glRotatef(-90,0,0,1);
			glTranslatef(-h,-w,0);
			break;
	}	
}

override public function end () :Void
{
	// don't release the event handlers
	// They are needed in case the director is run again
	CCTouchDispatcher.sharedDispatcher().removeAllDelegates();
	
	super.end();
}

}


}
