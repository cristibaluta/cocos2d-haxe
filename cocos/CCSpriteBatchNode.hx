/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
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

import cocos.CCNode;
import cocos.CCTextureAtlas;
import cocos.CCMacros;
import cocos.CCConfig;
import cocos.CCSprite;
import cocos.CCGrid;
import cocos.CCDrawingPrimitives;
import cocos.CCTextureCache;
import cocos.CCTypes;
using cocos.support.CCArrayExtension;
using cocos.support.CGPointExtension;

/** CCSpriteBatchNode is like a batch node: if it contains children, it will draw them in 1 single OpenGL call
 * (often known as "batch draw").
 *
 * A CCSpriteBatchNode can reference one and only one texture (one image file, one texture atlas).
 * Only the CCSprites that are contained in that texture can be added to the CCSpriteBatchNode.
 * All CCSprites added to a CCSpriteBatchNode are drawn in one OpenGL ES draw call.
 * If the CCSprites are not added to a CCSpriteBatchNode then an OpenGL ES draw call will be needed for each one, which is less efficient.
 *
 *
 * Limitations:
 *  - The only object that is accepted as child (or grandchild, grand-grandchild, etc...) is CCSprite or any subclass of CCSprite. eg: particles, labels and layer can't be added to a CCSpriteBatchNode.
 *  - Either all its children are Aliased or Antialiased. It can't be a mix. This is because "alias" is a property of the texture, and all the sprites share the same texture.
 * 
 * @since v0.7.1
 */
