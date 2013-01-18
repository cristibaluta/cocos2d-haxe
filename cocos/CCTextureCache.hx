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

//import cocos.platform.CCGL;
import cocos.platform.flash.CCAssets;
import cocos.CCTexture2D;
import cocos.CCMacros;
import cocos.CCConfiguration;
import cocos.CCDirector;
import cocos.CCConfig;
import cocos.action.CCActionManager;
import cocos.action.CCActionInstant;
import cocos.support.UIImage;
using cocos.support.CCFileUtils;// removeHDSuffixFromFile

/** Singleton that handles the loading of textures
 * Once the texture is loaded, the next time it will return
 * a reference of the previously loaded texture reducing GPU & CPU memory
 */
class CCTextureCache
{
var textures_ :Hash<CCTexture2D>;


/** Retruns ths shared instance of the cache */
static var sharedTextureCache_ :CCTextureCache;

public static function sharedTextureCache () :CCTextureCache
{
	if (sharedTextureCache_ == null)
		sharedTextureCache_ = new CCTextureCache().init();
		
	return sharedTextureCache_;
}

/** purges the cache. It releases the retained instance.
 @since v0.99.0
 */
public static function purgeSharedTextureCache ()
{
	if (sharedTextureCache_ != null)
		sharedTextureCache_.release();
		sharedTextureCache_ = null;
}


/** Returns a Texture2D object given an file image
 * If the file image was not previously loaded, it will create a new CCTexture2D
 *  object and it will return it. It will use the filename as a key.
 * Otherwise it will return a reference of a previosly loaded image.
 * Supported image extensions: .png, .bmp, .tiff, .jpeg, .pvr, .gif
 */
public function addImage (path:String) :CCTexture2D
{
	trace ("addImage "+path);
	if(path == null) throw "TextureCache: fileimage MUST not be null";
	
	// remove possible -HD suffix to prevent caching the same image twice (issue #1040)
	path = path.removeHDSuffixFromFile();
	var tex :CCTexture2D = textures_.get ( path );
	
	if( tex == null ) {
		
		var fullpath :String = path.fullPathFromRelativePath();
		trace("fullpath "+fullpath);
		//var image :UIImage = new UIImage().initWithContentsOfFile ( fullpath );
		var image :UIImage = CCAssets.getCachedFile ( fullpath );
		
		tex = new CCTexture2D().initWithImage ( image );
		
		if( tex != null )
			textures_.set ( path, tex );
		else
			trace("cocos2d: Couldn't add image:"+path+" in CCTextureCache");
	}
	
	return tex;
}


/** Returns a Texture2D object given an CGImageRef image
 * If the image was not previously loaded, it will create a new CCTexture2D object and it will return it.
 * Otherwise it will return a reference of a previously loaded image
 * The "key" parameter will be used as the "key" for the cache.
 * If "key" is null, then a new texture will be created each time.
 * @since v0.8
 */
public function addUIImage (imageref:UIImage, key:String) :CCTexture2D
{
	if (imageref == null) throw "TextureCache: image MUST not be null";
	
	var tex :CCTexture2D = textures_.get(key);
	
	// If key is null, then create a new texture each time
	if( key != null && tex != null )
		return tex;
	
	tex = new CCTexture2D().initWithImage(imageref);
	
	if( key != null && tex != null )
		textures_.set (key, tex);
	else
		trace("cocos2d: Couldn't add UIImage in CCTextureCache");
	
	return tex;
}


/** Returns a Texture2D object given a file image
 * If the file image was not previously loaded, it will create a new CCTexture2D object and it will return it.
 * Otherwise it will load a texture in a new thread, and when the image is loaded, the callback will be called with the Texture2D as a parameter.
 * The callback will be called from the main thread, so it is safe to create any cocos2d object from the callback.
 * Supported image extensions: .png, .bmp, .tiff, .jpeg, .pvr, .gif
 * @since v0.8
 */
public function addImageAsync (path:String, target:Dynamic, selector:Dynamic) :Void
{
	if(path == null) throw "TextureCache: fileimage MUST not be null";
	
	path = path.removeHDSuffixFromFile();
	var tex :CCTexture2D = textures_.get(path);
	
	if( tex != null ) {
		target.performSelector ( selector, tex );
		return;
	}

	// schedule the load
	
	var asyncObject = new CCAsyncObject();
		asyncObject.selector = selector;
		asyncObject.target = target;
		asyncObject.data = path;
	
	addImageWithAsyncObject ( asyncObject );
}
public function addImageWithAsyncObject ( async:CCAsyncObject )
{
	// load / create the texture
	var tex :CCTexture2D = this.addImage ( async.data );
	// The callback will be executed on the main thread
	async.target.performSelectorOnMainThread (async.selector, tex, false);
	
	var action = cocos.action.CCCallFuncO.actionWithTarget ( async.target, async.selector, tex );
	CCActionManager.sharedManager().addAction ( action, async.target, false );
}


/** Returns an already created texture. Returns null if the texture doesn't exist.
 @since v0.99.5
 */
inline public function textureForKey (key:String) :CCTexture2D
{
    return textures_.get ( key );    
}


/** Purges the dictionary of loaded textures.
 * Call this method if you receive the "Memory Warning"
 * In the short term: it will free some resources preventing your app from being killed
 * In the medium term: it will allocate more resources
 * In the long term: it will be the same
 */
public function removeAllTextures ()
{
	textures_ = new Hash<CCTexture2D>();
}


/** Removes unused textures
 * Textures that have a retain count of 1 will be deleted
 * It is convinient to call this method after when starting a new Scene
 * @since v0.8
 */
public function removeUnusedTextures ()
{
	for( key in textures_.keys() ) {
		var value /*:CCTextureCache*/ = textureForKey ( key );
		// TO DO. Probably there's no way to find the retain count of an object like in objecive-c	
/*		if( value.retainCount == 1 ) {
			trace("cocos2d: CCTextureCache: removing unused texture: "+ key);
			textures_.removeObjectForKey ( key );
		}*/
	}
}

/** Deletes a texture from the cache given a texture
 */
public function removeTexture (tex:CCTexture2D) 
{
	if( tex == null )
		return;

	for( key in textures_.keys() )
		if (textures_.get(key) == tex)
			removeTextureForKey ( key );
}

/** Deletes a texture from the cache given a its key name
 @since v0.99.4
 */
inline public function removeTextureForKey ( name:String )
{
	textures_.remove ( name );
}


public function new () {}
public function init () :CCTextureCache
{
	textures_ = new Hash<CCTexture2D>();
	return this;
}

public function toString () :String
{
	return "<CCTextureCache | num of textures =  "+0+" | keys: "+textures_.keys()+">";
}

public function release () :Void
{
	trace("cocos2d: releaseing "+ this);
	textures_ = null;
}

public function dumpCachedTextureInfo ()
{
	var count :Int = 0;
	var totalBytes :Int = 0;
	for (texKey in textures_.keys()) {
		var tex :CCTexture2D = textures_.get ( texKey );
		var bpp :Int = 8;//tex.bitsPerPixelForFormat;
		// Each texture takes up width * height * bytesPerPixel bytes.
		var bytes :Int = Math.round (tex.pixelsWide * tex.pixelsHigh * bpp / 8);
		totalBytes += bytes;
		count++;
		trace("cocos2d: \""+texKey+"\" id="+tex.name+" => "+(bytes/1024)+" KB");
	}
	trace( "cocos2d: CCTextureCache dumpDebugInfo: "+count+" textures, for "+totalBytes / 1024+" KB ("+totalBytes / (1024.0*1024.0)+" MB)");
}

}


class CCAsyncObject
{
public var selector :Dynamic;
public var target :Dynamic;
public var data :Dynamic;

public function new () {}
public function release ()
{
	data = null;
}
}
