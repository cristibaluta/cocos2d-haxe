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
 * Portions of this code are based and inspired on:
 *   http://www.71squared.co.uk/2009/04/iphone-game-programming-tutorial-4-bitmap-font-class
 *   by Michael Daley
 * 
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */
package cocos;


import cocos.CCSpriteBatchNode;
import cocos.CCConfig;
import cocos.CCSprite;
import cocos.CCDrawingPrimitives;
import cocos.CCConfiguration;
import cocos.CCTypes;
import cocos.support.CGRect;
import cocos.support.CGPoint;
import cocos.support.CGSize;
import cocos.support.NSDictionary;
import cocos.support.CCFileUtils;
using cocos.support.CGPointExtension;
using cocos.support.StringExtension;
//import cocos.support.uthash;


/** @struct BMFontDef
 BMFont definition
 */
typedef BMFontDef = {
	//! ID of the character
	var charID :Int;
	//! origin and size of the font
	var rect :CGRect;
	//! The X amount the image should be offset when drawing the image (in pixels)
	var xOffset :Int;
	//! The Y amount the image should be offset when drawing the image (in pixels)
	var yOffset :Int;
	//! The amount to move the current position after drawing the character (in pixels)
	var xAdvance :Int;
}

/** @struct ccBMFontPadding
 BMFont padding
 @since v0.8.2
 */
typedef BMFontPadding = {
	/// padding left
	var left :Int;
	/// padding top
	var top :Int;
	/// padding right
	var right :Int;
	/// padding bottom
	var bottom :Int;
}

// Equal function for targetSet.
typedef KerningHashElement =
{
	var key :Int;// key for the hash. 16-bit for 1st element, 16-bit for 2nd element
	var amount :Int;
	var hh :Dynamic;//UT_hash_handle;
}



/** CCBMFontConfiguration has parsed configuration of the the .fnt file
 @since v0.8
 */
class CCBMFontConfiguration
{
	// how many characters are supported
	static var kCCBMFontMaxChars = 2048; //256,
	
// XXX: Creating a public interface so that the bitmapFontArray[] is accesible

	// The characters building up the font
	public var BMFontArray_ :Array<BMFontDef>;
	
	// FNTConfig: Common Height
	public var commonHeight_ :Int;
	
	// Padding
	public var padding_ :BMFontPadding;
	
	// atlas name
	public var atlasName :String;

