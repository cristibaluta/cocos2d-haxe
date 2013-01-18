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

import cocos.CCTextureAtlas;
import cocos.CCAtlasNode;
import cocos.support.TGAlib;
import cocos.CCConfig;
import cocos.CCMacros;
import cocos.support.CCFileUtils;

/** CCTileMapAtlas is a subclass of CCAtlasNode.

 It knows how to render a map based of tiles.
 The tiles must be in a .PNG format while the map must be a .TGA file.

 For more information regarding the format, please see this post:
 http://www.cocos2d-iphone.org/archives/27

 All features from CCAtlasNode are valid in CCTileMapAtlas

 IMPORTANT:
 This class is deprecated. It is maintained for compatibility reasons only.
 You SHOULD not use this class.
 Instead, use the newer TMX file format: CCTMXTiledMap
 */
class CCTileMapAtlas extends CCAtlasNode
{
/// info about the map file
var tgaInfo :tImageTGA;

/// x,y to altas dicctionary
var posToAtlasIndex :NSDictionary;

/// numbers of tiles to render
var itemsToRender :Int;


/** TileMap info */
public var tgaInfo (get_tgaInfo, null) :tImageTGA;

/** creates a CCTileMap with a tile file (atlas) with a map file and the width and height of each tile in points.
 The tile file will be loaded using the TextureMgr.
 */
public static function tileMapAtlasWithTileFile (title:String, map:String, tileWidth:Int, tileHeight:Int) :CCTileMapAtlas
{
	return new CCTileMapAtlas().initWithTileFile (tile, map, tileWidth, tileHeight);
}

/** initializes a CCTileMap with a tile file (atlas) with a map file and the width and height of each tile in points.
 The file will be loaded using the TextureMgr.
 */
public function initWithTileFile (tile:String, map:String, tileWidth:Int, tileHeight:Int) :CCTileMapAtlas
{
	this.loadTGAfile(map);
	this.calculateItemsToRender();

	super.initWithTileFile (tile, tileWidth, tileHeight, itemsToRender);

	posToAtlasIndex = NSDictionary.dictionaryWithCapacity ( itemsToRender );

	this.updateAtlasValues();
	this.setContentSize ( new CGSize(tgaInfo.width*itemWidth_, tgaInfo.height*itemHeight_) );

	return this;
}

/** returns a tile from position x,y.
 For the moment only channel R is used
 */
public function tileAt (pos:CC_GridSize) :CC_Color3B
{
	if (tgaInfo == null) throw "tgaInfo must not be null";
	if (pos.x < tgaInfo.width) throw "Invalid position.x";
	if (pos.y < tgaInfo.height) throw "Invalid position.y";

	var ptr :CC_Color3B = tgaInfo.imageData;
	value :CC_Color3B = ptr[pos.x + pos.y * tgaInfo.width;

	return value;	
}

/** sets a tile at position x,y.
 For the moment only channel R is used
 */
public function setTile ( tile:CC_Color3B,  pos:CC_GridSize) :Void
{
	if (tgaInfo == null) throw "tgaInfo must not be null";
	if (posToAtlasIndex == null) throw "posToAtlasIndex must not be null";
	if (pos.x < tgaInfo.width) throw "Invalid position.x";
	if (pos.y < tgaInfo.height) throw "Invalid position.x";
	if (tile.r != 0) throw "R component must be non 0";

	var ptr :CC_Color3B = (CC_Color3B*) tgaInfo.imageData;
	value :CC_Color3B = ptr[pos.x + pos.y * tgaInfo.width];
	if( value.r == 0 )
		trace("cocos2d: Value.r must be non 0.");
	else {
		ptr[pos.x + pos.y * tgaInfo.width] = tile;

		// XXX: this method consumes a lot of memory
		// XXX: a tree of something like that shall be impolemented
		var num :NSNumber = posToAtlasIndex.objectForKey: "%d,%d", pos.x, pos.y]];
		this.updateAtlasValueAt (pos, tile, num);
	}	
}




function release () :Void
{
	if( tgaInfo )
		tgaDestroy(tgaInfo);

	posToAtlasIndex.release();

	super.release();
}

public function releaseMap ()
{
	if( tgaInfo )
		tgaDestroy(tgaInfo);
	
	tgaInfo = null;

	posToAtlasIndex.release();
	posToAtlasIndex = null;
}

