/* cocos2d for iPhone
 * http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2007 Scott Lembcke
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
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * Some of the functions were based on Chipmunk's cpVect.h.
 */

/**
 @file
 CGPoint extensions based on Chipmunk's cpVect file.
 These extensions work both with CGPoint and cpVect.
 
 The "ccp" prefix means: "CoCos2d Point"
 
 Examples:
  - ccpAdd( ccp(1,1), ccp(2,2) ); // preferred cocos2d way
  - ccpAdd( CGPointMake(1,1), CGPointMake(2,2) ); // also ok but more verbose
  
  - cpvadd( cpv(1,1), cpv(2,2) ); // way of the chipmunk
  - ccpAdd( cpv(1,1), cpv(2,2) ); // mixing chipmunk and cocos2d (avoid)
  - cpvadd( CGPointMake(1,1), CGPointMake(2,2) ); // mixing chipmunk and CG (avoid)
 */

package support;

import objc.CGAffineTransform;
import objc.CGPoint;
import objc.CGSize;

typedef LineIntersection = {
	var S:Float;
	var T:Float;
	var bool:Bool;
}


class CGPointExtension {
	
	inline static var kCGPointEpsilon = 0.0;
	
	
	
	/** Returns opposite of point.
	 @return CGPoint
	 @since v0.7.2
	 */
	public static function neg(v:CGPoint) :CGPoint
	{
		return new CGPoint (-v.x, -v.y);
	}
	
	/** Calculates sum of two points.
	 @return CGPoint
	 @since v0.7.2
	 */
	public static function add(v1:CGPoint, v2:CGPoint) :CGPoint
	{
		return new CGPoint (v1.x + v2.x, v1.y + v2.y);
	}
	
	/** Calculates difference of two points.
	 @return CGPoint
	 @since v0.7.2
	 */
	public static function sub(v1:CGPoint, v2:CGPoint) :CGPoint
	{
		return new CGPoint (v1.x - v2.x, v1.y - v2.y);
	}
	
	/** Returns point multiplied by given factor.
	 @return CGPoint
	 @since v0.7.2
	 */
	public static function mult(v:CGPoint, s:Float) :CGPoint
	{
		return new CGPoint (v.x*s, v.y*s);
	}
	
	/** Multiplies a nd b components, a.x*b.x, a.y*b.y
	 @returns a component-wise multiplication
	 @since v0.99.1
	 */
	public static function compMult(a:CGPoint, b:CGPoint) :CGPoint
	{
		return new CGPoint (a.x * b.x, a.y * b.y);
	}
	
	
	/** Calculates midpoint between two points.
	 @return CGPoint
	 @since v0.7.2
	 */
	public static function midpoint(v1:CGPoint, v2:CGPoint) :CGPoint
	{
		return mult (add (v1, v2), 0.5);
	}
	
	/** Calculates dot product of two points.
	 @return CGFloat
	 @since v0.7.2
	 */
	public static function dot(v1:CGPoint, v2:CGPoint) :Float
	{
		return v1.x*v2.x + v1.y*v2.y;
	}
	
	/** Calculates cross product of two points.
	 @return CGFloat
	 @since v0.7.2
	 */
	public static function cross(v1:CGPoint, v2:CGPoint) :Float
	{
		return v1.x*v2.y - v1.y*v2.x;
	}
	
	/** Calculates perpendicular of v, rotated 90 degrees counter-clockwise -- cross(v, perp(v)) >= 0
	 @return CGPoint
	 @since v0.7.2
	 */
	public static function perp(v:CGPoint) :CGPoint
	{
		return new CGPoint (-v.y, v.x);
	}
	
	/** Calculates perpendicular of v, rotated 90 degrees clockwise -- cross(v, rperp(v)) <= 0
	 @return CGPoint
	 @since v0.7.2
	 */
	public static function rperp(v:CGPoint) :CGPoint
	{
		return new CGPoint (v.y, -v.x);
	}
	
	/** Calculates the projection of v1 over v2.
	 @return CGPoint
	 @since v0.7.2
	*/
	public static function project(v1:CGPoint, v2:CGPoint) :CGPoint
	{
		return mult (v2, dot(v1,v2) / dot(v2,v2));
	}
	