	// values for kerning
	public var kerningDictionary_ :KerningHashElement;
	public var configurations :NSDictionary;


/** allocates a CCBMFontConfiguration with a FNT file */
public static function configurationWithFNTFile (FNTfile:String) :CCBMFontConfiguration
{
	return new CCBMFontConfiguration().initWithFNTfile (FNTfile);
}

public function new () {}
/** initializes a CCBMFontConfiguration with a FNT file */
public function initWithFNTfile (fntFile:String) :CCBMFontConfiguration
{
	kerningDictionary_ = null;
	BMFontArray_[kCCBMFontMaxChars] = null;
	this.parseConfigFile ( fntFile );
	
	return this;
}


// -
// FNTConfig Cache - free functions

public function FNTConfigLoadFile( fntFile:String ) :CCBMFontConfiguration
{
	var ret :CCBMFontConfiguration = null;
	
	if( configurations == null )
		configurations = new NSDictionary();
	
	ret = configurations.objectForKey ( fntFile );
	if( ret == null ) {
		ret = CCBMFontConfiguration.configurationWithFNTFile ( fntFile );
		configurations.setObject ( ret, fntFile );
	}
	
	return ret;
}

public function FNTConfigRemoveCache()
{
	configurations.removeAllObjects;
}

public function release ()
{
	trace( "cocos2d: releaseing "+ this);
	this.purgeKerningDictionary();
}

public function toString () :String
{
	return "<CCBMFontConfiguration | Kernings:%d | Image = "+atlasName;
}

public function purgeKerningDictionary ()
{
	var current :KerningHashElement = null;
	
	while(kerningDictionary_ != null) {
		current = kerningDictionary_;
		//HASH_DEL(kerningDictionary_,current);
	}
}

public function parseConfigFile ( fntFile:String )
{
	var fullpath :String = CCFileUtils.fullPathFromRelativePath ( fntFile );
	var contents :String = CCFileUtils.stringWithContentsOfFile(fullpath);
	
	// Move all lines in the string, which are denoted by \n, into an array
	var lines :Array<String> = contents.split("\n");
	
	// Loop through all the lines in the lines array processing each one
	for( line in lines ) {
		// parse spacing / padding
		if(line.indexOf("info face") == 0) {
			// XXX: info parsing is incomplete
			// Not needed for the Hiero editors, but needed for the AngelCode editor
//			this.parseInfoArguments ( line );
		}
		// Check to see if the start of the line is something we are interested in
		else if(line.indexOf("common lineHeight") == 0) {
			this.parseCommonArguments ( line );
		}
		else if(line.indexOf("page id") == 0) {
			this.parseImageFileName ( line, fntFile );
		}
		else if(line.indexOf("chars c") == 0) {
			// Ignore this line
		}
		else if(line.indexOf("char") == 0) {
			// Parse the current line and create a new CharDef
			var characterDefinition :BMFontDef = parseCharacterDefinition (line, null);

			// Add the CharDef returned to the charArray
			BMFontArray_[ characterDefinition.charID ] = characterDefinition;
		}
		else if(line.indexOf("kernings count") == 0) {
			this.parseKerningCapacity ( line );
		}
		else if(line.indexOf("kerning first") == 0) {
			this.parseKerningEntry ( line );
		}
	}
	// Finished with lines so release it
	lines = null;
}

public function parseImageFileName (line:String, fntFile:String) :Void
{
	var propertyValue :String = null;

	// Break the values for this line up using =
	var values :Array<String> = line.split("=");
	
	// Get the enumerator for the array of components which has been created
	var nse :Iterator<String> = values.iterator();
	
	// We need to move past the first entry in the array before we start assigning values
	nse.next();
	
	// page ID. Sanity check
	propertyValue = nse.next();
	if (Std.parseInt(propertyValue) != 0) throw "XXX: LabelBMFont only supports 1 page";
	
	// file 
	propertyValue = nse.next();
	var array :Array<String> = propertyValue.split("\"");
	propertyValue = array[1];
	//if (propertyValue,"LabelBMFont file could not be found");
	
	// Supports subdirectories
	var  dir :String = fntFile.stringByDeletingLastPathComponent();
	atlasName = dir.stringByAppendingPathComponent ( propertyValue );
}

public function parseInfoArguments ( line:String )
{
	//
	// possible lines to parse:
	// info face="Script" size=32 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=1,4,3,2 spacing=0,0 outline=0
	// info face="Cracked" size=36 bold=0 italic=0 charset="" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1
	//
	var values :Array<String> = line.split("=");
	var nse :Iterator<String> = values.iterator();
	var propertyValue :String = null;
	
	// We need to move past the first entry in the array before we start assigning values
	nse.next();
	
	// face (ignore)
	nse.next();
	
	// size (ignore)
	nse.next();

	// bold (ignore)
	nse.next();

	// italic (ignore)
	nse.next();
	
	// charset (ignore)
	nse.next();

	// unicode (ignore)
	nse.next();

	// strechH (ignore)
	nse.next();

	// smooth (ignore)
	nse.next();
	
	// aa (ignore)
	nse.next();
	
	// padding (ignore)
	propertyValue = nse.next();
	
	{
		var paddingValues :Array<String> = propertyValue.split(",");
		var paddingEnum :Iterator<String> = paddingValues.iterator();
		// padding top
		propertyValue = paddingEnum.next();
		padding_.top = Std.parseInt(propertyValue);
		
		// padding right
		propertyValue = paddingEnum.next();
		padding_.right = Std.parseInt(propertyValue);

		// padding bottom
		propertyValue = paddingEnum.next();
		padding_.bottom = Std.parseInt(propertyValue);
		
		// padding left
		propertyValue = paddingEnum.next();
		padding_.left = Std.parseInt(propertyValue);
		
		trace("cocos2d: padding: "+padding_.left+","+padding_.top+","+padding_.right+","+padding_.bottom);
	}

	// spacing (ignore)
	nse.next();	
}

public function parseCommonArguments ( line:String )
{
	//
	// line to parse:
	// common lineHeight=104 base=26 scaleW=1024 scaleH=512 pages=1 packed=0
	//
	var values :Array<String> = line.split("=");
	var nse :Iterator<String> = values.iterator();
	var propertyValue :String = null;
	
	// We need to move past the first entry in the array before we start assigning values
	nse.next();
	
	// Character ID
	propertyValue = nse.next();
	commonHeight_ = Std.parseInt(propertyValue);
	
	// base (ignore)
	nse.next();
	
	
	// scaleW. sanity check
	propertyValue = nse.next();	
	if (Std.parseInt(propertyValue) <= CCConfiguration.sharedConfiguration().maxTextureSize)
		throw "CCLabelBMFont: page can't be larger than supported";
	
	// scaleH. sanity check
	propertyValue = nse.next();
	if (Std.parseInt(propertyValue) <= CCConfiguration.sharedConfiguration().maxTextureSize)
		throw "CCLabelBMFont: page can't be larger than supported";
	
	// pages. sanity check
	propertyValue = nse.next();
	if (Std.parseInt(propertyValue) == 1) throw "CCBitfontAtlas: only supports 1 page";
	
	// packed (ignore) What does this mean ??
}
public function parseCharacterDefinition (line:String, characterDefinition:BMFontDef) :BMFontDef
{	
	// Break the values for this line up using =
	var values :Array<String> = line.split("=");
	var nse :Iterator<String> = values.iterator();	
	var propertyValue :String;
	
	// We need to move past the first entry in the array before we start assigning values
	nse.next();
	
	// Character ID
	propertyValue = nse.next();
	//propertyValue = propertyValue.substringToIndex (propertyValue.rangeOfString(" ").location);
	propertyValue = propertyValue.substr (propertyValue.indexOf(" "));
	characterDefinition.charID = Std.parseInt (propertyValue);
	
	if (characterDefinition.charID >= kCCBMFontMaxChars) throw "BitmpaFontAtlas: CharID bigger than supported";

	// Character x
	propertyValue = nse.next();
	characterDefinition.rect.origin.x = Std.parseInt(propertyValue);
	// Character y
	propertyValue = nse.next();
	characterDefinition.rect.origin.y = Std.parseInt(propertyValue);
	// Character width
	propertyValue = nse.next();
	characterDefinition.rect.size.width = Std.parseInt(propertyValue);
	// Character height
	propertyValue = nse.next();
	characterDefinition.rect.size.height = Std.parseInt(propertyValue);
	// Character xoffset
	propertyValue = nse.next();
	characterDefinition.xOffset = Std.parseInt(propertyValue);
	// Character yoffset
	propertyValue = nse.next();
	characterDefinition.yOffset = Std.parseInt(propertyValue);
	// Character xadvance
	propertyValue = nse.next();
	characterDefinition.xAdvance = Std.parseInt(propertyValue);
	
	return characterDefinition;
}

public function parseKerningCapacity(line:String)
{
	// When using uthash there is not need to parse the capacity.

//	if (!kerningDictionary, "dictionary already initialized");
//	
//	// Break the values for this line up using =
//	var values :Array<String> = line.split("="];
//	var nse :NSEnumerator = values.objectEnumerator;	
//	var  propertyValue :String;
//	
//	// We need to move past the first entry in the array before we start assigning values
//	nse.next();
//	
//	// count
//	propertyValue = nse.next();
//	var capacity :Int = Std.parseInt(propertyValue);
//	
//	if( capacity != -1 )
//		kerningDictionary = ccHashSetNew(capacity, targetSetEql);
}

public function parseKerningEntry(line:String)
{
	var values :Array<String> = line.split("=");
	var nse :Iterator<String> = values.iterator();
	var propertyValue :String;
	
	// We need to move past the first entry in the array before we start assigning values
	nse.next();
	
	// first
	propertyValue = nse.next();
	var first :Int = Std.parseInt (propertyValue);
	
	// second
	propertyValue = nse.next();
	var second :Int = Std.parseInt (propertyValue);
	
	// second
	propertyValue = nse.next();
	var amount :Int = Std.parseInt (propertyValue);

	var element :KerningHashElement =
	{
		key : (first<<16) | (second&0xffff),
		amount :amount,
		hh :null
	};
	//HASH_ADD_INT(kerningDictionary_,key, element);
}

}





