/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008, 2009 Jason Booth
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

/*
 * A ribbon is a dynamically generated list of polygons drawn as a single or series
 * of triangle strips. The primary use of Ribbon is as the drawing class of Motion Streak,
 * but it is quite useful on it's own. When manually drawing a ribbon, you can call addPointAt
 * and pass in the parameters for the next location in the ribbon. The system will automatically
 * generate new polygons, texture them accourding to your texture width, etc, etc.
 *
 * Ribbon data is stored in a RibbonSegment class. This class statically allocates enough verticies and
 * texture coordinates for 50 locations (100 verts or 48 triangles). The ribbon class will allocate
 * new segments when they are needed, and reuse old ones if available. The idea is to avoid constantly
 * allocating new memory and prefer a more static method. However, since there is no way to determine
 * the maximum size of some ribbons (motion streaks), a truely static allocation is not possible.
 *
 */
package cocos;


import cocos.CCNode;
import cocos.CCTexture2D;
import cocos.CCTextureCache;
import cocos.CCMacros;
import cocos.CCTypes;
import cocos.support.CGPoint;
import cocos.support.CGPointExtension;
using cocos.support.CGPointExtension;
using cocos.support.CCArrayExtension;

/**
 * A CCRibbon is a dynamically generated list of polygons drawn as a single or series
 * of triangle strips. The primary use of CCRibbon is as the drawing class of Motion Streak,
 * but it is quite useful on it's own. When manually drawing a ribbon, you can call addPointAt
 * and pass in the parameters for the next location in the ribbon. The system will automatically
 * generate new polygons, texture them accourding to your texture width, etc, etc.
 *
 * CCRibbon data is stored in a CCRibbonSegment class. This class statically allocates enough verticies and
 * texture coordinates for 50 locations (100 verts or 48 triangles). The ribbon class will allocate
 * new segments when they are needed, and reuse old ones if available. The idea is to avoid constantly
 * allocating new memory and prefer a more static method. However, since there is no way to determine
 * the maximum size of some ribbons (motion streaks), a truely static allocation is not possible.
 *
 * @since v0.8.1
 */