	/** Rotates two points.
	 @return CGPoint
	 @since v0.7.2
	 */
	public static function rotate (v1:CGPoint, v2:CGPoint) :CGPoint {
		return new CGPoint (v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
	}
	
	/** Unrotates two points.
	 @return CGPoint
	 @since v0.7.2
	 */
	public static function unrotate (v1:CGPoint, v2:CGPoint) :CGPoint {
		return new CGPoint (v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
	}
	
	
	/** Calculates the square length of a CGPoint (not calling sqrt() )
	 @return CGFloat
	 @since v0.7.2
	 */
	public static function lengthSQ(v:CGPoint) :Float
	{
		return dot(v, v);
		return Math.sqrt ( v.x+v.y );
	}
	
	/** Calculates distance between point an origin
	 @return CGFloat
	 @since v0.7.2
	 */
	inline public static function length (v:CGPoint) :Float
	{
		return Math.sqrt ( lengthSQ(v) );
	}

	/** Calculates the distance between two points
	 @return CGFloat
	 @since v0.7.2
	 */
	inline public static function distance(v1:CGPoint, v2:CGPoint) :Float
	{
		return length(sub(v1, v2));
	}

	/** Returns point multiplied to a length of 1.
	 @return CGPoint
	 @since v0.7.2
	 */
	inline public static function normalize(v:CGPoint) :CGPoint
	{
		return mult (v, 1.0/length(v));
	}

	/** Converts radians to a normalized vector.
	 @return CGPoint
	 @since v0.7.2
	 */
	public static function forAngle(a:Float) :CGPoint
	{
		return new CGPoint (Math.cos(a), Math.sin(a));
	}

	/** Converts a vector to radians.
	 @return CGFloat
	 @since v0.7.2
	 */
	public static function toAngle(v:CGPoint) :Float
	{
		return Math.atan2 (v.y, v.x);
	}
	
	/** Linear Interpolation between two points a and b
	 @returns
		alpha == 0 ? a
		alpha == 1 ? b
		otherwise a value between a..b
	 @since v0.99.1
	 */
	public static function lerp(a:CGPoint, b:CGPoint, alpha:Float) :CGPoint
	{
		return add (mult (a, 1.0 - alpha), mult (b, alpha));
	}

	/** Clamp a value between from and to.
	 @since v0.99.1
	 */
	public static function clampf(value:Float, min_inclusive:Float, max_inclusive:Float) :Float
	{
		if (min_inclusive > max_inclusive) {
			var obj = CCMacros.CC_SWAP (min_inclusive, max_inclusive);
			min_inclusive = obj.x;
			max_inclusive = obj.y;
		}
		return value < min_inclusive ? min_inclusive : value < max_inclusive? value : max_inclusive;
	}

	/** Clamp a point between from and to.
	 @since v0.99.1
	 */
	public static function clamp(p:CGPoint, min_inclusive:CGPoint, max_inclusive:CGPoint) :CGPoint
	{
		return new CGPoint (clampf(p.x,min_inclusive.x,max_inclusive.x), clampf(p.y, min_inclusive.y, max_inclusive.y));
	}

	/** Quickly convert CGSize to a CGPoint
	 @since v0.99.1
	 */
	public static function fromSize(s:CGSize) :CGPoint
	{
		return new CGPoint (s.width, s.height);
	}

	/** Run a math operation function on each point component
	 * absf, fllorf, ceilf, roundf
	 * any function that has the signature: float func(float);
	 * For example: let's try to take the floor of x,y
	 * ccpCompOp(p,floorf);
	 @since v0.99.1
	 */
	public static function compOp(p:CGPoint, opFunc:Dynamic) :CGPoint
	{
		return new CGPoint (opFunc(p.x), opFunc(p.y));
	}
	
	/** @returns if points have fuzzy equality which means equal with some degree of variance.
	 @since v0.99.1
	 */
	public static function fuzzyEqual(a:CGPoint, b:CGPoint, v:Float) :Bool
	{
		if(a.x - v <= b.x && b.x <= a.x + v)
			if(a.y - v <= b.y && b.y <= a.y + v)
				return true;
		return false;
	}
	
	/** @returns the signed angle in radians between two vector directions
	 @since v0.99.1
	 */
	public static function angleSigned(a:CGPoint, b:CGPoint) :Float
	{
		var a2:CGPoint = normalize(a);
		var b2:CGPoint = normalize(b);
		var angle:Float = Math.atan2 (a2.x * b2.y - a2.y * b2.x, dot(a2, b2));
		if( Math.abs(angle) < kCGPointEpsilon ) return 0.0;
		return angle;
	}
	
	/** @returns the angle in radians between two vector directions
	 @since v0.99.1
	*/
	public static function angle (a:CGPoint, b:CGPoint) :Float
	{
		var ang :Float = Math.acos ( dot (normalize(a), normalize(b)) );
		if( Math.abs(ang) < kCGPointEpsilon ) return 0.0;
		return ang;
	}
	
	
	/** Rotates a point counter clockwise by the angle around a pivot
	 @param v is the point to rotate
	 @param pivot is the pivot, naturally
	 @param angle is the angle of rotation cw in radians
	 @returns the rotated point
	 @since v0.99.1
	 */
	public static function rotateByAngle(v:CGPoint, pivot:CGPoint, angle:Float) :CGPoint
	{
		var r :CGPoint = sub(v, pivot);
		var cosa :Float = Math.cos(angle);
		var sina :Float = Math.sin(angle);
		var t :Float = r.x;
		r.x = t*cosa - r.y*sina + pivot.x;
		r.y = t*sina + r.y*cosa + pivot.y;
		return r;
	}

	
	
	/** A general line-line intersection test
	 @param p1 
		is the startpoint for the first line P1 = (p1 - p2)
	 @param p2 
		is the endpoint for the first line P1 = (p1 - p2)
	 @param p3 
		is the startpoint for the second line P2 = (p3 - p4)
	 @param p4 
		is the endpoint for the second line P2 = (p3 - p4)
	 @param s 
		is the range for a hitpoint in P1 (pa = p1 + s*(p2 - p1))
	 @param t
		is the range for a hitpoint in P3 (pa = p2 + t*(p4 - p3))
	 @return bool 
		indicating successful intersection of a line
		note that to truly test intersection for segments we have to make 
		sure that s & t lie within [0..1] and for rays, make sure s & t > 0
		the hit point is		p3 + t * (p4 - p3);
		the hit point also is	p1 + s * (p2 - p1);
	 @since v0.99.1
	 */
	public static function lineIntersect (A:CGPoint, B:CGPoint, C:CGPoint, D:CGPoint, S:Float, T:Float) :LineIntersection
	{    
		// FAIL: Line undefined
		if ( (A.x==B.x && A.y==B.y) || (C.x==D.x && C.y==D.y) ) return {S:S, T:T, bool:false};
		
		var BAx:Float = B.x - A.x;
		var BAy:Float = B.y - A.y;
		var DCx:Float = D.x - C.x;
		var DCy:Float = D.y - C.y;
		var ACx:Float = A.x - C.x;
		var ACy:Float = A.y - C.y;
		
		var denom:Float = DCy*BAx - DCx*BAy;
		var b :Bool = false;
		
		S = DCx*ACy - DCy*ACx;
		T = BAx*ACy - BAy*ACx;

		if (denom == 0) {
			if (S == 0 || T == 0) { 
				// Lines incident
				b = true;   
			}
			else {
				// Lines parallel and not incident
				b = false;
			}
		}
		else {
			S = S / denom;
			T = T / denom;
		}

		// Point of intersection
		// P:CGPoint;
		// P.x = A.x + *S * (B.x - A.x);
		// P.y = A.y + *S * (B.y - A.y);

		return {S:S, T:T, bool:b};
	}
	
	/*
	 ccpSegmentIntersect returns YES if Segment A-B intersects with segment C-D
	 @since v1.0.0
	 */
	public static function segmentIntersect(A:CGPoint, B:CGPoint, C:CGPoint, D:CGPoint) :Bool
	{
		var S:Float = 0, T:Float = 0;
		var ST :LineIntersection = lineIntersect (A, B, C, D, S, T);
			S = ST.S;
			T = ST.T;
		if( ST.bool && (S >= 0.0 && S <= 1.0 && T >= 0.0 && T <= 1.0) )
			return true;

		return false;
	}
	
	/*
	 ccpIntersectPoint returns the intersection point of line A-B, C-D
	 @since v1.0.0
	 */
	public static function intersectPoint(A:CGPoint, B:CGPoint, C:CGPoint, D:CGPoint) :CGPoint
	{
		var S:Float=0, T:Float=0;
		var ST :LineIntersection = lineIntersect (A, B, C, D, S, T);
			S = ST.S;
			T = ST.T;
		if( ST.bool ) {
			// Point of intersection
			return new CGPoint (A.x + S * (B.x - A.x), A.y + S * (B.y - A.y));
		}

		return new CGPoint (0,0);
	}
	
	
	
	public static function equalToPoint (point:CGPoint, newPoint:CGPoint) :Bool {
		if (point.x == newPoint.x) if (point.y == newPoint.y) return true;
		return false;
	}
	public static function applyAffineTransform (point:CGPoint, t:CGAffineTransform) :CGPoint {
		return point;
	}
	public static function pointFromString (p:String) :CGPoint
	{
		var arr = p.split("{").join("").split("}").join("").split(",");
		return new CGPoint ( Std.parseInt(arr[0]), Std.parseInt(arr[1]) );
	}
	
}
