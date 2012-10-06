//
//  TestCases
//
//  Created by Baluta Cristian on 2011-12-12.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//

class Tests {
	
	static function main(){
		var r = new haxe.unit.TestRunner();
			r.add( new Test_NSDictionary() );
			r.add( new Test_UIImage() );
			r.add( new Test_CCMacros() );
			r.add( new Test_CGExtensions() );
			r.run();
	}
}
