//
//  FontTTF
//
//  Created by Baluta Cristian on 2011-12-11.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//

class Sample_LabelTTF extends flash.display.MovieClip {
	
	
	public function new(){
		super();
		try{
			var label :CCLabelTTF = CCLabelTTF.labelWithString ("Hello World", null,null,null, "Arial", 64);
			var size = new objc.CGSize (500, 500);
			label.position = new objc.CGPoint ( size.width/2, size.height/2 );
			//this.addChild ( label );
		}
		catch(e:Dynamic){
			trace(e);
			var stack = haxe.Stack.exceptionStack();
			trace ( haxe.Stack.toString ( stack ) );
		}
		trace("fin");
	}
	
	public static function main(){
		haxe.Firebug.redirectTraces();
		flash.Lib.current.addChild ( new Sample_LabelTTF() );
	}
}

