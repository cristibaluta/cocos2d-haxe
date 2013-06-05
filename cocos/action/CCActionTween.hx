/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright 2009 lhunath (Maarten Billemont)
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

import cocos.action.CCActionInterval;

/** CCActionTween
 
 CCActionTween is an action that lets you update any property of an object.
 For example, if you want to modify the "width" property of a target from 200 to 300 in 2 senconds, then:
 
	var modifyWidth :id = CCActionTween.actionWithDuration ( 2, "width", 200, 300 );
	target.runAction ( modifyWidth );
 

 Another example: CCScaleTo action could be rewriten using CCPropertyAction:
 
	// scaleA and scaleB are equivalents
	var scaleA :id = CCScaleTo.actionWithDuration ( 2, 3 );
	var scaleB :id = CCActionTween.actionWithDuration ( 2, "scale", 1, 3 );

 
 @since v0.99.2
 */

class CCActionTween extends CCActionInterval
{
var key_ :String;
var from_ :Float;
var to_ :Float;
var delta_ :Float;


/** creates an initializes the action with the property name (key), and the from and to parameters. */
public static function actionWithDuration (aDuration:Float, aKey:String, aFrom:Float, aTo:Float) :CCActionTween
{
	return new CCActionTween (aDuration, aKey, aFrom, aTo);
}

/** initializes the action with the property name (key), and the from and to parameters. */
public function new (aDuration:Float, key:String, from:Float, to:Float)
{
	super();
	super.initWithDuration ( aDuration );
    
	key_	= key;
	to_		= to;
	from_	= from;
}

override public function startWithTarget (aTarget:Dynamic) :Void
{
	super.startWithTarget ( aTarget );
	delta_ = to_ - from_;
}

override public function update (dt:Float) :Void
{    
	target_.setValue (key_, to_ - delta_ * (1 - dt));
}

override public function reverse () :CCFiniteTimeAction
{
	return actionWithDuration (duration, key_, to_, from_);
}


}
