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

import cocos.action.CCFiniteTimeAction;

/** Instant actions are immediate actions. They don't have a duration like
 the CCIntervalAction actions.
*/ 
class CCActionInstant extends CCFiniteTimeAction
{

override public function init () :CCAction
{
	super.init();	
	duration = 0;
	return this;
}

public function copy () :CCActionInstant
{
	var c = new CCActionInstant();
		c.init();
		c.duration = duration;
	return c;
}

override public function isDone () :Bool
{
	return true;
}

override public function step (dt:Float)
{
	this.update(1);
}

override public function update (t:Float) :Void
{
	// ignore
}

override public function reverse () :CCFiniteTimeAction
{
	return this.copy();
}

}
