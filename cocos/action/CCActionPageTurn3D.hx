/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Sindesso Pty Ltd http://www.sindesso.com/
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


class CCPageTurn3D
{
/*
 * Update each tick
 * Time is the percentage of the way through the duration
 */
function update (time:Float) :Void
{
	var tt :Float = Math.max( 0, time - 0.25 );
	var deltaAy :Float = ( tt * tt * 500);
	var ay :Float = -100 - deltaAy;
	
	var deltaTheta :Float = - M_PI_2 * Math.sqrt( time);
	var theta :Float = /*0.01*/  M_PI_2 + deltaTheta;
	
	var sinTheta :Float = Math.sin(theta);
	var cosTheta :Float = Math.cos(theta);
	
	for( i in 0...gridSize_.x+1 )
	{
		for( j in  0...gridSize_.y+1 )
		{
			// Get original vertex
			var p :CC_Vertex3F = this.originalVertex ( new CC_GridSize(i,j) );
			
			var R :Float = Math.sqrt(p.x*p.x + (p.y - ay) * (p.y - ay));
			var r :Float = R * sinTheta;
			var alpha :Float = Math.sin( p.x / R );
			var beta :Float = alpha / sinTheta;
			var cosBeta :Float = Math.cos( beta );
			
			// If beta > PI then we've wrapped around the cone
			// Reduce the radius to stop these points interfering with others
			if( beta <= M_PI)
				p.x = ( r * Math.sin(beta));
			else
			{
				// Force X = 0 to stop wrapped
				// points
				p.x = 0;
			}
			
			p.y = ( R + ay - ( r*(1 - cosBeta)*sinTheta));
			
			// We scale z here to avoid the animation being
			// too much bigger than the screen due to perspectve transform
			p.z = (r * ( 1 - cosBeta ) * cosTheta) / 7; // "100" didn't work for
				
			// Stop z coord from dropping beneath underlying page in a transition
			// issue #751				
			if( p.z<0.5 )
				p.z = 0.5;
			
			// Set new coords
			this.setVertex ( new CC_GridSize(i,j), p );
		}
	}
}
}
