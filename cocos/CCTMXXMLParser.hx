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

import cocos.CCMacros;
import cocos.CCTMXTiledMap;
import cocos.CCTMXObjectGroup;
//import cocos.support.base64;
//import cocos.support.ZipUtils;
import cocos.support.CCFileUtils;
import cocos.support.CGPoint;
import cocos.support.CGSize;
import cocos.support.CGRect;
import cocos.support.NSDictionary;
using cocos.support.CGPointExtension;


//typedef TMXLayerAttrib = Int;

enum TMXProperty {
	TMXPropertyNone;
	TMXPropertyMap;
	TMXPropertyLayer;
	TMXPropertyObjectGroup;
	TMXPropertyObject;
	TMXPropertyTile;
}

/* CCTMXLayerInfo contains the information about the layers like:
 - Layer name
 - Layer size
 - Layer opacity at creation time (it can be modified at runtime)
 - Whether the layer is visible (if it's not visible, then the CocosNode won't be created)

 This information is obtained from the TMX file.
 */
class CCTMXLayerInfo
{
//
inline static var TMXLayerAttribNone = 1 << 0;
inline static var TMXLayerAttribBase64 = 1 << 1;
inline static var TMXLayerAttribGzip = 1 << 2;
inline static var TMXLayerAttribZlib = 1 << 3;

public var name :String;
public var layerSize :CGSize;
public var tiles :Array<Dynamic>;
public var visible :Bool;
public var opacity :Float;
public var ownTiles :Bool;
public var minGID :Int;
public var maxGID :Int;
public var properties :NSDictionary;
public var offset :CGPoint;


public function new () {}
public function init () :CCTMXLayerInfo
{
	ownTiles = true;
	minGID = 100000;
	maxGID = 0;
	this.name = null;
	tiles = null;
	offset = new CGPoint(0,0);
	properties = new NSDictionary();
	
	return this;
}
public function release ()
{
	trace("cocos2d: releaseing "+this);
	
	name = null;
	properties.release();

	if( ownTiles && tiles != null ) {
		tiles = null;
	}
}
}

/* CCTMXTilesetInfo contains the information about the tilesets like:
 - Tileset name
 - Tilset spacing
 - Tileset margin
 - size of the tiles
 - Image used for the tiles
 - Image size

 This information is obtained from the TMX file. 
 */
class CCTMXTilesetInfo
{
public var name :String;
public var firstGid :Int;
public var tileSize :CGSize;
public var spacing :Int;
public var margin :Int;

// filename containing the tiles (should be spritesheet / texture atlas)
public var sourceImage :String;
// size in pixels of the image
public var imageSize :CGSize;

public function new () {}
public function release ()
{
	trace("cocos2d: releaseing "+ this);
}

public function rectForGID (gid:Int) :CGRect
{
	var rect :CGRect;
	rect.size = tileSize;
	
	gid = gid - firstGid;
	
	var max_x :Int = (imageSize.width - margin_2 + spacing_) / (tileSize.width + spacing);
	//	var max_y :Int = (imageSize.height - margin*2 + spacing) / (tileSize.height + spacing);
	
	rect.origin.x = (gid % max_x) * (tileSize.width + spacing) + margin;
	rect.origin.y = (gid / max_x) * (tileSize.height + spacing) + margin;
	
	return rect;
}

}

/* CCTMXMapInfo contains the information about the map like:
 - Map orientation (hexagonal, isometric or orthogonal)
 - Tile size
 - Map size

 And it also contains:
 - Layers (an array of TMXLayerInfo objects)
 - Tilesets (an array of TMXTilesetInfo objects)
 - ObjectGroups (an array of TMXObjectGroupInfo objects)

 This information is obtained from the TMX file.

 */
class CCTMXMapInfo
{	
public var currentString :String;
public var storingCharacters :Bool;	
public var layerAttribs :Int;
public var parentElement :Int;
public var parentGID_ :Int;


	// tmx filename
public var filename :String;

	// map orientation
public var orientation :Int;	

	// map width & height
public var mapSize :CGSize;

	// tiles width & height
public var tileSize :CGSize;

	// Layers
public var layers :Array<CCTMXLayerInfo>;

	// tilesets
public var tilesets :Array<CCTMXTilesetInfo>;

	// ObjectGroups
public var objectGroups :Array<CCTMXObjectGroup>;

	// properties
public var properties :NSDictionary;

