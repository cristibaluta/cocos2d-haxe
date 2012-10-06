/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 On-Core
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
import CCNode;
import CCCamera;
import CCTypes;
import CCMacros;
import CCTexture2D;
import CCDirector;
import CCGrabber;
import objc.CGSize;
import objc.CGPoint;
using support.CGPointExtension;
using support.CCUtils;

#if flash
import platforms.flash.CCDirectorFlash;
import platforms.flash.FlashView;
#elseif nme
import platforms.nme.CCDirectorNME;
#end

/** Base class for other
 */
class CCGridBase
{
//
public var gridSize :CGSize;

/** wheter or not the grid is active */
public var active (default, setActive) :Bool;
/** number of times that the grid will be reused */
public var reuseGrid :Int;
/** size of the grid */
//public var gridSize (get_gridSize, null) :CC_GridSize;
/** pixels between the grids */
public var step :CGPoint;
/** texture used */
public var texture :CCTexture2D;
/** grabber used */
public var grabber :CCGrabber;
/** is texture flipped */
public var isTextureFlipped (default, setIsTextureFlipped) :Bool;


public function new () {}
	
public static function gridWithSize (gridSize:CGSize, ?texture:CCTexture2D, ?flipped:Bool=false) :CCGridBase
{
	return new CCGridBase().initWithSize (gridSize, texture, flipped);
}

public function initWithSize (gridSize:CGSize, ?texture:CCTexture2D, ?flipped:Bool=false) :CCGridBase
{
	var director :CCDirector = CCDirector.sharedDirector();
	var s :CGSize = director.winSizeInPixels();
	
	var POTWide = Math.round(s.width).ccNextPOT();
	var POTHigh = Math.round(s.height).ccNextPOT();
#if flash
	var glview :FlashView = CCDirector.sharedDirector().view;
#end
	var data = new flash.display.BitmapData(POTWide, POTHigh);//(POTWide * POTHigh * 4), 1);
	var texture :CCTexture2D = new CCTexture2D().initWithData (data, POTWide, POTHigh, s);
	
	
	active = false;
	reuseGrid = 0;
	this.gridSize = gridSize;

	this.texture = texture;
	isTextureFlipped = flipped;
	
	var texSize :CGSize = texture.contentSizeInPixels;
	step.x = texSize.width / gridSize.width;
	step.y = texSize.height / gridSize.height;
	
	grabber = new CCGrabber().init();
	grabber.grab ( texture );
	
	this.calculateVertexPoints();
	
	return this;
}


public function toString () :String
{
	return "CCGrid | Dimensions = "+gridSize.width+"x"+gridSize.height;
}

public function release () :Void
{
	trace("cocos2d: releaseing "+ this);
	
	this.setActive ( false );
	
	texture.release();
	grabber.release();
}

// properties
public function setActive (active:Bool) :Bool
{
	this.active = active;
	if( ! active ) {
		var director = CCDirector.sharedDirector();
		director.setProjection ( director.projection );
	}
	return active;
}
public function setIsTextureFlipped (flipped:Bool) :Bool
{
	if( isTextureFlipped != flipped ) {
		isTextureFlipped = flipped;
		this.calculateVertexPoints();
	}
	return flipped;
}

// This routine can be merged with Director

public function applyLandscape () :Void
{
#if nme
	var director :CCDirector = CCDirector.sharedDirector();
	var winSize :CGSize = director.displaySizeInPixels();
	var w = winSize.width / 2;
	var h = winSize.height / 2;
	var orientation :CC_DeviceOrientation  = director.deviceOrientation();

	switch (orientation) {
		case CCDeviceOrientationLandscapeLeft:
/*			glTranslatef(w,h,0);
			glRotatef(-90,0,0,1);
			glTranslatef(-h,-w,0);*/
			
		case CCDeviceOrientationLandscapeRight:
/*			glTranslatef(w,h,0);
			glRotatef(90,0,0,1);
			glTranslatef(-h,-w,0);*/
			
		case CCDeviceOrientationPortraitUpsideDown:
/*			glTranslatef(w,h,0);
			glRotatef(180,0,0,1);
			glTranslatef(-w,-h,0);*/
	}
#end
}


public function set2DProjection () :Void
{
	var	winSize :CGSize = CCDirector.sharedDirector().winSizeInPixels();
	
/*	glLoadIdentity();
	glViewport(0, 0, winSize.width, winSize.height);
	glMatrixMode(GL.PROJECTION);
	glLoadIdentity();
	ccglOrtho(0, winSize.width, 0, winSize.height, -1024, 1024);
	glMatrixMode(GL.MODELVIEW);*/
}

// This routine can be merged with Director
public function set3DProjection () :Void
{
	var director :CCDirector = CCDirector.sharedDirector();
	var winSize :CGSize = director.displaySizeInPixels();
	
/*	glViewport(0, 0, winSize.width, winSize.height);
	glMatrixMode(GL.PROJECTION);
	glLoadIdentity();
	gluPerspective(60, winSize.width/winSize.height, 0.5, 1500.0);
	
	glMatrixMode(GL.MODELVIEW);	
	glLoadIdentity();
	gluLookAt( winSize.width/2, winSize.height/2, director.getZEye(),
			  winSize.width/2, winSize.height/2, 0,
			  0.0, 1.0, 0.0
			  );*/
}

public function beforeDraw () :Void
{
	this.set2DProjection();
	grabber.beforeRender ( texture );
}

public function afterDraw (target:CCNode) :Void
{
	grabber.afterRender ( texture );
	
	this.set3DProjection();
#if ios
	this.applyLandscape();
#end

	if( target.camera.dirty ) {

		var offset :CGPoint = target.anchorPointInPixels;

		//
		// XXX: Camera should be applied in the AnchorPoint
		//
/*		ccglTranslate (offset.x, offset.y, 0);
		target.camera.locate();
		ccglTranslate (-offset.x, -offset.y, 0);*/
	}
		
//	glBindTexture(GL.TEXTURE_2D, texture.name);

	this.blit();
}

public function blit () :Void
{
	trace("Abstract class needs implementation");
}

public function reuse () :Void
{
	trace("Abstract class needs implementation");
}

public function calculateVertexPoints () :Void
{
	trace("Abstract class needs implementation");
}

}




