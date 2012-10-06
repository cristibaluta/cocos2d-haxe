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
import CCNode;
import CCTMXXMLParser;
import CCTMXLayer;
import CCTMXObjectGroup;
import CCSprite;
import CCTextureCache;
import objc.CGPoint;
import objc.CGSize;
import objc.NSDictionary;
using support.CGPointExtension;


/** Possible oritentations of the TMX map */
enum CCTMXOrientation
{
	/** Orthogonal orientation */
	CCTMXOrientationOrtho;
	/** Hexagonal orientation */
	CCTMXOrientationHex;
	/** Isometric orientation */
	CCTMXOrientationIso;
}

/** CCTMXTiledMap knows how to parse and render a TMX map.

 It adds support for the TMX tiled map format used by http://www.mapeditor.org
 It supports isometric, hexagonal and orthogonal tiles.
 It also supports object groups, objects, and properties.

 Features:
 - Each tile will be treated as an CCSprite
 - The sprites are created on demand. They will be created only when you call "layer.tileAt:]"
 - Each tile can be rotated / moved / scaled / tinted / "opacitied", since each tile is a CCSprite
 - Tiles can be added/removed in runtime
 - The z-order of the tiles can be modified in runtime
 - Each tile has an anchorPoint of (0,0)
 - The anchorPoint of the TMXTileMap is (0,0)
 - The TMX layers will be added as a child
 - The TMX layers will be aliased by default
 - The tileset image will be loaded using the CCTextureCache
 - Each tile will have a unique tag
 - Each tile will have a unique z value. top-left: z=1, bottom-right: z=max z
 - Each object group will be treated as an Array<>
 - Object class which will contain all the properties in a dictionary
 - Properties can be assigned to the Map, Layer, Object Group, and Object

 Limitations:
 - It only supports one tileset per layer.
 - Embeded images are not supported
 - It only supports the XML format (the JSON format is not supported)

 Technical description:
   Each layer is created using an CCTMXLayer (subclass of CCSpriteBatchNode). If you have 5 layers, then 5 CCTMXLayer will be created,
   unless the layer visibility is off. In that case, the layer won't be created at all.
   You can obtain the layers (CCTMXLayer objects) at runtime by:
  - map.getChildByTag ( tag_number );  // 0=1st layer, 1=2nd layer, 2=3rd layer, etc...
  - map.layerNamed ( name_of_the_layer );

   Each object group is created using a CCTMXObjectGroup which is a subclass of Array<>.
   You can obtain the object groups at runtime by:
   - map.objectGroupNamed ( name_of_the_object_group );

   Each object is a CCTMXObject.

   Each property is stored as a key-value pair in an NSDictionary.
   You can obtain the properties at runtime by:

		map.propertyNamed ( name_of_the_property );
		layer.propertyNamed ( name_of_the_property );
		objectGroup.propertyNamed ( name_of_the_property );
		object.propertyNamed ( name_of_the_property );

 @since v0.8.1
 */
