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
package cocos.action;

import cocos.CCTypes;
import cocos.CCDirector;
import cocos.CCMacros;
import cocos.action.CCActionInterval;


/** Base class for CCAction objects.
 */
class CCAction
{
inline static var kCCActionTagInvalid = -1;

var originalTarget_ :Dynamic;
var target_ :Dynamic;

public var tag :Int;/** The action tag. An identifier of the action */

/** The "target". The action will modify the target properties.
 The target will be set with the 'startWithTarget' method.
 When the 'stop' method is called, target will be set to null.
 The target is 'assigned', it is not 'retained'.
 */
public var target (get, null) :Dynamic;
/** The original target, since target can be null.
 Is the target that were used to run the action. Unless you are doing something complex, 
 like CCActionManager, you should NOT call this method.
 @since v0.8.2*/
public var originalTarget (get, null) :Dynamic;



//! called before the action start. It will also set the target.
public function startWithTarget (aTarget:Dynamic)
{
	originalTarget_ = target_ = aTarget;
}

public static function action () :CCAction
{
	return new CCAction().init();
}

public function new () {}
public function init () :CCAction
{	
	originalTarget_ = target_ = null;
	tag = kCCActionTagInvalid;
	
	return this;
}

public function release () :Void
{
	trace("cocos2d: releaseing");
}

public function toString () :String
{
	return "<CCAction | Tag = "+tag+">";
}

public function isDone () :Bool
{
	return true;
}
function get_target () :Dynamic {
	return target_;
}
function get_originalTarget () :Dynamic {
	return originalTarget_;
}

//! called after the action has finished. It will set the 'target' to null.
//! IMPORTANT: You should never call "action.stop()" manually. Instead, use: "target.stopAction ( action );"
public function stop () :Void
{
	target_ = null;
}

//! called every frame with it's delta time. DON'T override unless you know what you are doing.
public function step (dt:Float)
{
	trace("Action.step. override me");
}

//! called once per frame. time a value between 0 and 1
//! For example: 
//! * 0 means that the action just started
//! * 0.5 means that the action is in the middle
//! * 1 means that the action is over
public function update (time:Float) :Void
{
	trace("Action.update. override me");
}


}
