//
//  CGAffineTransform
//
//  Created by Baluta Cristian on 2011-07-12.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
package objc;

#if flash
import flash.geom.Matrix;
#end

class CGAffineTransform {
	
	public var a : Float;
	public var b : Float;
	public var c : Float;
	public var d : Float;
	public var tx : Float;
	public var ty : Float;
	
	public function new ( ?a:Float=0, ?b:Float=0, ?c:Float=0, ?d:Float=0, ?tx:Float=0, ?ty:Float=0 ) {
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.tx = tx;
		this.ty = ty;
	}
	public function clone() : CGAffineTransform {
		return new CGAffineTransform (a, b, c, d, tx, ty);
	}
	public function concat( m : CGAffineTransform ) : Void {
		
	}
	public function identity() : CGAffineTransform {
		return this;
	}
	public function invert() : Void {
		
	}
	public function rotate( angle : Float ) : Void {
		
	}
	public function scale( sx : Float, sy : Float ) : Void {
		
	}
	public function setTo( aa : Float, ba : Float, ca : Float, da : Float, txa : Float, tya : Float ) : Void {
		
	}
	public function transformPoint( point : CGPoint ) : CGPoint {
		return point;
	}
	public function translate( dx : Float, dy : Float ) : Void {
		
	}
	
}