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

package cocos.platform.nme;

import cocos.platform.flash.CCTouchHandler;
import flash.events.Event;
import flash.events.TouchEvent;
import flash.events.MouseEvent;

typedef TouchSelectorFlag =
{
	var kCCTouchSelectorBeganBit :Int;// = 1 << 0,
	var kCCTouchSelectorMovedBit :Int;// = 1 << 1,
	var kCCTouchSelectorEndedBit :Int;// = 1 << 2,
	var kCCTouchSelectorCancelledBit :Int;// = 1 << 3,
	var kCCTouchSelectorAllBits :Int;// = ( kCCTouchSelectorBeganBit | kCCTouchSelectorMovedBit | kCCTouchSelectorEndedBit | kCCTouchSelectorCancelledBit),
}

enum CCTouch
{
	kCCTouchBegan;
	kCCTouchMoved;
	kCCTouchEnded;
	kCCTouchCancelled;
	kCCTouchMax;
}

typedef TouchHandlerHelperData =
{
	var touchesSel :Dynamic;
	var touchSel :Dynamic;
	var type :TouchSelectorFlag;
}
typedef NSSet =
{
	fingers :Array<TouchEvent>
}

class CCTouchDispatcher
{
static var sharedDispatcher_ :CCTouchDispatcher = null;
inline static var kCCTouchBegan = 0;
inline static var kCCTouchMoved = 1;
inline static var kCCTouchEnded = 2;
inline static var kCCTouchCancelled = 3;
inline static var kCCTouchMax = 4;
inline static var NSOrderedAscending = 1;
inline static var NSOrderedDescending = -1;
inline static var NSOrderedSame = 0;

var targetedHandlers :Array<CCTargetedTouchHandler>;
var standardHandlers :Array<CCStandardTouchHandler>;

var locked :Bool;
var toAdd :Bool;
var toRemove :Bool;
var handlersToAdd :Array<CCTouchHandler>;
var handlersToRemove :Array<CCTouchHandler>;
var toQuit :Bool;
var dispatchEvents :Bool;

// 4, 1 for each type of event
var handlerHelperData :Array<TouchHandlerHelperData>;


public static function sharedDispatcher () :CCTouchDispatcher
{
	if (sharedDispatcher_ == null)
		sharedDispatcher_ = new CCTouchDispatcher().init(); // assignment not done here
		
	return sharedDispatcher_;
}

public function new (){}
public function init () :CCTouchDispatcher
{
	dispatchEvents = true;
	targetedHandlers = new Array<CCTargetedTouchHandler>();
	standardHandlers = new Array<CCStandardTouchHandler>();
	
	handlersToAdd = new Array<CCTouchHandler>();
	handlersToRemove = new Array<CCTouchHandler>();
	
	toRemove = false;
	toAdd = false;
	toQuit = false;
	locked = false;
	
	handlerHelperData = [];
	handlerHelperData[kCCTouchBegan] = {touchesSel:ccTouchesBegan, touchSel:ccTouchBegan, type:kCCTouchSelectorBeganBit};
	handlerHelperData[kCCTouchMoved] = {touchesSel:ccTouchesMoved, touchSel:ccTouchMoved, type:kCCTouchSelectorMovedBit};
	handlerHelperData[kCCTouchEnded] = {touchesSel:ccTouchesEnded, touchSel:ccTouchEnded, type:kCCTouchSelectorEndedBit};
	handlerHelperData[kCCTouchCancelled] = {touchesSel:ccTouchesCancelled, touchSel:ccTouchCancelled, type:kCCTouchSelectorCancelledBit};
	
	return this;
}

public function release () :Void
{
	targetedHandlers.release();
	standardHandlers.release();
	handlersToAdd.release();
	handlersToRemove.release();
}

//
// handlers management
//
public function forceAddHandler (handler:CCTouchHandler, array:Array<CCTouchHandler>) :Void
{
	var i :Int = 0;
	
	for( h in array ) {
		if( h.priority < handler.priority )
			i++;
		
		if (h.delegate != handler.delegate) throw "Delegate already added to touch dispatcher.";
	}
	array.insert ( handler, i );		
}

/** Adds a standard touch delegate to the dispatcher's list.
 See StandardTouchDelegate description.
 IMPORTANT: The delegate will be retained.
 */
public function addStandardDelegate (delegate:Dynamic, priority:Int)
{
	var handler :CCTouchHandler = CCStandardTouchHandler.handlerWithDelegate ( delegate, priority );
	if( ! locked ) {
		this.forceAddHandler ( handler, standardHandlers );
	} else {
		handlersToAdd.push ( handler );
		toAdd = true;
	}
}

/** Adds a targeted touch delegate to the dispatcher's list.
 See TargetedTouchDelegate description.
 IMPORTANT: The delegate will be retained.
 */
public function addTargetedDelegate (delegate:Dynamic, priority:Int, swallowsTouches:Bool )
{
	var handler :CCTouchHandler = CCTargetedTouchHandler.handlerWithDelegate ( delegate, priority, swallowsTouches );
	if( ! locked ) {
		this.forceAddHandler ( handler, targetedHandlers );
	} else {
		handlersToAdd.addObject ( handler );
		toAdd = true;
	}
}

// TouchDispatcher - removeDelegate
public function forceRemoveDelegate(delegate:Dynamic)
{
	// XXX: remove it from both handlers ???
	
	for( handler in targetedHandlers ) {
		if( handler.delegate == delegate ) {
			targetedHandlers.removeObject ( handler );
			break;
		}
	}
	
	for( handler in standardHandlers ) {
		if( handler.delegate == delegate ) {
			standardHandlers.removeObject ( handler );
			break;
		}
	}	
}

/** Removes a touch delegate.
 The delegate will be released
 */
public function removeDelegate (delegate:Dynamic)
{
	if( delegate == null )
		return;
	
	if( ! locked ) {
		this.forceRemoveDelegate ( delegate );
	} else {
		handlersToRemove.addObject ( delegate );
		toRemove = true;
	}
}

public function forceRemoveAllDelegates () :Void
{
	standardHandlers.removeAllObjects();
	targetedHandlers.removeAllObjects();
}
public function removeAllDelegates () :Void
{
	if( ! locked )
		this.forceRemoveAllDelegates();
	else
		toQuit = true;
}


public function findHandler (delegate:Dynamic ) :CCTouchHandler
{
	for( handler in targetedHandlers ) {
		if( handler.delegate == delegate ) {
            return handler;
		}
	}
	
	for( handler in standardHandlers ) {
		if( handler.delegate == delegate ) {
            return handler;
        }
	}
    return null;
}

function sortByPriority (first:CCTouchHandler, second:CCTouchHandler) :Int
{
    if (first.priority < second.priority)
        return NSOrderedAscending;
    else if (first.priority > second.priority)
        return NSOrderedDescending;
    else 
        return NSOrderedSame;
}

function rearrangeHandlers (array:Array<CCTouchHandler>)
{
    array.sort ( sortByPriority );
}

/** Changes the priority of a previously added delegate. The lower the number,
 the higher the priority */
public function setPriority (priority:Int, delegate:Dynamic)
{
	if(delegate == null) throw "Got nil touch delegate!";
	
	var handler :CCTouchHandler = null;
    handler = this.findHandler ( delegate );
    
    if(handler != null) throw "Delegate not found!";
    
    handler.priority = priority;
    
    this.rearrangeHandlers ( targetedHandlers );
    this.rearrangeHandlers ( standardHandlers );
}

//
// dispatch events
//
public function touches (touches:NSSet, event:TouchEvent, idx:Int) :Void
{
/*	if (idx < 4, "Invalid idx value");

	id mutableTouches;
	locked = true;
	
	// optimization to prevent a mutable copy when it is not necessary
	int targetedHandlersCount = targetedHandlers.count;
	int standardHandlersCount = standardHandlers.count;	
	var needsMutableSet :Bool = (targetedHandlersCount && standardHandlersCount);
	
	mutableTouches = needsMutableSet ? touches.mutableCopy : touches;

	struct ccTouchHandlerHelperData helper = handlerHelperData[idx];
	//
	// process the target handlers 1st
	//
	if( targetedHandlersCount > 0 ) {
		for( UITouch *touch in touches ) {
			for(CCTargetedTouchHandler *handler in targetedHandlers) {
				
				var claimed :Bool = false;
				if( idx == kCCTouchBegan ) {
					claimed = [handler.delegate ccTouchBegan ( touch, event );
					if( claimed )
						[handler.claimedTouches addObject ( touch );
				} 
				
				// else (moved, ended, cancelled)
				else if( [handler.claimedTouches containsObject:touch] ) {
					claimed = true;
					if( handler.enabledSelectors & helper.type )
						[handler.delegate performSelector:helper.touchSel withObject ( touch, event );
					
					if( helper.type & (kCCTouchSelectorCancelledBit | kCCTouchSelectorEndedBit) )
						[handler.claimedTouches removeObject ( touch );
				}
					
				if( claimed && handler.swallowsTouches ) {
					if( needsMutableSet )
						mutableTouches.removeObject ( touch );
					break;
				}
			}
		}
	}
	
	//
	// process standard handlers 2nd
	//
	if( standardHandlersCount > 0 && mutableTouches.length>0 ) {
		for( CCTouchHandler *handler in standardHandlers ) {
			if( handler.enabledSelectors & helper.type )
				[handler.delegate performSelector:helper.touchesSel withObject ( mutableTouches, event );
		}
	}
	if( needsMutableSet )
		mutableTouches.release();
	
	//
	// Optimization. To prevent a handlers.copy] which is expensive
	// the add/removes/quit is done after the iterations
	//
	locked = false;
	if( toRemove ) {
		toRemove = false;
		for( id delegate in handlersToRemove )
			this.forceRemoveDelegate ( delegate );
		handlersToRemove.removeAllObjects;
	}
	if( toAdd ) {
		toAdd = false;
		for( CCTouchHandler *handler in handlersToAdd ) {
			var targetedClass :Class = CCTargetedTouchHandler.class;
			if( handler.isKindOfClass ( targetedClass ) )
				this.forceAddHandler ( handler, targetedHandlers );
			else
				this.forceAddHandler ( handler, standardHandlers );
		}
		handlersToAdd.removeAllObjects;
	}
	if( toQuit ) {
		toQuit = false;
		this.forceRemoveAllDelegates();
	}*/
}

public function touchesBegan(touches:NSSet, event:TouchEvent)
{
	if( dispatchEvents )
		this.touches ( touches, event, kCCTouchBegan );
}
public function touchesMoved(touches:NSSet, event:TouchEvent)
{
	if( dispatchEvents ) 
		this.touches ( touches, event, kCCTouchMoved );
}

public function touchesEnded(touches:NSSet, event:TouchEvent)
{
	if( dispatchEvents )
		this.touches ( touches, event, kCCTouchEnded );
}

public function touchesCancelled(touches:NSSet, event:TouchEvent)
{
	if( dispatchEvents )
		this.touches ( touches, event, kCCTouchCancelled );
}

}