/** CCLabelBMFont is a subclass of CCSpriteBatchNode
  
 Features:
 - Treats each character like a CCSprite. This means that each individual character can be:
   - rotated
   - scaled
   - translated
   - tinted
   - chage the opacity
 - It can be used as part of a menu item.
 - anchorPoint can be used to align the "label"
 - Supports AngelCode text format
 
 Limitations:
  - All inner characters are using an anchorPoint of (0.5, 0.5) and it is not recommend to change it
    because it might affect the rendering
 
 CCLabelBMFont implements the protocol CCLabelProtocol, like CCLabel and CCLabelAtlas.
 CCLabelBMFont has the flexibility of CCLabel, the speed of CCLabelAtlas and all the features of CCSprite.
 If in doubt, use CCLabelBMFont instead of CCLabelAtlas / CCLabel.
 
 Supported editors:
  - http://www.n4te.com/hiero/hiero.jnlp
  - http://slick.cokeandcode.com/demos/hiero.jnlp
  - http://www.angelcode.com/products/bmfont/
 
 @since v0.8
 */

class CCLabelBMFont extends CCSpriteBatchNode
{
// how many characters are supported
static var kCCBMFontMaxChars = 2048; //256,

var configuration_ :CCBMFontConfiguration;
var opacityModifyRGB_ :Bool;
var string_ :String;
var opacity_ :Int;
var color_ :CC_Color3B;


// string to render
public var string (get, set) :String;
/** conforms to CCRGBAProtocol protocol */
public var opacity (get, set) :Int;
/** conforms to CCRGBAProtocol protocol */
public var color (get, set) :CC_Color3B;


/** Purges the cached data.
 Removes from memory the cached configurations and the atlas name dictionary.
 @since v0.99.3
 */
public static function purgeCachedData ()
{
	//FNTConfigRemoveCache();
}

/** creates a BMFont label with an initial string and the FNT file */
public static function labelWithString (string:String, fntFile:String) :CCLabelBMFont
{
	return new CCLabelBMFont().initWithString(string, fntFile);
}

/** init a BMFont label with an initial string and the FNT file */
public function initWithString (theString:String, fntFile:String) :CCLabelBMFont
{	
	if (configuration_ != null)
		configuration_.release(); // allow re-init
	//configuration_ = FNTConfigLoadFile(fntFile);
	
	if (configuration_ == null) throw "Error creating config for LabelBMFont";

	super.initWithFile (configuration_.atlasName, theString.length);

	opacity = 255;
	color = CCTypes.ccWHITE;

	contentSize = new CGSize();
	
	opacityModifyRGB_ = textureAtlas.texture.hasPremultipliedAlpha;

	anchorPoint_ = new CGPoint (0.5, 0.5);

	this.set_string ( theString );

	return this;
}


override public function release () :Void
{
	if (configuration_ != null)
		configuration_.release();
	super.release();
}

// LabelBMFont - Atlas generation

public function kerningAmountForFirst (first:Int, second:Int) :Int
{
	var ret :Int = 0;
	var key :Int = (first<<16) | (second & 0xffff);
	
	if( configuration_.kerningDictionary_ != null ) {
		var element :KerningHashElement = null;
		//key = HASH_FIND_INT (configuration_.kerningDictionary_, key, element);		
		if (element != null)
			ret = element.amount;
	}
		
	return ret;
}

public function createFontChars ()
{
	var nextFontPositionX :Int = 0;
	var nextFontPositionY :Int = 0;
	var prev :Int = -1;
	var kerningAmount :Int = 0;
	
	var tmpSize:CGSize = new CGSize();

	var longestLine :Int = 0;
	var totalHeight :Int = 0;
	
	var quantityOfLines :Int = 1;

	var stringLen :Int = string.length;
	if( stringLen == 0 )
		return;

	// quantity of lines NEEDS to be calculated before parsing the lines,
	// since the Y position needs to be calcualted before hand
	for(i in 0...(stringLen-1)) {
		var c :String = string.characterAtIndex ( i );
		if( c == "\n")
			quantityOfLines++;
	}
	
	totalHeight = configuration_.commonHeight_ * quantityOfLines;
	nextFontPositionY = - (configuration_.commonHeight_ - /*configuration_.commonHeight_ */quantityOfLines);
	
	for(i in 0...stringLen) {
		var c :String = string.characterAtIndex ( i );
		if (i < kCCBMFontMaxChars) throw "LabelBMFont: character outside bounds";
		
		if (c == '\n') {
			nextFontPositionX = 0;
			nextFontPositionY -= configuration_.commonHeight_;
			continue;
		}

		kerningAmount = this.kerningAmountForFirst ( prev, /*c*/i );
		
		var fontDef :BMFontDef = configuration_.BMFontArray_[/*c*/i];
		var rect :CGRect = fontDef.rect;
		var fontChar :CCSprite = cast this.getChildByTag ( i );
		if( fontChar == null ) {
			fontChar = new CCSprite().initWithBatchNode ( this, rect );
			this.addChild ( fontChar, 0, i );
		}
		else {
			// reusing fonts
			fontChar.set_textureRectInPixels (rect, false, rect.size);
			
			// restore to default in case they were modified
			fontChar.visible = true;
			fontChar.opacity = 255;
		}
		
		var yOffset :Float = configuration_.commonHeight_ - fontDef.yOffset;
		fontChar.positionInPixels = new CGPoint(nextFontPositionX + fontDef.xOffset + fontDef.rect.size.width*0.5 + kerningAmount,
												nextFontPositionY + yOffset - rect.size.height*0.5 );

		// update kerning
		nextFontPositionX += configuration_.BMFontArray_[/*c*/i].xAdvance + kerningAmount;
		prev = /*c*/i;

		// Apply label properties
		fontChar.set_opacityModifyRGB ( opacityModifyRGB_ );
		// Color MUST be set before opacity, since opacity might change color if OpacityModifyRGB is on
		fontChar.set_color ( color );

		// only apply opacity if it is different than 255 )
		// to prevent modifying the color too (issue #610)
		if( opacity != 255 )
			fontChar.set_opacity ( opacity );

		if (longestLine < nextFontPositionX)
			longestLine = nextFontPositionX;
	}

	tmpSize.width = longestLine;
	tmpSize.height = totalHeight;

	this.set_contentSizeInPixels ( tmpSize );
}

// LabelBMFont - CCLabelProtocol protocol
public function set_string (newString:String) :String
{
	string_ = newString;
	
	for(i in 0...children_.length)
		children_[i].visible = false;

	this.createFontChars();
	return string_;
}
public function get_string () :String {
	return string_;
}

// LabelBMFont - CCRGBAProtocol protocol

public function set_color ( color:CC_Color3B ) :CC_Color3B
{
	color_ = color;
	
	for(i in 0...children_.length)
		cast(children_[i]).set_color ( color_ );
	return color_;
}
public function get_color () :CC_Color3B {
	return color_;
}

public function set_opacity ( opacity:Int ) :Int
{
	opacity_ = opacity;

	for(i in 0...children_.length)
		cast (children_[i]).set_opacity ( opacity_ );
	return opacity_;
}
public function get_opacity () :Int {
	return opacity_;
}
public function set_opacityModifyRGB ( modify:Bool )
{
	opacityModifyRGB_ = modify;
	
	for(i in 0...children_.length)
		cast (children_[i]).set_opacityModifyRGB ( modify );
}

public function doesOpacityModifyRGB () :Bool
{
	return opacityModifyRGB_;
}

// LabelBMFont - AnchorPoint
override function set_anchorPoint ( point:CGPoint ) :CGPoint
{
	if( ! point.equalToPoint (anchorPoint_) ) {
		super.set_anchorPoint ( point );
		this.createFontChars();
	}
	return point;
}

// LabelBMFont - Debug draw
#if CC_LABELBMFONT_DEBUG_DRAW
override public function draw ()
{
	super.draw();

	var s:CGSize = this.contentSize;
	var vertices :Array<CGPoint> = [
		new CGPoint (0,0),
		new CGPoint (s.width,0),
		new CGPoint (s.width,s.height),
		new CGPoint (0,s.height),
	];
	//CC_DrawPoly(vertices, 4, true);
}
#end // CC_LABELBMFONT_DEBUG_DRAW

}
