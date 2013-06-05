/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008, 2009 Jason Booth
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
 *
 *********************************************************
 *
 * Motion Streak manages a Ribbon based on it's motion in absolute space.
 * You construct it with a fadeTime, minimum segment size, texture path, texture
 * length and color. The fadeTime controls how long it takes each vertex in
 * the streak to fade out, the minimum segment size it how many pixels the
 * streak will move before adding a new ribbon segement, and the texture
 * length is the how many pixels the texture is stretched across. The texture
 * is vertically aligned along the streak segemnts. 
 */
package cocos;


import cocos.CCNode;
import cocos.CCRibbon;
import cocos.CCTypes;
import cocos.support.CGPoint;
using cocos.support.CGPointExtension;

/**
 * CCMotionStreak manages a Ribbon based on it's motion in absolute space.
 * You construct it with a fadeTime, minimum segment size, texture path, texture
 * length and color. The fadeTime controls how long it takes each vertex in
 * the streak to fade out, the minimum segment size it how many pixels the
 * streak will move before adding a new ribbon segement, and the texture
 * length is the how many pixels the texture is stretched across. The texture
 * is vertically aligned along the streak segemnts. 
 *
 * Limitations:
 *   CCMotionStreak, by default, will use the GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA blending function.
 *   This blending function might not be the correct one for certain textures.
 *   But you can change it by using:
 *     obj.setBlendFunc: (ccBlendfunc) {new_src_blend_func, new_dst_blend_func}];
 *
 * @since v0.8.1
 */

class CCMotionStreak extends CCNode
{
public var ribbon :CCRibbon;
var segThreshold_ :Float;
var width_ :Float;
var lastLocation_ :CGPoint;

/** creates the a MotionStreak. The image will be loaded using the TextureMgr. */
public static function streakWithFade (fade:Float, seg:Float, image:String, width:Float, length:Float, color:CC_Color4B) :CCMotionStreak
{
	return new CCMotionStreak().initWithFade (fade, seg, image, width, length, color);
}

/** initializes a MotionStreak. The file will be loaded using the TextureMgr. */
public function initWithFade (fade:Float, seg:Float, image:String, width:Float, length:Float, color:CC_Color4B) :CCMotionStreak
{
	super.init();
	
	segThreshold_ = seg;
	width_ = width;
	lastLocation_ = new CGPoint(0,0);
	ribbon = CCRibbon.ribbonWithWidth ( width_, image, length, color, fade );
	this.addChild ( ribbon );

	// update ribbon position. Use schedule:Interval and not scheduleUpdated. issue #1075
	this.schedule (update, 0);
	
	return this;
}

public function update ( delta:Float )
{
	var location :CGPoint = this.convertToWorldSpace ( new CGPoint(0,0) );
	ribbon.set_position ( new CGPoint (-1*location.x, -1*location.y) );
	var len :Float = lastLocation_.sub ( location).length();
	if (len > segThreshold_) {
		ribbon.addPointAt ( location, width_ );
		lastLocation_ = location;
	}
	ribbon.update ( delta );
}

// MotionStreak - CocosNodeTexture protocol
public var texture (get, set) :CCTexture2D;
//public var blendFunc (getBlendFunc, set_texture) :CC_BlendFunc;

public function set_texture (texture:CCTexture2D) :CCTexture2D
{
	return ribbon.texture = texture;
}
public function get_texture () :CCTexture2D
{
	return ribbon.texture;
}

public function get_blendFunc () :CC_BlendFunc
{
	return ribbon.blendFunc;
}
public function set_blendFunc (blendFunc:CC_BlendFunc) :CC_BlendFunc
{
	return ribbon.blendFunc = blendFunc;
}

}
