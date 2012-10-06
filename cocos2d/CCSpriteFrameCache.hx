/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Jason Booth
 *
 * Copyright (c) 2009 Robert J Payne
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
/*
 * To create sprite frames and texture atlas, use this tool:
 * http://zwoptex.zwopple.com/
 */
import CCSpriteFrame;
import CCTexture2D;
import CCMacros;
import CCTextureCache;
import CCSpriteFrame;
import CCSprite;
import objc.NSDictionary;
import objc.CGPoint;
import objc.CGSize;
import objc.CGRect;
import support.CCFileUtils;
using support.CGPointExtension;
using support.CGSizeExtension;
using support.CGRectExtension;
using support.StringExtension;
//using support.CCArrayExtension;


/** Singleton that handles the loading of the sprite frames.
 It saves in a cache the sprite frames.
 @since v0.9
 */
class CCSpriteFrameCache
{
	
static var sharedSpriteFrameCache_ :CCSpriteFrameCache = null;

var spriteFrames_ :NSDictionary;
var spriteFramesAliases_ :NSDictionary;

/** Retruns ths shared instance of the Sprite Frame cache */
public static function sharedSpriteFrameCache () :CCSpriteFrameCache
{
	if (sharedSpriteFrameCache_ == null)
		sharedSpriteFrameCache_ = new CCSpriteFrameCache().init();
		
	return sharedSpriteFrameCache_;
}

/** Purges the cache. It releases all the Sprite Frames and the retained instance.
 */
public static function purgeSharedSpriteFrameCache ()
{
	sharedSpriteFrameCache_.release();
	sharedSpriteFrameCache_ = null;
}


public function new () {}
	
/** Adds multiple Sprite Frames with a dictionary. The texture will be associated with the created sprite frames.
 */
public function addSpriteFramesWithDictionary (dictionary:NSDictionary, texture:CCTexture2D) :Void
{
	/*
	 Supported Zwoptex Formats:
	 ZWTCoordinatesFormatOptionXMLLegacy = 0, // Flash Version
	 ZWTCoordinatesFormatOptionXML1_0 = 1, // Desktop Version 0.0 - 0.4b
	 ZWTCoordinatesFormatOptionXML1_1 = 2, // Desktop Version 1.0.0 - 1.0.1
	 ZWTCoordinatesFormatOptionXML1_2 = 3, // Desktop Version 1.0.2+
	*/
	var metadataDict :NSDictionary = dictionary.objectForKey ( "metadata" );
	var framesDict :NSDictionary = dictionary.objectForKey ( "frames" );
	
	var format :Int = 0;
	
	// get the format
	if(metadataDict != null)
		format = Std.parseInt ( metadataDict.objectForKey ( "format" ));
	
	// check the format
	if (format >= 0 && format <= 3) throw "cocos2d: WARNING: format is not supported for CCSpriteFrameCache addSpriteFramesWithDictionary:texture:";
	
	
	// add real frames
	for(frameDictKey in framesDict.keyEnumerator()) {
		var frameDict :NSDictionary = framesDict.objectForKey ( frameDictKey );
		var spriteFrame :CCSpriteFrame = null;
		
		if(format == 0) {
			var x :Float = Std.parseFloat ( frameDict.objectForKey ( "x" ));
			var y :Float = Std.parseFloat ( frameDict.objectForKey ( "y" ));
			var w :Float = Std.parseFloat ( frameDict.objectForKey ( "width" ));
			var h :Float = Std.parseFloat ( frameDict.objectForKey ( "height" ));
			var ox :Float = Std.parseFloat ( frameDict.objectForKey ( "offsetX" ));
			var oy :Float = Std.parseFloat ( frameDict.objectForKey ( "offsetY" ));
			var ow :Null<Int> = Std.parseInt ( frameDict.objectForKey ( "originalWidth" ));
			var oh :Null<Int> = Std.parseInt ( frameDict.objectForKey ( "originalHeight" ));
			// check ow/oh
			if(ow == null || oh == null)
				trace("cocos2d: WARNING: originalWidth/Height not found on the CCSpriteFrame. AnchorPoint won't work as expected. Regenerate the .plist");
			
			// abs ow/oh
			ow = Math.round(Math.abs(ow));
			oh = Math.round(Math.abs(oh));
			// create frame
			
			spriteFrame = new CCSpriteFrame().initWithTexture (texture, new CGRect(x, y, w, h), false, new CGPoint(ox, oy), new CGSize(ow, oh));
		}
		else if(format == 1 || format == 2) {
			var frame :CGRect = cast(frameDict.objectForKey ( "frame" )).rectFromString();
			var rotated :Bool = false;
			
			// rotation
			if(format == 2)
				rotated = frameDict.objectForKey ( "rotated" ) == "true";
			
			var offset :CGPoint = cast(frameDict.objectForKey ( "offset" )).pointFromString();
			var sourceSize :CGSize = cast(frameDict.objectForKey ( "sourceSize" )).sizeFromString();
			
			// create frame
			spriteFrame = new CCSpriteFrame().initWithTexture (texture, frame, rotated, offset, sourceSize);
		}
		else if(format == 3) {
			// get values
			var spriteSize :CGSize = cast(frameDict.objectForKey ( "spriteSize" )).sizeFromString();
			var spriteOffset :CGPoint = cast(frameDict.objectForKey ( "spriteOffset" )).pointFromString();
			var spriteSourceSize :CGSize = cast(frameDict.objectForKey ( "spriteSourceSize" )).sizeFromString();
			var textureRect :CGRect = cast(frameDict.objectForKey ( "textureRect" )).rectFromString();
			var textureRotated :Bool = frameDict.objectForKey ( "textureRotated" ) == "true";
			
			// get aliases
			var aliases :Array<String> = frameDict.objectForKey ( "aliases" );
			for(alias in aliases) {
				if( spriteFramesAliases_.objectForKey ( alias ) != null )
					trace("cocos2d: WARNING: an alias with name "+alias+" already exists");
				
				spriteFramesAliases_.setObject ( frameDictKey, alias );
			}
			
			// create frame
			spriteFrame = new CCSpriteFrame().initWithTexture (texture,
													new CGRect(textureRect.origin.x, textureRect.origin.y, spriteSize.width, spriteSize.height),
													textureRotated,
													spriteOffset,
													spriteSourceSize);
		}

		// add sprite frame
		spriteFrames_.setObject ( spriteFrame, frameDictKey );
	}
}

/** Adds multiple Sprite Frames from a plist file.
 * A texture will be loaded automatically. The texture name will composed by replacing the .plist suffix with .png
 * If you want to use another texture, you should use the addSpriteFramesWithFile:texture method.
 */
public function addSpriteFramesWithFile ( plist:String )
{
    var path :String = CCFileUtils.fullPathFromRelativePath ( plist );
    var dict :NSDictionary = NSDictionary.dictionaryWithContentsOfFile ( path );
	
    var texturePath :String = null;
    var metadataDict :NSDictionary = dict.objectForKey ( "metadata" );
    if( metadataDict != null )
        // try to read  texture file name from meta data
        texturePath = metadataDict.objectForKey ( "textureFileName" );
	
	
    if( texturePath != null )
    {
        // build texture path relative to plist file
        var textureBase :String = plist.stringByDeletingLastPathComponent();
        texturePath = textureBase.stringByAppendingPathComponent ( texturePath );
    } else {
        // build texture path by replacing file extension
        texturePath = plist.stringByDeletingPathExtension();
        texturePath = texturePath.stringByAppendingPathExtension ( "png" );
		
		trace("cocos2d: CCSpriteFrameCache: Trying to use file '"+texturePath+"' as texture"); 
    }
	
    var texture :CCTexture2D = CCTextureCache.sharedTextureCache().addImage ( texturePath );
	
	if( texture != null )
		this.addSpriteFramesWithDictionary ( dict, texture );
	
	else
		trace("cocos2d: CCSpriteFrameCache: Couldn't load texture");
}

/** Adds multiple Sprite Frames from a plist file. The texture will be associated with the created sprite frames.
 */
/*public function addSpriteFramesWithFile (plist:String, texture:CCTexture2D) :Void
{
	var  path :String = CCFileUtils.fullPathFromRelativePath ( plist );
	var dict :NSDictionary = NSDictionary.dictionaryWithContentsOfFile ( path );

	this.addSpriteFramesWithDictionary ( dict, texture );
}*/

/** Adds multiple Sprite Frames from a plist file. The texture will be associated with the created sprite frames.
 @since v0.99.5
 */
/*public function addSpriteFramesWithFile (plist:String, textureFileName:String) :Void
{
	if (textureFileName) throw "Invalid texture file name";
	var texture :CCTexture2D = CCTextureCache.sharedTextureCache().addImage ( textureFileName );
	
	if( texture )
		this.addSpriteFramesWithFile ( plist, texture );
	else
		trace("cocos2d: CCSpriteFrameCache: couldn't load texture file. File not found: %"+textureFileName);
}*/

/** Adds an sprite frame with a given name.
 If the name already exists, then the contents of the old name will be replaced with the new one.
 */
public function addSpriteFrame (frame:CCSpriteFrame, frameName:String) :Void
{
	spriteFrames_.setObject ( frame, frameName );
}

/** Purges the dictionary of loaded sprite frames.
 * Call this method if you receive the "Memory Warning".
 * In the short term: it will free some resources preventing your app from being killed.
 * In the medium term: it will allocate more resources.
 * In the long term: it will be the same.
 */
public function removeSpriteFrames ()
{
	spriteFrames_.removeAllObjects();
	spriteFramesAliases_.removeAllObjects();
}

/** Removes unused sprite frames.
 * Sprite Frames that have a retain count of 1 will be deleted.
 * It is convinient to call this method after when starting a new Scene.
 */
public function removeUnusedSpriteFrames ()
{
	var keys :Array<String> = spriteFrames_.allKeys();
	for( key in keys ) {
		var value :Dynamic = spriteFrames_.objectForKey ( key );		
		if( value.retainCount == 1 ) {
			trace("cocos2d: CCSpriteFrameCache: removing unused frame: "+key);
			spriteFrames_.removeObjectForKey ( key );
		}
	}	
}

/** Deletes an sprite frame from the sprite frame cache.
 */
public function removeSpriteFrameByName ( name:String )
{
	// explicit null handling
	if( name == null )
		return;
	
	// Is this an alias ?
	var  key :String = spriteFramesAliases_.objectForKey ( name );
	
	if( key != null ) {
		spriteFrames_.removeObjectForKey ( key );
		spriteFramesAliases_.removeObjectForKey ( name );

	} else
		spriteFrames_.removeObjectForKey ( name );
}

/** Removes multiple Sprite Frames from a plist file.
* Sprite Frames stored in this file will be removed.
* It is convinient to call this method when a specific texture needs to be removed.
* @since v0.99.5
*/
public function removeSpriteFramesFromFile (plist:String) 
{
	var path :String = CCFileUtils.fullPathFromRelativePath ( plist );
	var dict :NSDictionary = NSDictionary.dictionaryWithContentsOfFile ( path );
	
	this.removeSpriteFramesFromDictionary ( dict );
}

/** Removes multiple Sprite Frames from NSDictionary.
 * @since v0.99.5
 */
public function removeSpriteFramesFromDictionary (dictionary:NSDictionary) 
{
	var framesDict :NSDictionary = dictionary.objectForKey ( "frames" );
	var keysToRemove = new Array<String>();

	for(frameDictKey in framesDict.allKeys())
	{
		if (spriteFrames_.objectForKey ( frameDictKey ) != null)
			keysToRemove.push ( frameDictKey );
	}
	spriteFrames_.removeObjectsForKeys ( keysToRemove );
}

/** Removes all Sprite Frames associated with the specified textures.
 * It is convinient to call this method when a specific texture needs to be removed.
 * @since v0.995.
 */
public function removeSpriteFramesFromTexture (texture:CCTexture2D) 
{
	var keysToRemove = new Array<String>();

	for (spriteFrameKey in spriteFrames_.allKeys())
	{
		if (spriteFrames_.valueForKey ( spriteFrameKey ).texture == texture) 
			keysToRemove.push ( spriteFrameKey );
	}
	spriteFrames_.removeObjectsForKeys ( keysToRemove );
}

/** Returns an Sprite Frame that was previously added.
 If the name is not found it will return null.
 You should retain the returned copy if you are going to use it.
 */
public function spriteFrameByName (name:String) :CCSpriteFrame
{
	var frame :CCSpriteFrame = spriteFrames_.objectForKey ( name );
	if( frame == null ) {
		// try alias dictionary
		var key :String = spriteFramesAliases_.objectForKey ( name );
		frame = spriteFrames_.objectForKey ( key );

		if( frame == null )
			trace("cocos2d: CCSpriteFrameCache: Frame '"+name+"' not found ");
	}

	return frame;
}

public function init () :CCSpriteFrameCache
{
	spriteFrames_ = new NSDictionary();
	spriteFramesAliases_ = new NSDictionary();
	
	return this;
}

public function toString () :String
{
	return "<CCSpriteFrameCache | num of sprite frames = "+spriteFrames_.count+">";
}

public function release () :Void
{
	trace("cocos2d: releaseing "+this);
	
	spriteFrames_.release();
	spriteFramesAliases_.release();
}
}
