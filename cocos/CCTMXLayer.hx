/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
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
 *
 * TMX Tiled Map support:
 * http://www.mapeditor.org
 *
 */
package cocos;

import cocos.CCAtlasNode;
import cocos.CCSpriteBatchNode;
import cocos.CCTMXXMLParser;// contains CCTMXMapInfo; CCTMXLayerInfo; CCTMXTilesetInfo;
import cocos.CCTMXTiledMap;
import cocos.CCSprite;
import cocos.CCSpriteBatchNode;
import cocos.CCTextureCache;
import cocos.support.CGSize;
import cocos.support.CGPoint;
import cocos.support.CGRect;
using cocos.support.CGPointExtension;
using cocos.support.CCArrayExtension;

/** CCTMXLayer represents the TMX layer.

 It is a subclass of CCSpriteBatchNode. By default the tiles are rendered using a CCTextureAtlas.
 If you mofify a tile on runtime, then, that tile will become a CCSprite, otherwise no CCSprite objects are created.
 The benefits of using CCSprite objects as tiles are:
 - tiles (CCSprite) can be rotated/scaled/moved with a nice API

 If the layer contains a property named "cc_vertexz" with an integer (in can be positive or negative),
 then all the tiles belonging to the layer will use that value as their OpenGL vertex Z for depth.

 On the other hand, if the "cc_vertexz" property has the "automatic" value, then the tiles will use an automatic vertex Z value.
 Also before drawing the tiles, GL.ALPHA_TEST will be enabled, and disabled after drawing them. The used alpha func will be:

    glAlphaFunc( GL.GREATER, value )

 "value" by default is 0, but you can change it from Tiled by adding the "cc_alpha_func" property to the layer.
 The value 0 should work for most cases, but if you have tiles that are semi-transparent, then you might want to use a differnt
 value, like 0.5.

 For further information, please see the programming guide:

	http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:tiled_maps

 @since v0.8.1
 */
class CCTMXLayer extends CCSpriteBatchNode
{
	var tileset_ :CCTMXTilesetInfo;
	var layerName_ :String;
	var layerSize_ :CGSize;
	var mapTileSize_ :CGSize;
	var tiles_ :Array<Int>;			// GID are 32 bit
	var layerOrientation_ :Int;
	var properties_ :Array<Dynamic>;

	var opacity_ :Float; // TMX Layer supports opacity

	var minGID_ :Int;
	var maxGID_ :Int;

	// Only used when vertexZ is used
	var vertexZvalue_ :Int;
	var useAutomaticVertexZ_ :Bool;
	var alphaFuncValue_ :Float;

