//
//  Sample_CCMacros
//
//  Created by Baluta Cristian on 2012.
//  Copyright (c) 2012 ralcr.com. All rights reserved.
//

class Sample_CCMacros {
	
	
	public function new(){
		
		var nr :Float;
		var mistakes = 0;
		for (i in 0...1000) {
			 nr = CCMacros.RANDOM_MINUS1_1();
			 if (nr < -1 || nr > 1) {
				 trace ( nr );
				 mistakes ++;
			 }
		}
		trace (mistakes+" values from 1000 are not in the range -1_1");
		
		mistakes = 0;
		for (i in 0...1000) {
			 nr = CCMacros.RANDOM_0_1();
			 if (nr < 0 || nr > 1) {
				 trace ( nr );
				 mistakes ++;
			 }
		}
		trace (mistakes+" values from 1000 are not in the range 0_1");
		
		var x = 1, y = 2;
		trace("Values before swap "+x+", "+y);
		var obj = CCMacros.CC_SWAP(x, y);
		x = obj.x;
		y = obj.y;
		trace("Values after swap "+x+", "+y);
	}
	
	public static function main(){
		haxe.Firebug.redirectTraces();
		new Sample_CCMacros ();
	}
}

