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

import CCTypes;
//import platforms.CCGL;
import objc.CGPoint;

class CCDrawingPrimitives
{

public static function ccDrawPoint(point:CGPoint)
{
/*	var p :CC_Vertex2F = (CC_Vertex2F) {point.x * CCConfig.CC_CONTENT_SCALE_FACTOR, point.y * CCConfig.CC_CONTENT_SCALE_FACTOR };
	
	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.VERTEX_ARRAY, 
	// Unneeded states: GL.TEXTURE_2D, GL.TEXTURE_COORD_ARRAY, GL.COLOR_ARRAY	
	glDisable(GL.TEXTURE_2D);
	glDisableClientState(GL.TEXTURE_COORD_ARRAY);
	glDisableClientState(GL.COLOR_ARRAY);
	
	glVertexPointer(2, GL.FLOAT, 0, &p);	
	glDrawArrays(GL.POINTS, 0, 1);

	// restore default state
	glEnableClientState(GL.COLOR_ARRAY);
	glEnableClientState(GL.TEXTURE_COORD_ARRAY);
	glEnable(GL.TEXTURE_2D);*/	
}

public static function ccDrawPoints(points:CGPoint, numberOfPoints:Int)
{
	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.VERTEX_ARRAY, 
	// Unneeded states: GL.TEXTURE_2D, GL.TEXTURE_COORD_ARRAY, GL.COLOR_ARRAY	
/*	glDisable(GL.TEXTURE_2D);
	glDisableClientState(GL.TEXTURE_COORD_ARRAY);
	glDisableClientState(GL.COLOR_ARRAY);

	CC_Vertex2F newPoints[numberOfPoints];

	// iPhone and 32-bit machines optimization
	if( sizeof(CGPoint) == sizeof(CC_Vertex2F) ) {

		// points ?
		if( CCConfig.CC_CONTENT_SCALE_FACTOR != 1 ) {
			for( i in 0...numberOfPoints)
				newPoints[i] = { x:points[i].x * CCConfig.CC_CONTENT_SCALE_FACTOR, y:points[i].y * CCConfig.CC_CONTENT_SCALE_FACTOR };

			glVertexPointer(2, GL.FLOAT, 0, newPoints);

		} else
			glVertexPointer(2, GL.FLOAT, 0, points);
		
		glDrawArrays(GL.POINTS, 0, (GLsizei) numberOfPoints);
		
	} else {
		
		// Mac on 64-bit
		for( i in 0...numberOfPoints)
			newPoints[i] = { x:points[i].x, y:points[i].y };
			
		glVertexPointer(2, GL.FLOAT, 0, newPoints);
		glDrawArrays(GL.POINTS, 0, (GLsizei) numberOfPoints);

	}

	
	// restore default state
	glEnableClientState(GL.COLOR_ARRAY);
	glEnableClientState(GL.TEXTURE_COORD_ARRAY);
	glEnable(GL.TEXTURE_2D);*/
}


public static function ccDrawLine( origin:CGPoint, destination:CGPoint )
{
/*	CC_Vertex2F vertices[2] = {
		{origin.x * CCConfig.CC_CONTENT_SCALE_FACTOR, origin.y * CCConfig.CC_CONTENT_SCALE_FACTOR },
		{destination.x * CCConfig.CC_CONTENT_SCALE_FACTOR, destination.y * CCConfig.CC_CONTENT_SCALE_FACTOR }
	};

	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.VERTEX_ARRAY, 
	// Unneeded states: GL.TEXTURE_2D, GL.TEXTURE_COORD_ARRAY, GL.COLOR_ARRAY	
	glDisable(GL.TEXTURE_2D);
	glDisableClientState(GL.TEXTURE_COORD_ARRAY);
	glDisableClientState(GL.COLOR_ARRAY);
	
	glVertexPointer(2, GL.FLOAT, 0, vertices);	
	glDrawArrays(GL.LINES, 0, 2);
	
	// restore default state
	glEnableClientState(GL.COLOR_ARRAY);
	glEnableClientState(GL.TEXTURE_COORD_ARRAY);
	glEnable(GL.TEXTURE_2D);*/		
}


public static function ccDrawPoly( poli:CGPoint, numberOfPoints:Int, closePolygon:Bool )
{
/*	CC_Vertex2F newPoint[numberOfPoints];

	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.VERTEX_ARRAY, 
	// Unneeded states: GL.TEXTURE_2D, GL.TEXTURE_COORD_ARRAY, GL.COLOR_ARRAY	
	glDisable(GL.TEXTURE_2D);
	glDisableClientState(GL.TEXTURE_COORD_ARRAY);
	glDisableClientState(GL.COLOR_ARRAY);

	
	// iPhone and 32-bit machines
	if( sizeof(CGPoint) == sizeof(CC_Vertex2F) ) {

		// convert to pixels ?
		if( CCConfig.CC_CONTENT_SCALE_FACTOR != 1 ) {
			memcpy( newPoint, poli, numberOfPoints * sizeof(CC_Vertex2F) );
			for( Int i=0; i<numberOfPoints;i++)
				newPoint[i] = (CC_Vertex2F) { poli[i].x * CCConfig.CC_CONTENT_SCALE_FACTOR, poli[i].y * CCConfig.CC_CONTENT_SCALE_FACTOR };

			glVertexPointer(2, GL.FLOAT, 0, newPoint);

		} else
			glVertexPointer(2, GL.FLOAT, 0, poli);

		
	} else {
		// 64-bit machines (Mac)
		
		for( Int i=0; i<numberOfPoints;i++)
			newPoint[i] = (CC_Vertex2F) { poli[i].x, poli[i].y };

		glVertexPointer(2, GL.FLOAT, 0, newPoint );

	}
		
	if( closePolygon )
		glDrawArrays(GL.LINE_LOOP, 0, (GLsizei) numberOfPoints);
	else
		glDrawArrays(GL.LINE_STRIP, 0, (GLsizei) numberOfPoints);
	
	// restore default state
	glEnableClientState(GL.COLOR_ARRAY);
	glEnableClientState(GL.TEXTURE_COORD_ARRAY);
	glEnable(GL.TEXTURE_2D);*/	
}

public static function ccDrawCircle( center:CGPoint, r:Float, a:Float, segs:Int, drawLineToCenter:Bool)
{
/*	var additionalSegment :Int = 1;
	if (drawLineToCenter)
		additionalSegment++;

	var coef :Float = CCMacros.M_PI_2/segs;
	
	var vertices :Float = calloc( sizeof(Float)*2*(segs+2), 1);
	if( ! vertices )
		return;

	for(i in 0...(segs+1))
	{
		var rads :Float = i*coef;
		var j :Float = r * Math.cos(rads + a) + center.x;
		var k :Float = r * Math.sin(rads + a) + center.y;
		
		vertices[i*2] = j * CCConfig.CC_CONTENT_SCALE_FACTOR;
		vertices[i*2+1] = k * CCConfig.CC_CONTENT_SCALE_FACTOR;
	}
	vertices[(segs+1)*2] = center.x * CCConfig.CC_CONTENT_SCALE_FACTOR;
	vertices[(segs+1)*2+1] = center.y * CCConfig.CC_CONTENT_SCALE_FACTOR;
	
	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.VERTEX_ARRAY, 
	// Unneeded states: GL.TEXTURE_2D, GL.TEXTURE_COORD_ARRAY, GL.COLOR_ARRAY	
	glDisable(GL.TEXTURE_2D);
	glDisableClientState(GL.TEXTURE_COORD_ARRAY);
	glDisableClientState(GL.COLOR_ARRAY);
	
	glVertexPointer(2, GL.FLOAT, 0, vertices);	
	glDrawArrays(GL.LINE_STRIP, 0, (GLsizei) segs+additionalSegment);
	
	// restore default state
	glEnableClientState(GL.COLOR_ARRAY);
	glEnableClientState(GL.TEXTURE_COORD_ARRAY);
	glEnable(GL.TEXTURE_2D);	
	
	free( vertices );*/
}

public static function ccDrawQuadBezier(origin:CGPoint, control:CGPoint, destination:CGPoint, segments:Int)
{
/*	CC_Vertex2F verticessegments.+ 1];
	
	var t :Float = 0.0;
	for(Int i = 0; i < segments; i++)
	{
		var x :Float = Math.pow(1 - t, 2) * origin.x + 2.0 * (1 - t) * t * control.x + t * t * destination.x;
		var y :Float = Math.pow(1 - t, 2) * origin.y + 2.0 * (1 - t) * t * control.y + t * t * destination.y;
		vertices[i] = (CC_Vertex2F) {x * CCConfig.CC_CONTENT_SCALE_FACTOR, y * CCConfig.CC_CONTENT_SCALE_FACTOR };
		t += 1.0 / segments;
	}
	vertices[segments] = (CC_Vertex2F) {destination.x * CCConfig.CC_CONTENT_SCALE_FACTOR, destination.y * CCConfig.CC_CONTENT_SCALE_FACTOR };
	
	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.VERTEX_ARRAY, 
	// Unneeded states: GL.TEXTURE_2D, GL.TEXTURE_COORD_ARRAY, GL.COLOR_ARRAY	
	glDisable(GL.TEXTURE_2D);
	glDisableClientState(GL.TEXTURE_COORD_ARRAY);
	glDisableClientState(GL.COLOR_ARRAY);
	
	glVertexPointer(2, GL.FLOAT, 0, vertices);	
	glDrawArrays(GL.LINE_STRIP, 0, (GLsizei) segments + 1);
	
	// restore default state
	glEnableClientState(GL.COLOR_ARRAY);
	glEnableClientState(GL.TEXTURE_COORD_ARRAY);
	glEnable(GL.TEXTURE_2D);*/	
}

public static function ccDrawCubicBezier(origin:CGPoint, control1:CGPoint, control2:CGPoint, destination:CGPoint, segments:Int)
{
/*	CC_Vertex2F verticessegments.+ 1];
	
	var t :Float = 0;
	for(Int i = 0; i < segments; i++)
	{
		var x :Float = Math.pow(1 - t, 3) * origin.x + 3.0 * Math.pow(1 - t, 2) * t * control1.x + 3.0 * (1 - t) * t * t * control2.x + t * t * t * destination.x;
		var y :Float = Math.pow(1 - t, 3) * origin.y + 3.0 * Math.pow(1 - t, 2) * t * control1.y + 3.0 * (1 - t) * t * t * control2.y + t * t * t * destination.y;
		vertices[i] = (CC_Vertex2F) {x * CCConfig.CC_CONTENT_SCALE_FACTOR, y * CCConfig.CC_CONTENT_SCALE_FACTOR };
		t += 1.0 / segments;
	}
	vertices[segments] = (CC_Vertex2F) {destination.x * CCConfig.CC_CONTENT_SCALE_FACTOR, destination.y * CCConfig.CC_CONTENT_SCALE_FACTOR };
	
	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.VERTEX_ARRAY, 
	// Unneeded states: GL.TEXTURE_2D, GL.TEXTURE_COORD_ARRAY, GL.COLOR_ARRAY	
	glDisable(GL.TEXTURE_2D);
	glDisableClientState(GL.TEXTURE_COORD_ARRAY);
	glDisableClientState(GL.COLOR_ARRAY);
	
	glVertexPointer(2, GL.FLOAT, 0, vertices);	
	glDrawArrays(GL.LINE_STRIP, 0, (GLsizei) segments + 1);
	
	// restore default state
	glEnableClientState(GL.COLOR_ARRAY);
	glEnableClientState(GL.TEXTURE_COORD_ARRAY);
	glEnable(GL.TEXTURE_2D);*/
}

}