	// used for optimization
	var reusedTile_ :CCSprite;
	var atlasIndexArray_ :Array<Int>;

/** name of the layer */
//public var layerName (get_layerName, set_layerName) :String;
/** size of the layer in tiles */
//public var layerSize (get_layerSize, set_layerSize) :CGSize;
/** size of the map's tile (could be differnt from the tile's size) */
//public var mapTileSize (get_mapTileSize, set_mapTileSize) :CGSize;
/** pointer to the map of tiles */
//public var tiles (get_tiles, set_tiles) :Int;
/** Tilset information for the layer */
//public var tileset (get_tileset, set_tileset) :CCTMXTilesetInfo;
/** Layer orientation, which is the same as the map orientation */
//public var layerOrientation (get_layerOrientation, set_layerOrientation) :Int;
/** properties from the layer. They can be added using Tiled */
//public var properties (get_properties, set_properties) :Array<>;

/** creates a CCTMXLayer with an tileset info, a layer info and a map info */
public static function layerWithTilesetInfo (tilesetInfo:CCTMXTilesetInfo, layerInfo:CCTMXLayerInfo, mapInfo:CCTMXMapInfo ) :CCTMXLayer
{
	return new CCTMXLayer().initWithTilesetInfo (tilesetInfo, layerInfo, mapInfo);
}

/** initializes a CCTMXLayer with a tileset info, a layer info and a map info */
public function initWithTilesetInfo (tilesetInfo:CCTMXTilesetInfo, layerInfo:CCTMXLayerInfo, mapInfo:CCTMXMapInfo) :CCTMXLayer
{	
	// XXX: is 35% a good estimate ?
	var size :CGSize = layerInfo.layerSize;
	var totalNumberOfTiles :Float = size.width * size.height;
	var capacity :Float = totalNumberOfTiles * 0.35 + 1; // 35 percent is occupied ?
	
	var tex :CCTexture2D = null;
	if( tilesetInfo )
		tex = CCTextureCache.sharedTextureCache().addImage ( tilesetInfo.sourceImage );
	
	super.initWithTexture (tex, capacity);
	
	// layerInfo
	this.layerName = layerInfo.name;
	layerSize_ = layerInfo.layerSize;
	tiles_ = layerInfo.tiles;
	minGID_ = layerInfo.minGID;
	maxGID_ = layerInfo.maxGID;
	opacity_ = layerInfo.opacity;
	this.properties = NSDictionary.dictionaryWithDictionary ( layerInfo.properties );

	// tilesetInfo
	this.tileset = tilesetInfo;
	
	// mapInfo
	mapTileSize_ = mapInfo.tileSize;
	layerOrientation_ = mapInfo.orientation;
	
	// offset (after layer orientation is set);
	var offset :CGPoint = this.calculateLayerOffset( layerInfo.offset );
	this.setPositionInPixels ( offset );
	
	atlasIndexArray_ = new Array();
	atlasIndexArray_[totalNumberOfTiles] = null;
	
	this.setContentSizeInPixels ( new CGSize( layerSize_.width * mapTileSize_.width, layerSize_.height * mapTileSize_.height ) );
	
	useAutomaticVertexZ_= false;
	vertexZvalue_ = 0;
	alphaFuncValue_ = 0;
	
	return this;
}

/** release the map that contains the tile position from memory.
 Unless you want to know at runtime the tiles positions, you can safely call this method.
 If you are going to call layer.tileGIDAt:] then, don't release the map
 */
public function releaseMap ()
{
	tiles_ = null;
	atlasIndexArray_ = null;
}
override public function release ()
{
	layerName_.release();
	tileset_.release();
	reusedTile_.release();
	properties_.release();

	tiles_ = null;
	atlasIndexArray_ = null;

	super.release();
}

/** returns the tile (CCSprite) at a given a tile coordinate.
 The returned CCSprite will be already added to the CCTMXLayer. Don't add it again.
 The CCSprite can be treated like any other CCSprite: rotated, scaled, translated, opacity, color, etc.
 You can remove either by calling:
	- layer.removeChild ( sprite, cleanup );
	- or layer.removeTileAt:new CGPoint (x,y);
 */
//
public function tileAt (pos:CGPoint) :CCSprite
{
	if (pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0) throw "TMXLayer: invalid position";
	if (tiles_==null && atlasIndexArray_==null) throw "TMXLayer: the tiles map has been released";
	
	var tile :CCSprite = null;
	var gid :Int = this.tileGIDAt ( pos );
	
	// if GID == 0, then no tile is present
	if( gid != -1 ) {
		var z :Int = pos.x + pos.y * layerSize_.width;
		tile = this.getChildByTag ( z );
		
		// tile not created yet. create it
		if( tile == null ) {
			var rect :CGRect = tileset_.rectForGID ( gid );			
			tile = new CCSprite().initWithBatchNode ( this, rect );
			tile.setPositionInPixels (this.positionAt(pos));
			tile.setVertexZ (this.vertexZForPos(pos));
			tile.anchorPoint = new CGPoint(0,0);
			tile.opacity = opacity_;
			
			var indexForZ :Int = this.atlasIndexForExistantZ ( z );
			this.addSpriteWithoutQuad ( tile, indexForZ, z );
			tile.release();
		}
	}
	return tile;
}

/** returns the tile gid at a given tile coordinate.
 if it returns 0, it means that the tile is empty.
 This method requires the the tile map has not been previously released (eg. don't call layer.releaseMap])
 */
public function tileGIDAt (pos:CGPoint) :Int
{
	if (pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0) throw "TMXLayer: invalid position";
	if (tiles_ == null && atlasIndexArray_ == null) throw "TMXLayer: the tiles map has been released";
	
	var idx :Int = Math.round ( pos.x + pos.y * layerSize_.width );
	return tiles_[ idx ];
}

/** sets the tile gid (gid = tile global id) at a given tile coordinate.
 The Tile GID can be obtained by using the method "tileGIDAt" or by using the TMX editor . Tileset Mgr +1.
 If a tile is already placed at that position, then it will be removed.
 */
public function setTileGID (gid:Int, pos:CGPoint) :Void
{
	if (pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0) throw "TMXLayer: invalid position";
	if (tiles_ && atlasIndexArray_) throw "TMXLayer: the tiles map has been released";
	if (gid == 0 || gid >= tileset_.firstGid) throw "TMXLayer: invalid gid" ;

	var currentGID :Int = this.tileGIDAt ( pos );
	
	if( currentGID != gid ) {
		
		// setting gid=0 is equal to remove the tile
		if( gid == 0 )
			this.removeTileAt ( pos );

		// empty tile. create a new one
		else if( currentGID == 0 )
			this.insertTileForGID ( gid, pos );

		// modifying an existing tile with a non-empty tile
		else {

			var z :Int = pos.x + pos.y * layerSize_.width;
			var sprite :Dynamic = this.getChildByTag ( z );
			if( sprite ) {
				var rect :CGRect = tileset_.rectForGID ( gid );
				sprite.setTextureRectInPixels (rect, false, rect.size);
				tiles_[z] = gid;
			} else
				this.updateTileForGID ( gid, pos );
		}
	}
}

/** removes a tile at given tile coordinate */
public function removeTileAt ( pos:CGPoint )
{
	if (pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0) throw "TMXLayer: invalid position";
	if (tiles_ && atlasIndexArray_) throw "TMXLayer: the tiles map has been released";

	var gid :Int = this.tileGIDAt ( pos );
	
	if( gid ) {
		
		var z :Int = pos.x + pos.y * layerSize_.width;
		var atlasIndex :Int = this.atlasIndexForExistantZ ( z );
		
		// remove tile from GID map
		tiles_[z] = 0;

		// remove tile from atlas position array
		atlasIndexArray_.emoveValueAtIndex ( atlasIndex );
		
		// remove it from sprites and/or texture atlas
		var sprite :Dynamic = this.getChildByTag ( z );
		if( sprite )
			super.removeChild ( sprite, true );
		else {
			textureAtlas_.removeQuadAtIndex ( atlasIndex );

			// update possible children
			for(i in 0...children_.length) {
				var ai :Int = children_[i].atlasIndex;
				if( ai >= atlasIndex) {
					children_[i].setAtlasIndex (  ai-1 );
				}
			}
		}
	}
}

/** returns the position in pixels of a given tile coordinate */
public function positionAt (pos:CGPoint) :CGPoint
{
	var ret :CGPoint = new CGPoint(0,0);
	switch( layerOrientation_ ) {
		case CCTMXOrientationOrtho:
			ret = this.positionForOrthoAt ( pos );
		case CCTMXOrientationIso:
			ret = this.positionForIsoAt ( pos );
		case CCTMXOrientationHex:
			ret = this.positionForHexAt ( pos );
	}
	return ret;
}

/** return the value for the specific property name */
public function propertyNamed (propertyName:String) :Dynamic
{
	return properties_.valueForKey ( propertyName );
}

/** Creates the tiles */
public function setupTiles ()
{	
	// Optimization: quick hack that sets the image size on the tileset
	tileset_.imageSize = textureAtlas_.texture.contentSizeInPixels();
	
	// By default all the tiles are aliased
	// pros:
	//  - easier to render
	// cons:
	//  - difficult to scale / rotate / etc.
	textureAtlas_.texture ( setAliasTexParameters );
	
	var o :CFByteOrder = CFByteOrderGetCurrent();
		
	// Parse cocos2d properties
	this.parseInternalProperties();
	
	for( y in 0...layerSize_.height ) {
		for( x in 0...layerSize_.width ) {
			
			var pos :Int = x + layerSize_.width * y;
			var gid :Int = tiles_[ pos ];
			
			// gid are stored in little endian.
			// if host is big endian, then swap
			if( o == CFByteOrderBigEndian )
				gid = CFSwapInt32( gid );
			
			// XXX: gid == 0 -. empty tile
			if( gid != 0 ) {
				this.appendTileForGID (gid, new CGPoint (x,y));
				
				// Optimization: update min and max GID rendered by the layer
				minGID_ = Math.min(gid, minGID_);
				maxGID_ = Math.max(gid, maxGID_);
			}
		}
	}
	
	if ( maxGID_ >= tileset_.firstGid && minGID_ >= tileset_.firstGid) 
	throw "TMX: Only 1 tilset per layer is supported";	
}

/** CCTMXLayer doesn't support adding a CCSprite manually.
 @warning addchild:z:tag: is not supported on CCTMXLayer. Instead of setTileGID:at:/tileAt:
 */
override public function addChild (node:CCNode, ?z:Int, ?tag:Int, ?pos:haxe.PosInfos) :Void
{
	throw "addChild: is not supported on CCTMXLayer. Instead use setTileGID:at:/tileAt:";
}

override public function removeChild (sprite:CCSprite, cleanup:Bool) :Void
{
	// allows removing null objects
	if( ! sprite )
		return;

	if (children_.containsObject ( sprite )) throw "Tile does not belong to TMXLayer";
	
	var atlasIndex :Int = sprite.atlasIndex;
	var zz :Int = atlasIndexArray_[atlasIndex];
	tiles_[zz] = 0;
	atlasIndexArray_.arrayRemoveValueAtIndex ( atlasIndex );
	
	super.removeChild ( sprite, cleanup );
}









// -
// CCTMXLayer

//int compareInts (const void * a, const void * b);


/*@interface CCTMXLayer ()
public function positionForIsoAt (pos:CGPoint) :CGPoint
public function positionForOrthoAt (pos:CGPoint) :CGPoint
public function positionForHexAt (pos:CGPoint) :CGPoint

public function calculateLayerOffset (offset:CGPoint) :CGPoint
*/
/* optimization methos */
/*-(CCSprite*) appendTileForGID:(uint32_t)gid at:(CGPoint)pos;
-(CCSprite*) insertTileForGID:(uint32_t)gid at:(CGPoint)pos;
-(CCSprite*) updateTileForGID:(uint32_t)gid at:(CGPoint)pos;
*/
/* The layer recognizes some special properties, like cc_vertez */
/*public function parseInternalProperties;

public function vertexZForPos (pos:CGPoint) :Int

// index
public function atlasIndexForExistantZ (z:Int) :Int
public function atlasIndexForNewZ (z:Int) :Int
}*/
/*
class CCTMXLayer
public var layerSize (get_layerSize, set_layerSize) :, layerName = layerName_, tiles = tiles_;
public var tileset (get_tileset, set_tileset) :;
public var layerOrientation (get_layerOrientation, set_layerOrientation) :;
public var mapTileSize (get_mapTileSize, set_mapTileSize) :;
public var properties (get_properties, set_properties) :;
*/
// CCTMXLayer - init & alloc & release



public function parseInternalProperties ()
{
	// if cc_vertex=automatic, then tiles will be rendered using vertexz
	var vertexz :String = this.propertyNamed("cc_vertexz");
	if( vertexz ) {
		if( vertexz == "automatic" )
			useAutomaticVertexZ_ = true;
		else
			vertexZvalue_ = Std.parseInt(vertexz);
	}
	
	var alphaFuncVal :String = this.propertyNamed("cc_alpha_func");
	alphaFuncValue_ = Std.parseFloat(alphaFuncVal);
}

// CCTMXLayer - obtaining tiles/gids





// CCTMXLayer - adding helper methods

public function insertTileForGID (gid:Int, pos:CGPoint ) :CCSprite
{
	var rect :CGRect = tileset_.rectForGID ( gid );
	
	var z :Int = pos.x + pos.y * layerSize_.width;
	
	if( ! reusedTile_ )
		reusedTile_ = new CCSprite().initWithBatchNode ( this, rect );
	else
		reusedTile_.initWithBatchNode ( this, rect );
	
	reusedTile_.setPositionInPixels ( this.positionAt(pos) );
	reusedTile_.setVertexZ ( this.vertexZForPos(pos) );
	reusedTile_.anchorPoint = new CGPoint(0,0);
	reusedTile_.setOpacity ( opacity_ );
	
	// get atlas index
	var indexForZ :Int = this.atlasIndexForNewZ ( z );
	
	// Optimization: add the quad without adding a child
	this.addQuadFromSprite ( reusedTile_, indexForZ );
	
	// insert it into the local atlasindex array
	ccCArrayInsertValueAtIndex (atlasIndexArray_, z, indexForZ);
	
	// update possible children
	for(i in 0...children_.length) {
		var ai :Int = children_[i].atlasIndex;
		if( ai >= indexForZ)
			children_[i].setAtlasIndex ( ai+1 );
	}
	
	tiles_[z] = gid;
	
	return reusedTile_;
}

public function updateTileForGID (gid:Int, pos:CGPoint ) :CCSprite
{
	var rect :CGRect = tileset_.rectForGID ( gid );
	
	var z :Int = pos.x + pos.y * layerSize_.width;
	
	if( ! reusedTile_ )
		reusedTile_ = new CCSprite().initWithBatchNode ( this, rect );
	else
		reusedTile_.initWithBatchNode ( this, rect );
	
	reusedTile_.setPositionInPixels ( this.positionAt (pos));
	reusedTile_.setVertexZ (this.vertexZForPos(pos));
	reusedTile_.anchorPoint = new CGPoint(0,0);
	reusedTile_.setOpacity ( opacity_ );
	
	// get atlas index
	var indexForZ :Int = this.atlasIndexForExistantZ ( z );

	reusedTile_.setAtlasIndex ( indexForZ );
	reusedTile_.setDirty ( true );
	reusedTile_.updateTransform;
	tiles_[z] = gid;
	
	return reusedTile_;
}


// used only when parsing the map. useless after the map was parsed
// since lot's of assumptions are no longer true
public function appendTileForGID (gid:Int, pos:CGPoint ) :CCSprite
{
	var rect :CGRect = tileset_.rectForGID ( gid );
	
	var z :Int = pos.x + pos.y * layerSize_.width;
	
	if( reusedTile_ == null )
		reusedTile_ = new CCSprite().initWithBatchNode ( this, rect );
	else
		reusedTile_.initWithBatchNode ( this, rect );
	
	reusedTile_.setPositionInPixels (this.positionAt (pos));
	reusedTile_.setVertexZ (this.vertexZForPos (pos));
	reusedTile_.anchorPoint = new CGPoint(0,0);
	reusedTile_.setOpacity ( opacity_ );
	
	// optimization:
	// The difference between appendTileForGID and insertTileforGID is that append is faster, since
	// it appends the tile at the end of the texture atlas
	var indexForZ :Int = atlasIndexArray_.num;


	// don't add it using the "standard" way.
	this.addQuadFromSprite ( reusedTile_, indexForZ );
	
	
	// append should be after addQuadFromSprite since it modifies the quantity values
	//ccCArrayInsertValueAtIndex(atlasIndexArray_, (void*)z, indexForZ);
	atlasIndexArray_.insert (z, indexForZ);
	
	return reusedTile_;
}

// CCTMXLayer - atlasIndex and Z

function compareInts (a:Int, b:Int) :Int
{
	return ( a - b );
}

public function atlasIndexForExistantZ ( z:Int ) :Int
{
	var key :Int = z;
	//var item :Int = bsearch((void*)&key, (void*)&atlasIndexArray_[0], atlasIndexArray_.num, sizeof(void*), compareInts);
	var item = 0;
	
	if (item == -1) throw "TMX atlas index not found. Shall not happen";

	var index :Int = (item - atlasIndexArray_) / sizeof(void);
	return index;
}

public function atlasIndexForNewZ ( z:Int ) :Int
{
	// XXX: This can be improved with a sort of binary search
	var i :Int = 0;
	for(i in 0...atlasIndexArray_.num) {
		var val :Int = atlasIndexArray_[i];
		if( z < val )
			break;
	}	
	return i;
}

// CCTMXLayer - obtaining positions, offset

public function calculateLayerOffset (pos:CGPoint) :CGPoint
{
	var ret :CGPoint = new CGPoint(0,0);
	switch( layerOrientation_ ) {
		case CCTMXOrientationOrtho:
			ret = new CGPoint ( pos.x * mapTileSize_.width, -pos.y *mapTileSize_.height);
			
		case CCTMXOrientationIso:
			ret = new CGPoint ( (mapTileSize_.width /2) * (pos.x - pos.y),
					  			(mapTileSize_.height /2 ) * (-pos.x - pos.y) );
			
		case CCTMXOrientationHex:
			if (pos.equalToPoint (new CGPoint(0,0))) throw "offset for hexagonal map not implemented yet";
	}
	return ret;	
}



function positionForOrthoAt ( pos:CGPoint ) :CGPoint
{
	var xy :CGPoint = new CGPoint(
		pos.x * mapTileSize_.width,
		(layerSize_.height - pos.y - 1) * mapTileSize_.height
	);
	return xy;
}

function positionForIsoAt ( pos:CGPoint ) :CGPoint
{
	var xy :CGPoint = new CGPoint(
		mapTileSize_.width /2 * ( layerSize_.width + pos.x - pos.y - 1),
		mapTileSize_.height /2 * (( layerSize_.height * 2 - pos.x - pos.y) - 2)
	);
	return xy;
}

function positionForHexAt ( pos:CGPoint ) :CGPoint
{
	var diffY :Float = 0;
	if( pos.x % 2 == 1 )
		diffY = -mapTileSize_.height/2;
	
	var xy :CGPoint = new CGPoint(
		pos.x * mapTileSize_.width*3/4,
		(layerSize_.height - pos.y - 1) * mapTileSize_.height + diffY
	);
	return xy;
}

function vertexZForPos ( pos:CGPoint ) :Int
{
	var ret :Int = 0;
	var maxVal :Int = 0;
	if( useAutomaticVertexZ_ ) {
		switch( layerOrientation_ ) {
			case CCTMXOrientationIso:
				maxVal = Math.round (layerSize_.width + layerSize_.height);
				ret = - Math.round (maxVal - (pos.x + pos.y));
			
			case CCTMXOrientationOrtho:
				ret = - Math.round (layerSize_.height-pos.y);
			
			case CCTMXOrientationHex:
				throw "TMX Hexa zOrder not supported";
			default:
				throw "TMX invalid value";
		}
	} else
		ret = vertexZvalue_;
	
	return ret;
}

// CCTMXLayer - draw

override public function draw ()
{
/*	if( useAutomaticVertexZ_ ) {
		glEnable(GL.ALPHA_TEST);
		glAlphaFunc(GL.GREATER, alphaFuncValue_);
	}
	*/
	super.draw();
	
/*	if( useAutomaticVertexZ_ )
		glDisable(GL.ALPHA_TEST);*/
}

}
