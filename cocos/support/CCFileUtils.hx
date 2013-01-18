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
package cocos.support;

import cocos.CCConfiguration;
import cocos.CCMacros;
import cocos.CCConfig;

//static NSFileManager __localFileManager=null;

class CCFileUtils
{
	
public static function removeHDSuffixFromFile ( path:String ) :String
{
#if CC_IS_RETINA_DISPLAY_SUPPORTED

	if( CCConfig.CC_CONTENT_SCALE_FACTOR == 2 )
		return StringTools.replace (path, CC_RETINA_DISPLAY_FILENAME_SUFFIX, "");
#end
	return path;
}


/*public static function initialize ()
{
	if( Std.is (this, CCFileUtils) )
		__localFileManager = new NSFileManager().init();
}*/

public static function getDoubleResolutionImage ( path:String ) :String
{
#if CC_IS_RETINA_DISPLAY_SUPPORTED

	if( CCConfig.CC_CONTENT_SCALE_FACTOR == 2 ) {
		// check if path already has the suffix.
		if( path.indexOf ( CC_RETINA_DISPLAY_FILENAME_SUFFIX ) != -1 ) {
			trace ("cocos2d: WARNING Filename("+name+") already has the suffix "+CC_RETINA_DISPLAY_FILENAME_SUFFIX+". Using it.");			
			return path;
		}

		var arr = path.split(".");
		var extension = arr.pop();
		var retinaName = arr.join(".") + CC_RETINA_DISPLAY_FILENAME_SUFFIX + "." + extension;
		
		if( __localFileManager.fileExistsAtPath ( retinaName ) )
			return retinaName;

		trace ("cocos2d: CCFileUtils: Warning HD file not found: " + retinaName );
	}
	
#end // CC_IS_RETINA_DISPLAY_SUPPORTED
	
	return path;
}

public static function fullPathFromRelativePath (relPath:String) :String
{
	if (relPath == null) throw "CCFileUtils: Invalid path";

	var fullpath :String = null;
	
	// only if it is not an absolute path
	if( relPath != null )
	{
		var arr :Array<String> = relPath.split("/");
		var file :String = arr.pop();
		var imageDirectory :String = arr.join("/");
		
/*		fullpath = [NSBundle.mainBundle] pathForResource:file
												   ofType:nil
											  inDirectory ( imageDirectory );*/
	}
	
	if (fullpath == null)
		fullpath = relPath;
	
	fullpath = getDoubleResolutionImage ( fullpath );
	
	return fullpath;	
}

public static function stringWithContentsOfFile (file:String) :String {
	return "";
}
}
