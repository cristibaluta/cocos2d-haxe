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

import cocos.CCTypes;
import cocos.CCConfig;
import cocos.CCTexture2D;
import cocos.CCTextureCache;

/** A class that implements a Texture Atlas.
 Supported features:
   * The atlas file can be a PVRTC, PNG or any other fomrat supported by Texture2D
   * Quads can be udpated in runtime
   * Quads can be added in runtime
   * Quads can be removed in runtime
   * Quads can be re-ordered in runtime
   * The TextureAtlas capacity can be increased or decreased in runtime
   * OpenGL component: V3F, C4B, T2F.
 The quads are rendered using an OpenGL ES VBO.
 To render the quads using an interleaved vertex array list, you should modify the ccConfig.h file 
 */
class CCTextureAtlas
{
var totalQuads_ :Int;
var capacity_ :Int;
var indices_ :Array<Float>;// or Int?

/** quantity of quads that are going to be drawn */
public var totalQuads (get_totalQuads, null) :Int;
/** quantity of quads that can be stored with the current texture atlas size */
public var capacity (get_capacity, null) :Int;
/** Texture of the texture atlas */
public var texture :CCTexture2D;
/** Quads that are going to be rendered */
public var quads :Array<CC_V3F_C4B_T2F_Quad>;

/** creates a TextureAtlas with an filename and with an initial capacity for Quads.
 * The TextureAtlas capacity can be increased in runtime.
 */
public static function textureAtlasWithFile (file:String, capacity:Int) :CCTextureAtlas
{
	return new CCTextureAtlas().initWithFile (file, capacity);
}

public function new () {}
	
	
/** initializes a TextureAtlas with a filename and with a certain capacity for Quads.
 * The TextureAtlas capacity can be increased in runtime.
 *
 * WARNING: Do not reinitialize the TextureAtlas because it will leak memory (issue #706)
 */
public function initWithFile (file:String, capacity:Int) :CCTextureAtlas
{
	// retained in property
	var tex :CCTexture2D = CCTextureCache.sharedTextureCache().addImage(file);
	return this.initWithTexture (tex, capacity);
}

/** creates a TextureAtlas with a previously initialized Texture2D object, and
 * with an initial capacity for n Quads. 
 * The TextureAtlas capacity can be increased in runtime.
 */
public static function textureAtlasWithTexture (tex:CCTexture2D, capacity:Int) :CCTextureAtlas
{
	return new CCTextureAtlas().initWithTexture (tex, capacity);
}

/** initializes a TextureAtlas with a previously initialized Texture2D object, and
 * with an initial capacity for Quads. 
 * The TextureAtlas capacity can be increased in runtime.
 *
 * WARNING: Do not reinitialize the TextureAtlas because it will leak memory (issue #706)
 */
public function initWithTexture (tex:CCTexture2D, capacity:Int) :CCTextureAtlas
{
	capacity_ = capacity;
	totalQuads_ = 0;

	// retained in property
	this.texture = tex;

	// Re-initialization is not allowed
	if (quads==null && indices_==null) throw "CCTextureAtlas re-initialization is not allowed";

	quads = [];//calloc( sizeof(quads[0]) * capacity_, 1 );
	indices_ = [];//calloc( sizeof(indices_[0]) * capacity_ * 6, 1 );
	
	this.initIndices();
	return this;
}

/** updates a Quad (texture, vertex and color) at a certain index
 * index must be between 0 and the atlas capacity - 1
 @since v0.8
 */
public function updateQuad (quad:CC_V3F_C4B_T2F_Quad, n:Int) :CC_V3F_C4B_T2F_Quad
{
	if (n >= capacity_) throw "updateQuadWithTexture: Invalid index";
	//totalQuads_ = Math.max (Math.round(n+1), Math.round(totalQuads_));
	quads[n] = quad;

	return quad;
}

/** Inserts a Quad (texture, vertex and color) at a certain index
 index must be between 0 and the atlas capacity - 1
 @since v0.8
 */
public function insertQuad (quad:CC_V3F_C4B_T2F_Quad, index:Int) :Void
{
	if(index >= capacity_) throw "insertQuadWithTexture: Invalid index";

	totalQuads_++;
	if( totalQuads_ > capacity_) throw "invalid totalQuads";

	// issue #575. index can be > totalQuads
	var remaining :Int = (totalQuads_-1) - index;

	// last object doesn't need to be moved
	//if( remaining > 0)
		// tex coordinates
		//memmove( &quads[index+1],&quads[index], sizeof(quads[0]) * remaining );

	quads[index] = quad;
}

/** Removes the quad that is located at a certain index and inserts it at a new index
 This operation is faster than removing and inserting in a quad in 2 different steps
 @since v0.7.2
*/
public function insertQuadFromIndex (oldIndex:Int, newIndex:Int) :Void
{
	if(newIndex >= totalQuads_) throw "insertQuadFromIndex:atIndex: Invalid index";
	if(oldIndex >= totalQuads_) throw "insertQuadFromIndex:atIndex: Invalid index";

	if( oldIndex == newIndex )
		return;

	var howMany = Math.abs (oldIndex - newIndex);
	var dst = oldIndex;
	var src = oldIndex + 1;
	if( oldIndex > newIndex) {
		dst = newIndex+1;
		src = newIndex;
	}

	// tex coordinates
	var quadsBackup :CC_V3F_C4B_T2F_Quad = quads[oldIndex];
	//memmove( &quads[dst],&quads[src], sizeof(quads[0]) * howMany );
	quads[newIndex] = quadsBackup;
}

/** removes a quad at a given index number.
 The capacity remains the same, but the total number of quads to be drawn is reduced in 1
 @since v0.7.2
 */
public function removeQuadAtIndex (index:Int)
{
	if(index >= totalQuads_) throw "removeQuadAtIndex: Invalid index";
	
	var remaining :Int = (totalQuads_-1) - index;
	
	// last object doesn't need to be moved
	//if( remaining )
		// tex coordinates
		//memmove( &quads[index],&quads[index+1], sizeof(quads[0]) * remaining );

	totalQuads_--;
}

/** removes all Quads.
 The TextureAtlas capacity remains untouched. No memory is freed.
 The total number of quads to be drawn will be 0
 @since v0.7.2
 */
public function removeAllQuads ()
{
	totalQuads_ = 0;
}
function get_totalQuads () :Int {
	return totalQuads_;
}


/** resize the capacity of the CCTextureAtlas.
 * The new capacity can be lower or higher than the current one
 * It returns true if the resize was successful.
 * If it fails to resize the capacity it will return NO with a new capacity of 0.
 */
public function resizeCapacity (newCapacity:Int) :Bool
{
	if( newCapacity == capacity_ )
		return true;

	// update capacity and totolQuads
	//totalQuads_ = Math.min (Math.round(totalQuads_), Math.round(newCapacity));
	capacity_ = newCapacity;
	
	this.initIndices();
	
	return true;
}
function get_capacity () :Int {
	return capacity_;
}


/** draws n quads from an index (offset).
 n + start can't be greater than the capacity of the atlas

 @since v1.0
 */
public function drawNumberOfQuads (n:Int, ?start:Int=0)
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: -

