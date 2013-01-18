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
package cocos.particle;

import cocos.CCParticleSystem;
import cocos.CCTextureCache;
import cocos.CCMacros;
import cocos.CCTypes;
import cocos.support.CGPoint;
using cocos.support.CGPointExtension;


/** CCParticleSystemPoint is a subclass of CCParticleSystem
 Attributes of a Particle System:
 * All the attributes of Particle System

 Features:
  * consumes small memory: uses 1 vertex (x,y) per particle, no need to assign tex coordinates
  * size can't be bigger than 64
  * the system can't be scaled since the particles are rendered using GL.POINT_SPRITE
 
 Limitations:
  * On 3rd gen iPhone devices and iPads, this node performs MUCH slower than CCParticleSystemQuad.
 */
class CCParticleSystemPoint extends CCParticleSystem
{	
	inline static var CC_MAX_PARTICLE_SIZE = 64;
	// Array of (x,y,size) 
	var vertices :Array<CC_PointSprite>;
	// vertices buffer id
#if CC_USES_VBO
	var verticesID :Int;
#end


public function new () {}
override public function initWithTotalParticles (numberOfParticles:Int) :CCParticleSystemPoint
{
	super.initWithTotalParticles ( numberOfParticles );
	vertices = malloc( sizeof(ccPointSprite) * totalParticles );

	if( ! vertices ) {
		trace("cocos2d: Particle system: not enough memory");
		this.release();
		return null;
	}

	return this;
}

override function release () :Void
{
	vertices = null;
#if CC_USES_VBO
	glDeleteBuffers(1, &verticesID);
#end
	
	super.release();
}

public function updateQuadWithParticle (p:CC_Particle, newPos:CGPoint) :Void
{	
	// place vertices and colos in array
	vertices[particleIdx].pos = cast({x:newPos.x, y:newPos.y}, CC_Vertex2F);
	vertices[particleIdx].size = p.size;
	var color :CC_Color4B =  { r:p.color.r*255, g:p.color.g*255, b:p.color.b*255, a:p.color.a*255 }
	vertices[particleIdx].color = color;
}

public function postStep ()
{
#if CC_USES_VBO
	glBindBuffer(GL.ARRAY_BUFFER, verticesID);
	glBufferSubData(GL.ARRAY_BUFFER, 0, sizeof(ccPointSprite)*particleCount, vertices);
	glBindBuffer(GL.ARRAY_BUFFER, 0);
#end
}

public function draw ()
{
	super.draw();

    if (particleIdx==0)
        return;
/*	
	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY
	// Unneeded states: GL.TEXTURE_COORD_ARRAY
	glDisableClientState(GL.TEXTURE_COORD_ARRAY);
	
	glBindTexture(GL.TEXTURE_2D, texture_.name);
	
	glEnable(GL.POINT_SPRITE_OES);
	glTexEnvi( GL.POINT_SPRITE_OES, GL.COORD_REPLACE_OES, GL.true );
	
#define kPointSize sizeof(vertices[0])

#if CC_USES_VBO
	glBindBuffer(GL.ARRAY_BUFFER, verticesID);

	glVertexPointer(2,GL.FLOAT, kPointSize, 0);

	glColorPointer(4, GL.UNSIGNED_BYTE, kPointSize, (GLvoid*) offsetof(ccPointSprite, color) );

	glEnableClientState(GL.POINT_SIZE_ARRAY_OES);
	glPointSizePointerOES(GL.FLOAT, kPointSize, (GLvoid*) offsetof(ccPointSprite, size) );
#else // Uses Vertex Array List
	var offset :Int = (int)vertices;
	glVertexPointer(2,GL.FLOAT, kPointSize, (GLvoid*) offset);
	
	var diff :Int = offsetof(ccPointSprite, color);
	glColorPointer(4, GL.UNSIGNED_BYTE, kPointSize, (GLvoid*) (offset+diff));
	
	glEnableClientState(GL.POINT_SIZE_ARRAY_OES);
	diff = offsetof(ccPointSprite, size);
	glPointSizePointerOES(GL.FLOAT, kPointSize, (GLvoid*) (offset+diff));
#end

	var newBlend :Bool = blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc_.src, blendFunc_.dst );


	glDrawArrays(GL.POINTS, 0, particleIdx);
	
	// restore blend state
	if( newBlend )
		glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST);

	
#if CC_USES_VBO
	// unbind VBO buffer
	glBindBuffer(GL.ARRAY_BUFFER, 0);
#end
	
	glDisableClientState(GL.POINT_SIZE_ARRAY_OES);
	glDisable(GL.POINT_SPRITE_OES);

	// restore GL default state
	glEnableClientState(GL.TEXTURE_COORD_ARRAY);*/
}

// Non supported properties

//
// SPIN IS NOT SUPPORTED
//
public function setStartSpin ( a:Float )
{
	if (a == 0) throw "PointParticleSystem doesn't support spinning";
	super.setStartSpin ( a );
}
public function setStartSpinVar ( a:Float )
{
	if (a == 0) throw "PointParticleSystem doesn't support spinning";
	super.setStartSpin ( a );
}
public function setEndSpin ( a:Float )
{
	if (a == 0) throw "PointParticleSystem doesn't support spinning";
	super.setStartSpin ( a );
}
public function setEndSpinVar ( a:Float )
{
	if (a == 0) throw "PointParticleSystem doesn't support spinning";
	super.setStartSpin ( a );
}

//
// SIZE > 64 IS NOT SUPPORTED
//
public function setStartSize ( size:Float )
{
	if (size >= 0 && size <= CC_MAX_PARTICLE_SIZE) throw "PointParticleSystem only supports 0 <= size <= 64";
	super.setStartSize ( size );
}

public function setEndSize ( size:Float )
{
	if ((size == kCCParticleStartSizeEqualToEndSize) ||
		(size >= 0 && size <= CC_MAX_PARTICLE_SIZE)) throw "PointParticleSystem only supports 0 <= size <= 64";
	super.setEndSize ( size );
}
}

