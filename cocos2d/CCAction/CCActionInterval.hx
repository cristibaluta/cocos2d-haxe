/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
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
import CCFiniteTimeAction;
using support.CGPointExtension;

/** An interval action is an action that takes place within a certain period of time.
It has an start time, and a finish time. The finish time is the parameter
duration plus the start time.

These CCActionInterval actions have some interesting properties, like:
 - They can run normally (default)
 - They can run reversed with the reverse method
 - They can run with the time altered with the Accelerate, AccelDeccel and Speed actions.

For example, you can simulate a Ping Pong effect running the action normally and
then running it again in Reverse mode.

Example:

	var  * pingPongAction :CCAction = CCSequence.actions: action, action.reverse], null];
*/
class CCActionInterval extends CCFiniteTimeAction
{

var elapsed_ :Float;
var firstTick_ :Bool;


/** how many seconds had elapsed since the actions started to run. */
public var elapsed (get_elapsed, null) :Float;
function get_elapsed () :Float {
	return elapsed_;
}


override public function init () :CCAction
{
	throw "IntervalActionInit: Init not supported. Use InitWithDuration";
	return null;
}

/** creates the action */
public static function actionWithDuration ( d:Float ) :CCActionInterval
{
	return new CCActionInterval().initWithDuration ( d );
}

/** initializes the action. position is not required here but classes that extend this one requires it */
public function initWithDuration ( d:Float ) :CCActionInterval
{
	super.init();
	
	duration = d;
	// prevent division by 0
	// This comparison could be in step:, but it might decrease the performance
	// by 3% in heavy based action games.
	if( duration == 0 )
		duration = 1;//FLT_EPSILON;
	duration *= 1000;// use miliseconds in haxe
	elapsed_ = 0;
	firstTick_ = true;
	
	return this;
}

public function copy () :CCActionInterval
{
	return new CCActionInterval().initWithDuration(duration);
}

/** returns true if the action has finished */
override public function isDone () :Bool
{
	return (elapsed_ >= duration);
}

override public function step ( dt:Float )
{
	trace("step "+dt);
	if( firstTick_ ) {
		firstTick_ = false;
		elapsed_ = 0;
	} else
		elapsed_ += dt;

	this.update ( Math.min (1, elapsed_/(duration)) );
}

override public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	elapsed_ = 0.0;
	firstTick_ = true;
}

/** returns a reversed action */
override public function reverse () :CCFiniteTimeAction
{
	throw "CCIntervalAction: reverse not implemented.";
	return null;
}

}
