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
import CCMacros;
import CCSpriteFrame;
import CCTexture2D;
import CCTextureCache;
import objc.CGRect;

class CCAnimation
{
public var name :String;
public var delay :Float;
public var frames :Array<CCSpriteFrame>;


public static function animation () :CCAnimation
{
	return new CCAnimation().init();
}
public static function animationWithFrames ( frames:Array<CCSpriteFrame>, ?delay:Float=.0 ) :CCAnimation
{
	return new CCAnimation().initWithFrames (frames, delay);
}

public function new () {}
public function init () :CCAnimation
{
	return this.initWithFrames ( null, 0 );
}
public function initWithFrames ( array:Array<CCSpriteFrame>, ?delay:Float=.0 ) :CCAnimation
{
	this.delay = delay;
	this.frames = array == null ? [] : null;
	
	return this;
}

public function toString () :String
{
	return "<CCAnimation | frames="+frames.length+", delay:"+delay+">";
}

public function release () :Void
{
	trace( "cocos2d: releaseing "+this);
	frames = null;
}

public function addFrame (frame:CCSpriteFrame)
{
	frames.push ( frame );
}

public function addFrameWithFilename (filename:String)
{
	var texture :CCTexture2D = CCTextureCache.sharedTextureCache().addImage ( filename );
	var rect = new CGRect(0,0,0,0);
		rect.size = texture.contentSize;
	var frame :CCSpriteFrame = CCSpriteFrame.frameWithTexture ( texture, rect );
	frames.push ( frame );
}

public function addFrameWithTexture (texture:CCTexture2D, rect:CGRect) :Void
{
	var frame :CCSpriteFrame = CCSpriteFrame.frameWithTexture ( texture, rect );
	frames.push ( frame );
}

}
