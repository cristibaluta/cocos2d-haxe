/*

===== IMPORTANT =====

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical accuracy, it is not
final. Apple is supplying this information to help you plan for the adoption of
the technologies and programming interfaces described herein. This information
is subject to change, and software implemented based on this sample code should
be tested with final operating system software and final documentation. Newer
versions of this sample code may be provided with future seeds of the API or
technology. For information about updates to this and other developer
documentation, view the New & Updated sidebars in subsequent documentationd
seeds.

=====================

File: Texture2D.m
Abstract: Creates OpenGL 2D textures from images or text.

Version: 1.6

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/
package cocos;


#if flash
	import flash.display.BitmapData;
	import flash.display.Bitmap;
#end

import cocos.CCConfig;
import cocos.CCConfiguration;
import cocos.CCTypes;
import cocos.support.UIImage;
import cocos.support.CGSize;
import cocos.support.CGRect;
import cocos.support.CGPoint;
using cocos.support.CCUtils;

// FontLabel support
import cocos.fontlabel.FontManager;
import cocos.fontlabel.FontLabelStringDrawing;
using cocos.fontlabel.FontLabelStringDrawing;

/**
 Extension to set the Min / Mag filter
 */
typedef TexParams = {
	var minFilter :GL;
	var magFilter :GL;
	var wrapS :GL;
	var wrapT :GL;
}
typedef CCTextAlignment = {}
enum CCLineBreakMode {
	CCLineBreakModeWordWrap;
}

/** CCTexture2D class.
 * This class allows to easily create OpenGL 2D textures from images, text or raw data.
 * The created CCTexture2D object will always have power-of-two dimensions. 
 * Depending on how you create the CCTexture2D object, the actual image area of the texture 
   might be smaller than the texture dimensions i.e. "contentSize" != (pixelsWide, pixelsHigh) 
   and (maxS, maxT) != (1.0, 1.0).
 * Be aware that the content of the generated textures will be upside-down!
 */
