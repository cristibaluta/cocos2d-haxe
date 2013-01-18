//
//  CGPoint
//
//  Created by Baluta Cristian on 2011-07-12.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
package cocos.support;

class CGPoint {
	
	public var x :Float;
	public var y :Float;
	
	public function new (x:Float=0.0, y:Float=0.0) {
		this.x = x;
		this.y = y;
	}
	public function toString () :String {
		return "[CGPoint x="+x+", y="+y+"]";
	}
}