////////////////////////////////////////////////////////////

/**
 CCGrid3D is a 3D grid implementation. Each vertex has 3 dimensions: x,y,z
 */
class CCGrid3D extends CCGridBase
{
var texCoordinates :Array<Float>;
var vertices :Array<Float>;
var originalVertices :Array<Float>;
var indices :Array<Float>;

override public function release () :Void
{
	texCoordinates = null;
	vertices = null;
	indices = null;
	originalVertices = null;
	
	super.release();
}

override public function blit () :Void
{
	var n = Math.round (gridSize.width * gridSize.height);
	
	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Unneeded states: GL.COLOR_ARRAY
/*	glDisableClientState(GL.COLOR_ARRAY);	
	
	glVertexPointer(3, GL.FLOAT, 0, vertices);
	glTexCoordPointer(2, GL.FLOAT, 0, texCoordinates);
	glDrawElements(GL.TRIANGLES, (GLsizei) n*6, GL.UNSIGNED_SHORT, indices);*/
	
	// restore GL default state
	//glEnableClientState(GL.COLOR_ARRAY);
}

override public function calculateVertexPoints () :Void
{
	var width :Float = texture.pixelsWide;
	var height :Float = texture.pixelsHigh;
	var imageH :Float = texture.contentSizeInPixels.height;
	
	var x:Int, y:Int, i:Int;
	/*
	vertices = malloc((gridSize.x+1)*(gridSize.y+1)*sizeof(CC_Vertex3F));
	originalVertices = malloc((gridSize.x+1)*(gridSize.y+1)*sizeof(CC_Vertex3F));
	texCoordinates = malloc((gridSize.x+1)*(gridSize.y+1)*sizeof(CGPoint));
	indices = malloc(gridSize.x*gridSize.y*sizeof(GLushort)*6);
	
	var vertArray :Array<Float> = vertices;
	var texArray :Array<Float> = texCoordinates;
	var idxArray :GLushort = indices;
	
	for( x in 0...gridSize.x )
	{
		for( y in 0...gridSize.y )
		{
			var idx = Math.round ((y * gridSize.x) + x);
			
			var x1 :Float = x * step.x;
			var x2 :Float = x1 + step.x;
			var y1 :Float = y * step.y;
			var y2 :Float = y1 + step.y;
			
			var a :GLushort = x * (gridSize.y+1) + y;
			var b :GLushort = (x+1) * (gridSize.y+1) + y;
			var c :GLushort = (x+1) * (gridSize.y+1) + (y+1);
			var d :GLushort = x * (gridSize.y+1) + (y+1);
			
			var tempidx[6] :GLushort = { a, b, d, b, c, d };
			
			memcpy(&idxArray[6*idx], tempidx, 6*sizeof(GLushort));
			
			int l1[4] = { a*3, b*3, c*3, d*3 };
			var	e :GLushort = {x1,y1,0};
			var	f :GLushort = {x2,y1,0};
			var	g :GLushort = {x2,y2,0};
			var	h :GLushort = {x1,y2,0};
			
			CC_Vertex3F l2[4] = { e, f, g, h };
			
			int tex1[4] = { a*2, b*2, c*2, d*2 };
			var tex2[4] :CGPoint = { new CGPoint (x1, y1), new CGPoint (x2, y1), new CGPoint (x2, y2), new CGPoint (x1, y2) };
			
			for( i = 0; i < 4; i++ )
			{
				vertArray[ l1[i] ] = l2[i].x;
				vertArray[ l1[i] + 1 ] = l2[i].y;
				vertArray[ l1[i] + 2 ] = l2[i].z;
				
				texArray[ tex1[i] ] = tex2[i].x / width;
				if( isTextureFlipped )
					texArray[ tex1[i] + 1 ] = (imageH - tex2[i].y) / height;
				else
					texArray[ tex1[i] + 1 ] = tex2[i].y / height;
			}
		}
	}
	
	memcpy(originalVertices, vertices, (gridSize.x+1)*(gridSize.y+1)*sizeof(CC_Vertex3F));*/
}

public function vertex (pos:CC_GridSize) :CC_Vertex3F
{
	var index = Math.round ((pos.x * (gridSize.height+1) + pos.y) * 3);
	var vertArray :Array<Float> = vertices;
	
	var vert:CC_Vertex3F = { x:vertArray[index], y:vertArray[index+1], z:vertArray[index+2] };
	
	return vert;
}

public function originalVertex (pos:CC_GridSize) :CC_Vertex3F
{
	var index = Math.round ((pos.x * (gridSize.height+1) + pos.y) * 3);
	var vertArray :Array<Float> = originalVertices;
	
	var vert:CC_Vertex3F = { x:vertArray[index], y:vertArray[index+1], z:vertArray[index+2] };
	
	return vert;
}

public function setVertex (pos:CC_GridSize, vertex:CC_Vertex3F) :Void
{
	var index = Math.round ((pos.x * (gridSize.height+1) + pos.y) * 3);
	var vertArray :Array<Float> = vertices;
	vertArray[index] = vertex.x;
	vertArray[index+1] = vertex.y;
	vertArray[index+2] = vertex.z;
}

override public function reuse () :Void
{
	if ( reuseGrid > 0 )
	{
		//memcpy(originalVertices, vertices, (gridSize.x+1)*(gridSize.y+1)*sizeof(CC_Vertex3F));
		reuseGrid--;
	}
}

}




