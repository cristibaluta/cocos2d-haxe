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
package cocos;

import cocos.CCTypes;
import cocos.support.CGPoint;
import cocos.support.CGRect;
import cocos.support.CGSize;
import cocos.support.CGAffineTransform;
import cocos.support.UIImage;
using cocos.support.CCArrayExtension;
using cocos.support.CGRectExtension;

// CCSprite

//typedef CCSpriteIndexNotInitialized = Null; 	/// CCSprite invalid index on the CCSpriteBatchode
// XXX: Optmization
typedef TransformValues = {
	var pos :CGPoint;		// position x and y
	var scale :CGPoint;		// scale x and y
	var rotation :Float;
	var skew :CGPoint;		// skew x and y
	var ap :CGPoint;			// anchor point in pixels
	var visible :Bool;
}

/**
 Whether or not an CCSprite will rotate, scale or translate with it's parent.
 Useful in health bars, when you want that the health bar translates with it's parent but you don't
 want it to rotate with its parent.
 @since v0.99.0
 */
enum CCHonorParentTransform
{
	//! Translate with it's parent
	CC_HONOR_PARENT_TRANSFORM_TRANSLATE;// =  1 << 0,
	//! Rotate with it's parent
	CC_HONOR_PARENT_TRANSFORM_ROTATE;//	=  1 << 1,
	//! Scale with it's parent
	CC_HONOR_PARENT_TRANSFORM_SCALE;//		=  1 << 2,
	//! Skew with it's parent
	CC_HONOR_PARENT_TRANSFORM_SKEW;//		=  1 << 3,

	//! All possible transformation enabled. Default value.
	CC_HONOR_PARENT_TRANSFORM_ALL;//		=  CC_HONOR_PARENT_TRANSFORM_TRANSLATE | CC_HONOR_PARENT_TRANSFORM_ROTATE | CC_HONOR_PARENT_TRANSFORM_SCALE | CC_HONOR_PARENT_TRANSFORM_SKEW,
}

/** CCSprite is a 2d image ( http://en.wikipedia.org/wiki/Sprite_(computer_graphics) )
 *
 * CCSprite can be created with an image, or with a sub-rectangle of an image.
 *
 * If the parent or any of its ancestors is a CCSpriteBatchNode then the following features/limitations are valid
 *	- Features when the parent is a CCBatchNode:
 *		- MUCH faster rendering, specially if the CCSpriteBatchNode has many children. All the children will be drawn in a single batch.
 *
 *	- Limitations
 *		- Camera is not supported yet (eg: CCOrbitCamera action doesn't work)
 *		- GridBase actions are not supported (eg: CCLens, CCRipple, CCTwirl)
 *		- The Alias/Antialias property belongs to CCSpriteBatchNode, so you can't individually set the aliased property.
 *		- The Blending function property belongs to CCSpriteBatchNode, so you can't individually set the blending function property.
 *		- Parallax scroller is not supported, but can be simulated with a "proxy" sprite.
 *
 *  If the parent is an standard CCNode, then CCSprite behaves like any other CCNode:
 *    - It supports blending functions
 *    - It supports aliasing / antialiasing
 *    - But the rendering will be slower: 1 draw per children.
 *
 * The default anchorPoint in CCSprite is (0.5, 0.5).
 */
