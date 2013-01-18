/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2009 Jason Booth
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

/** Base class for Easing actions
 */
class CCActionEase extends CCActionInterval
{
var other :CCActionInterval;

public static function actionWithAction (action:CCActionInterval) :CCActionEase
{
	return new CCActionEase().initWithAction (action);
}

public function initWithAction (action:CCActionInterval) :CCActionEase
{
	if (action==null) throw "Ease: arguments must be non-null";
  
	super.initWithDuration (action.duration);
	other = action;
	
	return this;
}

override public function release () :Void
{
	other.release();
	super.release();
}

override public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	other.startWithTarget ( target_ );
}

override public function stop () :Void
{
	other.stop;
	super.stop();
}

override function update (t:Float) :Void
{
	other.update ( t );
}

override public function reverse () :CCFiniteTimeAction
{
	//return cast new CCActionEase().initWithAction ( other.reverse() );
	return cast other.reverse();
}

}