	// tile properties
public var tileProperties :NSDictionary;


/*public var orientation (get_orientation, set_orientation) :Int;
public var mapSize (get_mapSize, set_mapSize) :CGSize;
public var tileSize (get_tileSize, set_tileSize) :CGSize;
public var layers (get_layers, set_layers) :Array<>;
public var tilesets (get_tilesets, set_tilesets) :Array<>;
public var filename (get_filename, set_filename) :String;
public var objectGroups (get_objectGroups, set_objectGroups) :Array<>;
public var properties (get_properties, set_properties) :NSDictionary;
public var tileProperties (get_tileProperties, set_tileProperties) :NSDictionary;
*/
/** creates a TMX Format with a tmx file */
public static function formatWithTMXFile ( tmxFile:String ) :CCTMXMapInfo
{
	return new CCTMXMapInfo().initWithTMXFile(tmxFile);
}

public function new () {}

/** initializes a TMX format witha  tmx file */
public function initWithTMXFile (tmxFile:String) :CCTMXMapInfo
{
	this.tilesets = new Array<CCTMXTilesetInfo>();
	this.layers = new Array<CCTMXLayerInfo>();
	this.objectGroups = new Array<CCTMXObjectGroup>();
	this.filename = tmxFile;
	this.properties = new NSDictionary();
	this.tileProperties = new NSDictionary();

	// tmp vars
	currentString = "";
	storingCharacters = false;
	layerAttribs = TMXLayerAttribNone;
	parentElement = TMXPropertyNone;
	
	this.parseXMLFile ( filename_ );
	
	return this;
}
/* initalises parsing of an XML file, either a tmx (Map) file or tsx (Tileset) file */
public function parseXMLFile (xmlFilename:String)
{
	var url :String = CCFileUtils.fullPathFromRelativePath ( xmlFilename );
/*	var data :NSData = NSData.dataWithContentsOfURL ( url );
	var parser :NSXMLParser = new NSXMLParser().initWithData ( data );

	// we'll do the parsing
	parser.setDelegate ( this );
	parser.setShouldProcessNamespaces ( false );
	parser.setShouldReportNamespacePrefixes ( false );
	parser.setShouldResolveExternalEntities ( false );
	parser.parse();

	if ( parser.parserError) throw ("Error parsing file: "+ xmlFilename );

	parser.release();*/
}

// the XML parser calls here with all the elements
public function parser (parser:Xml, elementName:String, namespaceURI:String, qName:String, attributeDict:NSDictionary) :Void
{
	/*if(elementName == "map") {
		var  version :String = attributeDict.valueForKey ( "version" );
		if( version != "1.0" )
			trace("cocos2d: TMXFormat: Unsupported TMX version: ", version);
		var orientationStr :String = attributeDict.valueForKey ( "orientation" );
		if( orientationStr == "orthogonal" )
			orientation_ = CCTMXOrientationOrtho;
		else if ( orientationStr == "isometric" )
			orientation_ = CCTMXOrientationIso;
		else if( orientationStr == "hexagonal" )
			orientation_ = CCTMXOrientationHex;
		else
			trace("cocos2d: TMXFomat: Unsupported orientation: "+ orientation_);

		mapSize_.width = attributeDict.valueForKey ( "width" ).intValue;
		mapSize_.height = attributeDict.valueForKey ( "height" ).intValue;
		tileSize_.width = attributeDict.valueForKey ( "tilewidth" ).intValue;
		tileSize_.height = attributeDict.valueForKey ( "tileheight" ).intValue;

		// The parent element is now "map"
		parentElement = TMXPropertyMap;
	}
	else if(elementName == "tileset" ) {
		
		// If this is an external tileset then start parsing that
		var  externalTilesetFilename :String = attributeDict.valueForKey ( "source" );
		if (externalTilesetFilename) {
				// Tileset file will be relative to the map file. So we need to convert it to an absolute path
				var  dir :String = filename_.stringByDeletingLastPathComponent;	// Directory of map file
				externalTilesetFilename = dir.stringByAppendingPathComponent ( externalTilesetFilename );	// Append path to tileset file
				
				this.parseXMLFile ( externalTilesetFilename );
		} else {
				
			var tileset :CCTMXTilesetInfo = new CCTMXTilesetInfo();
			tileset.name = attributeDict.valueForKey ( "name" );
			tileset.firstGid = attributeDict.valueForKey ( "firstgid" ).intValue;
			tileset.spacing = attributeDict.valueForKey ( "spacing" ).intValue;
			tileset.margin = attributeDict.valueForKey ( "margin" ).intValue;
			var s:CGSize = new CGSize();
			s.width = attributeDict.valueForKey ( "tilewidth" ).intValue;
			s.height = attributeDict.valueForKey ( "tileheight" ).intValue;
			tileset.tileSize = s;
			
			tilesets_.addObject ( tileset );
			tileset.release();
		}

	}
	else if(elementName == "tile" ){
		var info :CCTMXTilesetInfo = tilesets.lastObject;
		var dict :NSDictionary = NSDictionary.dictionaryWithCapacity ( 3 );
		parentGID = info.firstGid + attributeDict.valueForKey ( "id" ).intValue;
		tileProperties_.setObject (dict, parentGID );
		
		parentElement = TMXPropertyTile;
		
	}
	else if(elementName == "layer" ) {
		var layer :CCTMXLayerInfo = new CCTMXLayerInfo();
		layer.name = attributeDict.valueForKey ( "name" );
		
		var s:CGSize = new CGSize();
		s.width = attributeDict.valueForKey ( "width" ).intValue;
		s.height = attributeDict.valueForKey ( "height" ).intValue;
		layer.layerSize = s;
		
		layer.visible = !(attributeDict.valueForKey ( "visible" ) == "0");
		
		if( attributeDict.valueForKey ( "opacity" ) )
			layer.opacity = 255 * attributeDict.valueForKey ( "opacity" ).FloatValue;
		else
			layer.opacity = 255;
		
		var x :Int = attributeDict.valueForKey ( "x" ).intValue;
		var y :Int = attributeDict.valueForKey ( "y" ).intValue;
		layer.offset = new CGPoint (x,y);
		
		layers.push ( layer );
		
		// The parent element is now "layer"
		parentElement = TMXPropertyLayer;
	
	} else if(elementName == "objectgroup" ) {
		
		var objectGroup :CCTMXObjectGroup = new CCTMXObjectGroup().init();
		objectGroup.groupName = attributeDict.valueForKey ( "name" );
		var positionOffset :CGPoint;
		positionOffset.x = attributeDict.valueForKey ( "x" ).intValue * tileSize_.width;
		positionOffset.y = attributeDict.valueForKey ( "y" ).intValue * tileSize_.height;
		objectGroup.positionOffset = positionOffset;
		
		objectGroups_.addObject ( objectGroup );
		objectGroup.release();
		
		// The parent element is now "objectgroup"
		parentElement = TMXPropertyObjectGroup;
			
	} else if(elementName == "image" ) {

		var tileset :CCTMXTilesetInfo = tilesets_.lastObject;
		
		// build full path
		var  imagename :String = attributeDict.valueForKey ( "source" );		
		var  path :String = filename_.stringByDeletingLastPathComponent;		
		tileset.sourceImage = path.stringByAppendingPathComponent ( imagename );

	} else if(elementName == "data" ) {
		var  encoding :String = attributeDict.valueForKey ( "encoding" );
		var  compression :String = attributeDict.valueForKey ( "compression" );
		
		if( encoding == "base64" ) {
			layerAttribs |= TMXLayerAttribBase64;
			storingCharacters = true;
			
			if( compression == "gzip" )
				layerAttribs |= TMXLayerAttribGzip;

			else if( compression == "zlib" )
				layerAttribs |= TMXLayerAttribZlib;

			if (!compression || compression == "gzip" || compression == "zlib") throw "TMX: unsupported compression method" ;
		}
		
		if (layerAttribs != TMXLayerAttribNone) throw "TMX tile map: Only base64 and/or gzip/zlib maps are supported" ;
		
	}
	else if(elementName == "object" ) {
	
		var objectGroup :CCTMXObjectGroup = objectGroups_.lastObject;
		
		// The value for "type" was blank or not a valid class name
		// Create an instance of TMXObjectInfo to store the object and its properties
		var dict :NSDictionary = new NSDictionary().initWithCapacity ( 5 );
		
		// Set the name of the object to the value for "name"
		dict.setValue (attributeDict.valueForKey ( "name" ), "name");
		
		// Assign all the attributes as key/name pairs in the properties dictionary
		dict.setValue (attributeDict.valueForKey ( "type" ), "type");
		var x :Int = attributeDict.valueForKey ( "x" ).intValue + objectGroup.positionOffset.x;
		dict.setValue (x, "x");
		var y :Int = attributeDict.valueForKey ( "y" ).intValue + objectGroup.positionOffset.y;
		// Correct y position. (Tiled uses Flipped, cocos2d uses Standard)
		y = (mapSize_.height * tileSize_.height) - y - attributeDict.valueForKey ( "height" ).intValue;
		dict.setValue (y, "y");
		dict.setValue (attributeDict.valueForKey ( "width" ), "width");
		dict.setValue (attributeDict.valueForKey ( "height" ), "height");
		
		// Add the object to the objectGroup
		objectGroup.objects.push ( dict );
		
		// The parent element is now "object"
		parentElement = TMXPropertyObject;
		
	}
	else if(elementName == "property" ) {
	
		if ( parentElement == TMXPropertyNone ) {
		
			trace( "TMX tile map: Parent element is unsupported. Cannot add property named '"+attributeDict.valueForKey ( "name" )+"' with value '"+attributeDict.valueForKey ( "value" )+"'");
			
		}
		else if ( parentElement == TMXPropertyMap ) {
		
			// The parent element is the map
			properties_.setValue (attributeDict.valueForKey ( "value" ), attributeDict.valueForKey ( "name" ));
			
		}
		else if ( parentElement == TMXPropertyLayer ) {
		
			// The parent element is the last layer
			var layer :CCTMXLayerInfo = layers_.lastObject();
			// Add the property to the layer
			layer.properties.setValue (attributeDict.valueForKey ( "value" ), attributeDict.valueForKey ( "name" ));
			
		}
		else if ( parentElement == TMXPropertyObjectGroup ) {
			
			// The parent element is the last object group
			var objectGroup :CCTMXObjectGroup = objectGroups_.lastObject;
			objectGroup.properties.setValue (attributeDict.valueForKey ( "value" ), attributeDict.valueForKey ( "name" ));
			
		}
		else if ( parentElement == TMXPropertyObject ) {
			
			// The parent element is the last object
			var objectGroup :CCTMXObjectGroup = objectGroups_.lastObject();
			var dict :NSDictionary = objectGroup.objects.lastObject();
			
			var  propertyName :String = attributeDict.valueForKey ( "name" );
			var  propertyValue :String = attributeDict.valueForKey ( "value" );

			dict.setValue ( propertyValue, propertyName );
		}
		else if ( parentElement == TMXPropertyTile ) {
			
			var dict :NSDictionary = tileProperties_.objectForKey(parentGID_);
			var  propertyName :String = attributeDict.valueForKey ( "name" );
			var  propertyValue :String = attributeDict.valueForKey ( "value" );
			dict.setObject ( propertyValue, propertyName );
			
		}
	}*/
}

public function parser2 (parser:Xml, elementName:String, namespaceURI:String, qName:String) :Void
{
	var len :Int = 0;

	//if(elementName == "data" && layerAttribs&TMXLayerAttribBase64) {
/*		storingCharacters = false;
		
		var layer :CCTMXLayerInfo = layers.lastObject();
		
		char *buffer;
		//len = base64Decode((char*)currentString.UTF8String], (int) currentString.length], &buffer);
		if( ! buffer ) {
			trace("cocos2d: TiledMap: decode data error");
			return;
		}
		
		if( layerAttribs & (TMXLayerAttribGzip | TMXLayerAttribZlib) ) {
			char *deflated;
			var s:CGSize = layer.layerSize;
			var sizeHint :Int = s.width * s.height * sizeof(uint32_t);

			var inflatedLen :Int = ccInflateMemoryWithHint(buffer, len, &deflated, sizeHint);
			if (inflatedLen == sizeHint) throw "CCTMXXMLParser: Hint failed!";
			
			inflatedLen = (int)&inflatedLen; // XXX: to avoid warings in compiler

			free( buffer );
			
			if( ! deflated ) {
				trace("cocos2d: TiledMap: inflate data error");
				return;
			}
			
			layer.tiles = deflated;
		} else
			layer.tiles = buffer;
		
		currentString.set_string ( "" );*/
			
/*	} else if (elementName == "map") {
		// The map element has ended
		parentElement = TMXPropertyNone;
		
	} else if (elementName == "layer") {
		// The layer element has ended
		parentElement = TMXPropertyNone;
		
	} else if (elementName == "objectgroup") {
		// The objectgroup element has ended
		parentElement = TMXPropertyNone;
		
	} else if (elementName == "object") {
		// The object element has ended
		parentElement = TMXPropertyNone;
	}*/
}

/*public function parser3 (parser:Xml, string:String) :Void
{
    if (storingCharacters)
		currentString.appendString ( string );
}*/


//
// the level did not load, file not found, etc.
//
/*public function parser (parser:NSXMLParser, parseError:NSError) :Void
	trace("cocos2d: Error on XML Parse: "+ parseError.localizedDescription);
}
*/
public function release ()
{
	trace("cocos2d: releaseing "+ this);
/*	tilesets_.release();
	layers_.release();
	filename_.release();
	currentString.release();
	objectGroups_.release();
	properties_.release();
	tileProperties_.release();*/
}

}