class CCSprite extends CCNode
{

inline static var CCSpriteIndexNotInitialized = -1;

//
// Data used when the sprite is rendered using a CCSpriteBatchNode
//
var texture_ :CCTexture2D;
var batchNode_ :CCSpriteBatchNode;			// Used batch node (weak reference)
var recursiveDirty_ :Bool;		// Subchildren needs to be updated
var hasChildren_ :Bool;			// optimization to check if it contain children

// texture
var rect_ :CGRect;
var rectInPixels_ :CGRect;
var rectRotated_ :Bool;

// Offset Position (used by Zwoptex)
var offsetPositionInPixels_ :CGPoint;
var unflippedOffsetPositionFromCenter_ :CGPoint;

// vertex coords, texture coords and color info
var quad_ :CC_V3F_C4B_T2F_Quad;

// opacity and RGB protocol
var	color_ :CC_Color3B;
var colorUnmodified_ :CC_Color3B;
var opacity_ :Int;
var opacityModifyRGB_ :Bool;

/** whether or not the Sprite needs to be updated in the Atlas */
public var dirty :Bool;
/** the quad (tex coords, vertex coords and color) information */
public var quad (get, null) :CC_V3F_C4B_T2F_Quad;
/** The index used on the TextureAtlas. Don't modify this value unless you know what you are doing */
// Absolute (real) Index on the batch node
public var atlasIndex :Int;
/** returns the rect of the CCSprite in points */
public var textureRect (get, null) :CGRect;
/** returns whether or not the texture rectangle is rotated */
public var textureRectRotated (get, null) :Bool;
/** whether or not the sprite is flipped horizontally. 
 It only flips the texture of the sprite, and not the texture of the sprite's children.
 Also, flipping the texture doesn't alter the anchorPoint.
 If you want to flip the anchorPoint too, and/or to flip the children too use:

	sprite.scaleX *= -1;
 */
public var flipX (default, set) :Bool;
/** whether or not the sprite is flipped vertically.
 It only flips the texture of the sprite, and not the texture of the sprite's children.
 Also, flipping the texture doesn't alter the anchorPoint.
 If you want to flip the anchorPoint too, and/or to flip the children too use:

	sprite.scaleY *= -1;
 */
public var flipY (default, set) :Bool;
/** opacity: conforms to CCRGBAProtocol protocol */
public var opacity (get, set) :Int;
/** RGB colors: conforms to CCRGBAProtocol protocol */
public var color (get, set) :CC_Color3B;
/** whether or not the Sprite is rendered using a CCSpriteBatchNode */
// whether or not it's parent is a CCSpriteBatchNode
public var usesBatchNode :Bool;
/** weak reference of the CCTextureAtlas used when the sprite is rendered using a CCSpriteBatchNode */
public var textureAtlas :CCTextureAtlas;
// Texture used to render the sprite
public var texture (get, set) :CCTexture2D;
/** weak reference to the CCSpriteBatchNode that renders the CCSprite */
public var batchNode :CCSpriteBatchNode;
/** whether or not to transform according to its parent transfomrations.
 Useful for health bars. eg: Don't rotate the health bar, even if the parent rotates.
 IMPORTANT: Only valid if it is rendered using an CCSpriteBatchNode.
 @since v0.99.0
 */
public var honorParentTransform :CCHonorParentTransform;
/** offset position in pixels of the sprite in points. Calculated automatically by editors like Zwoptex.
 @since v0.99.0
 */
public var offsetPositionInPixels (get, null) :CGPoint;
/** conforms to CCTextureProtocol protocol */
public var blendFunc :CC_BlendFunc;

// CCSprite - Initializers

/** Creates an sprite with a texture.
 The rect used will be the size of the texture.
 The offset will be (0,0).
 */
public static function spriteWithTexture (texture:CCTexture2D, ?rect:CGRect) :CCSprite
{
	return new CCSprite().initWithTexture (texture, rect);
}

/** Creates an sprite with an image filename.
 The rect used will be the size of the image.
 The offset will be (0,0).
 */
public static function spriteWithFile (filename:String, ?rect:CGRect) :CCSprite
{
	return new CCSprite().initWithFileAndRect (filename, rect);
}

/** Creates an sprite with an sprite frame.
 */
public static function spriteWithSpriteFrame (spriteFrame:CCSpriteFrame) :CCSprite
{
	return new CCSprite().initWithSpriteFrame ( spriteFrame );
}

/** Creates an sprite with an sprite frame name.
 An CCSpriteFrame will be fetched from the CCSpriteFrameCache by name.
 If the CCSpriteFrame doesn't exist it will raise an exception.
 @since v0.9
 */
public static function spriteWithSpriteFrameName (spriteFrameName:String) :CCSprite
{
	var frame:CCSpriteFrame = CCSpriteFrameCache.sharedSpriteFrameCache().spriteFrameByName ( spriteFrameName );
	
	if(frame==null) throw "Invalid spriteFrameName: "+spriteFrameName;
	return spriteWithSpriteFrame ( frame );
}

/** Creates an sprite with a CGImageRef and a key.
 The key is used by the CCTextureCache to know if a texture was already created with this CGImage.
 For example, a valid key is: "sprite_frame_01".
 If key is null, then a new texture will be created each time by the CCTextureCache. 
 @since v0.99.0
 */
public static function spriteWithCGImage (image:UIImage, key:String) :CCSprite
{
	return new CCSprite().initWithUIImage (image, key);
}

/** Creates an sprite with an CCBatchNode and a rect
 */
public static function spriteWithBatchNode (batchNode:CCSpriteBatchNode, rect:CGRect) :CCSprite
{
	return new CCSprite().initWithBatchNode (batchNode, rect);
}



override public function init () :CCNode
{
	trace("init");
	super.init();
	dirty = recursiveDirty_ = false;
	unflippedOffsetPositionFromCenter_ = new CGPoint();
	
	// by default use "Self Render".
	// if the sprite is added to a batchnode, then it will automatically switch to "batchnode Render"
	//this.useSelfRender();
	
	opacityModifyRGB_ = true;
	opacity_ = 255;
	color_ = colorUnmodified_ = CCTypes.ccWHITE;
	
/*	blendFunc.src = CC_BLEND_SRC;
	blendFunc.dst = CC_BLEND_DST;*/
	
	// update texture (calls updateBlendFunc)
	//this.set_texture(null);
	
	// clean the Quad
	//bzero(&quad_, sizeof(quad_));
	
	flipY = flipX = false;
	
	// default transform anchor: center
	anchorPoint_ = new CGPoint (0.5, 0.5);
	
	// zwoptex default values
	offsetPositionInPixels_ = new CGPoint (0.0, 0.0);
	
	honorParentTransform = CC_HONOR_PARENT_TRANSFORM_ALL;
	hasChildren_ = false;
	
	// Atlas: Color
	var tmpColor :CC_Color4B = {r:255,g:255,b:255,a:255};
	var tmpVertices :CC_Vertex3F = { x:0.0, y:0.0, z:0.0 };
	var tmpCoords :CC_Tex2F = { u:0.0, v:0.0 };
	var tmp = { vertices:tmpVertices, colors:tmpColor, texCoords:tmpCoords };
	quad_ = { bl : tmp, br : tmp, tl : tmp, tr : tmp };
	
	// Atlas: Vertex
	// updated in "useSelfRender"
	// Atlas: TexCoords
	this.set_textureRectInPixels (new CGRect(0,0,0,0), false, new CGSize(0,0));
	
	// updateMethod selector
	//updateMethod = (__typeof__(updateMethod))this.methodForSelector:@selector(updateTransform)();
	
	this.useSelfRender();
	
	return this;
}


/** Initializes an sprite with a texture and a rect in points.
 The offset will be (0,0).
 */
public function initWithTexture (texture:CCTexture2D, rect:CGRect)
{
	if(texture==null) throw "Invalid texture for sprite";
	trace("initWithTexture "+texture);trace(rect);
	if (rect == null) {
		rect = new CGRect(0,0,0,0);
		rect.size = texture.contentSizeInPixels;
	}
	// IMPORTANT: this.init() and not super.init();
	this.init();
	this.set_texture ( texture );
	this.set_textureRect ( rect );
	
	return this;
}

/** Initializes an sprite with an image filename.
 The rect used will be the size of the image.
 The offset will be (0,0).
 */
public function initWithFile (filename:String) :CCSprite
{
	if (filename==null) throw "Invalid filename for sprite: "+filename;
	
	var texture :CCTexture2D = CCTextureCache.sharedTextureCache().addImage ( filename );
	if (texture != null) {
		var rect = new CGRect(0,0,0,0);
		rect.size = texture.contentSize;
		trace(rect);
		return initWithTexture (texture, rect);
	}
	this.release();
	return null;
}
public function initWithFileAndRect (filename:String, rect:CGRect) :CCSprite
{
	trace("initWithFileAndRect "+filename+", "+rect);
	if(filename==null) throw "Invalid filename for sprite";
	
	var texture :CCTexture2D = CCTextureCache.sharedTextureCache().addImage ( filename );
	if( texture != null )
		return this.initWithTexture (texture, rect);

	this.release();
	return null;
}


/** Initializes an sprite with an sprite frame.
 */
public function initWithSpriteFrame (spriteFrame:CCSpriteFrame) :CCSprite
{
	if(spriteFrame==null) throw "Invalid spriteFrame for sprite";

	var ret = this.initWithTexture (spriteFrame.texture, spriteFrame.rect);
	this.set_displayFrame ( spriteFrame );
	return ret;
}

/** Initializes an sprite with an sprite frame name.
 An CCSpriteFrame will be fetched from the CCSpriteFrameCache by name.
 If the CCSpriteFrame doesn't exist it will raise an exception.
 @since v0.9
 */
public function initWithSpriteFrameName (spriteFrameName:String) :CCSprite
{
	if(spriteFrameName==null) throw "Invalid spriteFrameName for sprite";

	var frame :CCSpriteFrame = CCSpriteFrameCache.sharedSpriteFrameCache().spriteFrameByName(spriteFrameName);
	return this.initWithSpriteFrame(frame);
}

/** Initializes an sprite with a CGImageRef and a key
 The key is used by the CCTextureCache to know if a texture was already created with this CGImage.
 For example, a valid key is: "sprite_frame_01".
 If key is null, then a new texture will be created each time by the CCTextureCache. 
 @since v0.99.0
 */
public function initWithUIImage (image:UIImage, key:String)
{
	if(image==null) throw "Invalid CGImageRef for sprite";
	
	// XXX: possible bug. See issue #349. New API should be added
	var texture :CCTexture2D = CCTextureCache.sharedTextureCache().addUIImage (image, key);
	
	var rect = new CGRect(0,0,0,0);
	rect.size = texture.contentSize;
	
	return this.initWithTexture (texture, rect);
}

/** Initializes an sprite with an CCSpriteBatchNode and a rect in points
	Initializes an sprite with an CCSpriteBatchNode and a rect in pixels
 */
public function initWithBatchNode(batchNode:CCSpriteBatchNode, rect:CGRect, rectIsInPixels:Bool=false) :CCSprite
{
	var ret = null;
	
	if (rectIsInPixels) {
		ret = this.initWithTexture (batchNode.texture, rect);
		this.set_textureRectInPixels (rect, false, rect.size);
		this.useBatchNode ( batchNode );
	}
	else {
		ret = this.initWithTexture (batchNode.texture, rect);
		this.useBatchNode ( batchNode );
	}
	
	return ret;
}

override public function toString () :String
{
	return "<CCSprite | Rect = ("+rect_+") | tag = "+tag+" | atlasIndex = "+atlasIndex+", position = "+position_;
}

override public function release ()
{
	if (texture_ != null)
		texture_.release();
	super.release();
}

/** tell the sprite to use this-render.
 @since v0.99.0
 */
public function useSelfRender ()
{
	atlasIndex = CCSpriteIndexNotInitialized;
	usesBatchNode = false;
	textureAtlas = null;
	batchNode_ = null;
	dirty = recursiveDirty_ = false;
	
	var x1 :Float = 0 + offsetPositionInPixels_.x;
	var y1 :Float = 0 + offsetPositionInPixels_.y;
	var x2 :Float = x1 + rectInPixels_.size.width;
	var y2 :Float = y1 + rectInPixels_.size.height;
	quad_.bl.vertices = { x:x1, y:y1, z:0.0 };
	quad_.br.vertices = { x:x2, y:y1, z:0.0 };
	quad_.tl.vertices = { x:x1, y:y2, z:0.0 };
	quad_.tr.vertices = { x:x2, y:y2, z:0.0 };
}

/** tell the sprite to use sprite batch node
 @since v0.99.0
 */
public function useBatchNode (batchNode:CCSpriteBatchNode)
{
	usesBatchNode = true;
	textureAtlas = batchNode.textureAtlas; // weak ref
	batchNode_ = batchNode; // weak ref
}

/** updates the texture rect of the CCSprite in points.
 */
public function set_textureRect (rect:CGRect)
{
	trace("set_textureRect "+rect);
	var rectInPixels :CGRect = CCMacros.CC_RECT_POINTS_TO_PIXELS( rect );
	this.set_textureRectInPixels (rectInPixels, false, /*untrimmedSize (*/rectInPixels.size);
}

/** updates the texture rect, rectRotated and untrimmed size of the CCSprite in pixels
 */
public function set_textureRectInPixels (rect:CGRect, rotated:Bool, untrimmedSize:CGSize) :Void
{
	trace("set_textureRectInPixels "+rect+", untrimmedSize "+untrimmedSize);
	rectInPixels_ = rect;
	rect_ = CCMacros.CC_RECT_PIXELS_TO_POINTS ( rect );
	rectRotated_ = rotated;

	this.set_contentSizeInPixels ( untrimmedSize );
	this.updateTextureCoords ( rectInPixels_ );

	var relativeOffsetInPixels :CGPoint = unflippedOffsetPositionFromCenter_;
	
	// issue #732
	if( flipX )
		relativeOffsetInPixels.x = -relativeOffsetInPixels.x;
	if( flipY )
		relativeOffsetInPixels.y = -relativeOffsetInPixels.y;
	
	offsetPositionInPixels_.x = relativeOffsetInPixels.x + (contentSizeInPixels.width - rectInPixels_.size.width) / 2;
	offsetPositionInPixels_.y = relativeOffsetInPixels.y + (contentSizeInPixels.height - rectInPixels_.size.height) / 2;
	
	// rendering using batch node
	if( usesBatchNode ) {
		// update dirty, don't update recursiveDirty_
		dirty = true;
	}

	// this rendering
	else {
		// Atlas: Vertex
		var x1 :Float = 0 + offsetPositionInPixels_.x;
		var y1 :Float = 0 + offsetPositionInPixels_.y;
		var x2 :Float = x1 + rectInPixels_.size.width;
		var y2 :Float = y1 + rectInPixels_.size.height;
		
		// Don't update Z.
		quad_.bl.vertices = { x:x1, y:y1, z:0.0 };
		quad_.br.vertices = { x:x2, y:y1, z:0.0 };
		quad_.tl.vertices = { x:x1, y:y2, z:0.0 };
		quad_.tr.vertices = { x:x2, y:y2, z:0.0 };
	}
}

public function updateTextureCoords (rect:CGRect)
{
	trace("updateTextureCoords "+rect);
	var tex :CCTexture2D = (usesBatchNode) ? textureAtlas.texture : texture_;
	if(tex == null)
		return;
	
	var atlasWidth :Float = tex.pixelsWide;
	var atlasHeight :Float = tex.pixelsHigh;
	var left:Float, right:Float, top:Float, bottom:Float;
	
	if(rectRotated_){
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		left	= (2*rect.origin.x+1)/(2*atlasWidth);
		right	= left+(rect.size.height*2-2)/(2*atlasWidth);
		top		= (2*rect.origin.y+1)/(2*atlasHeight);
		bottom	= top+(rect.size.width*2-2)/(2*atlasHeight);
#else
		left	= rect.origin.x/atlasWidth;
		right	= left+(rect.size.height/atlasWidth);
		top		= rect.origin.y/atlasHeight;
		bottom	= top+(rect.size.width/atlasHeight);
#end // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		
		if( flipX) {
			var obj = CCMacros.CC_SWAP (top,bottom);// Returns {x, y}
			top = obj.x;
			bottom = obj.y;
		}
		if( flipY) {
			var obj = CCMacros.CC_SWAP (left,right);
			left = obj.x;
			right = obj.y;
		}
		
		quad_.bl.texCoords.u = left;
		quad_.bl.texCoords.v = top;
		quad_.br.texCoords.u = left;
		quad_.br.texCoords.v = bottom;
		quad_.tl.texCoords.u = right;
		quad_.tl.texCoords.v = top;
		quad_.tr.texCoords.u = right;
		quad_.tr.texCoords.v = bottom;
	} else {
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		left	= (2*rect.origin.x+1)/(2*atlasWidth);
		right	= left + (rect.size.width*2-2)/(2*atlasWidth);
		top		= (2*rect.origin.y+1)/(2*atlasHeight);
		bottom	= top + (rect.size.height*2-2)/(2*atlasHeight);
#else
		left	= rect.origin.x/atlasWidth;
		right	= left + rect.size.width/atlasWidth;
		top		= rect.origin.y/atlasHeight;
		bottom	= top + rect.size.height/atlasHeight;
#end // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		
		if( flipX) {
			var obj = CCMacros.CC_SWAP (left,right);
			left = obj.x;
			right = obj.y;
		}
		if( flipY) {
			var obj = CCMacros.CC_SWAP (top,bottom);// Returns {x, y}
			top = obj.x;
			bottom = obj.y;
		}
		
		quad_.bl.texCoords.u = left;
		quad_.bl.texCoords.v = bottom;
		quad_.br.texCoords.u = right;
		quad_.br.texCoords.v = bottom;
		quad_.tl.texCoords.u = left;
		quad_.tl.texCoords.v = top;
		quad_.tr.texCoords.u = right;
		quad_.tr.texCoords.v = top;
	}
}

// CCSprite - BatchNode methods

/** updates the quad according the the rotation, position, scale values.
 */
public function updateTransform ()
{
	if( !usesBatchNode) throw "updateTransform is only valid when CCSprite is being renderd using an CCSpriteBatchNode";

	// optimization. Quick return if not dirty
	if( ! dirty )
		return;
	
	var matrix :CGAffineTransform;
	
	// Optimization: if it is not visible, then do nothing
	if( ! visible ) {
		quad_.br.vertices = quad_.tl.vertices = quad_.tr.vertices = quad_.bl.vertices = {x:0.0, y:0.0, z:0.0};
		//textureAtlas.updateQuad (&quad_, atlasIndex);
		dirty = recursiveDirty_ = false;
		return;
	}
	

	// Optimization: If parent is batchnode, or parent is null
	// build Affine transform manually
	if( parent == null || parent == batchNode_ ) {
		
		var radians :Float = -CCMacros.CC_DEGREES_TO_RADIANS(rotation);
		var c :Float = Math.cos(radians);
		var s :Float = Math.sin(radians);

		matrix = new CGAffineTransform( c * scaleX,  s * scaleX,
									   -s * scaleY, c * scaleY,
									   positionInPixels.x, positionInPixels.y);
		if( skewX != null || skewY != null ) {
			var skewMatrix :CGAffineTransform = new CGAffineTransform(	1.0, Math.tan( CCMacros.CCMacros.CC_DEGREES_TO_RADIANS(skewY) ),
																 		Math.tan( CCMacros.CCMacros.CC_DEGREES_TO_RADIANS(skewX) ), 1.0,
																 		0.0, 0.0);
			matrix.concat ( skewMatrix );
		}
		matrix.translate (-anchorPointInPixels_.x, -anchorPointInPixels_.y);

		
	} else { 	// parent_ != batchNode_ 

		// else do affine transformation according to the HonorParentTransform

		matrix = new CGAffineTransform().identity();
		var prevHonor :CCHonorParentTransform = CC_HONOR_PARENT_TRANSFORM_ALL;
		
		var p :CCNode = this;
		while (p !=null && p != batchNode_) {
			
			// Might happen. Issue #1053
			if( !Std.is(p, CCSprite)) throw "CCSprite should be a CCSprite subclass. Probably you initialized an sprite with a batchnode, but you didn't add it to the batch node.";

			var tv :Dynamic = cast(p, CCSprite).getTransformValues();
			
			// If any of the parents are not visible, then don't draw this node
			if( ! tv.visible ) {
				quad_.br.vertices = quad_.tl.vertices = quad_.tr.vertices = quad_.bl.vertices = {x:0.0, y:0.0, z:0.0};
				//textureAtlas.updateQuad:&quad_.atIndex ( atlasIndex );
				dirty = recursiveDirty_ = false;
				return;
			}
			var newMatrix :CGAffineTransform = new CGAffineTransform().identity();
			
			// 2nd: Translate, Skew, Rotate, Scale
			if( prevHonor == CC_HONOR_PARENT_TRANSFORM_TRANSLATE )
				newMatrix.translate(tv.pos.x, tv.pos.y);
			if( prevHonor == CC_HONOR_PARENT_TRANSFORM_ROTATE )
				newMatrix.rotate(-CCMacros.CC_DEGREES_TO_RADIANS(tv.rotation));
			if( prevHonor == CC_HONOR_PARENT_TRANSFORM_SKEW ) {
				var skew :CGAffineTransform = new CGAffineTransform (1.0, Math.tan(CCMacros.CC_DEGREES_TO_RADIANS(tv.skew.y)), Math.tan(CCMacros.CC_DEGREES_TO_RADIANS(tv.skew.x)), 1.0, 0.0, 0.0);
				// apply the skew to the transform
				//newMatrix = CGAffineTransformConcat(skew, newMatrix);
				newMatrix.concat(skew);
			}
			if( prevHonor == CC_HONOR_PARENT_TRANSFORM_SCALE ) {
				newMatrix.scale(tv.scale.x, tv.scale.y);
			}
			
			// 3rd: Translate anchor point
			newMatrix.translate (-tv.ap.x, -tv.ap.y);

			// 4th: Matrix multiplication
			matrix.concat( newMatrix );
			
			prevHonor = cast(p).honorParentTransform;
			
			p = p.parent;
		}
	}
	
	
	//
	// calculate the Quad based on the Affine Matrix
	//	

	var size :CGSize = rectInPixels_.size;

	var x1 :Float = offsetPositionInPixels_.x;
	var y1 :Float = offsetPositionInPixels_.y;
	
	var x2 :Float = x1 + size.width;
	var y2 :Float = y1 + size.height;
	var x :Float = matrix.tx;
	var y :Float = matrix.ty;
	
	var cr :Float = matrix.a;
	var sr :Float = matrix.b;
	var cr2 :Float = matrix.d;
	var sr2 :Float = -matrix.c;
	var ax :Float = x1 * cr - y1 * sr2 + x;
	var ay :Float = x1 * sr + y1 * cr2 + y;
	
	var bx :Float = x2 * cr - y1 * sr2 + x;
	var by :Float = x2 * sr + y1 * cr2 + y;
	
	var cx :Float = x2 * cr - y2 * sr2 + x;
	var cy :Float = x2 * sr + y2 * cr2 + y;
	
	var dx :Float = x1 * cr - y2 * sr2 + x;
	var dy :Float = x1 * sr + y2 * cr2 + y;
	
	quad_.bl.vertices = { x:RENDER_IN_SUBPIXEL(ax), y:RENDER_IN_SUBPIXEL(ay), z:vertexZ_ };
	quad_.br.vertices = { x:RENDER_IN_SUBPIXEL(bx), y:RENDER_IN_SUBPIXEL(by), z:vertexZ_ };
	quad_.tl.vertices = { x:RENDER_IN_SUBPIXEL(dx), y:RENDER_IN_SUBPIXEL(dy), z:vertexZ_ };
	quad_.tr.vertices = { x:RENDER_IN_SUBPIXEL(cx), y:RENDER_IN_SUBPIXEL(cy), z:vertexZ_ };
	
	//textureAtlas.updateQuad (&quad_, atlasIndex);
	dirty = recursiveDirty_ = false;
}

// XXX: Optimization: instead of calling 5 times the parent sprite to obtain: position, scale.x, scale.y, anchorpoint and rotation,
// this fuction return the 5 values in 1 single call
public function getTransformValues () :TransformValues
{
	var tv :TransformValues = {
		pos :positionInPixels,
		scale :new CGPoint(scaleX, scaleY),
		rotation :rotation,
		skew :new CGPoint(skewX, skewY),
		ap :anchorPointInPixels_,
		visible :visible
	};
	return tv;
}

// CCSprite - draw

override public function draw ()
{
	//trace("draw the texture with size "+contentSize);
	
	this.view_.graphics.beginBitmapFill ( texture_.data, new flash.geom.Matrix(), false, true);
	this.view_.graphics.drawRect (0, 0, contentSize.width, contentSize.height);
	this.view_.graphics.endFill();
	flash.Lib.current.addChild ( this.view_ );
	
/*
	if (!usesBatchNode, "If CCSprite is being rendered by CCSpriteBatchNode, CCSprite#draw SHOULD NOT be called");

	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Unneeded states: -

	var newBlend :Bool = blendFunc.src != CC_BLEND_SRC || blendFunc.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc.src, blendFunc.dst );

#define kQuadSize sizeof(quad_.bl)
	glBindTexture(GL.TEXTURE_2D, texture.name]);
	
	var offset :long = (long)&quad_;
	
	// vertex
	var diff :Int = offsetof( CC_V3F_C4B_T2F, vertices);
	glVertexPointer(3, GL.FLOAT, kQuadSize, (void*) (offset + diff) );
	
	// color
	diff = offsetof( CC_V3F_C4B_T2F, colors);
	glColorPointer(4, GL.UNSIGNED_BYTE, kQuadSize, (void*)(offset + diff));
	
	// tex coords
	diff = offsetof( CC_V3F_C4B_T2F, texCoords);
	glTexCoordPointer(2, GL.FLOAT, kQuadSize, (void*)(offset + diff));
	
	glDrawArrays(GL.TRIANGLE_STRIP, 0, 4);
	
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	s:CGSize = this.contentSize;
	var vertices[4] :CGPoint = {
		new CGPoint (0,0), new CGPoint (s.width,0),
		new CGPoint (s.width,s.height), new CGPoint (0,s.height)
	};
	CC_rawPoly(vertices, 4, true);
#else CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	s:CGSize = this.texture_Rect.size;
	var offsetPix :CGPoint = this.offsetPositionInPixels;
	var vertices[4] :CGPoint = {
		new CGPoint (offsetPix.x,offsetPix.y), new CGPoint (offsetPix.x+s.width,offsetPix.y),
		new CGPoint (offsetPix.x+s.width,offsetPix.y+s.height), new CGPoint (offsetPix.x,offsetPix.y+s.height)
	};
	CC_rawPoly(vertices, 4, true);
#end // CC_SPRITE_DEBUG_DRAW
	*/
}

// CCSprite - CCNode overrides

override public function addChild (child:CCNode, ?z:Null<Int>, ?tag:Null<Int>, ?pos:haxe.PosInfos) :Void
{
	trace("addChild");
	if (child == null) throw "child must be non-null";
	
	super.addChild (child, z, tag, pos);
	
	if( usesBatchNode ) {
		if( !Std.is(child,CCSprite)) throw "CCSprite only supports CCSprites as children when using CCSpriteBatchNode";
		if( cast(child).texture.name != textureAtlas.texture.name) throw "CCSprite is not using the same texture id";
		
		var index :Int = batchNode_.atlasIndexForChild (cast(child), z);
		batchNode_.insertChild (cast(child), index);
	}
	
	hasChildren_ = true;
}

override function reorderChild (child:CCNode, z:Int) :Void
{
	if ( child == null ) throw "Child must be non-null";
	if ( children_.containsObject(child)) throw "Child doesn't belong to Sprite";
	if ( z == child.zOrder )
		return;

	if( usesBatchNode ) {
		// XXX: Instead of removing/adding, it is more efficient to reorder manually
		this.removeChild (child, false);
		this.addChild (child, z);
		child.release();
	}
	else
		super.reorderChild (child, z);
}

override public function removeChild (sprite:CCNode , doCleanup:Bool) :Void
{
	if( usesBatchNode )
		batchNode_.removeSpriteFromAtlas ( cast(sprite) );

	super.removeChild (sprite, doCleanup);
	
	hasChildren_ = ( children_.length > 0 );
}

override public function removeAllChildrenWithCleanup (doCleanup:Bool)
{
	if( usesBatchNode ) {
		for(child in children_)
			batchNode_.removeSpriteFromAtlas ( cast(child, CCSprite) );
	}
	
	super.removeAllChildrenWithCleanup ( doCleanup );
	
	hasChildren_ = false;
}

//
// CCNode property overloads
// used only when parent is CCSpriteBatchNode
//
// CCSprite - property overloads

public function setDirtyRecursively (b:Bool)
{
	dirty = recursiveDirty_ = b;
	// recursively set dirty
	if( hasChildren_ ) {
		var child :CCSprite = null;
		for (child in children_)
			cast(child).setDirtyRecursively(true);
	}
}

// XXX HACK: optimization
function SET_DIRTY_RECURSIVELY() {
	if( usesBatchNode && ! recursiveDirty_ ) {
		dirty = recursiveDirty_ = true;
		if( hasChildren_ )
			this.setDirtyRecursively(true);
	}
}

override public function set_position(pos:CGPoint) :CGPoint
{
	super.set_position(pos);
	SET_DIRTY_RECURSIVELY();
	return pos;
}

override function set_positionInPixels(pos:CGPoint) :CGPoint
{
	super.set_positionInPixels(pos);
	SET_DIRTY_RECURSIVELY();
	return pos;
}

override function set_rotation(rot:Float) :Float
{
	super.set_rotation(rot);
	SET_DIRTY_RECURSIVELY();
	return rot;
}

override public function set_skewX(sx:Null<Float>) :Null<Float>
{
	super.set_skewX(sx);
	SET_DIRTY_RECURSIVELY();
	return sx;
}

override public function set_skewY(sy:Null<Float>) :Null<Float>
{
	super.set_skewY(sy);
	SET_DIRTY_RECURSIVELY();
	return sy;
}

override function set_scaleX(sx:Float) :Float
{
	super.set_scaleX(sx);
	SET_DIRTY_RECURSIVELY();
	return sx;
}

override function set_scaleY(sy:Float) :Float
{
	super.set_scaleY(sy);
	SET_DIRTY_RECURSIVELY();
	return sy;
}

override function set_scale(s:Float) :Float
{
	super.set_scale(s);
	SET_DIRTY_RECURSIVELY();
	return s;
}

override function set_vertexZ(z:Float) :Float
{
	super.set_vertexZ(z);
	SET_DIRTY_RECURSIVELY();
	return z;
}

override function set_anchorPoint(anchor:CGPoint) :CGPoint
{
	super.set_anchorPoint(anchor);
	SET_DIRTY_RECURSIVELY();
	return anchor;
}

override function set_isRelativeAnchorPoint(relative:Bool) :Bool
{
	if(usesBatchNode) throw "relativeTransformAnchor is invalid in CCSprite";
	return super.set_isRelativeAnchorPoint(relative);
}

override function set_visible (v:Bool) :Bool
{
	super.set_visible(v);
	SET_DIRTY_RECURSIVELY();
	return v;
}

function set_flipX(v:Bool) :Bool
{
	if( flipX != v ) {
		flipX = v;
		this.set_textureRectInPixels (rectInPixels_, rectRotated_, contentSizeInPixels);
	}
	return v;
}

function set_flipY(v:Bool) :Bool
{
	if( flipY != v ) {
		flipY = v;	
		this.set_textureRectInPixels (rectInPixels_, rectRotated_, contentSizeInPixels);
	}
	return v;
}



function get_quad () :CC_V3F_C4B_T2F_Quad {
	return quad_;
}
function get_textureRect () :CGRect {
	return rect_;
}
function get_textureRectRotated () :Bool {
	return rectRotated_;
}
function get_offsetPositionInPixels () :CGPoint {
	return offsetPositionInPixels_;
}



//
// RGBA protocol
//
// CCSprite - RGBA protocol
public function updateColor ()
{
	var color4 :CC_Color4B = { r:color_.r, g:color_.g, b:color_.b, a:Math.round(opacity/100*255) };
	
	quad_.bl.colors = color4;
	quad_.br.colors = color4;
	quad_.tl.colors = color4;
	quad_.tr.colors = color4;
	
	// renders using Sprite Manager
	if( usesBatchNode ) {
		if( atlasIndex != -1)
			textureAtlas.updateQuad (quad_, atlasIndex);
		else
			// no need to set it recursively
			// update dirty, don't update recursiveDirty_
			dirty = true;
	}
	// this render
	// do nothing
}

public function set_opacity (anOpacity:Int) :Int
{
	opacity_ = anOpacity;

	// special opacity for premultiplied textures
	if( opacityModifyRGB_ )
		set_color ( colorUnmodified_ );
	
	this.updateColor();
	return opacity_;
}
public function get_opacity () :Int {
	return opacity_;
}

public function get_color () :CC_Color3B
{
	if(opacityModifyRGB_)
		return colorUnmodified_;
	
	return color_;
}

public function set_color (color3:CC_Color3B) :CC_Color3B
{
	if (color3 == null) throw "Set a non null color please";
	color_ = colorUnmodified_ = color3;
	
	if( opacityModifyRGB_ ){
		color_.r = Math.round (color3.r * opacity/255);
		color_.g = Math.round (color3.g * opacity/255);
		color_.b = Math.round (color3.b * opacity/255);
	}
	
	this.updateColor();
	return color_;
}

public function set_opacityModifyRGB (modify:Bool)
{
	var oldColor = get_color();
	opacityModifyRGB_ = modify;
	set_color ( oldColor );
}

public function doesOpacityModifyRGB () :Bool
{
	return opacityModifyRGB_;
}

//
// Frames
//
// CCSprite - Frames

public function set_displayFrame (frame:CCSpriteFrame)
{
	unflippedOffsetPositionFromCenter_ = frame.offsetInPixels;

	var newTexture :CCTexture2D = frame.texture;
	// update texture before updating texture rect
	if ( newTexture.name != texture_.name )
		this.set_texture ( newTexture );
	
	// update rect
	rectRotated_ = frame.rotated;
	this.set_textureRectInPixels (frame.rectInPixels, frame.rotated, frame.originalSizeInPixels);
}

// CCSprite - Animation

/** changes the display frame with animation name and index.
 The animation name will be get from the CCAnimationCache
 @since v0.99.5
 */
public function set_displayFrameWithAnimationName (animationName:String, frameIndex:Int) :Void
{
	if( animationName == null) throw "CCSprite#setDisplayFrameWithAnimationName. animationName must not be null";
	
	var a :CCAnimation = CCAnimationCache.sharedAnimationCache().animationByName ( animationName );
	if( a == null ) throw "CCSprite#setDisplayFrameWithAnimationName: Frame not found";
	
	var frame :CCSpriteFrame = a.frames.objectAtIndex ( frameIndex );
	if( frame == null ) throw "CCSprite#setDisplayFrame. Invalid frame";
	
	this.set_displayFrame ( frame );
}

/** returns whether or not a CCSpriteFrame is being displayed */
public function isFrameDisplayed (frame:CCSpriteFrame) :Bool
{
	return ( frame.rect.equalToRect ( rect_ ) && frame.texture.name == this.texture_.name );
}

/** returns the current displayed frame. */
public function displayedFrame () :CCSpriteFrame
{
	return CCSpriteFrame.frameWithTexture (	texture_,
											rectInPixels_,
											rectRotated_,
											unflippedOffsetPositionFromCenter_,
											contentSizeInPixels);
}

// CCSprite - CocosNodeTexture protocol

public function updateBlendFunc ()
{
/*	if ( usesBatchNode ) throw "CCSprite: updateBlendFunc doesn't work when the sprite is rendered using a CCSpriteBatchNode";

	// it's possible to have an untextured sprite
	if( texture_ == null || !texture_.hasPremultipliedAlpha ) {
		blendFunc.src = GL.SRC_ALPHA;
		blendFunc.dst = GL.ONE_MINUS_SRC_ALPHA;
		this.set_opacityModifyRGB (false);
	} else {
		blendFunc.src = CCMacros.CC_BLEND_SRC;
		blendFunc.dst = CCMacros.CC_BLEND_DST;
		this.set_opacityModifyRGB(true);
	}*/
}

function get_texture () :CCTexture2D {
	return texture_;
}
function set_texture (tex:CCTexture2D) :CCTexture2D
{
	trace("set_texture "+tex);
	if( usesBatchNode ) throw "CCSprite: set_texture doesn't work when the sprite is rendered using a CCSpriteBatchNode";
	
	// accept texture==null as argument
	if( !Std.is(tex, CCTexture2D)) throw "set_texture expects a CCTexture2D. Invalid argument";
	
	if (texture_ != null)
		texture_.release();
		texture_ = tex;
	
	this.updateBlendFunc();
	
	return texture_;
}

}
