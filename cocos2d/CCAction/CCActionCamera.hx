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
import CCCamera;// Defines Eye typedef
import CCActionInterval;
import CCNode;
import CCMacros;

/** Base class for CCCamera actions
 */
class CCActionCamera extends CCActionInterval
{
//
var centerXOrig_ :Float;
var centerYOrig_ :Float;
var centerZOrig_ :Float;

var eyeXOrig_ :Float;
var eyeYOrig_ :Float;
var eyeZOrig_ :Float;

var upXOrig_ :Float;
var upYOrig_ :Float;
var upZOrig_ :Float;

override public function startWithTarget (aTarget:Dynamic) :Void
{
	super.startWithTarget ( aTarget );
	
	var camera :CCCamera = target_.camera;
	var center :Eye = camera.center (centerXOrig_, centerYOrig_, centerZOrig_);
	var eye :Eye = camera.eye (eyeXOrig_, eyeYOrig_, eyeZOrig_);
	var up :Eye = camera.up (upXOrig_, upYOrig_, upZOrig_);
	
	centerXOrig_ = center.x;	centerYOrig_ = center.y;	centerZOrig_ = center.z;
	eyeXOrig_ = center.x;		eyeYOrig_ = center.y;		eyeZOrig_ = center.z;
	upXOrig_ = center.x;		upYOrig_ = center.y;		upZOrig_ = center.z;
}

override public function reverse () :CCFiniteTimeAction
{
	return cast CCReverseTime.actionWithAction ( this );
}

}
