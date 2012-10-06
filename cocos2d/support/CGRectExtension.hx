//
//  CGRectExtension
//
//  Created by Baluta Cristian on 2011-10-25.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
package support;

import objc.CGRect;
import objc.CGPoint;
import objc.CGAffineTransform;

class CGRectExtension
{
	public static function equalToRect (rect:CGRect, newRect:CGRect) :Bool
	{
		if (rect.origin.x != newRect.origin.x) return false;
		if (rect.origin.y != newRect.origin.y) return false;
		if (rect.size.width != newRect.size.width) return false;
		if (rect.size.height != newRect.size.height) return false;
		
		return true;
	}
	public static function rectFromString (p:String) :CGRect
	{
		var arr = p.split("{").join("").split("}").join("").split(",");
		return new CGRect ( Std.parseInt(arr[0]), Std.parseInt(arr[1]), Std.parseInt(arr[2]), Std.parseInt(arr[3]) );
	}
	public static function applyAffineTransform (r:CGRect, t:CGAffineTransform) {
		
	}
	
	public static function containsPoint (r:CGRect, p:CGPoint) :Bool
	{
		return (p.x >= r.origin.x &&
				p.x <= r.origin.x + r.size.width &&
				p.y >= r.origin.y &&
				p.y <= r.origin.y + r.size.height);
	}
	
}
