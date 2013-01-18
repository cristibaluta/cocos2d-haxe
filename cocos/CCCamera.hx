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
package cocos;

import cocos.CCNode;
import cocos.CCDrawingPrimitives;
import cocos.support.CGSize;
//import cocos.platform.CCGL;

/** 
    A CCCamera is used in every CCNode.
    Useful to look at the object from different views.
    The OpenGL gluLookAt() function is used to locate the
    camera.

    If the object is transformed by any of the scale, rotation or
    position attributes, then they will override the camera.

	IMPORTANT: Either your use the camera or the rotation/scale/position properties. You can't use both.
    World coordinates won't work if you use the camera.

    Limitations:

     - Some nodes, like CCParallaxNode, CCParticle uses world node coordinates, and they won't work properly if you move them (or any of their ancestors)
       using the camera.

     - It doesn't work on batched nodes like CCSprite objects when they are parented to a CCSpriteBatchNode object.

	 - It is recommended to use it ONLY if you are going to create 3D effects. For 2D effecs, use the action CCFollow or position/scale/rotate.

*/
typedef Eye = 
{
	var x:Float;
	var y:Float;
	var z:Float;
}

class CCCamera
{
//
var eyeX_ :Float;
var eyeY_ :Float;
var eyeZ_ :Float;

var centerX_ :Float;
var centerY_ :Float;
var centerZ_ :Float;

var upX_ :Float;
var upY_ :Float;
var upZ_ :Float;

var dirty_ :Bool;


/** whether of not the camera is dirty */
public var dirty (getDirty, setDirty) :Bool;
public function getDirty () :Bool {
	return dirty_;
}
public function setDirty (d:Bool) :Bool {
	return dirty_ = d;
}


public function new () {}
public function init () :CCCamera
{
	this.restore();
	return this;
}

public function toString () :String
{
	return "CCCamera | center = ("+centerX_+","+centerY_+","+centerZ_+")";
}


public function release ()
{
	trace("cocos2d: releaseing "+this);
}

/** sets the camera in the defaul position */
public function restore () :Void
{
	eyeX_ = eyeY_ = 0;
	eyeZ_ = CCCamera.getZEye();
	
	centerX_ = centerY_ = centerZ_ = 0;
	
	upX_ = 0.0;
	upY_ = 1.0;
	upZ_ = 0.0;
	
	dirty_ = false;
}

/** Sets the camera using gluLookAt using its eye, center and up_vector */
public function locate () :Void
{
	//if( dirty_ )
	//	gluLookAt (eyeX_, eyeY_, eyeZ_, centerX_, centerY_, centerZ_, upX_, upY_, upZ_);
}

/** returns the Z eye */
public static function getZEye () :Float
{
	//return FLT_EPSILON;
	var s :CGSize = CCDirector.sharedDirector().displaySizeInPixels();
	return ( s.height / 1.1566 );
}


/** sets the eye values in points */
public function setEye (x:Float, y:Float, z:Float) :Void
{
	eyeX_ = x * CCConfig.CC_CONTENT_SCALE_FACTOR;
	eyeY_ = y * CCConfig.CC_CONTENT_SCALE_FACTOR;
	eyeZ_ = z * CCConfig.CC_CONTENT_SCALE_FACTOR;
	dirty_ = true;	
}

/** sets the center values in points */
public function setCenter (x:Float, y:Float, z:Float) :Void
{
	centerX_ = x * CCConfig.CC_CONTENT_SCALE_FACTOR;
	centerY_ = y * CCConfig.CC_CONTENT_SCALE_FACTOR;
	centerZ_ = z * CCConfig.CC_CONTENT_SCALE_FACTOR;
	dirty_ = true;
}

/** sets the up values */
public function setUp (x:Float, y:Float, z:Float) :Void
{
	upX_ = x;
	upY_ = y;
	upZ_ = z;
	dirty_ = true;
}

/** get the eye vector values in points */
public function eye (x:Float, y:Float, z:Float) :Eye
{
	return
	{
		x : eyeX_ / CCConfig.CC_CONTENT_SCALE_FACTOR,
		y : eyeY_ / CCConfig.CC_CONTENT_SCALE_FACTOR,
		z : eyeZ_ / CCConfig.CC_CONTENT_SCALE_FACTOR
	}
}

/** get the center vector values in points */
public function center (x:Float, y:Float, z:Float) :Eye
{
	return
	{
		x : centerX_ / CCConfig.CC_CONTENT_SCALE_FACTOR,
		y : centerY_ / CCConfig.CC_CONTENT_SCALE_FACTOR,
		z : centerZ_ / CCConfig.CC_CONTENT_SCALE_FACTOR
	}
}

/** get the up vector values */
public function up (x:Float, y:Float, z:Float) :Eye
{
	return
	{
		x : upX_,
		y : upY_,
		z : upZ_
	}
}

}
