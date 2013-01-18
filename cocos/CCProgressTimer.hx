/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Lam Pham
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

import cocos.CCSprite;
import cocos.CCMacros;
import cocos.CCTextureCache;
import cocos.CCTypes;
import cocos.support.CGPoint;
import cocos.support.CGSize;
import cocos.support.CGPointExtension;
using cocos.support.CGPointExtension;

/** Types of progress
 @since v0.99.1
 */
enum CCProgressTimerType {
	/// Radial Counter-Clockwise 
	kCCProgressTimerTypeRadialCCW;
	/// Radial ClockWise
	kCCProgressTimerTypeRadialCW;
	/// Horizontal Left-Right
	kCCProgressTimerTypeHorizontalBarLR;
	/// Horizontal Right-Left
	kCCProgressTimerTypeHorizontalBarRL;
	/// Vertical Bottom-top
	kCCProgressTimerTypeVerticalBarBT;
	/// Vertical Top-Bottom
	kCCProgressTimerTypeVerticalBarTB;
}

/**
 CCProgresstimer is a subclass of CCNode.
 It renders the inner sprite according to the percentage.
 The progress can be Radial, Horizontal or vertical.
 @since v0.99.1
 */
class CCProgressTimer extends CCNode
{
var type_ :CCProgressTimerType;
var percentage_ :Float;
var sprite_ :CCSprite;
var vertexDataCount_ :Int;
var vertexData_ :Array<CC_V2F_C4B_T2F>;

inline static var kProgressTextureCoordsCount = 4;
//  kProgressTextureCoords holds points {0,0} {0,1} {1,1} {1,0} we can represent it as bits
inline static var kProgressTextureCoords = 0x1e;


/**	Change the percentage to change progress. */
public var type (get_type, set_type) :CCProgressTimerType;
/** Percentages are from 0 to 100 */
public var percentage (getPercentage, setPercentage) :Float;
/** The image to show the progress percentage */
public var sprite (get_sprite, set_sprite) :CCSprite;


/** Creates a progress timer with an image filename as the shape the timer goes through */
public static function progressWithFile (filename:String)
{
	return new CCProgressTimer().initWithFile(filename);
}

/** Initializes  a progress timer with an image filename as the shape the timer goes through */
public function initWithFile (filename:String) :CCProgressTimer
{
	return this.initWithTexture ( CCTextureCache.sharedTextureCache().addImage(filename) );
}

/** Creates a progress timer with the texture as the shape the timer goes through */
public static function progressWithTexture (texture:CCTexture2D) :CCProgressTimer
{
	return new CCProgressTimer().initWithTexture(texture);
}

/** Creates a progress timer with the texture as the shape the timer goes through */
public function initWithTexture (texture:CCTexture2D) :CCProgressTimer
{
	super.init();
	
	this.sprite = CCSprite.spriteWithTexture ( texture );
	percentage_ = 0.0;
	vertexData_ = [];
	vertexDataCount_ = 0;
	this.anchorPoint = new CGPoint (.5,.5);
	this.contentSize = sprite_.contentSize;
	this.type = kCCProgressTimerTypeRadialCCW;
	
	return this;
}



override public function release () :Void
{
	if (vertexData_ != null)
		vertexData_ = null;
	
	sprite_.release();
	super.release();
}

public function setPercentage (percentage:Float) :Float
{
	if (percentage_ != percentage) {
        percentage_ = percentage.clampf (0, 100);
		this.updateProgress();
	}
	return percentage_;
}
public function getPercentage () :Float {
	return percentage_;
}

public function set_sprite (newSprite:CCSprite) :CCSprite
{
	if (sprite_ != newSprite) {
		sprite_.release(); 
		sprite_ = newSprite;
		
		//	Everytime we set a new sprite, we free the current vertex data
		if (vertexData_ != null) {
			vertexData_ = null;
			vertexDataCount_ = 0;
		}
	}
	return sprite_;
}
public function get_sprite () :CCSprite {
	return sprite_;
}

public function set_type ( newType:CCProgressTimerType ) :CCProgressTimerType
{
	if (newType != type_) {
		
		//	release all previous information
		if(vertexData_ != null){
			vertexData_ = null;
			vertexDataCount_ = 0;
		}
		type_ = newType;
	}
	return newType;
}
public function get_type () :CCProgressTimerType {
	return type_;
}


///
//	@returns the vertex position from the texture coordinate
///
public function vertexFromTexCoord (texCoord:CGPoint) :CC_Vertex2F
{
	var tmp :CGPoint;
	if (sprite_.texture != null) {
		var texture :CCTexture2D = sprite_.texture;
		var texSize :CGSize = texture.contentSizeInPixels;
		tmp = new CGPoint (texSize.width*texCoord.x/texture.maxS, texSize.height*(1-(texCoord.y/texture.maxT)));
	} else
		tmp = new CGPoint(0,0);

	var ret :CC_Vertex2F = {x:tmp.x, y:tmp.y};
	
	return ret;
}

public function updateColor ()
{
	var op :Float = sprite_.opacity;
	var c3b :CC_Color3B = sprite_.color;
	var color /*:CC_Color4B*/ = { r:c3b.r, g:c3b.g, b:c3b.b, a:op };
	if (sprite_.texture.hasPremultipliedAlpha) {
		color.r *= Math.round(op/255);
		color.g *= Math.round(op/255);
		color.b *= Math.round(op/255);
	}
	
	if (vertexData_ != null){
		for (i in 0...vertexDataCount_) {
			//vertexData_[i].colors = color;
		}
	}
}

public function updateProgress ()
{
	switch (type_) {
		case kCCProgressTimerTypeRadialCW,
		 	 kCCProgressTimerTypeRadialCCW: this.updateRadial();
		
		case kCCProgressTimerTypeHorizontalBarLR,
			 kCCProgressTimerTypeHorizontalBarRL,
			 kCCProgressTimerTypeVerticalBarBT,
			 kCCProgressTimerTypeVerticalBarTB: this.updateBar();
	}
}

///
//	Update does the work of mapping the texture onto the triangles
//	It now doesn't occur the cost of free/alloc data every update cycle.
//	It also only changes the percentage point but no other points if they have not
//	been modified.
//	
//	It now deals with flipped texture. If you run into this problem, just use the
//	sprite property and enable the methods flipX, flipY.
///
public function updateRadial ()
{		
	//	Texture Max is the actual max coordinates to deal with non-power of 2 textures
	var tMax :CGPoint = new CGPoint (sprite_.texture.maxS, sprite_.texture.maxT);
	
	//	Grab the midpoint
	var midpoint :CGPoint = this.anchorPoint.compMult ( tMax );
	
	var alpha :Float = percentage_ / 100.0;
	
	//	Otherwise we can get the angle from the alpha
	var angle :Float = 2.0*CCMacros.M_PI * ( type_ == kCCProgressTimerTypeRadialCW ? alpha : 1.0 - alpha);
	
	//	We find the vector to do a hit detection based on the percentage
	//	We know the first vector is the one @ 12 o'clock (top,mid) so we rotate 
	//	from that by the progress angle around the midpoint pivot
	var topMid :CGPoint = new CGPoint (midpoint.x, 0.0);
	var percentagePt :CGPoint = topMid.rotateByAngle (midpoint, angle);
	
	
	var index :Int = 0;
	var hit :CGPoint = new CGPoint(0,0);
	
	if (alpha == 0.0) {
		//	More efficient since we don't always need to check intersection
		//	If the alpha is zero then the hit point is top mid and the index is 0.
		hit = topMid;
		index = 0;
	} else if (alpha == 1.0) {
		//	More efficient since we don't always need to check intersection
		//	If the alpha is one then the hit point is top mid and the index is 4.
		hit = topMid;
		index = 4;
	} else {
		//	We run a for loop checking the edges of the texture to find the
		//	intersection point
		//	We loop through five points since the top is split in half
		
		var min_t :Float = Math.POSITIVE_INFINITY;//FLT_MAX;
		
		for (i in 0...(kProgressTextureCoordsCount+1)) {
			var pIndex :Int = (i + (kProgressTextureCoordsCount - 1))%kProgressTextureCoordsCount;
			
			var edgePtA :CGPoint = CGPointExtension.compMult (this.boundaryTexCoord(i % kProgressTextureCoordsCount),tMax);
			var edgePtB :CGPoint = CGPointExtension.compMult (this.boundaryTexCoord(pIndex),tMax);
			
			//	Remember that the top edge is split in half for the 12 o'clock position
			//	Let's deal with that here by finding the correct endpoints
			if(i == 0){
				edgePtB = CGPointExtension.lerp (edgePtA,edgePtB,0.5);
			} else if(i == 4){
				edgePtA = CGPointExtension.lerp (edgePtA,edgePtB,0.5);
			}
			
			//	s and t are returned by ccpLineIntersect
			var s = 0.0, t = 0.0;
			var st :LineIntersection = CGPointExtension.lineIntersect (edgePtA, edgePtB, midpoint, percentagePt, s, t);
			s = st.S;
			t = st.T;
			
			if(st.bool) {
				
				//	Since our hit test is on rays we have to deal with the top edge
				//	being in split in half so we have to test as a segment
				if ((i == 0 || i == 4)) {
					//	s represents the point between edgePtA--edgePtB
					if (!(0.0 <= s && s <= 1.0)) {
						continue;
					}
				}
				//	As long as our t isn't negative we are at least finding a 
				//	correct hitpoint from midpoint to percentagePt.
				if (t >= 0.0) {
					//	Because the percentage line and all the texture edges are
					//	rays we should only account for the shortest intersection
					if (t < min_t) {
						min_t = t;
						index = i;
					}
				}
			}
		}
		
		//	Now that we have the minimum magnitude we can use that to find our intersection
		hit = CGPointExtension.add (midpoint, CGPointExtension.mult (CGPointExtension.sub (percentagePt, midpoint), min_t));
		
	}
	
	
	//	The size of the vertex data is the index from the hitpoint
	//	the 3 is for the midpoint, 12 o'clock point and hitpoint position.
	
	var sameIndexCount :Bool = true;
	if (vertexDataCount_ != index + 3){
		sameIndexCount = false;
		if (vertexData_ != null) {
			vertexData_ = null;
			vertexDataCount_ = 0;
		}
	}
	
	
	if (vertexData_ == null) {
		vertexDataCount_ = index + 3;
		vertexData_ = [];
		this.updateColor();
	}
	
	if (!sameIndexCount) {
		
		//	First we populate the array with the midpoint, then all 
		//	vertices/texcoords/colors of the 12 'o clock start and edges and the hitpoint
		vertexData_[0].texCoords = {u:midpoint.x, v:midpoint.y};
		vertexData_[0].vertices = this.vertexFromTexCoord ( midpoint );
		
		vertexData_[1].texCoords = {u:midpoint.x, v:0.0};
		vertexData_[1].vertices = this.vertexFromTexCoord ( new CGPoint (midpoint.x, 0.0) );
		
		for(i in 0...index){
			var texCoords :CGPoint = CGPointExtension.compMult (this.boundaryTexCoord(i), tMax);
			
			vertexData_[i+2].texCoords = {u:texCoords.x, v:texCoords.y};
			vertexData_[i+2].vertices = this.vertexFromTexCoord ( texCoords );
		}
		
		//	Flip the texture coordinates if set
		if (sprite_.flipY || sprite_.flipX) {
			for(i in 0...vertexDataCount_ - 1){
				if (sprite_.flipX) {
					vertexData_[i].texCoords.u = tMax.x - vertexData_[i].texCoords.u;
				}
				if(sprite_.flipY){
					vertexData_[i].texCoords.v = tMax.y - vertexData_[i].texCoords.v;
				}
			}
		}
	}
	
	//	hitpoint will go last
	vertexData_[vertexDataCount_ - 1].texCoords = {u:hit.x, v:hit.y};
	vertexData_[vertexDataCount_ - 1].vertices = this.vertexFromTexCoord ( hit );
	
	if (sprite_.flipY || sprite_.flipX) {
		if (sprite_.flipX) {
			vertexData_[vertexDataCount_ - 1].texCoords.u = tMax.x - vertexData_[vertexDataCount_ - 1].texCoords.u;
		}
		if(sprite_.flipY){
			vertexData_[vertexDataCount_ - 1].texCoords.v = tMax.y - vertexData_[vertexDataCount_ - 1].texCoords.v;
		}
	}
}

///
//	Update does the work of mapping the texture onto the triangles for the bar
//	It now doesn't occur the cost of free/alloc data every update cycle.
//	It also only changes the percentage point but no other points if they have not
//	been modified.
//	
//	It now deals with flipped texture. If you run into this problem, just use the
//	sprite property and enable the methods flipX, flipY.
///
public function updateBar ()
{
	var alpha :Float = percentage_ / 100.0;
	var tMax :CGPoint = new CGPoint (sprite_.texture.maxS, sprite_.texture.maxT);
	var vIndexes = [0,0];
	var index = 0;
	
	//	We know vertex data is always equal to the 4 corners
	//	If we don't have vertex data then we create it here and populate
	//	the side of the bar vertices that won't ever change.
	if (vertexData_ == null) {
		vertexDataCount_ = kProgressTextureCoordsCount;
		vertexData_ = [];
		
		if(type_ == kCCProgressTimerTypeHorizontalBarLR)
		{
			vertexData_[vIndexes[0] = 0].texCoords = {u:0.0, v:0.0};
			vertexData_[vIndexes[1] = 1].texCoords = {u:0.0, v:tMax.y};
		}
		else if (type_ == kCCProgressTimerTypeHorizontalBarRL)
		{
			vertexData_[vIndexes[0] = 2].texCoords = {u:tMax.x, v:tMax.y};
			vertexData_[vIndexes[1] = 3].texCoords = {u:tMax.x, v:0.0};
		}
		else if (type_ == kCCProgressTimerTypeVerticalBarBT)
		{
			vertexData_[vIndexes[0] = 1].texCoords = {u:0.0, v:tMax.y};
			vertexData_[vIndexes[1] = 3].texCoords = {u:tMax.x, v:tMax.y};
		}
		else if (type_ == kCCProgressTimerTypeVerticalBarTB)
		{
			vertexData_[vIndexes[0] = 0].texCoords = {u:0.0, v:0.0};
			vertexData_[vIndexes[1] = 2].texCoords = {u:tMax.x, v:0.0};
		}
		
		index = vIndexes[0];
		vertexData_[index].vertices = this.vertexFromTexCoord (new CGPoint (vertexData_[index].texCoords.u, vertexData_[index].texCoords.v));
		
		index = vIndexes[1];
		vertexData_[index].vertices = this.vertexFromTexCoord (new CGPoint (vertexData_[index].texCoords.u, vertexData_[index].texCoords.v));
		
		if (sprite_.flipY || sprite_.flipX) {
			if (sprite_.flipX) {
				index = vIndexes[0];
				vertexData_[index].texCoords.u = tMax.x - vertexData_[index].texCoords.u;
				index = vIndexes[1];
				vertexData_[index].texCoords.u = tMax.x - vertexData_[index].texCoords.u;
			}
			if(sprite_.flipY){
				index = vIndexes[0];
				vertexData_[index].texCoords.v = tMax.y - vertexData_[index].texCoords.v;
				index = vIndexes[1];
				vertexData_[index].texCoords.v = tMax.y - vertexData_[index].texCoords.v;
			}
		}
		
		this.updateColor();
	}
	
	if(type_ == kCCProgressTimerTypeHorizontalBarLR) {
		vertexData_[vIndexes[0] = 3].texCoords = {u:tMax.x*alpha, v:tMax.y};
		vertexData_[vIndexes[1] = 2].texCoords = {u:tMax.x*alpha, v:0.0};
	}else if (type_ == kCCProgressTimerTypeHorizontalBarRL) {
		vertexData_[vIndexes[0] = 1].texCoords = {u:tMax.x*(1.0 - alpha), v:0.0};
		vertexData_[vIndexes[1] = 0].texCoords = {u:tMax.x*(1.0 - alpha), v:tMax.y};
	}else if (type_ == kCCProgressTimerTypeVerticalBarBT) {
		vertexData_[vIndexes[0] = 0].texCoords = {u:0.0, v:tMax.y*(1.0 - alpha)};
		vertexData_[vIndexes[1] = 2].texCoords = {u:tMax.x, v:tMax.y*(1.0 - alpha)};
	}else if (type_ == kCCProgressTimerTypeVerticalBarTB) {
		vertexData_[vIndexes[0] = 1].texCoords = {u:0.0, v:tMax.y*alpha};
		vertexData_[vIndexes[1] = 3].texCoords = {u:tMax.x, v:tMax.y*alpha};
	}
	
	index = vIndexes[0];
	vertexData_[index].vertices = this.vertexFromTexCoord ( new CGPoint (vertexData_[index].texCoords.u, vertexData_[index].texCoords.v) );
	index = vIndexes[1];
	vertexData_[index].vertices = this.vertexFromTexCoord ( new CGPoint (vertexData_[index].texCoords.u, vertexData_[index].texCoords.v) );
	
	if (sprite_.flipY || sprite_.flipX) {
		if (sprite_.flipX) {
			index = vIndexes[0];
			vertexData_[index].texCoords.u = tMax.x - vertexData_[index].texCoords.u;
			index = vIndexes[1];
			vertexData_[index].texCoords.u = tMax.x - vertexData_[index].texCoords.u;
		}
		if(sprite_.flipY){
			index = vIndexes[0];
			vertexData_[index].texCoords.v = tMax.y - vertexData_[index].texCoords.v;
			index = vIndexes[1];
			vertexData_[index].texCoords.v = tMax.y - vertexData_[index].texCoords.v;
		}
	}
	
}

public function boundaryTexCoord ( index:Int ) :CGPoint
{
	if (index < kProgressTextureCoordsCount) {
		switch (type_) {
			case kCCProgressTimerTypeRadialCW:
				return new CGPoint ((kProgressTextureCoords >> ((index << 1)+1)) & 1,
									(kProgressTextureCoords >> (index << 1)) & 1);
			case kCCProgressTimerTypeRadialCCW:
				return new CGPoint ((kProgressTextureCoords >> (7-(index << 1))) & 1,
									(kProgressTextureCoords >> (7-((index << 1)+1))) & 1);
			case kCCProgressTimerTypeVerticalBarTB,
				kCCProgressTimerTypeVerticalBarBT,
				kCCProgressTimerTypeHorizontalBarRL,
				kCCProgressTimerTypeHorizontalBarLR :
				return new CGPoint(0,0);
		}
	}
	return new CGPoint(0,0);
}

override public function draw ()
{
	super.draw();
	
/*	if(!vertexData_)return;
	if(!sprite_)return;
	var blendFunc :CC_BlendFunc = sprite_.blendFunc;
	var newBlend :Bool = blendFunc.src != CC_BLEND_SRC || blendFunc.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc.src, blendFunc.dst );
	
	///	========================================================================
	//	Replaced texture_.drawAtPoint:new CGPoint(0,0)] with my own vertexData
	//	Everything above me and below me is copied from CCTextureNode's draw
	glBindTexture(GL.TEXTURE_2D, sprite_.texture.name);
	glVertexPointer(2, GL.FLOAT, sizeof(CC_V2F_C4B_T2F), &vertexData_[0].vertices);
	glTexCoordPointer(2, GL.FLOAT, sizeof(CC_V2F_C4B_T2F), &vertexData_[0].texCoords);
	glColorPointer(4, GL.UNSIGNED_BYTE, sizeof(CC_V2F_C4B_T2F), &vertexData_[0].colors);
	if(type_ == kCCProgressTimerTypeRadialCCW || type_ == kCCProgressTimerTypeRadialCW){
		glDrawArrays(GL.TRIANGLE_FAN, 0, vertexDataCount_);
	} else if (type_ == kCCProgressTimerTypeHorizontalBarLR ||
			   type_ == kCCProgressTimerTypeHorizontalBarRL ||
			   type_ == kCCProgressTimerTypeVerticalBarBT ||
			   type_ == kCCProgressTimerTypeVerticalBarTB) {
		glDrawArrays(GL.TRIANGLE_STRIP, 0, vertexDataCount_);
	}
	//glDrawElements(GL.TRIANGLES, indicesCount_, GL.UNSIGNED_BYTE, indices_);
	///	========================================================================
	
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);*/
}

}
