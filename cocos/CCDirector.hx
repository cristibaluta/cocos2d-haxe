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


/* Idea of decoupling Window from Director taken from OC3D project: http://code.google.com/p/oc3d/
 */
package cocos;

// cocos2d imports
import cocos.CCScheduler;
import cocos.action.CCActionManager;
import cocos.CCTextureCache;
import cocos.CCAnimationCache;
import cocos.CCLabelAtlas;
import cocos.CCMacros;
import cocos.CCScene;
import cocos.CCSpriteFrameCache;
import cocos.CCTexture2D;
import cocos.CCLabelBMFont;
import cocos.CCLayer;
import cocos.CCConfig;
import cocos.CCTypes;
import cocos.support.CGPoint;
import cocos.support.CGSize;
import cocos.support.CCProfiling;
using cocos.support.CCArrayExtension;

#if flash
	//typedef CC_DIRECTOR_DEFAULT = platform.flash.CCDirectorFlash;
	typedef CC_DIRECTOR_DEFAULT = cocos.platform.flash.CCDirectorDisplayLink;
	typedef CC_VIEW = cocos.platform.flash.FlashView;
#elseif nme
	typedef CC_DIRECTOR_DEFAULT = cocos.platform.nme.CCDirectorNME;
	typedef CC_VIEW = cocos.platform.nme.NMEView;
#elseif js
	typedef CC_DIRECTOR_DEFAULT = cocos.platform.js.CCDirectorJS;
	typedef CC_VIEW = cocos.platform.js.JSView;
#end

typedef CCProjectionProtocol = Dynamic;


/** @typedef CC_DirectorProjection
 Possible OpenGL projections used by director
 */
enum CC_DirectorProjection
{
	kCCDirectorProjection2D;/// sets a 2D projection (orthogonal projection).
	kCCDirectorProjection3D;/// sets a 3D projection with a fovy=60, znear=0.5 and zfar=1500.
	kCCDirectorProjectionCustom;/// it calls "updateProjection" on the projection delegate.
	kCCDirectorProjectionDefault;/// Detault projection is 3D projection
}



/**Class that creates and handle the main Window and manages how
and when to execute the Scenes.

 The CCDirector is also resposible for:
  - initializing the OpenGL ES context
  - setting the projection (default one is 3D)
  - setting the orientation (default one is Portrait)

 Since the CCDirector is a singleton, the standard way to use it is by calling:
  - CCDirector.sharedDirector().methodName();

 The CCDirector also sets the default OpenGL context:
  - GL.TEXTURE_2D is enabled
  - GL.VERTEX_ARRAY is enabled
  - GL.COLOR_ARRAY is enabled
  - GL.TEXTURE_COORD_ARRAY is enabled
*/
class CCDirector
{
	
	inline static var kDefaultFPS = 60.0;	// 60 frames per second
	
	var view_ :CC_VIEW;

	// internal timer - sec
	var animationInterval_ :Float;
	var oldAnimationInterval_ :Float;

	/* display FPS ? */
	var displayFPS_ :Bool;

	var frames_ :Int;
	var totalFrames_ :Int;

	var accumDt_ :Float;
	var frameRate_ :Float;
	var FPSLabel_ :CCLabelAtlas;

	/* is the running scene paused */
	var isPaused_ :Bool;

	/* The running scene */
	var runningScene_ :CCScene;
	
	/* will be the next 'runningScene' in the next frame
	 nextScene is a weak reference. */
	var nextScene_ :CCScene;

	/* If true, then "old" scene will receive the cleanup message */
	var sendCleanupToScene_ :Bool;

	/* scheduled scenes */
	var scenesStack_ :Array<CCScene>;

	/* last time the main loop was updated */
	var lastUpdate_ :Float;
	/* delta time since last tick to main loop */
	var dt :Float;
	/* whether or not the next delta time will be zero */
	var nextDeltaTimeZero_ :Bool;

	/* projection used */
	var projection_ :CC_DirectorProjection;

	/* window size in points */
	var winSizeInPoints_ :CGSize;

	/* window size in pixels */
	var	winSizeInPixels_ :CGSize;

