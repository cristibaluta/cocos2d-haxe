/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Leonardo Kasperavičius
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
package cocos.particle;

import cocos.CCParticleSystem;
import cocos.CCConfig;
import cocos.CCTextureCache;
import cocos.CCMacros;
import cocos.CCTypes;
import cocos.CCSpriteFrame;
import cocos.support.CGRect;
import cocos.support.CGPoint;
using cocos.support.CGPointExtension;


/** CCParticleSystemQuad is a subclass of CCParticleSystem

 It includes all the features of ParticleSystem.

 Special features and Limitations:	
  - Particle size can be any Float number.
  - The system can be scaled
  - The particles can be rotated
  - On 1st and 2nd gen iPhones: It is only a bit slower that CCParticleSystemPoint
  - On 3rd gen iPhone and iPads: It is MUCH faster than CCParticleSystemPoint
  - It consumes more RAM and more GPU memory than CCParticleSystemPoint
  - It supports subrects
 @since v0.8
 */
class CCParticleSystemQuad extends CCParticleSystem
{
var quads_ :CC_V2F_C4B_T2F_Quad;		// quads to be rendered
var indices_ :Array<Int>;		// indices
#if CC_USES_VBO
var quadsID_ :Int;		// VBO id
#end

/** initialices the indices for the vertices */
public function initIndices ()
{
	for( i in 0...totalParticles) {
		var i6 :Int = i*6;
		var i4 :Int = i*4;
		indices_[i6+0] = i4+0;
		indices_[i6+1] = i4+1;
		indices_[i6+2] = i4+2;
		
		indices_[i6+5] = i4+1;
		indices_[i6+4] = i4+2;
		indices_[i6+3] = i4+3;
	}
}

/** initilizes the texture with a rectangle measured Points */
public function initTexCoordsWithRect ( pointRect:CGRect )
{
	// convert to pixels coords
	var rect :CGRect = new CGRect (
							 pointRect.origin.x * CCConfig.CC_CONTENT_SCALE_FACTOR,
							 pointRect.origin.y * CCConfig.CC_CONTENT_SCALE_FACTOR,
							 pointRect.size.width * CCConfig.CC_CONTENT_SCALE_FACTOR,
							 pointRect.size.height * CCConfig.CC_CONTENT_SCALE_FACTOR );

	var wide :Float = texture_.pixelsWide;
	var high :Float = texture_.pixelsHigh;

#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
	var left :Float = (rect.origin.x*2+1) / (wide*2);
	var bottom :Float = (rect.origin.y*2+1) / (high*2);
	var right :Float = left + (rect.size.width*2-2) / (wide*2);
	var top :Float = bottom + (rect.size.height*2-2) / (high*2);
#else
	var left :Float = rect.origin.x / wide;
	var bottom :Float = rect.origin.y / high;
	var right :Float = left + rect.size.width / wide;
	var top :Float = bottom + rect.size.height / high;
#end // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
	
	// Important. Texture in cocos2d are inverted, so the Y component should be inverted
	CCMacros.CC_SWAP (top, bottom);
	
	for(i in 0...totalParticles) {
		// bottom-left vertex:
		quads_[i].bl.texCoords.u = left;
		quads_[i].bl.texCoords.v = bottom;
		// bottom-right vertex:
		quads_[i].br.texCoords.u = right;
		quads_[i].br.texCoords.v = bottom;
		// top-left vertex:
		quads_[i].tl.texCoords.u = left;
		quads_[i].tl.texCoords.v = top;
		// top-right vertex:
		quads_[i].tr.texCoords.u = right;
		quads_[i].tr.texCoords.v = top;
	}
}

/** Sets a new CCSpriteFrame as particle.
 WARNING: this method is experimental. Use setTexture:withRect instead.
 @since v0.99.4
 */
public function setDisplayFrame (spriteFrame:CCSpriteFrame)
{

	if (CGPointEqualToPoint( spriteFrame.offsetInPixels , new CGPoint(0,0) )) throw "QuadParticle only supports SpriteFrames with no offsets";

	// update texture before updating texture rect
	if ( spriteFrame.texture.name != texture_.name )
		this.setTexture(spriteFrame.texture);	
}

/** Sets a new texture with a rect. The rect is in Points.
 @since v0.99.4
 */
public function setTexture (texture:CCTexture2D, ?rect:CGRect) :Void
{
	// Only update the texture if is different from the current one
	if( texture.name != texture_.name )
		super.setTexture ( texture );

	if (rect == null) {
		var s:CGSize = texture.contentSize;
		rect = new CGRect (0,0, s.width, s.height);
	}
	this.initTexCoordsWithRect ( rect );
}




// overriding the init method
override public function initWithTotalParticles ( numberOfParticles:Int ) :CCParticleSystemQuad
{
	// base initialization
	super.initWithTotalParticles ( numberOfParticles );
	
	// allocating data space
	quads_ = calloc( sizeof(quads_[0]) * totalParticles, 1 );
	indices_ = calloc( sizeof(indices_[0]) * totalParticles * 6, 1 );
	
	if( !quads_ || !indices_) {
		trace("cocos2d: Particle system: not enough memory");
		if( quads_ != null )
			quads_ = null;
		if( indices_ != null )
			indices_ = null;
		
		this.release();
		return null;
	}
	
	// initialize only once the texCoords and the indices
	this.initTexCoordsWithRect ( new CGRect (0, 0, texture_.pixelsWide, texture_.pixelsHigh));
	this.initIndices();
	
	return this;
}

public function release () :Void
{
	quads_ = null;
	indices_ = null;
	super.release();
}

public function updateQuadWithParticle (p:CC_Particle, newPos:CGPoint) :Void
{
	// colors
	var quad :CC_V2F_C4B_T2F_Quad = quads_[particleIdx];
	
	var color :CC_Color4B = { r:p.color.r*255, g:p.color.g*255, b:p.color.b*255, a:p.color.a*255};
	quad.bl.colors = color;
	quad.br.colors = color;
	quad.tl.colors = color;
	quad.tr.colors = color;
	
	// vertices
	var size_2 = p.size/2;
	if( p.rotation ) {
		var x1 = -size_2;
		var y1 = -size_2;
		var x2 = size_2;
		var y2 = size_2;
		
		var x :Float = newPos.x;
		var y :Float = newPos.y;
		
		var r :Float = -CC_DEGREES_TO_RADIANS(p.rotation);
		var cr :Float = Math.cos(r);
		var sr :Float = Math.sin(r);
		var ax :Float = x1 * cr - y1 * sr + x;
		var ay :Float = x1 * sr + y1 * cr + y;
		var bx :Float = x2 * cr - y1 * sr + x;
		var by :Float = x2 * sr + y1 * cr + y;
		var cx :Float = x2 * cr - y2 * sr + x;
		var cy :Float = x2 * sr + y2 * cr + y;
		var dx :Float = x1 * cr - y2 * sr + x;
		var dy :Float = x1 * sr + y2 * cr + y;
		
		// bottom-left
		quad.bl.vertices.x = ax;
		quad.bl.vertices.y = ay;
		
		// bottom-right vertex:
		quad.br.vertices.x = bx;
		quad.br.vertices.y = by;
		
		// top-left vertex:
		quad.tl.vertices.x = dx;
		quad.tl.vertices.y = dy;
		
		// top-right vertex:
		quad.tr.vertices.x = cx;
		quad.tr.vertices.y = cy;
	} else {
		// bottom-left vertex:
		quad.bl.vertices.x = newPos.x - size_2;
		quad.bl.vertices.y = newPos.y - size_2;
		
		// bottom-right vertex:
		quad.br.vertices.x = newPos.x + size_2;
		quad.br.vertices.y = newPos.y - size_2;
		
		// top-left vertex:
		quad.tl.vertices.x = newPos.x - size_2;
		quad.tl.vertices.y = newPos.y + size_2;
		
		// top-right vertex:
		quad.tr.vertices.x = newPos.x + size_2;
		quad.tr.vertices.y = newPos.y + size_2;				
	}
}

public function postStep ()
{
#if CC_USES_VBO
	glBindBuffer(GL.ARRAY_BUFFER, quadsID_);
	glBufferSubData(GL.ARRAY_BUFFER, 0, sizeof(quads_[0])*particleCount, quads_);
	glBindBuffer(GL.ARRAY_BUFFER, 0);
#end
}

// overriding draw method
public function draw ()
{	
	super.draw();

	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Unneeded states: -

/*	glBindTexture(GL.TEXTURE_2D, texture_.name]);

#define kQuadSize sizeof(quads_[0].bl)

#if CC_USES_VBO
	glBindBuffer(GL.ARRAY_BUFFER, quadsID_);

	glVertexPointer(2,GL.FLOAT, kQuadSize, 0);

	glColorPointer(4, GL.UNSIGNED_BYTE, kQuadSize, (GLvoid*) offsetof(CC_V2F_C4B_T2F,colors) );
	
	glTexCoordPointer(2, GL.FLOAT, kQuadSize, (GLvoid*) offsetof(CC_V2F_C4B_T2F,texCoords) );
#else // vertex array list

	var offset :Int = (Int) quads_;

	// vertex
	var diff :Int = offsetof( CC_V2F_C4B_T2F, vertices);
	glVertexPointer(2,GL.FLOAT, kQuadSize, (GLvoid*) (offset+diff) );
	
	// color
	diff = offsetof( CC_V2F_C4B_T2F, colors);
	glColorPointer(4, GL.UNSIGNED_BYTE, kQuadSize, (GLvoid*)(offset + diff));
	
	// tex coords
	diff = offsetof( CC_V2F_C4B_T2F, texCoords);
	glTexCoordPointer(2, GL.FLOAT, kQuadSize, (GLvoid*)(offset + diff));		

#end // ! CC_USES_VBO
	
	var newBlend :Bool = blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	
	if (particleIdx == particleCount) throw "Abnormal error in particle quad";
	glDrawElements(GL.TRIANGLES, (GLsizei) particleIdx*6, GL.UNSIGNED_SHORT, indices_);
	
	// restore blend state
	if( newBlend )
		glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST );

#if CC_USES_VBO
	glBindBuffer(GL.ARRAY_BUFFER, 0);
#end

	// restore GL default state
	// -*/
}

}


