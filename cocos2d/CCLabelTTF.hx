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
import CCTexture2D;
import CCSprite;
import objc.CGSize;
import objc.CGRect;
using support.CGPointExtension;
using CCMacros;

/*#if nme
import platforms.nme.CCDirectorNME;
#end*/

/** CCLabel is a subclass of CCTextureNode that knows how to render text labels
 *
 * All features from CCTextureNode are valid in CCLabel
 *
 * CCLabel objects are slow. Consider using CCLabelAtlas or CCLabelBMFont instead.
 */

class CCLabelTTF extends CCSprite
{
var dimensions_ :CGSize;
var alignment_ :CCTextAlignment;
var lineBreakMode_ :CCLineBreakMode;
var fontName_ :String;
var fontSize_ :Float;
var string_ :String;

public var string (get_string, set_string) :String;


override public function init () :CCNode
{
	throw "CCLabelTTF: Init not supported. Use initWithString";
	return null;
}

public static function labelWithString (string:String,
										?dimensions:CGSize,
										?alignment:CCTextAlignment,
										?lineBreakMode:CCLineBreakMode,
										fontName:String,
										fontSize:Float) :CCLabelTTF
{
	return new CCLabelTTF().initWithString (string, dimensions, alignment, lineBreakMode, fontName, fontSize);
}

public function initWithString (str:String,
								?dimensions:CGSize,
								?alignment:CCTextAlignment,
								?lineBreakMode:CCLineBreakMode,
								fontName:String,
								fontSize:Float) :CCLabelTTF
{
	super.init();
	trace("initWithString "+str);
	dimensions_ = dimensions == null 
		? new CGSize() 
		: new CGSize (dimensions.width * CCConfig.CC_CONTENT_SCALE_FACTOR, dimensions.height * CCConfig.CC_CONTENT_SCALE_FACTOR);
	alignment_ = alignment;
	lineBreakMode_ = lineBreakMode != null ? lineBreakMode : CCLineBreakModeWordWrap;
	fontName_ = fontName;
	fontSize_ = fontSize * CCConfig.CC_CONTENT_SCALE_FACTOR;
	
	set_string ( str );
	
	return this;
}

public function set_string ( str:String ) :String
{trace("set string "+str);
	var tex :CCTexture2D = new CCTexture2D().initWithString (str, dimensions_, alignment_, lineBreakMode_, fontName_, fontSize_ );
	this.setTexture ( tex );

	var rect = new CGRect(0,0,0,0);
		rect.size = texture.contentSize;
	this.setTextureRect ( rect );
	
	return string;
}

public function get_string () :String
{
	return string_;
}
override public function toString () :String
{
	return "<CCLabelTTF | FontSize = "+fontSize_+"> "+super.toString();
}

}
