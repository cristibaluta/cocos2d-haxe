//
//  StringExtension
//
//  Created by Baluta Cristian on 2011-12-07.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
package support;

class StringExtension {
	
	public static function stringByDeletingLastPathComponent (s:String) :String {
		return s;
	}
	public static function stringByAppendingPathComponent (s:String, c:String) :String {
		return s+c;
	}
	public static function stringByAppendingPathExtension (s:String, ext:String) :String {
		return s+"/"+ext;
	}
	public static function stringByDeletingPathExtension (s:String) :String {
		return s;
	}
	
	public static function characterAtIndex (str:String, i:Int) :String {
		return str.substr (i, 1);
	}
}
