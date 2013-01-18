/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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


/**
 CCConfiguration contains some openGL (BitmapData drawing) variables
 @since v0.99.0
 */
class CCConfiguration
{

public var maxTextureSize :Int;
public var maxModelviewStackDepth :Int;
public var supportsPVRTC :Bool;
public var supportsNPOT :Bool;
public var supportsBGRA8888 :Bool;
public var supportsDiscardFramebuffer :Bool;
public var OSVersion :Int;
public var maxSamplesAllowed :Int;


//
// singleton stuff
//
static var _sharedConfiguration :CCConfiguration = null;

public static function sharedConfiguration () :CCConfiguration
{
	if (_sharedConfiguration == null)
		_sharedConfiguration = new CCConfiguration().init();

	return _sharedConfiguration;
}


public function new (){}
public function init () :CCConfiguration
{
	maxTextureSize = 2880;
	maxModelviewStackDepth = 10;
	supportsPVRTC = false;
	supportsNPOT = true;
	supportsBGRA8888 = false;
	supportsDiscardFramebuffer = true;
	OSVersion = 0;
	maxSamplesAllowed = 100;
	
	return this;
}

}