/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Jason Booth
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
import CCSprite;
import CCDirector;
import CCMacros;
import CCTypes;
import support.CCUtils;
import support.CCFileUtils;
import objc.CGSize;
using support.CCUtils;

enum CCImageFormat
{
	kCCImageFormatJPG;
	kCCImageFormatPNG;
	kCCImageFormatRawData;
}


/**
 CCRenderTexture is a generic rendering target. To render things into it,
 simply construct a render target, call begin on it, call visit on any cocos
 scenes or objects to render them, and call end. For convienience, render texture
 adds a sprite as it's display child with the results, so you can simply add
 the render texture to your scene and treat it like any other CocosNode.
 There are also functions for saving the render texture to disk in PNG or JPG format.
 
 @since v0.8.1
 */
class CCRenderTexture extends CCNode
{
var fbo_ :Int;
var oldFBO_ :Int;
var texture_ :CCTexture2D;


/** The CCSprite being used.
 The sprite, by default, will use the following blending function: GL.ONE, GL.ONE_MINUS_SRC_ALPHA.
 The blending function can be changed in runtime by calling:
	- [renderTexture.sprite] setBlendFunc:(CC_BlendFunc){GL.ONE, GL.ONE_MINUS_SRC_ALPHA}];
*/
public var sprite :CCSprite;

/** creates a RenderTexture object with width and height in Points, pixel format is RGBA8888 */
public static function renderTextureWithWidth ( w:Int, h:Int ) :CCRenderTexture
{
	return new CCRenderTexture().initWithWidth ( w, h );
}

/** initializes a RenderTexture object with width and height in Points and a pixel format, only RGB and RGBA formats are valid */
public function initWithWidth ( w:Int, h:Int ) :CCRenderTexture
{
	super.init();
	
	w *= CCConfig.CC_CONTENT_SCALE_FACTOR;
	h *= CCConfig.CC_CONTENT_SCALE_FACTOR;

//	glGetIntegerv(CC_GL.FRAMEBUFFER_BINDING, &oldFBO_);
	
	// textures must be power of two
	var powW :Int = w.ccNextPOT();
	var powH :Int = h.ccNextPOT();
	
	var data = new flash.display.BitmapData(powW, powH);
	//malloc((int)(powW * powH * 4));
	//memset(data, 0, (int)(powW * powH * 4));
	
	texture_ = new CCTexture2D().initWithData (data, powW, powH, new CGSize(w, h));
	
	// generate FBO
/*	ccglGenFramebuffers(1, &fbo_);
	ccglBindFramebuffer(CC_GL.FRAMEBUFFER, fbo_);

	// associate texture with FBO
	ccglFramebufferTexture2D(CC_GL.FRAMEBUFFER, CC_GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture_.name, 0);
*/
	// check if it worked (probably worth doing :) )
/*	var status :Int = ccglCheckFramebufferStatus(CC_GL.FRAMEBUFFER);
	if (status != CC_GL.FRAMEBUFFER_COMPLETE)
	{
		throw "Render Texture. Could not attach texture to framebuffer";
	}*/
	texture_.setAliasTexParameters();
	
	sprite = CCSprite.spriteWithTexture ( texture_ );
	
	texture_.release();
	sprite.scaleY = -1;
	this.addChild ( sprite );

	// issue #937
	sprite.blendFunc = {src:GL.ONE, dst:GL.ONE_MINUS_SRC_ALPHA};

	//ccglBindFramebuffer(CC_GL.FRAMEBUFFER, oldFBO_);
	
	return this;
}

/** starts grabbing */
public function begin ()
{
	// Save the current matrix
	//glPushMatrix();
	
	var texSize :CGSize = texture_.contentSizeInPixels;
	
	
	// Calculate the adjustment ratios based on the old and new projections
	var size:CGSize = CCDirector.sharedDirector().displaySizeInPixels();
	var widthRatio :Float = size.width / texSize.width;
	var heightRatio :Float = size.height / texSize.height;
	
	
	// Adjust the orthographic propjection and viewport
/*	ccglOrtho((Float)-1.0 / widthRatio,  (Float)1.0 / widthRatio, (Float)-1.0 / heightRatio, (Float)1.0 / heightRatio, -1,1);
	glViewport(0, 0, texSize.width, texSize.height);
	
	
	glGetIntegerv(CC_GL.FRAMEBUFFER_BINDING, &oldFBO_);
	ccglBindFramebuffer(CC_GL.FRAMEBUFFER, fbo_);//Will direct drawing to the frame buffer created above
	*/
	// Issue #1145
	// There is no need to enable the default GL states here
	// but since CCRenderTexture is mostly used outside the "render" loop
	// these states needs to be enabled.
	// Since this bug was discovered in API-freeze (very close of 1.0 release)
	// This bug won't be fixed to prevent incompatibilities with code.
	// 
	// If you understand the above mentioned message, then you can comment the following line
	// and enable the gl states manually, in case you need them.
	//CC_ENABLE_DEFAULT_GL.STATES();
}

/** starts rendering to the texture while clearing the texture first.
 This is more efficient then calling -clear first and then -begin */
public function beginWithClear (r:Float, g:Float, b:Float, a:Float) :Void
{
	this.begin();

	// save clear color
/*	Float	clearColor[4];
	glGetFloatv(GL.COLOR_CLEAR_VALUE,clearColor); 

	glClearColor(r, g, b, a);
	glClear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);

	// restore clear color
	glClearColor(clearColor[0], clearColor[1], clearColor[2], clearColor[3]);*/
}

/** ends grabbing */
public function end ()
{
/*	ccglBindFramebuffer(CC_GL.FRAMEBUFFER, oldFBO_);
	// Restore the original matrix and viewport
	glPopMatrix();
	var size:CGSize = CCDirector.sharedDirector().displaySizeInPixels;
	glViewport(0, 0, size.width, size.height);*/
}

/** clears the texture with a color */
public function clear (r:Float, g:Float, b:Float, a:Float) :Void
{
	this.beginWithClear (r, g, b, a);
	this.end();
}

}
