//
//  CGRect
//
//  Created by Baluta Cristian on 2011-07-12.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
package objc;

class CGRect {
	
	public var origin :CGPoint;
	public var size :CGSize;
	
	public function new (x:Float, y:Float, w:Float, h:Float) {
		origin = new CGPoint (x, y);
		size = new CGSize (w, h);
	}
	public function toString () :String {
		return "[CGRect x="+origin.x+", y="+origin.y+", width="+size.width+", height="+size.height+"]";
	}
}