class CCTMXTiledMap extends CCNode
{
var mapSize_ :CGSize;
var tileSize_ :CGSize;
var mapOrientation_ :Int;
var objectGroups_ :Array<CCTMXObjectGroup>;
var properties_ :NSDictionary;
var tileProperties_ :NSDictionary;

/** the map's size property measured in tiles */
//public var mapSize (get_mapSize, null) :CGSize;
/** the tiles's size property measured in pixels */
//public var tileSize (get_tileSize, null) :CGSize;
/** map orientation */
//public var mapOrientation (get_mapOrientation, null) :Int;
/** object groups */
//public var objectGroups (get_objectGroups, set_objectGroups) :Array<>;
/** properties */
//public var properties (get_properties, set_properties) :NSDictionary;


/** creates a TMX Tiled Map with a TMX file.*/
public static function  tiledMapWithTMXFile ( tmxFile:String ) :CCTMXTiledMap
{
	return new CCTMXTiledMap().initWithTMXFile ( tmxFile );
}

/** initializes a TMX Tiled Map with a TMX file */
public function initWithTMXFile (tmxFile:String) :CCTMXTiledMap
{
	if (tmxFile == null) throw "TMXTiledMap: tmx file should not bi null";

	super.init();
	
	this.setContentSize ( new CGSize() );

	var mapInfo :CCTMXMapInfo = CCTMXMapInfo.formatWithTMXFile ( tmxFile );
	
	if (mapInfo.tilesets.length == 0) throw "TMXTiledMap: Map not found. Please check the filename.";
	
	mapSize_ = mapInfo.mapSize;
	tileSize_ = mapInfo.tileSize;
	mapOrientation_ = mapInfo.orientation;
	objectGroups_ = mapInfo.objectGroups;
	properties_ = mapInfo.properties;
	tileProperties_ = mapInfo.tileProperties;
			
	var idx=0;

	for( layerInfo in mapInfo.layers ) {
		
		if( layerInfo.visible ) {
			var child :CCNode = this.parseLayer ( layerInfo, mapInfo );
			this.addChild ( child, idx, idx );
			
			// update content size with the max size
			var childSize:CGSize = child.contentSize;
			var currentSize:CGSize = this.contentSize;
			currentSize.width = Math.max( currentSize.width, childSize.width );
			currentSize.height = Math.max( currentSize.height, childSize.height );
			this.setContentSize ( currentSize );

			idx++;
		}			
	}
	
	return this;
}

/** return the TMXLayer for the specific layer */
public function layerNamed (layerName:String) :CCTMXLayer
{
	for (layer in children_) {
		if( Std.is (layer, CCTMXLayer) )
			if(layer.layerName == layerName)
				return layer;
	}
	
	// layer not found
	return null;
}

/** return the TMXObjectGroup for the secific group */
public function objectGroupNamed ( groupName:String ) :CCTMXObjectGroup
{
	for( objectGroup in objectGroups_ ) {
		if( objectGroup.groupName == groupName )
			return objectGroup;
	}
	
	// objectGroup not found
	return null;
}

/** return the value for the specific property name */
public function propertyNamed (propertyName:String) 
{
	return properties_.valueForKey ( propertyName );
}

/** return properties dictionary for tile GID */
public function propertiesForGID ( GID:Int ) :NSDictionary
{
	return tileProperties_.objectForKey( GID );
}




/*

public function parseLayer (layer:CCTMXLayerInfo, mapInfo:CCTMXMapInfo) :CCTMXTiledMap;
-(CCTMXTilesetInfo*) tilesetForLayer:(CCTMXLayerInfo*)layerInfo map:(CCTMXMapInfo*)mapInfo;
}

*/


override public function release () :Void
{
	//objectGroups_.release();
	properties_.release();
	tileProperties_.release();
	super.release();
}

// private
public function parseLayer (layerInfo:CCTMXLayerInfo, mapInfo:CCTMXMapInfo) :CCTMXTiledMap
{
	var tileset :CCTMXTilesetInfo = this.tilesetForLayer ( layerInfo, mapInfo );
	var layer :CCTMXLayer = CCTMXLayer.layerWithTilesetInfo ( tileset, layerInfo, mapInfo );

	// tell the layerinfo to release the ownership of the tiles map.
	layerInfo.ownTiles = false;

	layer.setupTiles();
	
	return layer;
}

public function tilesetForLayer (layerInfo:CCTMXLayerInfo, mapInfo:CCTMXMapInfo ) :CCTMXTilesetInfo
{
	//var o :CFByteOrder = CFByteOrderGetCurrent();
	var size :CGSize = layerInfo.layerSize;

	var iter :CCTMXTilesetInfo = mapInfo.tilesets.reverseObjectEnumerator();
	for( tileset in iter) {
		for( y in 0...size.height ) {
			for( x in 0...size.width ) {
				
				var pos :Int = x + size.width * y;
				var gid :Int = layerInfo.tiles[ pos ];
				
				// gid are stored in little endian.
				// if host is big endian, then swap
/*				if( o == CFByteOrderBigEndian )
					gid = CFSwapInt32( gid );*/
				
				// XXX: gid == 0 -. empty tile
				if( gid != 0 ) {
					
					// Optimization: quick return
					// if the layer is invalid (more than 1 tileset per layer) an assert will be thrown later
					if( gid >= tileset.firstGid )
						return tileset;
				}
			}
		}		
	}
	
	// If all the tiles are 0, return empty tileset
	trace("cocos2d: Warning: TMX Layer '%@' has no tiles"+layerInfo.name);
	return null;
}

}