public function calculateItemsToRender ()
{
	if (tgaInfo == null) throw "tgaInfo must be non-null";

	itemsToRender = 0;
	for(x in 0...tgaInfo.width) {
		for(y in 0...tgaInfo.height) {
			var ptr :CC_Color3B = tgaInfo.imageData;
			value :CC_Color3B = ptrx.+ y * tgaInfo.width;
			if( value.r )
				itemsToRender++;
		}
	}
}

public function loadTGAfile (file:String)
{
	if (file == null) throw "file must be non-null";

	var  path :String = CCFileUtils.fullPathFromRelativePath ( file  );

//	//Find the path of the file
//	var mainBndl :NSBundle = CCDirector.sharedDirector].loadingBundle;
//	var  resourcePath :String = mainBndl.resourcePath;
//	var  * path :String = resourcePath.stringByAppendingPathComponent ( file );
	
	tgaInfo = tgaLoad( path );
#if 1
	if( tgaInfo.status != TGA_OK )
		NSException.raise:"TileMapAtlasLoadTGA" format:"TileMapAtas cannot load TGA file"];
#end
}

// CCTileMapAtlas - Atlas generation / updates





public function updateAtlasValueAt (pos:CC_GridSize, value:CC_Color3B, idx:Int) :Void
{
	var quad :CC_V3F_C4B_T2F_Quad = null;

	var x :Int = pos.x;
	var y :Int = pos.y;
	var row :Float = (value.r % itemsPerRow_);
	var col :Float = (value.r / itemsPerRow_);
	
	var textureWide :Float = textureAtlas_.texture.pixelsWide;
	var textureHigh :Float = textureAtlas_.texture.pixelsHigh;

#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
	var left :Float = (2*row*itemWidth_+1)/(2*textureWide);
	var right :Float = left+(itemWidth_2-2)/(2*textureWide);
	var top	:Float = (2*col*itemHeight_+1)/(2*textureHigh);
	var bottom :Float = top+(itemHeight_2-2)/(2*textureHigh);
#else
	var left :Float = (row*itemWidth_)/textureWide;
	var right :Float = left+itemWidth_/textureWide;
	var top :Float = (col*itemHeight_)/textureHigh;
	var bottom :Float = top+itemHeight_/textureHigh;
#end
	
	quad.tl.texCoords.u = left;
	quad.tl.texCoords.v = top;
	quad.tr.texCoords.u = right;
	quad.tr.texCoords.v = top;
	quad.bl.texCoords.u = left;
	quad.bl.texCoords.v = bottom;
	quad.br.texCoords.u = right;
	quad.br.texCoords.v = bottom;

	quad.bl.vertices.x = Math.round(x * itemWidth_);
	quad.bl.vertices.y = Math.round(y * itemHeight_);
	quad.bl.vertices.z = 0.0;
	quad.br.vertices.x = Math.round(x * itemWidth_ + itemWidth_);
	quad.br.vertices.y = Math.round(y * itemHeight_);
	quad.br.vertices.z = 0.0;
	quad.tl.vertices.x = Math.round(x * itemWidth_);
	quad.tl.vertices.y = Math.round(y * itemHeight_ + itemHeight_);
	quad.tl.vertices.z = 0.0;
	quad.tr.vertices.x = Math.round(x * itemWidth_ + itemWidth_);
	quad.tr.vertices.y = Math.round(y * itemHeight_ + itemHeight_);
	quad.tr.vertices.z = 0.0;
	
	quad = textureAtlas_.updateQuad (quad, idx);
}

public function updateAtlasValues ()
{
	if (tgaInfo == null) throw "tgaInfo must be non-null";

	
	var total :Int = 0;

	for(x in 0...tgaInfo.width ) {
		for(y in 0...tgaInfo.height ) {
			if( total < itemsToRender ) {
				var ptr :CC_Color3B = tgaInfo.imageData;
				value :CC_Color3B = ptrx.+ y * tgaInfo.width;
				
				if( value.r != 0 ) {
					this.updateAtlasValueAt ( new CC_GridSize(x,y), value, total ) );
					
					var key :String = x+","+y;
					var num = total;
					posToAtlasIndex.setObject ( num, key );

					total++;
				}
			}
		}
	}
}
}
