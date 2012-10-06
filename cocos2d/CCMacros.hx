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
import CCConfig;
import CCTypes;
import objc.CGRect;

class CCMacros
{
inline public static var M_PI = Math.PI;
inline public static var M_PI_2 = Math.PI*2;


/** @def CC_SWAP
simple macro that swaps 2 variables
You have to extract them from the anonymous object
*/
inline public static function CC_SWAP( x, y ) :{x:Dynamic, y:Dynamic} {
 	return {x:y, y:x};
}

/** @def RANDOM_MINUS1_1
 returns a random Float between -1 and 1
 */
inline public static function RANDOM_MINUS1_1() :Float {
	return Math.random() * 2.0 - 1.0;
}

/** @def RANDOM_0_1
 returns a random Float between 0 and 1
 */
inline public static function RANDOM_0_1() :Float {
	return Math.random() * 1.0;
}

/** @def CC_DEGREES_TO_RADIANS
 converts degrees to radians
 */
inline public static function CC_DEGREES_TO_RADIANS(angle:Float) :Float {
	return angle * 0.01745329252; // PI / 180
}

/** @def CC_RADIANS_TO_DEGREES
 converts radians to degrees
 */
inline public static function CC_RADIANS_TO_DEGREES(angle:Float) :Float {
	return angle * 57.29577951; // PI * 180
}

/** @def CC_ENABLE_DEFAULT_GL.STATES
 GL states that are enabled:
	- GL.TEXTURE_2D
	- GL.VERTEX_ARRAY
	- GL.TEXTURE_COORD_ARRAY
	- GL.COLOR_ARRAY
 */
/*#define CC_ENABLE_DEFAULT_GL.STATES() {				\
	glEnableClientState(GL.VERTEX_ARRAY);			\
	glEnableClientState(GL.COLOR_ARRAY);			\
	glEnableClientState(GL.TEXTURE_COORD_ARRAY);	\
	glEnable(GL.TEXTURE_2D);						\
}

/** @def CC_DISABLE_DEFAULT_GL.STATES 
 Disable default GL states:
	- GL.TEXTURE_2D
	- GL.VERTEX_ARRAY
	- GL.TEXTURE_COORD_ARRAY
	- GL.COLOR_ARRAY
 */
/*#define CC_DISABLE_DEFAULT_GL.STATES() {			\
	glDisable(GL.TEXTURE_2D);						\
	glDisableClientState(GL.TEXTURE_COORD_ARRAY);	\
	glDisableClientState(GL.COLOR_ARRAY);			\
	glDisableClientState(GL.VERTEX_ARRAY);			\
}

/** @def CC_DIRECTOR_INIT
	- Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer.
	- The EAGLView view will have multiple touches disabled.
	- It will create a UIWindow and it will assign it the 'window' variable. 'window' must be declared before calling this marcro.
	- It will parent the EAGLView to the created window
	- If the firmware >= 3.1 it will create a Display Link Director. Else it will create an NSTimer director.
	- It will try to run at 60 FPS.
	- The FPS won't be displayed.
	- The orientation will be portrait.
	- It will connect the director with the EAGLView.

 IMPORTANT: If you want to use another type of render buffer (eg: RGBA8)
 or if you want to use a 16-bit or 24-bit depth buffer, you should NOT
 use this macro. Instead, you should create the EAGLView manually.
 
 @since v0.99.4
 */

/*#if ios

#define CC_DIRECTOR_INIT()																		\
do	{																							\
	window = new UIWindow().initWithFrame:[UIScreen.mainScreen] bounds]();					\
	if( ! CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )								\
		CCDirector.setDirectorType ( kCCDirectorTypeNSTimer );									\
	var __director :CCDirector = CCDirector.sharedDirector();										\
	[__director.setDeviceOrientation ( kCCDeviceOrientationPortrait );								\
	[__director.setDisplayFPS ( false );																\
	__director.setAnimationInterval:1.0/60();													\
	var __glView :EAGLView = EAGLView.viewWithFrame:window.bounds]								\
									pixelFormat:kEAGLColorFormatRGB565							\
									depthFormat:0 /* GL.DEPTH_COMPONENT24_OES */				
/*							 preserveBackbuffer:NO												\
									 sharegroup:null												\
								  multiSampling:NO												\
								numberOfSamples:0												\
													();											\
	[__director.setView ( __glView );														\
	[window.addSubview ( __glView );																\
	window.makeKeyAndVisible();																	\
} while(0)


#else __MAC_OS_X_VERSION_MAX_ALLOWED

import platforms.Mac/MacWindow;

#define CC_DIRECTOR_INIT(__WINSIZE__)															\
do	{																							\
	var frameRect :NSRect = NSMakeRect(0, 0, (__WINSIZE__).width, (__WINSIZE__).height);				\
	this.window = new MacWindow().initWithFrame ( frameRect,( false );					\
	this.glView = new MacGLView().initWithFrame ( frameRect, null );					\
	[this.window setContentView:this.glView();													\
	var __director :CCDirector = CCDirector.sharedDirector();										\
	[__director.setDisplayFPS ( false );																\
	__director.setView:this.glView();														\
	[(CCDirectorFlash*)__director.setOriginalWinSize ( __WINSIZE__ );								\
	[this.window makeMainWindow();																\
	[this.window.makeKeyAndOrderFront ( this );													\
} while(0)

#end

 
 /** @def CC_DIRECTOR_END
  Stops and removes the director from memory.
  Removes the EAGLView from its parent
  
  @since v0.99.4
  */
/*public static function CC_DIRECTOR_END() {
	var __director :CCDirector = CCDirector.sharedDirector();
	var __view = __director.view;
		__view.removeFromSuperview();
		__director.end();
}*/

#if CC_IS_RETINA_DISPLAY_SUPPORTED

/****************************/
/** RETINA DISPLAY ENABLED **/
/****************************/

/** @def CCConfig.CC_CONTENT_SCALE_FACTOR
 On Mac it returns 1;
 On iPhone it returns 2 if RetinaDisplay is On. Otherwise it returns 1
 */
/*import platforms.iOS/CCDirectorIOS;
#define CCConfig.CC_CONTENT_SCALE_FACTOR __ccContentScaleFactor


/** @def CC_RECT_PIXELS_TO_POINTS
 Converts a rect in pixels to points
 */
inline public static function CC_RECT_PIXELS_TO_POINTS (pixels:CGRect) :CGRect
{
	return new CGRect (	pixels.origin.x / CCConfig.CC_CONTENT_SCALE_FACTOR,
						pixels.origin.y / CCConfig.CC_CONTENT_SCALE_FACTOR,
						pixels.size.width / CCConfig.CC_CONTENT_SCALE_FACTOR,
						pixels.size.height / CCConfig.CC_CONTENT_SCALE_FACTOR );
}

/** @def CC_RECT_POINTS_TO_PIXELS
 Converts a rect in points to pixels
 */
inline public static function CC_RECT_POINTS_TO_PIXELS (points:CGRect) :CGRect
{
	return new CGRect (	points.origin.x * CCConfig.CC_CONTENT_SCALE_FACTOR,
						points.origin.y * CCConfig.CC_CONTENT_SCALE_FACTOR,
						points.size.width * CCConfig.CC_CONTENT_SCALE_FACTOR,
						points.size.height * CCConfig.CC_CONTENT_SCALE_FACTOR );
}

#else
/*****************************/
/** RETINA DISPLAY DISABLED **/
/*****************************/

inline public static function CC_RECT_PIXELS_TO_POINTS (pixels:CGRect) :CGRect { return pixels; }
inline public static function CC_RECT_POINTS_TO_PIXELS (points:CGRect) :CGRect { return points; }

#end // CC_IS_RETINA_DISPLAY_SUPPORTED

}
