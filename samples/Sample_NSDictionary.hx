//
//  NSDictionarySample
//
//  Created by Baluta Cristian on 2011-12-09.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
import objc.NSDictionary;

class Sample_NSDictionary {
	
	
	public function new(){
		var plist = haxe.Resource.getString("plist");
		
		var dict = NSDictionary.dictionaryWithContentsOfFile ( plist );
		
		trace(dict.allKeys());
		trace(dict.count);
		trace(dict.valueForKey("d"));
	}
	
	public static function main(){
		haxe.Firebug.redirectTraces();
		new Sample_NSDictionary();
	}
}
