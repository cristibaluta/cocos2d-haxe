/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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


// Only compile this code on Mac. These files should not be included on your iOS project.
// But in case they are included, it won't be compiled.
package platforms.flash;

import flash.display.MovieClip;
import CCDirector;
import platforms.flash.CCEventDispatcher;
import platforms.flash.FlashView;
import CCNode;
import CCScheduler;
import CCMacros;
import objc.CGPoint;
import objc.CGSize;
import objc.CGRect;
using support.CGRectExtension;
using support.CGSizeExtension;


enum CC_DirectorResize {
	/// If the window is resized, it won't be autoscaled
	kCCDirectorResize_NoScale;
	/// If the window is resized, it will be autoscaled (default behavior)
	kCCDirectorResize_AutoScale;
}

/** Base class of Mac directors
 @since v0.99.5
 */
class CCDirectorFlash extends CCDirector
{
var isFullScreen_ :Bool;
var resizeMode_ :CC_DirectorResize;
var winOffset_ :CGPoint;
var originalWinSize_ :CGSize;

var fullScreenWindow_ :MovieClip;
var windowView_ :MovieClip;
var superView_ :FlashView;
var originalWinRect_ :CGRect; // Original size and position

public var isFullScreen (get_isFullScreen, setFullScreen) :Bool;
public var originalWinSize (get_originalWinSize, set_originalWinSize) :CGSize;
// resize mode: with or without scaling
public var resizeMode (get_resizeMode, set_resizeMode) :CC_DirectorResize;


override public function init () :CCDirector
{
	trace("init");
	super.init();
	
	flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
	flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
	
	isFullScreen_ = false;
	resizeMode_ = kCCDirectorResize_AutoScale;
	
	originalWinSize_ = new CGSize();
	fullScreenWindow_ = null;
	windowView_ = null;
	winOffset_ = new CGPoint();
	
	return this;
}

override public function release()
{
    superView_.release();
	fullScreenWindow_.release();
	windowView_.release();
	super.release();
}

//
// setFullScreen code taken from GLFullScreen example by Apple
//
public function setFullScreen (fullscreen:Bool) :Bool
{
	
/*	
    if (isFullScreen_ == fullscreen) return;
    
    if( fullscreen ) {
        originalWinRect_ = [openGLView_ frame];

        // Cache normal window and superview of openGLView
        if(!windowView_)
            windowView_ = [[openGLView_ window] retain];
        
        [superViewGLView_ release];
        superViewGLView_ = [[openGLView_ superview] retain];
        
                              
        // Get screen size
        NSRect displayRect = [[NSScreen mainScreen] frame];
        
        // Create a screen-sized window on the display you want to take over
        fullScreenWindow_ = [[MacWindow alloc] initWithFrame:displayRect fullscreen:YES];
        
        // Remove glView from window
        [openGLView_ removeFromSuperview];
        
        // Set new frame
        [openGLView_ setFrame:displayRect];
        
        // Attach glView to fullscreen window
        [fullScreenWindow_ setContentView:openGLView_];
        
        // Show the fullscreen window
        [fullScreenWindow_ makeKeyAndOrderFront:self];
		[fullScreenWindow_ makeMainWindow];
        
    } else {
        
        // Remove glView from fullscreen window
        [openGLView_ removeFromSuperview];
        
        // Release fullscreen window
        [fullScreenWindow_ release];
        fullScreenWindow_ = null;
        
        // Attach glView to superview
        [superViewGLView_ addSubview:openGLView_];
        
        // Set new frame
        [openGLView_ setFrame:originalWinRect_];
        
        // Show the window
        [windowView_ makeKeyAndOrderFront:self];
		[windowView_ makeMainWindow];
    }
    isFullScreen_ = fullscreen;
    // re-configure glView
    setView(view_);
    view_.setNeedsDisplay(true);
*/
	return false;
}
public function get_isFullScreen () :Bool
{
	return isFullScreen_;
}

override public function setView (v:CC_VIEW) :CC_VIEW
{
	trace("setView "+v);
	super.setView ( v );
	
	// cache the NSWindow and NSOpenGLView created from the NIB
	if( !isFullScreen_ && originalWinSize_.equalToSize(new CGSize()))
    {
		originalWinSize_ = winSizeInPixels_;
	}
	return view;
}

public function get_originalWinSize () :CGSize
{
	return originalWinSize_;
}
public function set_originalWinSize (s:CGSize) :CGSize
{
	return originalWinSize_ = s;
}


public function get_resizeMode () :CC_DirectorResize
{
	return resizeMode_;
}

public function set_resizeMode (mode:CC_DirectorResize) :CC_DirectorResize
{
	if( mode != resizeMode_ ) {

		resizeMode_ = mode;

        this.setProjection (projection_);
        view_.setNeedsDisplay (true);
	}
	return resizeMode_;
}


//
// Draw the Scene
//
override public function drawScene ()
{
	/* calculate "global" dt */
	calculateDeltaTime();
	
	/* tick before glClear: issue #533 */
	if( ! isPaused_ ) {
		CCScheduler.sharedScheduler().tick ( dt );
	}
	
	//glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	/* to avoid flickr, nextScene MUST be here: after tick and before draw.
	 XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
	if( nextScene_ != null )
		setNextScene();
	
	//glPushMatrix();
	
	//applyOrientation();
	
	// By default enable VertexArray, ColorArray, TextureCoordArray and Texture2D
	//CC_ENABLE_DEFAULT_GL_STATES();
	
	/* draw the scene */
	runningScene_.visit();
	
	/* draw the notification node */
	//notificationNode_.visit();

	if( displayFPS_ )
		showFPS();
	
#if CC_ENABLE_PROFILERS
	showProfilers();
#end
	
	//CC_DISABLE_DEFAULT_GL_STATES();
	
	//glPopMatrix();
	
	totalFrames_++;

	//view_.swapBuffers();
}


override public function setProjection(projection:CC_DirectorProjection) :CC_DirectorProjection
{
	//trace("setprojection "+projection);
	var size :CGSize = winSizeInPixels_;
	
	var offset :CGPoint = new CGPoint();
	var widthAspect = size.width;
	var heightAspect = size.height;
	
	
	if( resizeMode_ == kCCDirectorResize_AutoScale && ! originalWinSize_.equalToSize( new CGSize() ) ) {
		
		size = originalWinSize_;

		var aspect = originalWinSize_.width / originalWinSize_.height;
		widthAspect = winSizeInPixels_.width;
		heightAspect = winSizeInPixels_.width / aspect;
		
		if( heightAspect > winSizeInPixels_.height ) {
			widthAspect = winSizeInPixels_.height * aspect;
			heightAspect = winSizeInPixels_.height;
		}
		
		winOffset_.x = (winSizeInPixels_.width - widthAspect) / 2;
		winOffset_.y =  (winSizeInPixels_.height - heightAspect) / 2;
		
		offset = winOffset_;

	}

	switch (projection) {
		case kCCDirectorProjection2D:
/*			glViewport(offset.x, offset.y, widthAspect, heightAspect);
			glMatrixMode(GL.PROJECTION);
			glLoadIdentity();
			ccglOrtho(0, size.width, 0, size.height, -1024, 1024);
			glMatrixMode(GL.MODELVIEW);
			glLoadIdentity();*/
			
		case kCCDirectorProjection3D:
/*			glViewport(offset.x, offset.y, widthAspect, heightAspect);
			glMatrixMode(GL.PROJECTION);
			glLoadIdentity();
			gluPerspective(60, (GLfloat)widthAspect/heightAspect, 0.1f, 1500.0f);
			
			glMatrixMode(GL.MODELVIEW);	
			glLoadIdentity();
			
			float eyeZ = size.height * [self getZEye] / winSizeInPixels_.height;

			gluLookAt( size.width/2, size.height/2, eyeZ,
					  size.width/2, size.height/2, 0,
					  0.0f, 1.0f, 0.0f);*/
			
		case kCCDirectorProjectionCustom:
			if( projectionDelegate )
				projectionDelegate.updateProjection();
			
		default:
			trace("cocos2d: Director: unrecognized projection");
	}
	
	projection_ = projection;
	return projection_;
}

public function enableRetinaDisplay ( enabled:Bool ) :Bool
{
	// Already enabled ?
/*	if( enabled && __ccContentScaleFactor == 2 )
		return true;
	
	// Already disabled
	if( ! enabled && __ccContentScaleFactor == 1 )
		return true;

	// setContentScaleFactor is not supported
	if (! Reflect.isFunction (view_.setContentScaleFactor) )
		return false;

	var newScale :Int = enabled ? 2 : 1;
	this.setContentScaleFactor ( newScale );*/
	
	return true;
}


// If scaling is supported, then it should always return the original size
// otherwise it should return the "real" size.
override public function winSize () :CGSize
{
	if( resizeMode_ == kCCDirectorResize_AutoScale )
		return originalWinSize_;
    
	return winSizeInPixels_;
}

override public function winSizeInPixels () :CGSize
{
	return this.winSize();
}

/** Converts window size coordiantes to logical coordinates.
 Useful only if resizeMode is kCCDirectorResize_Scale.
 If resizeMode is kCCDirectorResize_NoScale, then no conversion will be done.
*/
public function convertToLogicalCoordinates (coords:CGPoint) :CGPoint
{
	var ret :CGPoint = null;
	
	if( resizeMode_ == kCCDirectorResize_NoScale )
		ret = coords;
	
	else {
	
		var x_diff = originalWinSize_.width / (winSizeInPixels_.width - winOffset_.x * 2);
		var y_diff = originalWinSize_.height / (winSizeInPixels_.height - winOffset_.y * 2);
		
		var adjust_x = (winSizeInPixels_.width * x_diff - originalWinSize_.width ) / 2;
		var adjust_y = (winSizeInPixels_.height * y_diff - originalWinSize_.height ) / 2;
		
		ret = new CGPoint( (x_diff * coords.x) - adjust_x, ( y_diff * coords.y ) - adjust_y );
	}
	
	return ret;
}

}
