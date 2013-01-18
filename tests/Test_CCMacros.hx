//
//  Test_NSDictionary
//
//  Created by Baluta Cristian on 2011-12-12.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
import cocos.CCMacros;

class Test_CCMacros extends haxe.unit.TestCase {
	
	public function testMinus1_1(){
		var nr :Float;
		var mistakes = 0;
		for (i in 0...1000) {
			 nr = CCMacros.RANDOM_MINUS1_1();
			 if (nr < -1 || nr > 1)
				 mistakes ++;
		}
		
		assertTrue (mistakes == 0);
		
		//print("RANDOM_MINUS1_1 should return values under -1 1 interval only");
    }
	
	public function test0_1(){
		var nr :Float;
		var mistakes = 0;
		for (i in 0...1000) {
			 nr = CCMacros.RANDOM_0_1();
			 if (nr < -1 || nr > 1)
				 mistakes ++;
		}
		
		assertTrue (mistakes == 0);
    }
	
	public function testSwap(){
		
		var x = 1, y = 2;
		var obj = CCMacros.CC_SWAP(x, y);
		
		assertTrue (x==obj.y && y==obj.x);
    }
	
}
