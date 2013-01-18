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
 */
//import cocos.platform.CCGL;

/** RGB color composed of bytes 3 bytes
@since v0.8
 */
package cocos;

typedef CC_Color3B =
{
	var r :Int;
	var g :Int;
	var b :Int;
}

/** RGBA color composed of 4 bytes
@since v0.8
*/
typedef CC_Color4B =
{
	var r :Int;
	var g :Int;
	var b :Int;
	var a :Int;
}


/** RGBA color composed of 4 Floats
@since v0.8
*/
typedef CC_Color4F =
{
	var r :Float;
	var g :Float;
	var b :Float;
	var a :Float;
}

/** A vertex composed of 2 Floats: x, y
 @since v0.8
 */
typedef CC_Vertex2F =
{
	var x :Float;
	var y :Float;
}

/** A vertex composed of 2 Floats: x, y
 @since v0.8
 */
typedef CC_Vertex3F =
{
	var x :Float;
	var y :Float;
	var z :Float;
}

/** A texcoord composed of 2 Floats: u, y
 @since v0.8
 */
typedef CC_Tex2F =
{
	var u :Float;
	var v :Float;
}


//! Point Sprite component
typedef CC_PointSprite =
{
	var pos :CC_Vertex2F;	// 8 bytes
	var color :CC_Color4B;	// 4 bytes
	var size :Float;		// 4 bytes
}

//!	A 2D Quad. 4 * 2 Floats
typedef CC_Quad2 =
{
	var tl :CC_Vertex2F;
	var tr :CC_Vertex2F;
	var bl :CC_Vertex2F;
	var br :CC_Vertex2F;
};


//!	A 3D Quad. 4 * 3 Floats
typedef CC_Quad3 =
{
	var bl :CC_Vertex3F;
	var br :CC_Vertex3F;
	var tl :CC_Vertex3F;
	var tr :CC_Vertex3F;
}

//! A 2D grid size
typedef CC_GridSize =
{
	var x :Int;
	var y :Int;
}

//! a Point with a vertex point, a tex coord point and a color 4B
typedef CC_V2F_C4B_T2F =
{
	//! vertices (2F)
	var vertices :CC_Vertex2F;
	//! colors (4B)
	var colors :CC_Color4B;
	//! tex coords (2F)
	var texCoords :CC_Tex2F;
}

//! a Point with a vertex point, a tex coord point and a color 4F
typedef CC_V2F_C4F_T2F =
{
	//! vertices (2F)
	var vertices :CC_Vertex2F;
	//! colors (4F)
	var colors :CC_Color4F;
	//! tex coords (2F)
	var texCoords :CC_Tex2F;
}

//! a Point with a vertex point, a tex coord point and a color 4B
typedef CC_V3F_C4B_T2F =
{
	//! vertices (3F)
	var vertices :CC_Vertex3F;			// 12 bytes
//	char __padding__[4();

	//! colors (4B)
	var colors :CC_Color4B;				// 4 bytes
//	char __padding2__[4();

	// tex coords (2F)
	var texCoords :CC_Tex2F;			// 8 byts
}

//! 4 CC_Vertex2FTex2FColor4B Quad
typedef CC_V2F_C4B_T2F_Quad =
{
	//! bottom left
	var bl :CC_V2F_C4B_T2F;
	//! bottom right
	var br :CC_V2F_C4B_T2F;
	//! top left
	var tl :CC_V2F_C4B_T2F;
	//! top right
	var tr :CC_V2F_C4B_T2F;
}

//! 4 CC_Vertex3FTex2FColor4B
typedef CC_V3F_C4B_T2F_Quad =
{
	//! top left
	var tl :CC_V3F_C4B_T2F;
	//! bottom left
	var bl :CC_V3F_C4B_T2F;
	//! top right
	var tr :CC_V3F_C4B_T2F;
	//! bottom right
	var br :CC_V3F_C4B_T2F;
}

//! 4 CC_Vertex2FTex2FColor4F Quad
typedef CC_V2F_C4F_T2F_Quad =
{
	//! bottom left
	var bl :CC_V2F_C4F_T2F;
	//! bottom right
	var br :CC_V2F_C4F_T2F;
	//! top left
	var tl :CC_V2F_C4F_T2F;
	//! top right
	var tr :CC_V2F_C4F_T2F;
}

//! Blend Function used for textures
typedef CC_BlendFunc =
{
	//! source blend function
	var src :Dynamic;
	//! destination blend function
	var dst :Dynamic;
}



enum GL {
	SRC_ALPHA;
	ONE_MINUS_SRC_ALPHA;
	LINEAR;
	REPEAT;
	CLAMP_TO_EDGE;
	NEAREST;
	FLOAT;
	UNSIGNED_BYTE;
	UNSIGNED_SHORT;
	TRIANGLES;
	ONE;
}


class CCTypes
{

//predefined :CC_Color3B colors
//! White color (255,255,255)
static public var ccWHITE :CC_Color3B = {r:255,g:255,b:255};
//! Yellow color (255,255,0)
static public var ccYELLOW :CC_Color3B = {r:255,g:255,b:0};
//! Blue color (0,0,255)
static public var ccBLUE :CC_Color3B = {r:0,g:0,b:255};
//! Green Color (0,255,0)
static public var ccGREEN :CC_Color3B = {r:0,g:255,b:0};
//! Red Color (255,0,0,)
static public var ccRED :CC_Color3B = {r:255,g:0,b:0};
//! Magenta Color (255,0,255)
static public var ccMAGENTA :CC_Color3B = {r:255,g:0,b:255};
//! Black Color (0,0,0)
static public var ccBLACK :CC_Color3B = {r:0,g:0,b:0};
//! Orange Color (255,127,0)
static public var ccORANGE :CC_Color3B = {r:255,g:127,b:0};
//! Gray Color (166,166,166)
static public var ccGRAY :CC_Color3B = {r:166,g:166,b:166};

//! helper macro that creates an type :CC_Color3B
static public inline function ccc3(r:Int, g:Int, b:Int) :CC_Color3B
{
	var c:CC_Color3B = {r:r, g:g, b:b};
	return c;
}

/** Returns a CC_Color4F from a CC_Color3B. Alpha will be 1.
 @since v0.99.1
 */
static public inline function ccc4FFromccc3B(c:CC_Color3B) :CC_Color4F
{
	var c:CC_Color4F = {r:c.r/255, g:c.g/255, b:c.b/255, a:1.0};
	return c;
}

/** Returns a CC_Color4F from a CC_Color4B.
 @since v0.99.1
 */
static public inline function ccc4FFromccc4B(c:CC_Color4B) :CC_Color4F
{
	var c:CC_Color4F = {r:c.r/255, g:c.g/255, b:c.b/255, a:c.a/255};
	return c;
}

/** returns true if both CC_Color4F are equal. Otherwise it returns NO.
 @since v0.99.1
 */
static public inline function ccc4FEqual (a:CC_Color4F, b:CC_Color4F) :Bool
{
	return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
}

//! helper macro that creates an CC_Color4B type
static public inline function ccc4(r:Int, g:Int, b:Int, a:Int) :CC_Color4B
{
	var c:CC_Color4B = {r:r, g:g, b:b, a:a};
	return c;
}

//! helper function to create a CC_GridSize
static public inline function CC_GridSizeMake (x:Int, y:Int) :CC_GridSize
{
	var v :CC_GridSize = {x:x, y:y};
	return v;
}

}