	// profiler
#if CC_ENABLE_PROFILERS
	var accumDtForProfiler_ :Float;
#end

/** returns the cocos2d thread.
 If you want to run any cocos2d task, run it in this thread.
 On iOS usually it is the main thread.
 @since v0.99.5
 */
/** The current running Scene. Director can only run one Scene at the time */
public var runningScene (get, null) :CCScene;
/** The FPS value */
public var animationInterval (get, set) :Float;
/** Whether or not to display the FPS on the bottom-left corner */
public var displayFPS (get, set) :Bool;
/** The 'OpenGLView', where everything is rendered */
public var view (get, set) :CC_VIEW;
/** whether or not the next delta time will be zero */
public var nextDeltaTimeZero (get, set) :Bool;
/** Whether or not the Director is paused */
public var isPaused (get, null) :Bool;
/** Sets an OpenGL projection
 @since v0.8.2
 */
public var projection (get, set) :CC_DirectorProjection;
/** How many frames were called since the director started */
public var totalFrames (get, null) :Int;

/** Whether or not the replaced scene will receive the cleanup message.
 If the new scene is pushed, then the old scene won't receive the "cleanup" message.
 If the new scene replaces the old one, the it will receive the "cleanup" message.
 @since v0.99.0
 */
public var sendCleanupToScene (get, null) :Bool;

/** This object will be visited after the main scene is visited.
 This object MUST implement the "visit" selector.
 Useful to hook a notification object, like CCNotifications (http://github.com/manucorporat/CCNotifications)
 @since v0.99.5
 */
public var notificationNode :Dynamic;// was id

/** This object will be called when the OpenGL projection is udpated and only when the kCCDirectorProjectionCustom projection is used.
 @since v0.99.5
 */
public var projectionDelegate :Dynamic;


//
// singleton stuff
//
static var _sharedDirector :CCDirector;

public static function sharedDirector () :CCDirector
{
	if (_sharedDirector == null) {

		//
		// Default Director is TimerDirector
		// 
		if( _sharedDirector == null )// CCDirector class] isEqual:this.class]] )
			_sharedDirector = Type.createInstance (CC_DIRECTOR_DEFAULT, []).init();
/*		else
			_sharedDirector = new CCDirector().init();*/
	}
	
	return _sharedDirector;
}

public function new () {}

public function init () :CCDirector
{
	trace("init: "+ Cocos2d.cocos2dVersion() );

	//super.init();
	//trace("cocos2d: Using Director Type: ", Type.class(this));
	
	// scenes
	runningScene_ = null;
	nextScene_ = null;
	
	notificationNode = null;
	
	oldAnimationInterval_ = animationInterval_ = Math.round (1.0 / kDefaultFPS * 1000);
	scenesStack_ = new Array<CCScene>();// 10 maximum if possible
	
	// Set default projection (3D)
	projection_ = kCCDirectorProjectionDefault;

	// projection delegate if "Custom" projection is used
	projectionDelegate = null;

	// FPS
	displayFPS_ = false;
	totalFrames_ = frames_ = 0;
	
	// paused ?
	isPaused_ = false;
	
	winSizeInPixels_ = new CGSize(0, 0);
	winSizeInPoints_ = new CGSize(0, 0);

	return this;
}

public function release ()
{
	trace("cocos2d: releaseing "+ this);

#if CC_DIRECTOR_FAST_FPS
	FPSLabel_.release();
#end
	runningScene_.release();
	if (notificationNode != null)
		notificationNode.release();
	
	if (scenesStack_ != null)
		for (scene in scenesStack_)
			scene.release();
	scenesStack_ = null;
	
	if (projectionDelegate != null)
		projectionDelegate.release();
	
	_sharedDirector = null;
}

public function setDefaultValues ()
{
	// This method SHOULD be called only after view_ was initialized
	if ( view_ == null) throw "view_ must be initialized";

	this.set_alphaBlending( true );
	this.set_depthTest( true );
	this.set_projection( projection_ );
	
#if CC_DIRECTOR_FAST_FPS
    if (FPSLabel_ == null) {
		var currentFormat :CCTexture2DPixelFormat = CCTexture2D defaultAlphaPixelFormat();
		CCTexture2D.set_defaultAlphaPixelFormat ( kCCTexture2DPixelFormat_RGBA4444 );
		FPSLabel_ = CCLabelAtlas labelWithString:"00.0" charMapFile:"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'] retain();
		CCTexture2D.set_defaultAlphaPixelFormat ( currentFormat );		
	}
#end	// CC_DIRECTOR_FAST_FPS*/
}

//
// Draw the Scene
//
public function drawScene ()
{
	// Override me
	trace("drawScene - Override me");
}

public function calculateDeltaTime ()
{
	var now :Float = Date.now().getTime();
	
	// new delta time
	if( nextDeltaTimeZero_ ) {
		dt = 0;
		nextDeltaTimeZero_ = false;
	} else {
		dt = (now - lastUpdate_) + (now - lastUpdate_) / 1000000.0;
		dt = Math.max(0,dt);
	}

#if DEBUG
	// If we are debugging our code, prevent big delta time
	if( dt > 0.2 )
		dt = 1/60.0;
#end
	
	lastUpdate_ = now;
}

// Director - Memory Helper

public function purgeCachedData () :Void
{
	CCLabelBMFont.purgeCachedData();
	CCTextureCache.sharedTextureCache().removeUnusedTextures();
}

// Director - Scene OpenGL Helper

public function get_projection () :CC_DirectorProjection
{
	return projection_;
}

public function set_projection (projection:CC_DirectorProjection) :CC_DirectorProjection
{
	trace("cocos2d: override me");
	return null;
}

public function get_zEye () :Float
{
	return ( winSizeInPixels_.height / 1.1566 );
}

public function set_alphaBlending (on:Bool) :Bool
{
/*	if (on) {
		glEnable(GL.BLEND);
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
		
	} else
		glDisable(GL.BLEND);*/
	return on;
}

public function set_depthTest (on:Bool) :Bool
{
/*	if (on) {
		ccglClearDepth(1.0);
		glEnable(GL.DEPTH_TEST);
		glDepthFunc(GL.LEQUAL);
//		glHint(GL.PERSPECTIVE_CORRECTION_HINT, GL.NICEST);
	} else
		glDisable( GL.DEPTH_TEST );*/
	return on;
}

// Director Integration with a UIKit view

public function get_view () :CC_VIEW
{
	return view_;
}

public function set_view (v:CC_VIEW) :CC_VIEW
	{trace("setView "+v);
	if ( v == null) throw "View must be non-null";

	if( v != view_ ) {
		view_ = v;
		
		// set size
		winSizeInPixels_ = winSizeInPoints_ = v.bounds.size;

		this.setDefaultValues();
	}
	return v;
}

function get_sendCleanupToScene () :Bool {
	return sendCleanupToScene_;
}
function get_nextDeltaTimeZero () :Bool {
	return nextDeltaTimeZero_;
}
public function set_nextDeltaTimeZero (b:Bool) :Bool {
	return nextDeltaTimeZero_ = b;
}
function get_isPaused () :Bool {
	return isPaused_;
}
function get_totalFrames () :Int {
	return totalFrames_;
}
function get_animationInterval () :Float {
	return animationInterval_;
}
function set_animationInterval (i:Float) :Float {
	return animationInterval_ = i;
}
function get_runningScene () :CCScene {
	return runningScene_;
}

function get_displayFPS () :Bool {
	return displayFPS_;
}
public function set_displayFPS (b:Bool) :Bool {
	return displayFPS_ = b;
}

// Director Scene Landscape

/*public function convertToGL (uiPoint:CGPoint) :CGPoint
{
	trace("CCDirector#convertToGL: OVERRIDE ME.");
	return new CGPoint(0, 0);
}

public function convertToUI (glPoint:CGPoint) :CGPoint
{
	trace("CCDirector#convertToUI: OVERRIDE ME.");
	return new CGPoint(0, 0);
}*/

public function winSize () :CGSize
{
	return winSizeInPoints_;
}

public function winSizeInPixels () :CGSize
{
	return winSizeInPixels_;
}

public function displaySizeInPixels () :CGSize
{
	return winSizeInPixels_;
}

public function reshapeProjection (newWindowSize:CGSize) :Void
{
	winSizeInPixels_ = winSizeInPoints_ = newWindowSize;
	this.set_projection ( projection_ );
}

// Director Scene Management

public function runWithScene (scene:CCScene)
{
	if ( scene == null ) throw "Argument must be non-null";
	if ( runningScene_ != null ) throw "You can't run a scene if another Scene is running. Use replaceScene or pushScene instead";
	trace("RUN WITH SCENE "+scene);
	this.pushScene ( scene );
	this.startAnimation();
}

public function replaceScene (scene:CCScene)
{
	if ( scene == null ) throw "Argument must be non-null";

	var index :Int = scenesStack_.length;
	
	sendCleanupToScene_ = true;
	scenesStack_[index-1] = scene;
	nextScene_ = scene;	// nextScene_ is a weak ref
}

public function pushScene (scene:CCScene)
{
	if ( scene == null) throw "Argument must be non-null";

	sendCleanupToScene_ = false;

	scenesStack_.push ( scene );
	nextScene_ = scene;	// nextScene_ is a weak ref
}

public function popScene ()
{
	if (runningScene_ == null) throw "A running Scene is needed";

	scenesStack_.removeLastObject();
	var c :Int = scenesStack_.length;
	
	if( c == 0 )
		this.end();
	else {
		sendCleanupToScene_ = true;
		scenesStack_.insert (c-1, runningScene_);
		nextScene_ = runningScene_;
	}
}

public function end ()
{
	runningScene_.onExit();
	runningScene_.cleanup();
	runningScene_.release();

	runningScene_ = null;
	nextScene_ = null;
	
	// remove all objects, but don't release it.
	// runWithScene might be executed after 'end'.
	scenesStack_.removeAllObjects();
	
	this.stopAnimation();
	
#if CC_DIRECTOR_FAST_FPS
	FPSLabel_.release();
	FPSLabel_ = null;
#end
	if (projectionDelegate != null)
		projectionDelegate.release();
		projectionDelegate = null;
	
	// Purge bitmap cache
	CCLabelBMFont.purgeCachedData();
	// Purge all managers
	CCAnimationCache.purgeSharedAnimationCache();
	CCSpriteFrameCache.purgeSharedSpriteFrameCache();
	CCScheduler.purgeSharedScheduler();
	CCActionManager.purgeSharedManager();
	CCTextureCache.purgeSharedTextureCache();
	
	
	// OpenGL view
	
	// Since the director doesn't attach the openglview to the window
	// it shouldn't remove it from the window too.
	view_.removeFromSuperview();
	view_.release();
	view_ = null;
}

public function setNextScene ()
{
	trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>setNextScene");
	trace("runningScene_ "+runningScene_);
	var transClass :Class<Dynamic> = Type.getClass ( cocos.transition.CCTransitionScene );
	var runningIsTransition :Bool = Std.is (runningScene_, transClass);
	var newIsTransition :Bool = Std.is (nextScene_, transClass);

	// If it is not a transition, call onExit/cleanup
	if( ! newIsTransition ) {
		if (runningScene_ != null)
			runningScene_.onExit();

		// issue #709. the root node (scene) should receive the cleanup message too
		// otherwise it might be leaked.
		if( sendCleanupToScene_)
			if (runningScene_ != null)
				runningScene_.cleanup();
	}
	if (runningScene_ != null)
		runningScene_.release();
	
	runningScene_ = nextScene_;
	nextScene_ = null;

	if( ! runningIsTransition ) {
		runningScene_.onEnter();
		runningScene_.onEnterTransitionDidFinish();
	}
	view_.addChild ( runningScene_.view_ );
}

public function pause ()
{
	if( isPaused_ )
		return;

	oldAnimationInterval_ = animationInterval_;
	
	// when paused, don't consume CPU
	this.setAnimationInterval ( Math.round(1/4.0*1000) );
	isPaused_ = true;
}

public function resume ()
{
	if( ! isPaused_ )
		return;
	
	this.setAnimationInterval ( oldAnimationInterval_ );
	
	lastUpdate_ = Date.now().getTime();
	isPaused_ = false;
	dt = 0;
}

public function startAnimation ()
{
	trace("cocos2d: Director#startAnimation. Override me");
}

public function stopAnimation ()
{
	trace("cocos2d: Director#stopAnimation. Override me");
}

public function setAnimationInterval (interval:Float)
{
	trace("cocos2d: Director#setAnimationInterval. Override me");
}


// display the FPS using a LabelAtlas
// updates the FPS every frame
public function showFPS ()
{
	frames_++;
	accumDt_ += dt;
	return;
	if ( accumDt_ > CCConfig.CC_DIRECTOR_FPS_INTERVAL)  {
		frameRate_ = frames_/accumDt_;
		frames_ = 0;
		accumDt_ = 0;
		
		FPSLabel_.set_string ( Std.string (frameRate_) );
	}

	FPSLabel_.draw();
}

public function showProfilers()
{
#if CC_ENABLE_PROFILERS
	accumDtForProfiler_ += dt;
	if (accumDtForProfiler_ > 1.0) {
		accumDtForProfiler_ = 0;
		CCProfiler.sharedProfiler.displayTimers();
	}
#end // CC_ENABLE_PROFILERS
}

}

