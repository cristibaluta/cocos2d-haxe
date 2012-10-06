/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
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
import CCNode;
import CCTextureCache;
import CCMacros;
import objc.CGRect;
import objc.CGSize;
import objc.CGPoint;

/** A CCSpriteFrame has:
	- texture: A CCTexture2D that will be used by the CCSprite
	- rectangle: A rectangle of the texture


 You can modify the frame of a CCSprite by doing:

	var frame :CCSpriteFrame = CCSpriteFrame.frameWithTexture ( texture, rect, offset );
	sprite.setDisplayFrame ( frame );
 */
class CCSpriteFrame
{

/** rect of the frame in points. If it is updated, then rectInPixels will be updated too. */
public var rect (default, setRect) :CGRect;

/** rect of the frame in pixels. If it is updated, then rect (points) will be udpated too. */
public var rectInPixels (default, setRectInPixels) :CGRect;

/** whether or not the rect of the frame is rotated ( x = x+width, y = y+height, width = height, height = width ) */
public var rotated :Bool;

/** offset of the frame in pixels */
public var offsetInPixels :CGPoint;

/** original size of the trimmed image in pixels */
public var originalSizeInPixels :CGSize;

/** texture of the frame */
public var texture :CCTexture2D;



public static function frameWithTexture (	texture:CCTexture2D, 
											rectInPixels:CGRect, 
											?rotated:Bool, 
											?offset:CGPoint,
											?originalSize:CGSize) :CCSpriteFrame
{
	return new CCSpriteFrame().initWithTexture (texture, rectInPixels, rotated, offset, originalSize);
}


public function new () {}
public function initWithTexture (	texture:CCTexture2D, 
									rect:CGRect, 
									?rotated:Bool=false, 
									?offset:CGPoint, 
									?originalSize:CGSize) :CCSpriteFrame
{
	// TO CHECK if setter and getter are used at this time because we don't want to be used
	this.texture = texture;
	this.rectInPixels = rect;
	this.rect = CCMacros.CC_RECT_PIXELS_TO_POINTS( rect );
	this.rotated = rotated;
	this.offsetInPixels = (offset == null) ? new CGPoint(0,0) : offset;
	this.originalSizeInPixels = (originalSize == null) ? rectInPixels.size : originalSize;
	
	return this;	
}

public function toString () :String
{
	return "<CCSpriteFrame | TextureName="+texture.name+", "+rect+"> rotated:"+rotated;
}

public function release ()
{
	trace( "cocos2d: releaseing" );
	texture.release();
}

public function setRect ( r:CGRect ) :CGRect
{
	rect = r;
	rectInPixels = CCMacros.CC_RECT_POINTS_TO_PIXELS( r );
	return rect;
}

public function setRectInPixels ( r:CGRect ) :CGRect
{
	rectInPixels = r;
	rect = CCMacros.CC_RECT_PIXELS_TO_POINTS( r );
	return rectInPixels;
}

}
