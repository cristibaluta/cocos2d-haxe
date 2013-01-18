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
 *
 */
package cocos.transition;

import cocos.CCScene;
import cocos.CCNode;
import cocos.CCDirector;
import cocos.action.CCActionInterval;
import cocos.action.CCActionInstant;
import cocos.action.CCActionCamera;
import cocos.CCLayer;
import cocos.CCCamera;
import cocos.action.CCActionTiledGrid;
import cocos.action.CCActionEase;
import cocos.CCRenderTexture;
import cocos.support.CGPoint;
using cocos.support.CGPointExtension;

#if flash
import cocos.platform.flash.CCEventDispatcher;
#elseif nme
import cocos.platform.nme.CCTouchDispatcher;
#end

/** CCTransitionEaseScene can ease the actions of the scene protocol.
 @since v0.8.2
 */
/** returns the Ease action that will be performed on a linear action.
 @since v0.8.2
 */
/*public static function easeActionWithAction (action:CCActionInterval ) :CCActionInterval
{
}*/

/** Orientation Type used by some transitions
 */
enum Orientation {
	/// An horizontal orientation where the Left is nearer
	kOrientationLeftOver;
	/// An horizontal orientation where the Right is nearer
	kOrientationRightOver;
	/// A vertical orientation where the Up is nearer
	kOrientationUpOver;
	/// A vertical orientation where the Bottom is nearer
	kOrientationDownOver;
}



/** Base class for CCTransition scenes
 */
class CCTransitionScene extends CCScene
{
	var inScene_ :CCScene;
	var outScene_ :CCScene;
	var duration_ :Float;
	var inSceneOnTop_ :Bool;
	var sendCleanupToScene_ :Bool;

inline static var kSceneFade = 0xFADEFADE;

/** creates a base transition with duration and incoming scene */
//public static function transitionWithDuration:(Float) t scene:(CCScene*)s;
/** initializes a transition with duration and incoming scene */
//-(id) initWithDuration:(Float) t scene:(CCScene*)s;
/** called after the transition finishes */
//public function finish;
/** used by some transitions to hide the outter scene */
//public function hideOutShowIn;


public static function transitionWithDuration (t:Float, scene:CCScene ) :CCTransitionScene
{
	return new CCTransitionScene().initWithDuration (t, scene);
}

public function initWithDuration ( t:Float, s:CCScene ) :CCTransitionScene
{
	if (s == null) throw "Argument scene must be non-null";
	
	super.init();
	
	duration_ = t;
	inScene_ = s;
	outScene_ = CCDirector.sharedDirector().runningScene;
	
	if (inScene_ != outScene_) throw "Incoming scene must be different from the outgoing scene" ;

	// disable events while transitions
#if nme
	CCTouchDispatcher.sharedDispatcher().setDispatchEvents ( false );
#elseif flash
	CCEventDispatcher.sharedDispatcher().setDispatchEvents ( false );
#end

	this.sceneOrder();
	
	return this;
}
public function sceneOrder ()
{
	inSceneOnTop_ = true;
}

override public function draw ()
{
	super.draw();

	if( inSceneOnTop_ ) {
		outScene_.visit();
		inScene_.visit();
	} else {
		inScene_.visit();
		outScene_.visit();
	}
}

public function finish ()
{
	/* clean up */	
	inScene_.setVisible ( true );
	inScene_.setPosition ( new CGPoint (0,0) );
	inScene_.setScale ( 1.0 );
	inScene_.setRotation ( 0.0 );
	inScene_.camera.restore();
	
	outScene_.setVisible ( false );
	outScene_.setPosition ( new CGPoint (0,0) );
	outScene_.setScale ( 1.0 );
	outScene_.setRotation ( 0.0 );
	outScene_.camera.restore();
	
//	this.schedule:@selector(setNewScene:) interval ( 0 );
}

public function setNewScene ( dt:Float )
{	
	//this.unschedule ( _cmd );
	
	var director :CCDirector = CCDirector.sharedDirector();
	
	// Before replacing, save the "send cleanup to scene"
	sendCleanupToScene_ = director.sendCleanupToScene;
	
	director.replaceScene ( inScene_ );

	// enable events while transitions
#if flash
	CCEventDispatcher.sharedDispatcher().setDispatchEvents(true);
#elseif nme
	CCTouchDispatcher.sharedDispatcher().setDispatchEvents(true);
#elseif js

#end
	
	// issue #267
	outScene_.setVisible ( true );	
}

public function hideOutShowIn ()
{
	inScene_.setVisible ( true );
	outScene_.setVisible ( false );
}

// custom onEnter
override public function onEnter ()
{
	super.onEnter();
	inScene_.onEnter();
	// outScene_ should not receive the onEnter callback
}

// custom onExit
override public function onExit ()
{
	super.onExit();
	outScene_.onExit();

	// inScene_ should not receive the onExit callback
	// only the onEnterTransitionDidFinish
	inScene_.onEnterTransitionDidFinish();
}

// custom cleanup
override public function cleanup ()
{
	super.cleanup();
	
	if( sendCleanupToScene_ )
	   outScene_.cleanup();
}

override public function release () :Void
{
	inScene_.release();
	outScene_.release();
	super.release();
}

}
