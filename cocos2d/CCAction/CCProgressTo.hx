/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2010 Lam Pham
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

import CCProgressTimer;
import CCActionInterval;
import CCActionProgressTimer;

/**
 Progress to percentage
@since v0.99.1
*/
class CCProgressTo extends CCActionInterval
{
var to_ :Float;
var from_ :Float;

public static function  actionWithDuration (t:Float, percent:Float ) :CCProgressTo
{
	return new CCProgressTo (t, percent);
}

public function new (t:Float, percent:Float )
{
	super();
	super.initWithDuration(t);
	to_ = percent;
}

override public function startWithTarget (aTarget:Dynamic)
{
	super.startWithTarget ( aTarget );
	from_ = cast(target_, CCProgressTimer).percentage;
	
	// XXX: Is this correct ?
	// Adding it to support CCRepeat
	if( from_ == 100)
		from_ = 0;
}

override public function update (t:Float) :Void
{
	//cast(target_, CCProgressTimer).setPercentage (from_ + ( to_ - from_ ) * t);
}
/** Creates and initializes the action with a duration, a "from" percentage and a "to" percentage */
//public function actionWithDuration (duration:Float, fromPercentage:Float) :id to:(Float) toPercentage;
/** Initializes the action with a duration, a "from" percentage and a "to" percentage */
//public function initWithDuration (duration:Float, fromPercentage:Float) :id to:(Float) toPercentage;

/** Creates and initializes with a duration and a percent */
//public function actionWithDuration (duration:Float, percent:Float) :id;
/** Initializes with a duration and a percent */
//public function initWithDuration (duration:Float, percent:Float) :id;
}
