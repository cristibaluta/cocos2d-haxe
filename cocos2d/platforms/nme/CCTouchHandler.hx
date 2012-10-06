/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
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


// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.

/*
 * This file contains the delegates of the touches
 * There are 2 possible delegates:
 *   - CCStandardTouchHandler: propagates all the events at once
 *   - CCTargetedTouchHandler: propagates 1 event at the time
 */
package platforms.flash;

import CCMacros;
import platforms.nme.CCTouchDispatcher;


// TouchHandler
class CCTouchHandler
{
public var delegate :Dynamic;
public var priority :Int;
public var enabledSelectors :Array<TouchSelectorFlag>;

public static function handlerWithDelegate (aDelegate:Dynamic, aPriority:Int) :CCTouchHandler
{
	return new CCTouchHandler().initWithDelegate (aDelegate, aPriority);
}

public function initWithDelegate (aDelegate:Dynamic, aPriority:Int) :CCTouchHandler
{
	if (aDelegate == null) throw "Touch delegate may not be nil";
	
	delegate = aDelegate;
	priority = aPriority;
	enabledSelectors = [];
	
	return this;
}

public function release () {
	trace("cocos2d: releaseing "+ this);
}

}



class CCStandardTouchHandler extends CCTouchHandler
{
override public function initWithDelegate (del:Dynamic, pri:Int) :CCTouchHandler
{
	super.initWithDelegate (del, pri);
	
	if( Reflect.isFunction (del.ccTouchesBegan) )
		enabledSelectors.push ( kCCTouchSelectorBeganBit );
	if( Reflect.isFunction (del.ccTouchesMoved) )
		enabledSelectors.push ( kCCTouchSelectorMovedBit );
	if( Reflect.isFunction (del.ccTouchesEnded) )
		enabledSelectors.push ( kCCTouchSelectorEndedBit );
	if( Reflect.isFunction (del.ccTouchesCancelled) )
		enabledSelectors.push ( kCCTouchSelectorCancelledBit );
		
	return this;
}

}



class CCTargetedTouchHandler extends CCTouchHandler
{
//-(void) updateKnownTouches:(NSMutableSet *)touches withEvent:(UIEvent *)event selector:(SEL)selector unclaim:(Bool)doUnclaim;

public var swallowsTouches :Bool;
public var claimedTouches :Array<Dynamic>;

public static function handlerWithDelegate (aDelegate:Dynamic, priority:Int, swallow:Bool) :CCTargetedTouchHandler
{
	return new CCTargetedTouchHandler().initWithDelegate (aDelegate, priority, swallow);
}

override public function initWithDelegate (aDelegate:Dynamic, aPriority:Int, swallow:Bool) :CCTargetedTouchHandler
{
	super.initWithDelegate (aDelegate, aPriority);
	
	claimedTouches = new Array<Dynamic>();
	swallowsTouches = swallow;
	
	if( Reflect.isFunction (aDelegate.ccTouchBegan) )
		enabledSelectors.push ( kCCTouchSelectorBeganBit );
	if( Reflect.isFunction (aDelegate.ccTouchMoved) )
		enabledSelectors.push ( kCCTouchSelectorMovedBit );
	if( Reflect.isFunction (aDelegate.ccTouchEnded) )
		enabledSelectors.push ( kCCTouchSelectorEndedBit );
	if( Reflect.isFunction (aDelegate.ccTouchCancelled) )
		enabledSelectors.push ( kCCTouchSelectorCancelledBit );
		
	return this;
}

override public function release () {
	claimedTouches.release();
	super.release();
}
}
