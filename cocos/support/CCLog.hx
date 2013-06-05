package cocos.support;

class CCLog {
	
	static var lastMethod = "";
	static var ALLOW_TRACES_FROM = [
		"_CCScheduler",
		"_CCActionManager",
		"CCTimer",
		"_CCMoveTo",
		"_CCNode",
		"CCActionInstant",
		"_CCActionInterval",
		"cocos.action.CCSequence"];
	
	
	public static function redirectTraces () {
		
		#if !nme
			haxe.Log.trace = cocosTrace;
		#end
	}
	
	public static function cocosTrace (v : Dynamic, ?inf : haxe.PosInfos) : Void
	{
		if ( ALLOW_TRACES_FROM.length == 0 ) {
			_trace ( v, inf );
		}
		else for (c in ALLOW_TRACES_FROM) {
			if (c == inf.className.split(".").pop()) {
				_trace ( v, inf );
			}
		}
	}
	
	private static function _trace (v : Dynamic, ?inf : haxe.PosInfos) :Void
	{
		var line1 = (lastMethod == inf.methodName) ? "" : "\n";
		var fileInfo = line1 + inf.fileName + " : " + inf.methodName;
		
		#if flash
			if ((lastMethod != inf.methodName))
			flash.external.ExternalInterface.call ("console.log", fileInfo);
			flash.external.ExternalInterface.call ("console.log", inf.lineNumber + " :  " + Std.string(v));
		#elseif js
			if ((lastMethod != inf.methodName))
			untyped console.log (fileInfo);
			untyped console.log (inf.lineNumber + " :  " + Std.string(v));
		#end
		
		lastMethod = inf.methodName;
	}
}