////////////////////////////////////////////////////////////

/**
 CCTiledGrid3D is a 3D grid implementation. It differs from Grid3D in that
 the tiles can be separated from the grid.
*/
class CCTiledGrid3D extends CCGridBase
{
//
var texCoordinates :Array<Float>;
var vertices :Array<Float>;
var originalVertices :Array<Float>;
var indices :Array<Float>;


override public function release () :Void
{
	texCoordinates = null;
	vertices = null;
	indices = null;
	originalVertices = null;
	super.release();
}

override public function blit () :Void
{
	var n :Int = Math.round (gridSize.width * gridSize.height);
	
	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Unneeded states: GL.COLOR_ARRAY
/*	glDisableClientState(GL.COLOR_ARRAY);	
	
	glVertexPointer(3, GL.FLOAT, 0, vertices);
	glTexCoordPointer(2, GL.FLOAT, 0, texCoordinates);
	glDrawElements(GL.TRIANGLES, (GLsizei) n*6, GL.UNSIGNED_SHORT, indices);

	// restore default GL state
	glEnableClientState(GL.COLOR_ARRAY);*/
}

override public function calculateVertexPoints () :Void
{
	var width :Float = texture.pixelsWide;
	var height :Float = texture.pixelsHigh;
	var imageH :Float = texture.contentSizeInPixels.height;
	
/*	var numQuads :Int = gridSize.x * gridSize.y;
	
	vertices = malloc(numQuads*12*sizeof(Float));
	originalVertices = malloc(numQuads*12*sizeof(Float));
	texCoordinates = malloc(numQuads*8*sizeof(Float));
	indices = malloc(numQuads*6*sizeof(GLushort));
	
	var vertArray :Float = (Float*)vertices;
	var texArray :Float = (Float*)texCoordinates;
	var idxArray :GLushort = indices;
	
	var x:Int, y:Int;
	
	for( x in 0...gridSize.x )
	{
		for( y in 0...gridSize.y )
		{
			var x1 :Float = x * step.x;
			var x2 :Float = x1 + step.x;
			var y1 :Float = y * step.y;
			var y2 :Float = y1 + step.y;
			
			*vertArray++ = x1;
			*vertArray++ = y1;
			*vertArray++ = 0;
			*vertArray++ = x2;
			*vertArray++ = y1;
			*vertArray++ = 0;
			*vertArray++ = x1;
			*vertArray++ = y2;
			*vertArray++ = 0;
			*vertArray++ = x2;
			*vertArray++ = y2;
			*vertArray++ = 0;
			
			var newY1 :Float = y1;
			var newY2 :Float = y2;
			
			if( isTextureFlipped ) {
				newY1 = imageH - y1;
				newY2 = imageH - y2;
			}

			*texArray++ = x1 / width;
			*texArray++ = newY1 / height;
			*texArray++ = x2 / width;
			*texArray++ = newY1 / height;
			*texArray++ = x1 / width;
			*texArray++ = newY2 / height;
			*texArray++ = x2 / width;
			*texArray++ = newY2 / height;
		}
	}
	
	for( x in 0...numQuads)
	{
		idxArray[x*6+0] = x*4+0;
		idxArray[x*6+1] = x*4+1;
		idxArray[x*6+2] = x*4+2;
		
		idxArray[x*6+3] = x*4+1;
		idxArray[x*6+4] = x*4+2;
		idxArray[x*6+5] = x*4+3;
	}*/
	
	//memcpy(originalVertices, vertices, numQuads*12*sizeof(Float));
}

public function setTile (pos:CC_GridSize, coords:CC_Quad3) :Void
{
	var idx :Int = Math.round (gridSize.height * pos.x + pos.y) * 4 * 3;
	var vertArray :Array<Float> = vertices;
	//memcpy(&vertArray[idx], &coords, sizeof(ccQuad3));
}

public function originalTile (pos:CC_GridSize) :CC_Quad3
{
	var idx = Math.round((gridSize.height * pos.x + pos.y) * 4 * 3);
	var vertArray :Array<Float> = originalVertices;
	
	var ret :CC_Quad3 = null;
	//memcpy(&ret, &vertArray[idx], sizeof(ccQuad3));
	
	return ret;
}

public function tile (pos:CC_GridSize) :CC_Quad3
{
	var idx = Math.round((gridSize.height * pos.x + pos.y) * 4 * 3);
	var vertArray :Array<Float> = vertices;
	
	var ret :CC_Quad3 = null;
	//memcpy(&ret, &vertArray[idx], sizeof(ccQuad3));
	
	return ret;
}

override public function reuse () :Void
{
	if ( reuseGrid > 0 )
	{
		var numQuads :Int = Math.round ( gridSize.width * gridSize.height );
		
		//memcpy(originalVertices, vertices, numQuads*12*sizeof(Float));
		reuseGrid--;
	}
}

}
