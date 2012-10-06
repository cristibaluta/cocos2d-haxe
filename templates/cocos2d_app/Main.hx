//
//  Main.hx
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

class Main
{
	public static function main () {
		
		#if !nme
			haxe.Log.trace = cocosTrace;
		#end
		
		var app = new Game_AppDelegate();
	}
	
	public static var ALLOW_TRACES_FROM = ["_CCScheduler", "_CCActionManager", "CCTimer", "_CCMoveTo", "_CCNode", "CCActionInstant", "_CCActionInterval", "CCSequence"];
	public static function cocosTrace (v : Dynamic, ?inf : haxe.PosInfos) : Void
	{
		var lastMethod = "";
		
		for (c in ALLOW_TRACES_FROM) {
			if (c == inf.className) {
				var newLineIn = (lastMethod != inf.methodName) ? "" : "\n--------------------";
				var newLineOut = (lastMethod != inf.methodName) ? "" : "\n\n";
				
				haxe.Firebug.trace (newLineIn+Std.string(v)+newLineOut, inf);
				
				lastMethod = inf.methodName;
			}
		}
	}
}