class CCRibbon extends CCNode
{
var	segments_ :Array<CCRibbonSegment>;
var	deletedSegments_ :Array<CCRibbonSegment>;

var lastPoint1_ :CGPoint;
var lastPoint2_ :CGPoint;
var lastLocation_ :CGPoint;
var	vertCount_ :Int;
var texVPos_ :Float;
var curTime_ :Float;
var fadeTime_ :Float;
var delta_ :Float;
var lastWidth_ :Float;
var lastSign_ :Float;
var pastFirstPoint_ :Bool;


/** Texture used by the ribbon. Conforms to CCTextureProtocol protocol */
public var texture (default, set_texture) :CCTexture2D;
/** Texture lengths in pixels */
public var textureLength :Float;
/** GL blendind function */
public var blendFunc :CC_BlendFunc;
/** color used by the Ribbon (RGBA) */
public var color :CC_Color4B;

/** creates the ribbon */
public static function ribbonWithWidth ( w:Float, image:String, length:Float, color:CC_Color4B, fade:Float ) :CCRibbon
{
	return new CCRibbon().initWithWidth (w, image, length, color, fade);
}

/** init the ribbon */
public function initWithWidth ( w:Float, imagePath:String, length:Float, color:CC_Color4B, fade:Float ) :CCRibbon
{
	super.init();
	
	segments_ = new Array<CCRibbonSegment>();
	deletedSegments_ = new Array<CCRibbonSegment>();

	/* 1 initial segment */
	var seg :CCRibbonSegment = new CCRibbonSegment().init();
	segments_.push ( seg );
	
	textureLength = length;
	
	this.color = color;
	fadeTime_ = fade;
	lastLocation_ = new CGPoint(0,0);
	lastWidth_ = w/2;
	texVPos_ = 0.0;
	
	curTime_ = 0;
	pastFirstPoint_ = false;
	
	/* XXX:
	 Ribbon, by default uses this blend function, which might not be correct
	 if you are using premultiplied alpha images,
	 but 99% you might want to use this blending function regarding of the texture
	 */
	blendFunc = {
		src : GL.SRC_ALPHA,
		dst : GL.ONE_MINUS_SRC_ALPHA
	};
	
	texture = CCTextureCache.sharedTextureCache().addImage ( imagePath );
	
	/* default texture parameter */
	var params :TexParams = { minFilter:GL.LINEAR, magFilter:GL.LINEAR, wrapS:GL.REPEAT, wrapT:GL.REPEAT };
	//params = 
	texture.setTexParameters(params);
	
	return this;
}

/** add a point to the ribbon */
public function addPointAt (location:CGPoint, w:Float) :Void
{
	location.x *= CCConfig.CC_CONTENT_SCALE_FACTOR;
	location.y *= CCConfig.CC_CONTENT_SCALE_FACTOR;

	w = w*0.5;
	// if this is the first point added, cache it and return
	if (!pastFirstPoint_)
	{
		lastWidth_ = w;
		lastLocation_ = location;
		pastFirstPoint_ = true;
		return;
	}

	var sub :CGPoint = CGPointExtension.sub (lastLocation_, location);
	var r :Float = CGPointExtension.toAngle(sub) + CCMacros.M_PI_2();
	var p1 :CGPoint = CGPointExtension.add(this.rotatePoint(new CGPoint (-w, 0), r), location);
	var p2 :CGPoint = CGPointExtension.add(this.rotatePoint(new CGPoint (w, 0), r), location);
	var len :Float = Math.sqrt(Math.pow(lastLocation_.x - location.x, 2) + Math.pow(lastLocation_.y - location.y, 2));
	var tend :Float = texVPos_ + len/textureLength;
	var seg :CCRibbonSegment = segments_.lastObject();
	// lets kill old segments
	for (seg2 in segments_)
		if (seg2 != seg && seg2.finished)
			deletedSegments_.push ( seg2 );
		
	segments_.removeObjectsInArray ( deletedSegments_ );
	// is the segment full?
	if (seg.end >= 50)
		segments_.removeObjectsInArray ( deletedSegments_ );
	// grab last segment and append to it if it's not full
	seg = segments_.lastObject();
	// is the segment full?
	if (seg.end >= 50)
	{
		var newSeg :CCRibbonSegment = null;
		// grab it from the cache if we can
		if (deletedSegments_.length > 0)
		{
			newSeg = deletedSegments_.shift();
			newSeg.reset();
		}
		else
		{
			newSeg = new CCRibbonSegment().init(); // will be released later
		}
		
		newSeg.creationTime[0] = seg.creationTime[seg.end - 1];
		var v :Int = (seg.end-1)*6;
		var c :Int = (seg.end-1)*4;	
		newSeg.verts[0] = seg.verts[v];
		newSeg.verts[1] = seg.verts[v+1];
		newSeg.verts[2] = seg.verts[v+2];
		newSeg.verts[3] = seg.verts[v+3];
		newSeg.verts[4] = seg.verts[v+4];
		newSeg.verts[5] = seg.verts[v+5];
		
		newSeg.coords[0] = seg.coords[c];
		newSeg.coords[1] = seg.coords[c+1];
		newSeg.coords[2] = seg.coords[c+2];
		newSeg.coords[3] = seg.coords[c+3];	  
		newSeg.end++;
		seg = newSeg;
		segments_.addObject ( seg );
		
	}  
	if (seg.end == 0)
	{
		// first edge has to get rotation from the first real polygon
		var lp1 :CGPoint = CGPointExtension.add(this.rotatePoint (new CGPoint (-lastWidth_, 0), r), lastLocation_);
		var lp2 :CGPoint = CGPointExtension.add(this.rotatePoint (new CGPoint (lastWidth_, 0), r), lastLocation_);
		seg.creationTime[0] = curTime_ - delta_;
		seg.verts[0] = lp1.x;
		seg.verts[1] = lp1.y;
		seg.verts[2] = 0.0;
		seg.verts[3] = lp2.x;
		seg.verts[4] = lp2.y;
		seg.verts[5] = 0.0;
		seg.coords[0] = 0.0;
		seg.coords[1] = texVPos_;
		seg.coords[2] = 1.0;
		seg.coords[3] = texVPos_;
		seg.end++;
	}

	var v :Int = seg.end*6;
	var c :Int = seg.end*4;
	// add new vertex
	seg.creationTime[seg.end] = curTime_;
	seg.verts[v] = p1.x;
	seg.verts[v+1] = p1.y;
	seg.verts[v+2] = 0.0;
	seg.verts[v+3] = p2.x;
	seg.verts[v+4] = p2.y;
	seg.verts[v+5] = 0.0;


	seg.coords[c] = 0.0;
	seg.coords[c+1] = tend;
	seg.coords[c+2] = 1.0;
	seg.coords[c+3] = tend;

	texVPos_ = tend;
	lastLocation_ = location;
	lastPoint1_ = p1;
	lastPoint2_ = p2;
	lastWidth_ = w;
	seg.end++;
}
/** polling function */
public function update ( delta:Float )
{
	curTime_+= delta;
	delta_ = delta;
}


/** determine side of line */
public function sideOfLine ( p:CGPoint, l1:CGPoint, l2:CGPoint ) :Float
{
	var vp :CGPoint = CGPointExtension.perp (CGPointExtension.sub (l1, l2) );
	var vx :CGPoint = CGPointExtension.sub (p, l1);
	return CGPointExtension.dot (vx, vp);
}


override public function release () :Void
{
/*	segments_.release();
	deletedSegments_.release();*/
	segments_ = null;
	deletedSegments_ = null;
	texture.release();
	super.release();
}

// rotates a point around 0, 0
public function rotatePoint ( vec:CGPoint, a:Float ) :CGPoint
{
	var xtemp :Float = (vec.x * Math.cos(a)) - (vec.y * Math.sin(a));
	vec.y = (vec.x * Math.sin(a)) + (vec.y * Math.cos(a));
	vec.x = xtemp;
	return vec;
}



// adds a new segment to the ribbon


override public function draw ()
{
	super.draw();

	if (segments_.length > 0)
	{
		// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
		// Needed states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.TEXTURE_COORD_ARRAY
		// Unneeded states: GL.COLOR_ARRAY
/*		glDisableClientState(GL.COLOR_ARRAY);
		
		glBindTexture(GL.TEXTURE_2D, texture_.name);

		var newBlend :Bool = blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST;
		if( newBlend )
			glBlendFunc( blendFunc_.src, blendFunc_.dst );
*/
		for (seg in segments_)
			seg.draw ( curTime_, fadeTime_, color );

/*		if( newBlend )
			glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
		
		// restore default GL state
		glEnableClientState( GL.COLOR_ARRAY );*/
	}
}

// Ribbon - CocosNodeTexture protocol
public function set_texture (texture_:CCTexture2D) :CCTexture2D
{
	texture.release();
	texture = texture_;
	this.set_contentSizeInPixels ( texture.contentSizeInPixels );
	/* XXX Don't update blending function in Ribbons */
	return texture;
}

}