class CCTexture2D
{
var name_ :Int;
var size_ :CGSize;
var width_ :Int;
var height_ :Int;
var hasPremultipliedAlpha_ :Bool;


/** width in pixels */
public var pixelsWide (get_pixelsWide, null) :Int;
/** hight in pixels */
public var pixelsHigh (get_pixelsHigh, null) :Int;

/** texture name */
public var name (get_name, null) :Int;

/** returns content size of the texture in pixels */
public var contentSizeInPixels (get_contentSizeInPixels, null) :CGSize;
public var contentSize (get_contentSize, null) :CGSize;
public var data :BitmapData;

/** texture max S */
public var maxS :Float;
/** texture max T */
public var maxT :Float;
/** whether or not the texture has their Alpha premultiplied */
public var hasPremultipliedAlpha (get_hasPremultipliedAlpha, null) :Bool;



public function new () {}

public function initWithData (data:BitmapData, pixelsWide:Int, pixelsHigh:Int, contentSize:CGSize) :CCTexture2D
{
	trace("initWithData "+data);
	//glPixelStorei(GL.UNPACK_ALIGNMENT,1);
	//glGenTextures(1, &name_);
	//glBindTexture(GL.TEXTURE_2D, name_);
	this.data = data;
	this.setAntiAliasTexParameters();
	
	// Specify OpenGL texture image
	//glTexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, (GLsizei) width, (GLsizei) height, 0, GL.RGBA, GL.UNSIGNED_BYTE, data);

	size_ = contentSize;
	width_ = pixelsWide;
	height_ = pixelsHigh;
	maxS = size_.width / width_;
	maxT = size_.height / height_;

	hasPremultipliedAlpha_ = false;
	
	return this;
}

/** returns the content size of the texture in points */
public function get_contentSizeInPixels () :CGSize
{
	var ret = new CGSize();
		ret.width = size_.width / CCConfig.CC_CONTENT_SCALE_FACTOR;
		ret.height = size_.height / CCConfig.CC_CONTENT_SCALE_FACTOR;
	
	return ret;
}
public function get_contentSize () :CGSize {
	return size_;
}
function get_name () :Int {
	return name_;
}
function get_pixelsWide () :Int {
	return width_;
}
function get_pixelsHigh () :Int {
	return height_;
}
function get_hasPremultipliedAlpha () :Bool {
	return hasPremultipliedAlpha_;
}

/**
Drawing extensions to make it easy to draw basic quads using a CCTexture2D object.
These functions require GL.TEXTURE_2D and both GL.VERTEX_ARRAY and GL.TEXTURE_COORD_ARRAY client states to be enabled.
*/
/** draws a texture at a given point */
public function drawAtPoint (point:CGPoint) :Void
{
	trace("drawAtPoint "+point);
	var coordinates = [	0.0,	maxT,
						maxS,	maxT,
						0.0,	0.0,
						maxS,	0.0];
	var width = width_ * maxS;
	var height = height_ * maxT;

	var vertices = [point.x,			point.y,			0.0,
					width + point.x,	point.y,			0.0,
					point.x,			height  + point.y,	0.0,
					width + point.x,	height  + point.y,	0.0];
	
/*	glBindTexture(GL.TEXTURE_2D, name_);
	glVertexPointer(3, GL.FLOAT, 0, vertices);
	glTexCoordPointer(2, GL.FLOAT, 0, coordinates);
	glDrawArrays(GL.TRIANGLE_STRIP, 0, 4);*/
}

/** draws a texture inside a rect */
public function drawInRect ( rect:CGRect ) :Void
{
	var coordinates = [	0.0,	maxT,
						maxS,	maxT,
						0.0,	0.0,
						maxS,	0.0];
	var vertices = [rect.origin.x,							rect.origin.y,							/*0.0,*/
					rect.origin.x + rect.size.width,		rect.origin.y,							/*0.0,*/
					rect.origin.x,							rect.origin.y + rect.size.height,		/*0.0,*/
					rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height,		/*0.0*/ ];
	
/*	glBindTexture(GL.TEXTURE_2D, name_);
	glVertexPointer(2, GL.FLOAT, 0, vertices);
	glTexCoordPointer(2, GL.FLOAT, 0, coordinates);
	glDrawArrays(GL.TRIANGLE_STRIP, 0, 4);*/
}

/**
Extensions to make it easy to create a CCTexture2D object from an image file.
Note that RGBA type textures will have their alpha premultiplied - use the blending mode (GL.ONE, GL.ONE_MINUS_SRC_ALPHA).
*/
/** Initializes a texture from a UIImage object */
public function initWithImage (image:UIImage) :CCTexture2D
{
	var POTWide :Int;
	var POTHigh :Int;
	//var context :Dynamic = null;
	var data :BitmapData;
	//var tempData :BitmapData;
	//var inPixel32 :Int;
	//var outPixel16 :Int;
	var hasAlpha :Bool;
	var imageSize :CGSize;
	
	trace ("initWithImage "+image);
	if(image == null) {
		trace("cocos2d: CCTexture2D. Can't create Texture. UIImage is null");
		this.release();
		return null;
	}
	
	var conf :CCConfiguration = CCConfiguration.sharedConfiguration();

#if CC_TEXTURE_NPOT_SUPPORT
	if( conf.supportsNPOT ) {
		POTWide = image.width;
		POTHigh = image.height;
	} else
#end
	{
		POTWide = image.width.ccNextPOT();
		POTHigh = image.height.ccNextPOT();
	}
	trace("cocos2d: texture size "+POTWide+" x "+POTHigh);
	
	var maxTextureSize :Int = conf.maxTextureSize;
	if( POTHigh > maxTextureSize || POTWide > maxTextureSize ) {
		trace("cocos2d: WARNING: Image ("+POTWide+" x "+POTHigh+") is bigger than the supported "+maxTextureSize+" x "+maxTextureSize);
		this.release();
		return null;
	}
	
	//info = imageGetAlphaInfo(image);
	hasAlpha = true;// UIImage bitmap is created with transparency
	//((info == kimageAlphaPremultipliedLast) || (info == kimageAlphaPremultipliedFirst) || (info == kimageAlphaLast) || (info == kimageAlphaFirst) ? true : NO);
	
	imageSize = new CGSize (image.width, image.height);
	trace(imageSize);
	// Create the bitmap graphics context
#if flash
	data = new BitmapData (POTWide, POTHigh, true, 0x000000ff);
	data.draw ( image.bitmap );
	
	//context = new Bitmap (data, flash.display.PixelSnapping.AUTO, true);
	//CGContextClearRect(context, new CGRect (0, 0, POTWide, POTHigh));
	//CGContextTranslateCTM(context, 0, POTHigh - imageSize.height);
	//CGContextDrawImage(context, new CGRect (0, 0, imageGetWidth(image), imageGetHeight(image)), image);
#end
	// Repack the pixel data into the right format
	this.initWithData ( data, POTWide, POTHigh, imageSize );
	
	return this;
}

/**
Extensions to make it easy to create a CCTexture2D object from a string of text.
Note that the generated textures are of type A8 - use the blending mode (GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA).
*/
/** Initializes a texture from a string with dimensions, alignment, line break mode, font name and font size
 Supported lineBreakModes:
	- iOS: all UILineBreakMode supported modes
	- Mac: Only NSLineBreakByWordWrapping is supported.
 @since v1.0
 */
public function initWithString (string:String,
								?dimensions:CGSize,
								?alignment:CCTextAlignment,
								?lineBreakMode:CCLineBreakMode,
								fontName:String,
								fontSize:Float)
{
	trace("initWithString "+string);
	//if (!uifont) throw "Invalid font";
	
	//var context = this.graphics;
	
	// normal fonts
//	if( Std.is (uifont, UIFont) )
//		string.drawInRect ( new CGRect(0, 0, dimensions.width, dimensions.height), uifont, lineBreakMode, alignment );
	
//#if CC_FONT_LABEL_SUPPORT
	//string.drawInRect ( new CGRect(0, 0, dimensions.width, dimensions.height), uifont, lineBreakMode, alignment );
//#end
	
	var format = new flash.text.TextFormat();
	format.font = fontName;
	format.color = 0xFFFFFF;
	format.size = fontSize;
	
	var text = new flash.text.TextField();
	text.defaultTextFormat = format;
	text.antiAliasType = flash.text.AntiAliasType.ADVANCED;
	text.wordWrap = false;
	text.selectable = false;
	text.htmlText = string;
	text.autoSize = flash.text.TextFieldAutoSize.LEFT;
	
	if (dimensions == null || dimensions.width == 0 || dimensions.height == 0)
		dimensions = new CGSize (text.width, text.height);
	
	var POTWide :Int = Math.round(dimensions.width).ccNextPOT();
	var POTHigh :Int = Math.round(dimensions.height).ccNextPOT();
	
	var data = new flash.display.BitmapData (POTWide, POTHigh, true, 0x000000ff);
		data.draw ( text );
	
	this.initWithData ( data, POTWide, POTHigh, dimensions );

	return this;
}



public function setTexParameters (texParams:TexParams)
{
/*	glBindTexture( GL.TEXTURE_2D, name_ );
	glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, texParams.minFilter );
	glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, texParams.magFilter );
	glTexParameteri( GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, texParams.wrapS );
	glTexParameteri( GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, texParams.wrapT );*/
}
/** sets antialias texture parameters:
  - GL.TEXTURE_MIN_FILTER = GL.LINEAR
  - GL.TEXTURE_MAG_FILTER = GL.LINEAR

 @since v0.8
 */
public function setAntiAliasTexParameters ()
{
	var texParams :TexParams = { minFilter:GL.LINEAR, magFilter:GL.LINEAR, wrapS:GL.CLAMP_TO_EDGE, wrapT:GL.CLAMP_TO_EDGE };
	this.setTexParameters( texParams );
}

/** sets alias texture parameters:
  - GL.TEXTURE_MIN_FILTER = GL.NEAREST
  - GL.TEXTURE_MAG_FILTER = GL.NEAREST

 @since v0.8
 */
public function setAliasTexParameters ()
{
	var texParams :TexParams = { minFilter:GL.NEAREST, magFilter:GL.NEAREST, wrapS:GL.CLAMP_TO_EDGE, wrapT:GL.CLAMP_TO_EDGE };
	this.setTexParameters( texParams );
}


/** Generates mipmap images for the texture.
 It only works if the texture size is POT (power of 2).
 @since v0.99.0
 */
public function generateMipmap ()
{
	if (width_ == width_.ccNextPOT() && height_ == height_.ccNextPOT())
		throw "Mimpap texture only works in POT textures";
	//glBindTexture( GL.TEXTURE_2D, name_ );
	//ccglGenerateMipmap(GL.TEXTURE_2D);
}



public function release ()
{
	trace("cocos2d: releaseing "+ this);
/*	if(name_ != null)
		glDeleteTextures(1, name_);*/
}

public function toString () :String
{
	return "<CCTexture2D | Name = "+name_+" | Dimensions = "+width_+"x"+height_+" | Coordinates = ("+maxS+", "+maxT+")>";
}



/*
- (id) initWithString:(String*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment attributedString ( stringWithAttributes:NSAttributedString )
{				
	if (stringWithAttributes) throw "Invalid stringWithAttributes";

	var POTWide :Int = ccNextPOT(dimensions.width);
	var POTHigh :Int = ccNextPOT(dimensions.height);
	char*			data;
	
	var realDimensions :NSSize = stringWithAttributes.size;

	//Alignment
	var xPadding :Float = 0;
	
	// Mac crashes if the width or height is 0
	if( realDimensions.width > 0 && realDimensions.height > 0 ) {
		switch (alignment) {
			case CCTextAlignmentLeft: xPadding = 0;
			case CCTextAlignmentCenter: xPadding = (dimensions.width-realDimensions.width)/2.0;
			case CCTextAlignmentRight: xPadding = dimensions.width-realDimensions.width;
		}
		
		//Disable antialias
		[NSGraphicsContext.currentContext] setShouldAntialias ( false );	
		
		var image :NSImage = new NSImage().initWithSize:NSMakeSize(POTWide, POTHigh);
		image.lockFocus;	
		
		stringWithAttributes.drawAtPoint:NSMakePoint(xPadding, POTHigh-dimensions.height); // draw at offset position	
		
		var bitmap :NSBitmapImageRep = new NSBitmapImageRep().initWithFocusedViewRect:NSMakeRect (0.0, 0.0, POTWide, POTHigh);
		image.unlockFocus;
		
		data = (char*) bitmap.bitmapData;  //Use the same buffer to improve the performance.
		
		var textureSize :Int = POTWide*POTHigh;
		for(int i = 0; i<textureSize; i++) //Convert RGBA8888 to A8
			data[i] = data[i*4+3];
		
		data = this.keepData ( data, textureSize );
		this = this.initWithData ( data, kCCTexture2DPixelFormat_A8, POTWide, POTHigh, dimensions );
		
		bitmap.release();
		image.release(); 
			
	} else {
		this.release();
		return null;
	}
	
	return this;
}
*/
/*
- (id) initWithString:(String*)string fontName:(String*)name fontSize ( size:Float )
{
    dim:CGSize;

#if ios
	id font;
	font = UIFont.fontWithName ( name, size );
	if( font )
		dim = string.sizeWithFont ( font );

#if CC_FONT_LABEL_SUPPORT
	if( ! font ){
		font = FontManager.sharedManager().zFontWithName ( name, size );
		if (font)
			dim = string.sizeWithZFont ( font );
	}
#end // CC_FONT_LABEL_SUPPORT
	
	if( ! font ) {
		trace("cocos2d: Unable to load font "+ name);
		this.release();
		return null;
	}
	
	return this.initWithString ( string, dim, CCTextAlignmentCenter, UILineBreakModeWordWrap, font );
	
#else flash
	{

		var font :NSFont = NSFontManager.sharedFontManager().fontWithFamily (name, [NSUnboldFontMask, NSUnitalicFontMask], 0, size);

		var dict :NSDictionary = NSDictionary.dictionaryWithObject ( font, NSFontAttributeName );	

		var stringWithAttributes :NSAttributedString = [new NSAttributedString().initWithString:string attributes:dict] autorelease];

		dim = NSSizeToCGSize( stringWithAttributes.size] );
				
		return this.initWithString ( string, dim, CCTextAlignmentCenter, stringWithAttributes );
	}
#end // __MAC_OS_X_VERSION_MAX_ALLOWED
    
}
*/
/*
- (id) initWithString:(String*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(String*)name fontSize ( size:Float )
{
	return this.initWithString ( string, dimensions, alignment, CCLineBreakModeWordWrap, name, size );
}

- (id) initWithString:(String*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(String*)name fontSize ( size:Float )
{
#if ios
	id						uifont = null;
	
	uifont = UIFont.fontWithName ( name, size );
	
#if CC_FONT_LABEL_SUPPORT
	if( ! uifont )
		uifont = [FontManager.sharedManager] zFontWithName ( name, size );
#end // CC_FONT_LABEL_SUPPORT
	if( ! uifont ) {
		trace("cocos2d: Texture2d: Invalid Font: %@. Verify the .ttf name", name);
		this.release();
		return null;
	}
	
	return this.initWithString ( string, dimensions, alignment, lineBreakMode, uifont );
	
#else flash
	
	if (lineBreakMode == CCLineBreakModeWordWrap) throw "CCTexture2D: unsupported line break mode for Mac OS X";

	//String with attributes
	var stringWithAttributes :NSAttributedString =
	[new NSAttributedString().initWithString:string
									 attributes:NSDictionary.dictionaryWithObject:[NSFontManager.sharedFontManager]
																					fontWithFamily:name
																					traits:NSUnboldFontMask | NSUnitalicFontMask
																					weight:0
																					size:size]
																			forKey:NSFontAttributeName]
	  ]
	 autorelease];
	
	return this.initWithString ( string, dimensions, alignment, stringWithAttributes );
	
#end // Mac
}
*/
}

