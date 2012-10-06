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

import CCTextureAtlas;
import CCNode;
import CCMacros;
import CCTypes;
import objc.CGSize;

/** CCAtlasNode is a subclass of CCNode that implements the CCRGBAProtocol and
 CCTextureProtocol protocol

 It knows how to render a TextureAtlas object.
 If you are going to render a TextureAtlas consider subclassing CCAtlasNode (or a subclass of CCAtlasNode)

 All features from CCNode are valid, plus the following features:
 - opacity and RGB colors
 */
class CCAtlasNode extends CCNode
{
var textureAtlas_ :CCTextureAtlas;
var itemsPerRow_ :Int;
var itemsPerColumn_ :Int;
var itemWidth_ :Int;
var itemHeight_ :Int;
var opacity_ :Float;
var color_ :CC_Color3B;
var colorUnmodified_ :CC_Color3B;
var opacityModifyRGB_ :Bool;


/** conforms to CCTextureProtocol protocol */
public var texture (get_texture, set_texture) :CCTexture2D;

/** conforms to CCTextureProtocol protocol */
public var blendFunc :CC_BlendFunc;

public var opacity (get_opacity, set_opacity) :Float;
public var color (get_color, set_color) :CC_Color3B;

/** how many quads to draw */
public var quadsToDraw :Int;


// CCAtlasNode - Creation & Init
public static function atlasWithTileFile (tile:String, tileWidth:Int, tileHeight:Int, itemsToRender:Int) :CCAtlasNode
{
	return new CCAtlasNode().initWithTileFile (tile, tileWidth, tileHeight, itemsToRender);
}

public function initWithTileFile (tile:String, w:Int, h:Int, itemsToRender:Int) :CCAtlasNode
{
	super.init();
	
	itemWidth_ = w * CCConfig.CC_CONTENT_SCALE_FACTOR;
	itemHeight_ = h * CCConfig.CC_CONTENT_SCALE_FACTOR;
	
	opacity_ = 255;
	color_ = colorUnmodified_ = CCTypes.ccWHITE;
	opacityModifyRGB_ = true;
	
/*	blendFunc = {
		src : CCMacros.CC_BLEND_SRC,
		dst : CCMacros.CC_BLEND_DST
	}*/
	
	// double retain to avoid the autorelease pool
	// also, using: this.textureAtlas supports re-initialization without leaking
	this.textureAtlas_ = new CCTextureAtlas().initWithFile (tile, itemsToRender);
	this.updateBlendFunc();
	this.updateOpacityModifyRGB();
	this.calculateMaxItems();
	
	this.quadsToDraw = itemsToRender;
	
	return this;
}

override public function release () :Void
{
	textureAtlas_.release();
	super.release();
}

// CCAtlasNode - Atlas generation

public function calculateMaxItems ()
{
	var s:CGSize = textureAtlas_.texture.contentSizeInPixels;
	itemsPerColumn_ = Math.round (s.height / itemHeight_);
	itemsPerRow_ = Math.round (s.width / itemWidth_);
}

public function updateAtlasValues ()
{
	throw "CCAtlasNode: Abstract updateAtlasValue not overriden";
}

// CCAtlasNode - draw
override public function draw ()
{
	super.draw();

	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Unneeded states: GL.COLOR_ARRAY
/*	glDisableClientState(GL.COLOR_ARRAY);

	glColor4ub( color_.r, color_.g, color_.b, opacity_);

	var newBlend :Bool = blendFunc.src != CC_BLEND_SRC || blendFunc.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc.src, blendFunc.dst );
		
	textureAtlas_.drawNumberOfQuads (quadsToDraw, 0);
		
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	// is this chepear than saving/restoring color state ?
	// XXX: There is no need to restore the color to (255,255,255,255). Objects should use the color
	// XXX: that they need
//	glColor4ub( 255, 255, 255, 255);

	// restore default GL state
	glEnableClientState(GL.COLOR_ARRAY);
*/
}

// CCAtlasNode - RGBA protocol

public function get_color () :CC_Color3B
{
	if(opacityModifyRGB_)
		return colorUnmodified_;
	
	return color_;
}

public function set_color (color3:CC_Color3B) :CC_Color3B
{
	color_ = colorUnmodified_ = color3;
	
	if( opacityModifyRGB_ ){
		color_.r = Math.round (color3.r * opacity_/255);
		color_.g = Math.round (color3.g * opacity_/255);
		color_.b = Math.round (color3.b * opacity_/255);
	}
	return color3;
}

public function get_opacity () :Float
{
	return opacity_;
}

public function set_opacity (anOpacity:Float) :Float
{
	opacity_ = anOpacity;
	
	// special opacity for premultiplied textures
	if( opacityModifyRGB_ )
		this.set_color ( colorUnmodified_ );
	return opacity_;
}

public function setOpacityModifyRGB (modify:Bool) :Bool
{
	var oldColor :CC_Color3B = this.color;
	opacityModifyRGB_ = modify;
	this.color = oldColor;
	return modify;
}

public function doesOpacityModifyRGB () :Bool
{
	return opacityModifyRGB_;
}

public function updateOpacityModifyRGB ()
{
	opacityModifyRGB_ = textureAtlas_.texture.hasPremultipliedAlpha;
}

// CCAtlasNode - CocosNodeTexture protocol

public function updateBlendFunc ()
{
	if( ! textureAtlas_.texture.hasPremultipliedAlpha ) {
		blendFunc.src = GL.SRC_ALPHA;
		blendFunc.dst = GL.ONE_MINUS_SRC_ALPHA;
	}
}

public function set_texture (texture:CCTexture2D) :CCTexture2D
{
	textureAtlas_.texture = texture;
	this.updateBlendFunc();
	this.updateOpacityModifyRGB();
	return texture;
}

public function get_texture () :CCTexture2D
{
	return textureAtlas_.texture;
}

}