// -
// RibbonSegment

class CCRibbonSegment
{
//
public var verts :Array<Float>;//[50*6];
public var coords :Array<Float>;//[50*4];
public var colors :Array<Float>;//[50*8];
public var creationTime :Array<Float>;
public var finished :Bool;
public var end :Int;
public var begin :Int;


public function new () {}
public function init () :CCRibbonSegment
{
	this.reset();
	return this;
}

public function toString () :String
{
	return "<CCRibbonSegment | end = "+end+", begin = "+begin+">";
}

public function release ()
{
	trace("cocos2d: releaseing %"+ this);
}

public function reset ()
{
	end = 0;
	begin = 0;
	finished = false;
}

public function draw (curTime:Float, fadeTime:Float, color:CC_Color4B) :Void
{
	var r :Float = color.r;
	var g :Float = color.g;
	var b :Float = color.b;
	var a :Float = color.a;

	if (begin < 50)
	{
		// the motion streak class will call update and cause time to change, thus, if curTime_ != 0
		// we have to generate alpha for the ribbon each frame.
		if (curTime == 0)
		{
			// no alpha over time, so just set the color
			//glColor4ub(r,g,b,a);
		}
		else
		{
			// generate alpha/color for each point
			for (i in begin...end)
			{
				var idx :Int = i*8;
				colors[idx] = r;
				colors[idx+1] = g;
				colors[idx+2] = b;
				colors[idx+4] = r;
				colors[idx+5] = g;
				colors[idx+6] = b;
				var alive :Float = ((curTime - creationTime[i]) / fadeTime);
				if (alive > 1)
				{
					begin++;
					colors[idx+3] = 0;
					colors[idx+7] = 0;
				}
				else
				{
					colors[idx+3] = (255.0 - (alive * 255.0));
					colors[idx+7] = colors[idx+3];
				}
			}
			//glColorPointer(4, GL.UNSIGNED_BYTE, 0, &colors[begin*8]);
		}
/*		glVertexPointer(3, GL.FLOAT, 0, &verts[begin*6]);
		glTexCoordPointer(2, GL.FLOAT, 0, &coords[begin*4]);
		glDrawArrays(GL.TRIANGLE_STRIP, 0, (end - begin) * 2);*/
	}
	else
		finished = true;
}
}

