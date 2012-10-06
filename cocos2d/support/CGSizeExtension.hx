//
//  CGSizeExtension
//
//  Created by Baluta Cristian on 2011-11-09.
//  Copyright (c) 2011-2012 ralcr.com. All rights reserved.
//
package support;

import objc.CGSize;


class CGSizeExtension {

	public static function equalToSize (size:CGSize, newSize:CGSize) :Bool {
		if (size.width == newSize.width) if (size.height == newSize.height) return true;
		return false;
	}

	public static function sizeFromString (s:String) :CGSize
	{
		var arr = s.split("{").join("").split("}").join("").split(",");
		return new CGSize ( Std.parseInt(arr[0]), Std.parseInt(arr[1]) );
	}

}
