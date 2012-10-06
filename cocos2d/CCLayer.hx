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
#if flash
	import platforms.flash.CCEventDispatcher;
	import platforms.flash.CCDirectorFlash;
#elseif nme
	import platforms.nme.CCTouchDispatcher;
	import objc.UIAccelerometer;
#elseif js
	import platforms.js.CCEventDispatcher;
#end

import CCNode;
import CCDirector;
import CCMacros;
import objc.CGPoint;
import objc.CGSize;


// -
// CCLayer

/** CCLayer is a subclass of CCNode that implements the TouchEventsDelegate protocol.

 All features from CCNode are valid, plus the following new features:
 - It can receive iPhone Touches
 - It can receive Accelerometer input
*/
class CCLayer extends CCNode
{
var isTouchEnabled_ :Bool;
var isAccelerometerEnabled_ :Bool;
var isMouseEnabled_ :Bool;
var isKeyboardEnabled_ :Bool;


override public function init () :CCNode
{
	trace("init CCLayer");
	super.init();
	
	var s :CGSize = CCDirector.sharedDirector().winSize();
	anchorPoint_ = new CGPoint (0.5, 0.5);
	this.setContentSize ( s );
	this.isRelativeAnchorPoint = false;

	isTouchEnabled_ = false;
	isAccelerometerEnabled_ = false;
	isMouseEnabled_ = false;
	isKeyboardEnabled_ = false;
	
	return this;
}

/** If isTouchEnabled, this method is called onEnter. Override it to change the
 way CCLayer receives touch events.
 ( Default: [TouchDispatcher.sharedDispatcher] addStandardDelegate:this priority:0] )
 Example:
     public function registerWithTouchDispatcher ()
     {
        [TouchDispatcher.sharedDispatcher] addTargetedDelegate:this priority:INT_MIN+1.swallowsTouches ( true );
     }

 Valid only on iOS. Not valid on Mac.

 @since v0.8.0
 */
#if nme
public function registerWithTouchDispatcher () :Void {
	CCTouchDispatcher.sharedDispatcher().addStandardDelegate (this, 0);
}
public var isTouchEnabled (get_isTouchEnabled, set_isTouchEnabled) :Bool;
public var isAccelerometerEnabled (get_isAccelerometerEnabled, set_isAccelerometerEnabled) :Bool;

/** priority of the touch event delegate.
 Default 0.
 Override this method to set another priority.

 Valind only Mac. Not valid on iOS 
 */
public function touchDelegatePriority () :Int
{
	return 0;
}

public function get_isTouchEnabled () :Bool
{
	return isTouchEnabled_;
}

public function set_isTouchEnabled ( enabled:Bool ) :Bool
{
	if( isTouchEnabled_ != enabled ) {
		isTouchEnabled_ = enabled;
		if( isRunning ) {
			if( enabled )
				CCEventDispatcher.sharedDispatcher().addTouchDelegate (this, this.touchDelegatePriority);
			else
				CCEventDispatcher.sharedDispatcher().removeTouchDelegate ( this );
		}
	}
	return enabled;
}




// Layer - Touch and Accelerometer related
public function get_isAccelerometerEnabled () :Bool
{
	return isAccelerometerEnabled_;
}

public function set_isAccelerometerEnabled (enabled:Bool) :Bool
{
	if( enabled != isAccelerometerEnabled_ ) {
		isAccelerometerEnabled_ = enabled;
		if( isRunning ) {
			if( enabled )
				UIAccelerometer.sharedAccelerometer().setDelegate(this);
			else
				UIAccelerometer.sharedAccelerometer().setDelegate(null);
		}
	}
	return enabled;
}

public function get_isTouchEnabled () :Bool
{
	return isTouchEnabled_;
}

public function set_isTouchEnabled (enabled:Bool) :Bool
{
	if( isTouchEnabled_ != enabled ) {
		isTouchEnabled_ = enabled;
		if( isRunning ) {
			if( enabled )
				this.registerWithTouchDispatcher();
			else
				CCTouchDispatcher.sharedDispatcher().removeDelegate(this);
		}
	}
	return enabled;
}

#elseif flash

public var isMouseEnabled (get_isMouseEnabled, set_isMouseEnabled) :Bool;
public var isKeyboardEnabled (get_isKeyboardEnabled, set_isKeyboardEnabled) :Bool;

/** priority of the mouse event delegate.
 Default 0.
 Override this method to set another priority.

 Valind only Mac. Not valid on iOS 
 */
public function mouseDelegatePriority () :Int
{
	return 0;
}

public function get_isMouseEnabled () :Bool
{
	return isMouseEnabled_;
}

public function set_isMouseEnabled (enabled:Bool) :Bool
{
	if( isMouseEnabled_ != enabled ) {
		isMouseEnabled_ = enabled;

		if( isRunning ) {
			if( enabled )
				CCEventDispatcher.sharedDispatcher().addMouseDelegate (this, this.mouseDelegatePriority);
			else
				CCEventDispatcher.sharedDispatcher().removeMouseDelegate ( this );
		}
	}
	return enabled;
}

/** priority of the keyboard event delegate.
 Default 0.
 Override this method to set another priority.

 Valind only Mac. Not valid on iOS 
 */
public function keyboardDelegatePriority () :Int
{
	return 0;
}

public function get_isKeyboardEnabled () :Bool
{
	return isKeyboardEnabled_;
}

public function set_isKeyboardEnabled ( enabled:Bool ) :Bool
{
	if( isKeyboardEnabled_ != enabled ) {
		isKeyboardEnabled_ = enabled;
		
		if( isRunning ) {
			if( enabled )
				CCEventDispatcher.sharedDispatcher().addKeyboardDelegate (this, this.keyboardDelegatePriority);
			else
				CCEventDispatcher.sharedDispatcher().removeKeyboardDelegate ( this );
		}
	}
	return enabled;
}

#end


// Layer - Callbacks
override public function onEnter () :Void
{
#if nme
	// register 'parent' nodes first
	// since events are propagated in reverse order
	if (isTouchEnabled_)
		this.registerWithTouchDispatcher();
#end
	if( isMouseEnabled_ )
		CCEventDispatcher.sharedDispatcher().addMouseDelegate (this, this.mouseDelegatePriority());
	
	if( isKeyboardEnabled_)
		CCEventDispatcher.sharedDispatcher().addKeyboardDelegate (this, this.keyboardDelegatePriority());
#if nme
	if( isTouchEnabled_)
		CCEventDispatcher.sharedDispatcher().addTouchDelegate (this, this.touchDelegatePriority());
#end
	// then iterate over all the children
	super.onEnter();
}

// issue #624.
// Can't register mouse, touches here because of #issue #1018, and #1021
override public function onEnterTransitionDidFinish () :Void
{
#if nme
	if( isAccelerometerEnabled_ )
		UIAccelerometer.sharedAccelerometer().setDelegate(this);
#end
	super.onEnterTransitionDidFinish();
}


override public function onExit () :Void
{
#if nme
	if( isTouchEnabled_ )
		CCTouchDispatcher.sharedDispatcher().removeDelegate(this);

	if( isAccelerometerEnabled_ )
		UIAccelerometer.sharedAccelerometer().setDelegate(null);
	
	if( isTouchEnabled_ )
		CCEventDispatcher.sharedDispatcher().removeTouchDelegate(this);
#elseif flash

	if( isMouseEnabled_ )
		CCEventDispatcher.sharedDispatcher().removeMouseDelegate(this);
	
	if( isKeyboardEnabled_ )
		CCEventDispatcher.sharedDispatcher().removeKeyboardDelegate(this);
#end

	super.onExit();
}

#if nme
public function ccTouchBegan (touch:Dynamic) :Bool
{
	trace("Layer#ccTouchBegan override me");
	return true;
}
#end

}
