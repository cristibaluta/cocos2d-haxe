//
//  CCEventDispatcher
//
//  Created by Baluta Cristian on 2011-11-15.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
package platforms.flash;

class CCEventDispatcher {

public function new(){
	
}

public static function sharedDispatcher () :CCEventDispatcher {
	return new CCEventDispatcher();
}


public function setDispatchEvents (b:Bool) {
	
}

public function addMouseDelegate (target:Dynamic, func:Dynamic) {
	
}
public function removeMouseDelegate (target:Dynamic) {
	
}
public function addKeyboardDelegate (target:Dynamic, func:Dynamic) {
	
}
public function removeKeyboardDelegate (target:Dynamic) {
	
}
public function addTouchDelegate (target:Dynamic, func:Dynamic) {
	
}
public function removeTouchDelegate (target:Dynamic) {
	
}

}
