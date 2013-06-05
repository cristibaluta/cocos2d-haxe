/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
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
/** CCActionManager is a singleton that manages all the actions.
 Normally you won't need to use this singleton directly. 99% of the cases you will use the CCNode interface,
 which uses this singleton.
 But there are some cases where you might need to use this singleton.
 Examples:
	- When you want to run an action where the target is different from a CCNode. 
	- When you want to pause / resume the actions

 @since v0.8
 */
package cocos.action;

import cocos.CCScheduler;
import cocos.CCMacros;
import cocos.action.CCAction;
import cocos.support.HashUtils;
using cocos.support.CCArrayExtension;

class HashElement
{
	public var actions :Array<CCAction>;
	public var target :Dynamic;
	public var actionIndex :Int;
	public var currentAction :CCAction;
	public var currentActionSalvaged :Null<Bool>;
	public var paused :Null<Bool>;
	public var hh :Map<String,String>;
	public function new(){}
}


class CCActionManager
{
static var sharedManager_ :CCActionManager;
static var kCCActionTagInvalid = -1;

var targets :Array<HashElement>;
var currentTarget :HashElement;
var currentTargetSalvaged :Bool;


/** returns a shared instance of the CCActionManager */
static public function sharedManager () :CCActionManager
{
	if (sharedManager_ == null)
		sharedManager_ = new CCActionManager().init();
		
	return sharedManager_;
}

/** purges the shared action manager. It releases the retained instance.
 @since v0.99.0
 */
public static function purgeSharedManager () :Void
{
	if (sharedManager_ != null)
		sharedManager_.release();
		sharedManager_ = null;
}



public function new () {}
// ActionManager - init
public function init () :CCActionManager
{
	CCScheduler.sharedScheduler().scheduleUpdateForTarget (this, 0, false);
	targets = new Array<HashElement>();
	
	return this;
}

public function release ()
{
	trace( "cocos2d: releaseing "+this);
	CCScheduler.sharedScheduler().unscheduleUpdateForTarget ( this );
	this.removeAllActions();
	sharedManager_ = null;
}

// ActionManager - Private

private function deleteHashElement (element:HashElement) :Void
{
	trace("deletehashelement "+element);
	element.actions = null;
	targets.remove ( element );
//	trace("cocos2d: ---- buckets: %d/%d - "+ targets.entries, targets.size, element.target);
	element.target.release();
	element = null;
}

private function actionAllocWithHashElement (element:HashElement) :Void
{
	// 4 actions per Node by default // no limit in haxe
	if( element.actions == null )
		element.actions = new Array<CCAction>();
}

public function removeActionAtIndex (index:Int, element:HashElement)
{
	var action :CCAction = element.actions[index];

	if( action == element.currentAction && !element.currentActionSalvaged ) {
		//[element.currentAction retain();
		element.currentActionSalvaged = true;
	}
	
	element.actions.removeObjectAtIndex(index);

	// update actionIndex in case we are in tick:, looping over the actions
	if( element.actionIndex >= index )
		element.actionIndex--;
	
	if( element.actions.length == 0 ) {
		if( currentTarget == element )
			currentTargetSalvaged = true;
		else
			this.deleteHashElement ( element );
	}
}

/** Pauses the target: all running actions and newly added actions will be paused.
 */
public function pauseTarget (target:Dynamic)
{
	var element :HashElement = null;
	//HASH_FIND_INT(targets, &target, element);
	if( element != null )
		element.paused = true;
	else
		trace("cocos2d: pauseAllActions: Target not found");
}
/** Resumes the target. All queued actions will be resumed.
 */
public function resumeTarget (target:Dynamic)
{
	var element :HashElement = null;
	//HASH_FIND_INT(targets, &target, element);
	if( element != null )
		element.paused = false;
	else
		trace("cocos2d: resumeAllActions: Target not found");
}

// actions

/** Adds an action with a target.
 If the target is already present, then the action will be added to the existing target.
 If the target is not present, a new instance of this target will be created either paused or paused, and the action will be added to the newly created target.
 When the target is paused, the queued actions won't be 'ticked'.
 */
public function addAction (action:CCAction, target:Dynamic, paused:Bool)
{
	paused=false;
	trace(".........................................................");
	trace ("addAction "+action+", target:"+target+", paused:"+paused);
	if (action == null) throw "Argument action must be non-null";
	if (target == null) throw "Argument target must be non-null";
	
	var element :HashElement = null;
	for (e in targets)
		if (e.target == target) {
			element = e;
			break;
		}
	//element = HASH_FIND_INT(targets, &target);
	if( element == null ) {
		element = new HashElement();
		element.target = target;
		element.actionIndex = 0;
		element.paused = paused;
		targets.push ( element );
		//HASH_ADD_INT(targets, target, element);
		trace("cocos2d: ---- buckets: "+ targets.length);
	}
	
	this.actionAllocWithHashElement ( element ); // This s equivalent with the already added actions:[ ]

	if (element.actions.containsObject( action)) throw "runAction: Action already running";
		element.actions.push (action);

		trace("element");
		trace(element);
	
	action.startWithTarget ( target );
	trace("FIN ADD ACTION");
}

/** Removes all actions from all the targers.
 */
public function removeAllActions () :Void
{
	for (element in targets) {
		var target :Dynamic = element.target;
		//element = element.hh.next();
		this.removeAllActionsFromTarget ( target );
	}
}
/** Removes all actions from a certain target.
 All the actions that belongs to the target will be removed.
 */
public function removeAllActionsFromTarget (target:Dynamic)
{
	// explicit null handling
	if( target == null )
		return;
	
	var element :HashElement = null;
	//HASH_FIND_INT(targets, &target, element);
	if( element != null ) {
		if( element.actions.containsObject (element.currentAction) && !element.currentActionSalvaged ) {
			//[element.currentAction retain();
			element.currentActionSalvaged = true;
		}
		element.actions = [];
		if( currentTarget == element )
			currentTargetSalvaged = true;
		else
			this.deleteHashElement ( element );
	}
/*	else {
		trace("cocos2d: removeAllActionsFromTarget: Target not found");
	}*/
}

/** Removes an action given an action reference.
 */
public function removeAction (action:CCAction)
{
	trace("removeAction "+action);
	// explicit null handling
	if (action == null)
		return;
	return;
	var element :HashElement = null;
	var target :Dynamic = action.originalTarget;
	//HASH_FIND_INT(targets, &target, element );
	if( element != null ) {
		var i :Int = element.actions.indexOfObject ( action );
		if( i != -1 )
			this.removeActionAtIndex ( i, element );
	}
	else {
		trace("cocos2d: removeAction: Target not found");
	}
}

/** Removes an action given its tag and the target */
public function removeActionByTag (aTag:Int, target:Dynamic)
{
	if (aTag == kCCActionTagInvalid) throw "Invalid tag";
	if (target == null) throw "Target should be ! null";
	
	var element :HashElement = null;
	//HASH_FIND_INT(targets, &target, element);
	
	if( element != null ) {
		var limit :Int = element.actions.length;
		for( i in 0...limit) {
			var a :CCAction = element.actions[i];
			
			if( a.tag == aTag && a.originalTarget == target) {
				this.removeActionAtIndex (i, element );
				break;
			}
		}
	}
}

/** Gets an action given its tag an a target
 @return the Action the with the given tag
 */
public function getActionByTag (aTag:Int, target:Dynamic) :CCAction
{
	if (aTag == kCCActionTagInvalid) throw "Invalid tag";

	var element :HashElement = null;
	//HASH_FIND_INT(targets, &target, element);

	if( element != null ) {
		if( element.actions != null ) {
			var limit :Int = element.actions.length;
			for(i in 0...limit) {
				var a:CCAction = element.actions[i];
			
				if( a.tag == aTag )
					return a;
			}
		}
	}
	return null;
}
/** Returns the numbers of actions that are running in a certain target
 * Composable actions are counted as 1 action. Example:
 *    If you are running 1 Sequence of 7 actions, it will return 1.
 *    If you are running 7 Sequences of 2 actions, it will return 7.
 */
public function numberOfRunningActionsInTarget (target:Dynamic) :Int
{
	var element :HashElement = null;
	//HASH_FIND_INT(targets, &target, element);
	if( element != null )
		return element.actions != null ? element.actions.length : 0;

	trace("cocos2d: numberOfRunningActionsInTarget: Target not found");
	return 0;
}

// ActionManager - main loop

public function update (dt:Float)
{
	trace("update "+dt);
	for (elt in targets) {

		currentTarget = elt;
		currentTargetSalvaged = false;
		
		if( ! currentTarget.paused ) {
			
			// The 'actions' CCArray may change while inside this loop.
			for( i in 0...currentTarget.actions.length) {
				currentTarget.actionIndex = i;
				currentTarget.currentAction = currentTarget.actions[i];
				currentTarget.currentActionSalvaged = false;
				currentTarget.currentAction.step( dt );

				if( currentTarget.currentActionSalvaged ) {
					// The currentAction told the node to remove it. To prevent the action from
					// accidentally releaseating itthis before finishing its step, we retained
					// it. Now that step is done, it's safe to release it.
					currentTarget.currentAction.release();
				}
				else if (currentTarget.currentAction.isDone() ) {
					currentTarget.currentAction.stop();
					
					var a :CCAction = currentTarget.currentAction;
					// Make currentAction null to prevent removeAction from salvaging it.
					currentTarget.currentAction = null;
					this.removeAction ( a );
				}
				
				currentTarget.currentAction = null;
			}
		}

		// elt, at this moment, is still valid
		// so it is safe to ask this here (issue #490)
		//elt = elt.hh.iterator().next();
	
		// only delete currentTarget if no actions were scheduled during the cycle (issue #481)
		if( currentTargetSalvaged && currentTarget.actions.length == 0 )
			this.deleteHashElement ( currentTarget );
	}
	
	// issue #635
	currentTarget = null;
}
}
