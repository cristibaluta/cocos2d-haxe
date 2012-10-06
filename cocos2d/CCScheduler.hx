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
import CCTypes;
import CCMacros;
import CCTimer;// imports TICK_IMP
import support.HashUtils;
import support.ListUtils;// imports ListEntry
using support.CCArrayExtension;

//
// CCScheduler
//
/** Scheduler is responsible of triggering the scheduled callbacks.
 You should not use NSTimer. Instead use this class.

 There are 2 different types of callbacks (selectors):

	- update selector: the 'update' selector will be called every frame. You can customize the priority.
	- custom selector: A custom selector will be called every frame, or with a custom interval of time

 The 'custom selectors' should be avoided when possible. It is faster, and consumes less memory to use the 'update selector'.
*/

class CCScheduler
{
//
// "updates with priority" stuff
//
var updatesNeg :ListEntry;	// list of priority < 0
var updates0 :ListEntry;	// list priority == 0
var updatesPos :ListEntry;	// list priority > 0
var hashForUpdates :HashUpdateEntry;	// hash used to fetch quickly the list entries for pause,delete,etc.

	// Used for "selectors with interval"
var hashForSelectors :HashSelectorEntry;
var currentTarget :HashSelectorEntry;
var currentTargetSalvaged :Bool;

	// Optimization
var impMethod :Dynamic;//TICK_IMP;
var updateSelector :String;//Dynamic; // A reference to the function that should be called at update interval
var updateHashLocked :Bool; // If true unschedule will not remove anything from a hash. Elements will only be marked for deletion.

/** Modifies the time of all scheduled callbacks.
 You can use this property to create a 'slow motion' or 'fast fordward' effect.
 Default is 1.0. To create a 'slow motion' effect, use values below 1.0.
 To create a 'fast fordward' effect, use values higher than 1.0.
 @since v0.8
 @warning It will affect EVERY scheduled selector / action.
 */
public var timeScale :Float;

static var sharedScheduler_ :CCScheduler;

/** returns a shared instance of the Scheduler */
public static function sharedScheduler () :CCScheduler
{
	if (sharedScheduler_ == null)
		sharedScheduler_ = new CCScheduler().init();

	return sharedScheduler_;
}

/** purges the shared scheduler. It releases the retained instance.
 @since v0.99.0
 */
public static function purgeSharedScheduler ()
{
	sharedScheduler_.release();
	sharedScheduler_ = null;
}

public function new () {}
	

/** The scheduled method will be called every 'interval' seconds.
 If paused is true, then it won't be called until it is resumed.
 If 'interval' is 0, it will be called every frame, but if so, it recommened to use 'scheduleUpdateForTarget:' instead.
 If the selector is already scheduled, then only the interval parameter will be updated without re-scheduling it again.

 @since v0.99.3
 */
public function scheduleSelector (selector:Dynamic, target:Dynamic, interval:Float, paused:Bool) :Void
{
	if (selector == null) throw "Argument selector must be non-null";
	if (target == null) throw "Argument target must be non-null";
	trace("scheduleSelector "+selector+", target "+target);
	var element :HashSelectorEntry = null;
		//element = HashUtils.HASH_FIND_INT (hashForSelectors, target);
	//HASH_FIND_INT(hashForSelectors, &target, element);
	
	if( element == null ) {
		element = new HashSelectorEntry();
		element.timers = null;
		element.target = target;
		element.timerIndex = 0;
		element.currentTimer = null;
		element.currentTimerSalvaged = false;
		element.paused = false;
		element.hh = null;
			
		//HASH_ADD_INT( hashForSelectors, target, element );
		hashForSelectors.target = element;
	
		// Is this the 1st element ? Then set the pause level to all the selectors of this target
		element.paused = paused;
	
	} else
		if (element.paused == paused) throw "CCScheduler. Trying to schedule a selector with a pause value different than the target";
	
	
	if( element.timers == null )
		element.timers = new Array<CCTimer>();
	else {
		for( i in 0...element.timers.length ) {
			var timer :CCTimer = element.timers[i];
			if( selector == timer.selector ) {
				trace("CCScheduler#scheduleSelector. Selector already scheduled. Updating interval from: "+ timer.interval +" to "+ interval);
				timer.interval = interval;
				return;
			}
		}
		//ccArrayEnsureExtraCapacity(element.timers, 1);
	}
	trace(element.timers);
	var timer :CCTimer = new CCTimer().initWithTarget ( target, selector, interval );
	element.timers.push(timer);
	trace("element.timer.length "+element.timers.length);
	//ccArrayAppendObject(element.timers, timer);
}

/** Schedules the 'update' selector for a given target with a given priority.
 The 'update' selector will be called every frame.
 The lower the priority, the earlier it is called.
 @since v0.99.3
 */
public function scheduleUpdateForTarget (target:Dynamic, priority:Int, paused:Bool) :Void
{
	trace("scheduleUpdateForTarget "+target+", priority "+priority+", paused "+paused);
	trace("hashForUpdates "+hashForUpdates);
	var hashElement :HashUpdateEntry = null;
	trace(hashElement);
	//HASH_FIND_INT(hashForUpdates, &target, hashElement);
    if(hashElement != null)
    {
#if COCOS2D_DEBUG
        if (hashElement.entry.markedForDeletion) throw "CCScheduler: You can't re-schedule an 'update' selector'. Unschedule it first";
#end
        // TODO : check if priority has changed!
        
        hashElement.entry.markedForDeletion = false;
        return;
    }
	trace("priority "+priority);
	// most of the updates are going to be 0, that's way there
	// is an special list for updates with priority 0
	if( priority == 0 )
		updates0 = this.appendIn ( updates0, target, paused );

	else if( priority < 0 )
		updatesNeg = this.priorityIn ( updatesNeg, target, priority, paused );

	else // priority > 0
		updatesPos = this.priorityIn ( updatesPos, target, priority, paused );
}

/** Unshedules a selector for a given target.
 If you want to unschedule the "update", use unscheudleUpdateForTarget.
 @since v0.99.3
 */
public function unscheduleSelector (selector:Dynamic, target:Dynamic) :Void
{
	// explicity handle null arguments when removing an object
	if( target==null && selector==null)
		return;

	if (target == null) throw "Target MUST not be null";
	if (selector == null) throw "Selector MUST not be null";

	var element :HashSelectorEntry = null;
	//HASH_FIND_INT(hashForSelectors, &target, element);

	if( element != null ) {

		for( i in 0...element.timers.length ) {
			var timer :CCTimer = element.timers[i];


			if( selector == timer.selector ) {

				if( timer == element.currentTimer && !element.currentTimerSalvaged ) {
					element.currentTimerSalvaged = true;
				}

				element.timers.removeObjectAtIndex ( i );

				// update timerIndex in case we are in tick:, looping over the actions
				if( element.timerIndex >= i )
					element.timerIndex--;

				if( element.timers.length == 0 ) {
					if( currentTarget == element )
						currentTargetSalvaged = true;
					else
						this.removeHashElement ( element );
				}
				return;
			}
		}
	}

	// Not Found
//	trace("CCScheduler#unscheduleSelector:forTarget: selector not found: "+ selString);

}

/** Unschedules the update selector for a given target
 @since v0.99.3
 */
public function unscheduleUpdateForTarget (target:Dynamic)
{
	if( target == null )
		return;

	var element :HashUpdateEntry = null;
	//HASH_FIND_INT(hashForUpdates, &target, element);
	if( element != null ) {    
        if(updateHashLocked)
            element.entry.markedForDeletion = true;
        else
            this.removeUpdateFromHash ( element.entry );

//		// list entry
//		DL_DELETE( *element.list, element.entry );
//		free( element.entry );
//	
//		// hash entry
//		[element.target release();
//		HASH_DEL( hashForUpdates, element);
//		element = null;
	}
}

/** Unschedules all selectors for a given target.
 This also includes the "update" selector.
 @since v0.99.3
 */
public function unscheduleAllSelectorsForTarget (target:Dynamic)
{
	// explicit null handling
	if( target == null )
		return;

	// Custom Selectors
	var element :HashSelectorEntry = null;
	//HASH_FIND_INT(hashForSelectors, &target, element);

	if( element != null ) {
		if( element.timers.containsObject (element.currentTimer) && !element.currentTimerSalvaged ) {
			element.currentTimerSalvaged = true;
		}
		element.timers.ccArrayRemoveAllObjects();
		if( currentTarget == element )
			currentTargetSalvaged = true;
		else
			this.removeHashElement ( element );
	}

	// Update Selector
	this.unscheduleUpdateForTarget ( target );
}

/** Unschedules all selectors from all targets.
 You should NEVER call this method, unless you know what you are doing.

 @since v0.99.3
 */
public function unscheduleAllSelectors ()
{
	// Custom Selectors
	var element:HashSelectorEntry = hashForSelectors;
	while( element != null ) {	
		var target = element.target;
		element = element.hh.next;
		this.unscheduleAllSelectorsForTarget ( target );
	}

	// Updates selectors
	var entry :ListEntry = updates0;
	while( entry != null ) {
		this.unscheduleUpdateForTarget (entry);
		entry = entry.next;
	}
	entry = updatesNeg;
	while( entry != null ) {
		this.unscheduleUpdateForTarget (entry);
		entry = entry.next;
	}
	entry = updatesPos;
	while( entry != null ) {
		this.unscheduleUpdateForTarget (entry);
		entry = entry.next;
	}
}

/** Pauses the target.
 All scheduled selectors/update for a given target won't be 'ticked' until the target is resumed.
 If the target is not present, nothing happens.
 @since v0.99.3
 */
public function pauseTarget (target:Dynamic)
{
	if (target == null) throw "target must be non null" ;

	// Custom selectors
	var element :HashSelectorEntry = null;
	//HASH_FIND_INT(hashForSelectors, &target, element);
	if( element != null )
		element.paused = true;

	// Update selector
	var elementUpdate :HashUpdateEntry = null;
	//HASH_FIND_INT(hashForUpdates, &target, elementUpdate);
	if( elementUpdate != null ) {
		if (elementUpdate.entry == null) throw "pauseTarget: unknown error";
		elementUpdate.entry.paused = true;
	}
}

/** Resumes the target.
 The 'target' will be unpaused, so all schedule selectors/update will be 'ticked' again.
 If the target is not present, nothing happens.
 @since v0.99.3
 */
public function resumeTarget (target:Dynamic)
{
	if (target == null) throw "target must be non null";

	// Custom Selectors
	var element :HashSelectorEntry = null;
	//HASH_FIND_INT(hashForSelectors, &target, element);
	if( element != null )
		element.paused = false;

	// Update selector
	var elementUpdate :HashUpdateEntry = null;
	//HASH_FIND_INT(hashForUpdates, &target, elementUpdate);
	if( elementUpdate != null ) {
		if (elementUpdate.entry == null) throw "resumeTarget: unknown error";
		elementUpdate.entry.paused = false;
	}
}

/** Returns whether or not the target is paused
 @since v1.0.0
 */
public function isTargetPaused (target:Dynamic) :Bool
{
	if (target == null) throw "target must be non null" ;
	
	// Custom selectors
	var element :HashSelectorEntry = null;
	//HASH_FIND_INT(hashForSelectors, &target, element);
	if( element != null )
    {
		return element.paused;
    }
    return false;  // should never get here
	
}


public function init () :CCScheduler
{
	timeScale = 1.0;
	trace("init");
	// used to trigger CCTimer#update
	updateSelector = "update";
	
/*	updateSelector = update;
	impMethod = CCTimer.instanceMethodForSelector ( updateSelector );
*/
	// updates with priority
	updates0 = null;
	updatesNeg = null;
	updatesPos = null;
	hashForUpdates = null;
	
	// selectors with interval
	currentTarget = null;
	currentTargetSalvaged = false;
	hashForSelectors = null;
    updateHashLocked = false;
	
	return this;
}

public function release ()
{
	trace("cocos2d: releaseing "+ this);
	this.unscheduleAllSelectors();
	sharedScheduler_ = null;
}


// CCScheduler - Custom Selectors

public function removeHashElement (element:HashSelectorEntry)
{
	element.timers.ccArrayFree();
	element.target.release();
	//HASH_DEL(hashForSelectors, element);
}





// CCScheduler - Update Specific

public function priorityIn (list:ListEntry, target:Dynamic, priority:Int, paused:Bool) :ListEntry
{
	trace("priorityIn" );
	var listElement = new ListEntry();
		listElement.target = target;
		listElement.priority = priority;
		listElement.paused = paused;
		listElement.impMethod = /*(TICK_IMP) */target.methodForSelector ( updateSelector );
		listElement.next = null;
		listElement.prev = null;
		listElement.markedForDeletion = false;
	
	// empty list ?
	if( list == null ) {
		list = ListUtils.DL_APPEND( list, listElement );
	
	} else {
		var added :Bool = false;
		var elem :ListEntry = list;
		while( elem != null ) {
			if( priority < elem.priority ) {
				
				if( elem == list ){
					ListUtils.DL_PREPEND (list, listElement);
				} else {
					listElement.next = elem;
					listElement.prev = elem.prev;

					elem.prev.next = listElement;
					elem.prev = listElement;
				}
				
				added = true;
				break;
			}
		}
		
		// Not added? priority has the higher value. Append it.
		if( !added )
			ListUtils.DL_APPEND (list, listElement);
	}
	
	// update hash entry for quicker access
	var hashElement = new HashUpdateEntry();
		hashElement.target = target;
		hashElement.list = list;
		hashElement.entry = listElement;
		hashElement.hh = null;
	
	HashUtils.HASH_ADD_INT ( hashForUpdates, target, hashElement );
	
	return list;
}

// target can be: CCActionManager, 
public function appendIn (list:ListEntry, target:Dynamic, paused:Bool) :ListEntry
{
	trace("appendIn");
	
	var listElement = new ListEntry();
		listElement.target = target;
		listElement.paused = paused;
		listElement.markedForDeletion = false;
		listElement.impMethod = Reflect.field (target, updateSelector);
		listElement.prev = null;
		listElement.next = null;
		listElement.priority = 0;
	
	list = ListUtils.DL_APPEND (list, listElement);

	// update hash entry for quicker access
	var hashElement = new HashUpdateEntry();
		hashElement.target = target;
		hashElement.list = list;
		hashElement.entry = listElement;
		hashElement.hh = null;
	
	HashUtils.HASH_ADD_INT ( hashForUpdates, target, hashElement );
	hashForUpdates = hashElement;
	hashForUpdates.target = hashElement;
	
	return list;
}



public function removeUpdateFromHash (entry:ListEntry)
{
    var element :HashUpdateEntry = null;
    
    //element = HASH_FIND_INT (hashForUpdates, entry.target);
    if( element != null ) {
        // list entry
        ListUtils.DL_DELETE( element.list, element.entry );
        element.entry = null;
        
        // hash entry
        element.target.release();
        //HASH_DEL( hashForUpdates, element);
    }
}



/** #pragma mark CCScheduler - Main Loop
'tick' the scheduler.
 You should NEVER call this method, unless you know what you are doing.
 */
public function tick ( dt:Float )
{
	//trace("tick "+dt);
    updateHashLocked = true;
	
	if( timeScale != 1.0 )
		dt *= timeScale;

	// Iterate all over the Updates selectors
	var entry :ListEntry = updatesNeg;
	
	// updates with priority < 0
	while (entry != null) {
		if( ! entry.paused && !entry.markedForDeletion )
			entry.impMethod (entry.target, updateSelector, dt);// entry->impMethod( entry->target, updateSelector, dt );
		entry = entry.next;
	}

	// updates with priority == 0
	entry = updates0;trace(entry);
	while (entry != null) {
		if( ! entry.paused && !entry.markedForDeletion )
			try{entry.impMethod(dt);}catch(e:Dynamic){trace(e);}
			//try{Reflect.callMethod (entry.target, updateSelector, [dt]);}catch(e:Dynamic){trace(e);}
			//try{entry.impMethod (entry.target, updateSelector, dt);}catch(e:Dynamic){trace(e);trace(entry.target);trace(updateSelector);}
		entry = entry.next;
	}

	// updates with priority > 0
	entry = updatesPos;
	while (entry != null) {
		if( ! entry.paused && !entry.markedForDeletion )
			entry.impMethod (entry.target, updateSelector, dt);
		entry = entry.next;
	}

	// Iterate all over the  custome selectors
	var elt :HashSelectorEntry = hashForSelectors;
	while(elt != null) {

		currentTarget = elt;
		currentTargetSalvaged = false;

		if( ! currentTarget.paused ) {

			// The 'timers' CCArraymay change while inside this loop.
			for(timerIndex in 0...elt.timers.length) {
				elt.currentTimer = elt.timers[timerIndex];
				elt.currentTimerSalvaged = false;

				impMethod (elt.currentTimer, updateSelector, dt);

				if( elt.currentTimerSalvaged ) {
					// The currentTimer told the remove itthis. To prevent the timer from
					// accidentally releaseating itthis before finishing its step, we retained
					// it. Now that step is done, it's safe to release it.
					elt.currentTimer.release();
				}

				elt.currentTimer = null;
			}
		}

		// elt, at this moment, is still valid
		// so it is safe to ask this here (issue #490)
		elt = elt.hh.next;

		// only delete currentTarget if no actions were scheduled during the cycle (issue #481)
		if( currentTargetSalvaged && currentTarget.timers.length == 0 )
			this.removeHashElement ( currentTarget );
	}

    // delete all updates that are morked for deletion
    // updates with priority < 0
	entry = updatesNeg;
	while (entry != null) {
		if( entry.markedForDeletion ) this.removeUpdateFromHash ( entry );
		entry = entry.next;
	}

	// updates with priority == 0
	entry = updates0;
	while (entry != null) {
		if( entry.markedForDeletion ) this.removeUpdateFromHash ( entry );
		entry = entry.next;
	}

	// updates with priority > 0
	entry = updatesPos;
	while (entry != null) {
		if( entry.markedForDeletion ) this.removeUpdateFromHash ( entry );
		entry = entry.next;
	}

    updateHashLocked = false;
	currentTarget = null;
}

}