	//glBindTexture(GL_TEXTURE_2D, texture.name);
/* 	var kQuadSize = sizeof(quads[0].bl);

	var offset :Int = quads;
	// vertex
	var diff = offsetof( CC_V3F_C4B_T2F, vertices);
	//glVertexPointer(3, GL_FLOAT, kQuadSize, (offset + diff) );
	// color
	diff = offsetof( CC_V3F_C4B_T2F, colors);
	//glColorPointer(4, GL_UNSIGNED_BYTE, kQuadSize, (offset + diff));

	// tex coords
	diff = offsetof( CC_V3F_C4B_T2F, texCoords);*/
	//glTexCoordPointer(2, GL_FLOAT, kQuadSize, (offset + diff));

#if CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
	//glDrawElements(GL_TRIANGLE_STRIP, n*6, GL_UNSIGNED_SHORT, indices_ + start * 6 );
#else
	//glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, indices_ + start * 6 );
#end
}

/** draws all the Atlas's Quads
 */
public function drawQuads ()
{
	this.drawNumberOfQuads (totalQuads_, 0);
}



public function toString () :String
{
	return "<CCTextureAtlas | totalQuads = "+totalQuads_+">";
}

public function release () :Void
{
	trace("cocos2d: releaseing "+this);

	quads = null;
	indices_ = null;
	texture.release();
}

public function initIndices ()
{
	for( i in 0...capacity_) {
#if CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
		indices_[i*6+0] = i*4+0;
		indices_[i*6+1] = i*4+0;
		indices_[i*6+2] = i*4+2;
		indices_[i*6+3] = i*4+1;
		indices_[i*6+4] = i*4+3;
		indices_[i*6+5] = i*4+3;
#else
		indices_[i*6+0] = i*4+0;
		indices_[i*6+1] = i*4+1;
		indices_[i*6+2] = i*4+2;

		// inverted index. issue #179
		indices_[i*6+3] = i*4+3;
		indices_[i*6+4] = i*4+2;
		indices_[i*6+5] = i*4+1;
//		indices_[i*6+3] = i*4+2;
//		indices_[i*6+4] = i*4+3;
//		indices_[i*6+5] = i*4+1;	
#end
	}
}

}
