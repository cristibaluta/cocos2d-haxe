/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Sindesso Pty Ltd http://www.sindesso.com/
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
import CCActionPageTurn3D;
import CCDirector;
import CCTypes;
import objc.CGSize;

class CCTransitionPageTurn
{
	var back_ :Bool;
	
/** creates a base transition with duration and incoming scene */
public static function transitionWithDuration (t:Float, s:CCScene, backwards:Bool) :CCTransitionPageTurn
{
	return new CCTransitionPageTurn().initWithDuration (t, s, backwards);
}

public function new ()
{
	back_ = false;
}

/** initializes a transition with duration and incoming scene */
public function initWithDuration (t:Float, s:CCScene, backwards:Bool) :CCTransitionPageTurn
{
	// XXX: needed before super.init]
	back_ = backwards;
	super.initWithDuration (t, s);
	return this;
}

public function sceneOrder ()
{
	inSceneOnTop_ = back_;
}

//
public function onEnter ()
{
	super.onEnter();
	
	var s :CGSize = CCDirector.sharedDirector().winSize();
	var x:Int, y:Int;
	if( s.width > s.height)
	{
		x = 16;
		y = 12;
	}
	else
	{
		x = 12;
		y = 16;
	}
	
	var action  = this.actionWithSize ({x:x, y:y});
	
	if(! back_ )
	{
		outScene_.runAction ( CCSequence.actions (
							  action,
							  CCCallFunc.actionWithTarget (this, finish),
							  CCStopGrid.action,
							  null)
		 );
	}
	else
	{
		// to prevent initial flicker
		inScene_.visible = false;
		inScene_.runAction ( CCSequence.actions (
							 CCShow.action,
							 action,
							 CCCallFunc.actionWithTarget (this, finish),
							 CCStopGrid.action,
							 null)
		);
	}
	
}

public function actionWithSize (v:CC_GridSize) :CCActionInterval
{
	if( back_ )
	{
		// Get hold of the PageTurn3DAction
		return CCReverseTime.actionWithAction ( CCPageTurn3D.actionWithSize (v, duration_) );
	}
	else
	{
		// Get hold of the PageTurn3DAction
		return CCPageTurn3D.actionWithSize ( v, duration_ );
	}
}

}