class CCSpriteBatchNode extends CCNode
{
// all descendants: chlidren, gran children, etc...
var descendants_ :Array<CCNode>;
/** returns the TextureAtlas that is used */
public var textureAtlas :CCTextureAtlas;
public var texture (get_texture, set_texture) :CCTexture2D;
/** conforms to CCTextureProtocol protocol */
public var blendFunc :CC_BlendFunc;
/** descendants (children, gran children, etc) */
public var descendants (get_descendants, null) :Array<CCNode>;
public function get_descendants () :Array<CCNode> { return descendants_; }

static var defaultCapacity = 29;
static var selUpdate :Dynamic = null;


/*public static function initialize ()
{
	//if ( Std.is (this, CCSpriteBatchNode) ) {
	//	selUpdate = updateTransform();
	//}
}*/
/*
 * creation with CCTexture2D
 */
public static function batchNodeWithTexture (tex:CCTexture2D, ?capacity:Int=29 ) :CCSpriteBatchNode
{
	return new CCSpriteBatchNode().initWithTexture (tex, capacity);
}

/*
 * creation with File Image
 */
public static function batchNodeWithFile (fileImage:String, ?capacity:Int=29) :CCSpriteBatchNode
{
	return new CCSpriteBatchNode().initWithFile (fileImage, capacity);
}


/*
 * init with CCTexture2D
 */
public function initWithTexture (tex:CCTexture2D, capacity:Int) :CCSpriteBatchNode
{
	super.init();
		
/*	blendFunc.src = CC_BLEND_SRC;
	blendFunc.dst = CC_BLEND_DST;*/
	textureAtlas = new CCTextureAtlas().initWithTexture ( tex, capacity );
	
	this.updateBlendFunc();
	
	// no lazy alloc in this node
	children_ = new Array<CCNode>();
	descendants_ = new Array<CCNode>();
	
	return this;
}

/*
 * init with FileImage
 */
public function initWithFile (fileImage:String, capacity:Int) :CCSpriteBatchNode
{
	var tex :CCTexture2D = CCTextureCache.sharedTextureCache().addImage ( fileImage );
	return this.initWithTexture ( tex, capacity );
}

override public function toString () :String
{
	return "<CCSpriteBatchNode | Tag = "+tag+">";
}

override public function release () :Void
{	
	textureAtlas.release();
	descendants_ = null;
	
	super.release();
}

// CCSpriteBatchNode - composition

// override visit.
// Don't call visit on it's children
override public function visit ()
{
	
	// CAREFUL:
	// This visit is almost identical to CocosNode#visit
	// with the exception that it doesn't call visit on it's children
	//
	// The alternative is to have a void CCSprite#visit, but
	// although this is less mantainable, is faster
	//
	if (!visible)
		return;
	
	//glPushMatrix();
	
	if (grid != null && grid.active) {
		grid.beforeDraw();
		this.transformAncestors();
	}
	
	this.transform();
	this.draw();
	
	if (grid != null && grid.active)
		grid.afterDraw ( this );
	
	//glPopMatrix();
}


// override addChild:
override public function addChild (child:CCNode, ?z:Null<Int>, ?tag:Null<Int>, ?pos:haxe.PosInfos) :Void
{
	if (child == null) throw "Argument must be non-null";
	if (!Std.is (child, CCSprite)) throw "CCSpriteBatchNode only supports CCSprites as children";
	if (cast(child).texture.name == textureAtlas.texture.name) throw "CCSprite is not using the same texture id";
	
	super.addChild ( child, z, tag, pos );
	
	var index :Int = this.atlasIndexForChild ( cast child, z );
	this.insertChild ( child, index );	
}

// override reorderChild
override function reorderChild (child:CCNode, z:Int) :Void
{
	if (child == null) throw "Child must be non-null";
	if (!children_.containsObject ( child )) throw "Child doesn't belong to Sprite";
	
	if( z == child.zOrder )
		return;
	
	// XXX: Instead of removing/adding, it is more efficient to reorder manually
	this.removeChild ( child, false );
	this.addChild ( child, z );
}

// override removeChild:
override public function removeChild (sprite:CCNode, doCleanup:Bool) :Void
{
	// explicit null handling
	if (sprite == null)
		return;
	
	if (children_.containsObject ( sprite )) throw "CCSpriteBatchNode doesn't contain the sprite. Can't remove it";
	
	// cleanup before removing
	this.removeSpriteFromAtlas ( cast(sprite) );
	
	super.removeChild ( sprite, doCleanup );
}

public function removeChildAtIndex (index:Int, doCleanup:Bool) :Void
{
	this.removeChild (children_.objectAtIndex ( index ), doCleanup);
}

override public function removeAllChildrenWithCleanup ( doCleanup:Bool )
{
	// Invalidate atlas index. issue #569
	//children_.makeObjectsPerformSelector ( useSelfRender );
	
	super.removeAllChildrenWithCleanup ( doCleanup );
	
	descendants_.removeAllObjects();
	textureAtlas.removeAllQuads();
}

// CCSpriteBatchNode - draw
override public function draw ()
{
	super.draw();

	// Optimization: Fast Dispatch	
	if( textureAtlas.totalQuads == 0 )
		return;	
	
	var child :CCNode = null;
	var i :Int = descendants_.length;
	var arr :Array<CCNode> = descendants_;

	if( i > 0 ) {
		
		while (i-- > 0) {
			child = arr[i];
			// fast dispatch
			//child.updateMethod (child, selUpdate);
			
#if CC_SPRITEBATCHNODE_DEBUG_DRAW
			//Issue #528
			var rect :CGRect = child.boundingBox;
			var vertices :Array<CGPoint> = [
				new CGPoint (rect.origin.x, rect.origin.y),
				new CGPoint (rect.origin.x+rect.size.width, rect.origin.y),
				new CGPoint (rect.origin.x+rect.size.width, rect.origin.y+rect.size.height),
				new CGPoint (rect.origin.x, rect.origin.y+rect.size.height)
			];
			//CC_DrawPoly (vertices, 4, true);
#end // CC_SPRITEBATCHNODE_DEBUG_DRAW
		}
	}
	
	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Unneeded states: -
	
	textureAtlas.drawQuads();
}

// CCSpriteBatchNode - private
public function increaseAtlasCapacity ()
{
	// if we're going beyond the current TextureAtlas's capacity,
	// all the previously initialized sprites will need to redo their texture coords
	// this is likely computationally expensive
	var quantity :Int = Math.round ((textureAtlas.capacity + 1) * 4 / 3);
	
	trace("cocos2d: CCSpriteBatchNode: resizing TextureAtlas capacity from ["+textureAtlas.capacity+"] to ["+quantity+"].");
}


// CCSpriteBatchNode - Atlas Index Stuff

public function rebuildIndexInOrder (node:CCSprite, index:Int) :Int
{
	for(sprite in node.children_) {
		if( sprite.zOrder < 0 )
			index = this.rebuildIndexInOrder ( cast sprite, index );
	}
	
	// ignore this (batch node)
	if (cast (node, CCSpriteBatchNode) != this) {
		node.atlasIndex = index;
		index++;
	}
	
	for(sprite in node.children_) {
		if( sprite.zOrder >= 0 )
			index = this.rebuildIndexInOrder ( cast sprite, index );
	}
	
	return index;
}

public function highestAtlasIndexInChild (sprite:CCSprite) :Int
{
	var array :Array<CCNode> = sprite.children_;
	
	if( array.length == 0 )
		return sprite.atlasIndex;
	else
		return this.highestAtlasIndexInChild ( cast array.lastObject() );
}

public function lowestAtlasIndexInChild (sprite:CCSprite) :Int
{
	var array :Array<CCNode> = sprite.children_;
	
	if( array.length == 0 )
		return sprite.atlasIndex;
		return this.lowestAtlasIndexInChild ( cast(array[0]) );
}


public function atlasIndexForChild (sprite:CCSprite, z:Int) :Int
{
	var brothers :Array<CCNode> = sprite.parent.children_;
	var childIndex :Int = brothers.indexOfObject ( sprite );
	
	// ignore parent Z if parent is batchnode
	var ignoreParent :Bool = sprite.parent == this;
	var previous :CCSprite = null;
	if( childIndex > 0 )
		previous = cast brothers[childIndex-1];
	
	// first child of the sprite sheet
	if( ignoreParent ) {
		if( childIndex == 0 )
			return 0;
		// else
		return this.highestAtlasIndexInChild ( previous ) + 1;
	}
	
	// parent is a CCSprite, so, it must be taken into account
	
	// first child of an CCSprite ?
	if( childIndex == 0 )
	{
		var p :CCSprite = cast sprite.parent;
		
		// less than parent and brothers
		if( z < 0 )
			return p.atlasIndex;
		else
			return p.atlasIndex+1;
		
	} else {
		// previous & sprite belong to the same branch
		if( (previous.zOrder < 0 && z < 0) || (previous.zOrder >= 0 && z >= 0) )
			return this.highestAtlasIndexInChild (previous) + 1;
		
		// else (previous < 0 and sprite >= 0 )
		var p :CCSprite = cast sprite.parent;
		return p.atlasIndex + 1;
	}
	
	throw "Should not happen. Error calculating Z on Batch Node";
	return 0;
}

// CCSpriteBatchNode - add / remove / reorder helper methods
// add child helper
override public function insertChild (sprite:CCNode, index:Int) :Void
{
	cast (sprite, CCSprite).useBatchNode ( this );
	cast (sprite, CCSprite).atlasIndex = index;
	cast (sprite, CCSprite).dirty = true;
	
	if(textureAtlas.totalQuads == textureAtlas.capacity)
		this.increaseAtlasCapacity();
	
	var quad :CC_V3F_C4B_T2F_Quad = cast (sprite, CCSprite).quad;
	textureAtlas.insertQuad ( quad, index );
	
	var descendantsData = descendants_;
	
	descendantsData.insert (index, sprite);
	
	// update indices
	var i :Int = index+1;
	var child :CCSprite = null;
	while(i < descendantsData.length){
		child = cast descendantsData[i];
		child.atlasIndex = child.atlasIndex + 1;
		i++;
	}
	
	// add children recursively
	for (child in sprite.children_) {
		var idx :Int = this.atlasIndexForChild (cast child, child.zOrder);
		this.insertChild ( child, idx );
	}
}

// remove child helper
public function removeSpriteFromAtlas ( sprite:CCSprite )
{
	// remove from TextureAtlas
	textureAtlas.removeQuadAtIndex ( sprite.atlasIndex );
	
	// Cleanup sprite. It might be reused (issue #569)
	sprite.useSelfRender();
	
	var descendantsData = descendants_;
	var index :Int = descendantsData.indexOfObject( sprite );
	if( index != -1 ) {
		descendantsData.removeObjectAtIndex(index);
		
		// update all sprites beyond this one
		var count :Int = descendantsData.length;
		
		while(index < count)
		{
			var s :CCSprite = cast descendantsData[index];
			s.atlasIndex = s.atlasIndex - 1;
			index++;
		}
	}
	
	// remove children recursively
	for(child in sprite.children_)
		this.removeSpriteFromAtlas ( cast child );
}

// CCSpriteBatchNode - CocosNodeTexture protocol

public function updateBlendFunc ()
{
	if( ! textureAtlas.texture.hasPremultipliedAlpha ) {
		blendFunc.src = GL.SRC_ALPHA;
		blendFunc.dst = GL.ONE_MINUS_SRC_ALPHA;
	}
}

public function set_texture ( texture:CCTexture2D ) :CCTexture2D
{
	textureAtlas.texture = texture;
	this.updateBlendFunc();
	return textureAtlas.texture;
}

public function get_texture () :CCTexture2D
{
	return textureAtlas.texture;
}
}
