//
//  TMXTiledMapExtensions
//
//  Created by Baluta Cristian on 2011-11-17.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//

// -
// CCSpriteBatchNode Extension

/* IMPORTANT XXX IMPORTNAT:
 * These 2 methods can't be part of CCTMXLayer since they call super.add...], and CCSpriteBatchNode#add SHALL not be called
 */
class TMXTiledMapExtension//CCSpriteBatchNode

/* Adds a quad into the texture atlas but it won't be added into the children array.
 This method should be called only when you are dealing with very big AtlasSrite and when most of the CCSprite won't be updated.
 For example: a tile map (CCTMXMap) or a label with lots of characgers (CCLabelBMFont)
 */
public function addQuadFromSprite (sprite:CCSprite, index:Int) :Void
{
	if (sprite == null) throw "Argument must be non-null";
	if (Std.is (sprite, CCSprite)) throw "CCSpriteBatchNode only supports CCSprites as children";
	
	
	while(index >= textureAtlas_.capacity || textureAtlas_.capacity == textureAtlas_.totalQuads )
		this.increaseAtlasCapacity();

	//
	// update the quad directly. Don't add the sprite to the scene graph
	//

	sprite.useBatchNode ( this );
	sprite.setAtlasIndex ( index );

	var quad :CC_V3F_C4B_T2F_Quad = sprite.quad;
	textureAtlas_.insertQuad:&quad atIndex ( index );
	
	// XXX: updateTransform will update the textureAtlas too using updateQuad.
	// XXX: so, it should be AFTER the insertQuad
	sprite.setDirty ( true );
	sprite.updateTransform;
}

/* This is the opposite of "addQuadFromSprite.
 It add the sprite to the children and descendants array, but it doesn't update add it to the texture atlas
 */
public function addSpriteWithoutQuad (child:CCSprite, z:Int, aTag:Int) :id
{
	if (child == null) throw "Argument must be non-null";
	if (Std.is (child, CCSprite.class)) throw "CCSpriteBatchNode only supports CCSprites as children";
	
	// quad index is Z
	child.setAtlasIndex ( z );
	
	// XXX: optimize with a binary search
	var i=0;
	for( c in descendants_ ) {
		if( c.atlasIndex >= z )
			break;
		i++;
	}
	descendants_.insertObject ( child, i );
	
	
	// IMPORTANT: Call super, and not this. Avoid adding it to the texture atlas array
	super.addChild ( child, z, aTag );
	return this;	
}
}