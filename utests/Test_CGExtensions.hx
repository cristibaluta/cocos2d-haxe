//
//  Test_NSDictionary
//
//  Created by Baluta Cristian on 2011-12-12.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
import cocos.support.CGPoint;
import cocos.support.CGSize;
import cocos.support.CGRect;
import cocos.support.CGPointExtension;
import cocos.support.CGSizeExtension;
import cocos.support.CGRectExtension;


class Test_CGExtensions extends haxe.unit.TestCase {
    
    public function testCGObjectFromString()
	{
		var r : CGRect = CGRectExtension.rectFromString("{{1,2},{3,4}}");
		assertTrue (r.origin.x == 1 && r.origin.y == 2 && r.size.width == 3 && r.size.height == 4);
		
		var p : CGPoint = CGPointExtension.pointFromString("{1,2}");
		assertTrue (p.x == 1 && p.y == 2);
		
		var s : CGSize = CGSizeExtension.sizeFromString("{3,4}");
		assertTrue (s.width == 3 && s.height == 4);
		
/*		print (r);
		print (p);
		print (s);*/
    }
}
