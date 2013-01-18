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

import cocos.CCAtlasNode;
import cocos.CCTextureAtlas;
import cocos.CCConfig;
import cocos.CCMacros;
import cocos.CCTypes;
import cocos.CCDrawingPrimitives;
import cocos.support.CGSize;

/** CCLabelAtlas is a subclass of CCAtlasNode.

 It can be as a replacement of CCLabel since it is MUCH faster.

 CCLabelAtlas versus CCLabel:
 - CCLabelAtlas is MUCH faster than CCLabel
 - CCLabelAtlas "characters" have a fixed height and width
 - CCLabelAtlas "characters" can be anything you want since they are taken from an image file

 A more flexible class is CCLabelBMFont. It supports variable width characters and it also has a nice editor.
 */
class CCLabelAtlas extends CCAtlasNode
{		
// string to render
var string_ :String;
var string (getString, setString) :String;
// the first char in the charmap
var mapStartChar_ :String;



// CCLabelAtlas - Creation & Init
public static function labelWithString (string:String, charMapFile:String, itemWidth:Int, itemHeight:Int, startCharMap:String) :CCLabelAtlas
{
	return new CCLabelAtlas().initWithString (string, charMapFile, itemWidth, itemHeight, startCharMap);
}

public function initWithString (string:String, charMapFile:String, itemWidth:Int, itemHeight:Int, startCharMap:String) :CCLabelAtlas
{
	super.initWithTileFile (charMapFile, itemWidth, itemHeight, string.length);

	mapStartChar_ = startCharMap;
	this.setString(string);

	return this;
}

// CCLabelAtlas - Atlas generation

override public function updateAtlasValues ()
{
	var n :Int = string_.length;
	var quad :CC_V3F_C4B_T2F_Quad = null;
	var s :String = string_;
	var texture :CCTexture2D = textureAtlas_.texture;
	var textureWide :Float = texture.pixelsWide;
	var textureHigh :Float = texture.pixelsHigh;

	for( i in 0...n) {
		var a :Float = 0;//s[i] - mapStartChar_;
		var row :Float = (a % itemsPerRow_);
		var col :Float = (a / itemsPerRow_);
		
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		// Issue #938. Don't use texStepX & texStepY
		var left	 :Float = (2*row*itemWidth_+1)/(2*textureWide);
		var right	 :Float = left+(itemWidth_2-2)/(2*textureWide);
		var top	 :Float = (2*col*itemHeight_+1)/(2*textureHigh);
		var bottom :Float = top+(itemHeight_2-2)/(2*textureHigh);
#else
		var left	 :Float = row*itemWidth_/textureWide;
		var right	 :Float = left+itemWidth_/textureWide;
		var top	 :Float = col*itemHeight_/textureHigh;
		var bottom :Float = top+itemHeight_/textureHigh;
#end // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		
		quad.tl.texCoords.u = left;
		quad.tl.texCoords.v = top;
		quad.tr.texCoords.u = right;
		quad.tr.texCoords.v = top;
		quad.bl.texCoords.u = left;
		quad.bl.texCoords.v = bottom;
		quad.br.texCoords.u = right;
		quad.br.texCoords.v = bottom;
		
		quad.bl.vertices.x = Math.round(i * itemWidth_);
		quad.bl.vertices.y = 0;
		quad.bl.vertices.z = 0.0;
		quad.br.vertices.x = Math.round(i * itemWidth_ + itemWidth_);
		quad.br.vertices.y = 0;
		quad.br.vertices.z = 0.0;
		quad.tl.vertices.x = Math.round(i * itemWidth_);
		quad.tl.vertices.y = Math.round(itemHeight_);
		quad.tl.vertices.z = 0.0;
		quad.tr.vertices.x = Math.round(i * itemWidth_ + itemWidth_);
		quad.tr.vertices.y = Math.round(itemHeight_);
		quad.tr.vertices.z = 0.0;
		
		textureAtlas_.updateQuad (quad, i);
	}
}

// CCLabelAtlas - CCLabelProtocol

public function setString (newString:String) :String
{
	var len :Int = newString.length;
	if( len > textureAtlas_.capacity )
		textureAtlas_.resizeCapacity ( len );

	string_ = newString;
	this.updateAtlasValues();

	var s :CGSize = new CGSize (len * itemWidth_, itemHeight_);
	this.setContentSizeInPixels ( s );
	
	this.quadsToDraw = len;
	
	return string_;
}

public function getString () :String
{
	return string_;
}

// CCLabelAtlas - DebugDraw

#if CC_LABELATLAS_DEBUG_DRAW
public function draw ()
{
	super.draw();

	var s:CGSize = this.contentSize;
	var vertices :Array<CGPoint> = [
		new CGPoint (0,0),
		new CGPoint (s.width,0),
		new CGPoint (s.width,s.height),
		new CGPoint (0,s.height),
	];
	//ccDrawPoly (vertices, 4, true);
}
#end // CC_LABELATLAS_DEBUG_DRAW

}
