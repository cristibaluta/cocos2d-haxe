package objc;

class NSDictionary
{
	var hash_ :Hash<Dynamic>;
	var data_ :Hash<Dynamic>;
	public var count (getLength, null) :Int;
	
	/**
	 *  Initialization of a NSDictionary
	 **/
	public static function dictionary () :NSDictionary {
		return new NSDictionary();
	}
	public static function dictionaryWithContentsOfFile (path:String) :NSDictionary {
		var dict = new NSDictionary();
			dict.parse ( Xml.parse(path).firstElement() );
		return dict;
	}
	public static function dictionaryWithDictionary (dic:NSDictionary) :NSDictionary {
		var dict = new NSDictionary();
		return dict;
	}
	public static function dictionaryWithObject (obj:Dynamic, key:String) :NSDictionary {
		var dic = new NSDictionary();
		dic.setObject (obj, key);
		return dic;
	}
	public static function dictionaryWithObjects (obj:Array<Dynamic>, key:Array<String>) :NSDictionary {
		var dic = new NSDictionary();
		for (i in 0...key.length)
			dic.setObject (obj[i], key[i]);
		return dic;
	}
	
	
	
	public function new () {
		hash_ = new Hash<Dynamic>();
	}
	public function release () {
		hash_ = null;
	}
	
	
	/**
	 *  Parser
	 **/
	function parse ( xmlPlist:Xml ) {
		
		for (element in xmlPlist.elements()) {
			if (element.nodeName == "array") {
				hash_ = parseArray( element );
			}
			else if ( element.nodeName == "dict" ) {
				hash_ = parseDictionary( element );
			}
		}
	}
	function parseDictionary( xmlDict:Xml ) :Hash<Dynamic> {
		
		var h = new Hash<Dynamic>();
		var key :String = null;
		
		for (element in xmlDict.elements()) {
			if (key == null && element.nodeName == "key" ) {						
				key = element.firstChild().toString();
			}
			else {
				switch ( element.nodeName ) {
					case "dict": h.set (key, parseDictionary (element));
					case "array": h.set (key, parseArray (element));
					case "string": h.set (key, element.firstChild().toString());
					case "integer": h.set (key, Std.parseInt(element.firstChild().toString()));
					case "real": h.set (key, Std.parseFloat(element.firstChild().toString()));
					case "data": h.set (key, element.firstChild());
					case "date": 
						var d = element.firstChild().toString();
							d = StringTools.replace(d, "T", " ");
							d = StringTools.replace(d, "Z", "");
						h.set (key, Date.fromString(d));
				}
				key = null;
			}
		}
		//trace(h);
		return h;
	}
	function parseArray (dictArr:Xml) :Hash<Dynamic> {
		return parseDictionary ( dictArr );
	}
	
	
	function getLength () :Int {
		var keys = hash_.keys();
		var len = 0;
		for (key in keys)
			len ++;
		return len;
	}
	
	
	/**
	 *  Apple NSDictionary API
	 **/
	public function valueForKey (key:String) :Dynamic
	{
		return hash_.get(key);
	}
	public function objectForKey (key:String) :Dynamic
	{
		return hash_.get(key);
	}
	
	public function allKeys () :Array<String>
	{
		var keys = new Array<String>();
		for (key in keyEnumerator())
			keys.push ( key );
		return keys;
	}
	public function keyEnumerator () :Iterator<String> {
		return hash_.keys();
	}
	public function iterator () :Iterator<String> {
		return hash_.keys();
	}
	public function allKeysForObject (anObject:Dynamic) :Array<String>
	{
		return [];
	}
	public function allValues () :Array<Dynamic>
	{
		var objs = new Array<Dynamic>();
		for (obj in objectEnumerator())
			objs.push ( obj );
		return objs;
	}
	public function objectEnumerator () :Iterator<Dynamic> {
		return hash_.iterator();
	}
	
	public function isEqualToDictionary (otherDictionary:NSDictionary) :Bool {
		return this == otherDictionary;
	}
	
	
	/**
	 *  Mutable operations
	 **/
	
	public function setValue (value:Dynamic, key:String) :Void
	{
		hash_.set (key, value);
	}
	public function setObject (value:Dynamic, key:String) :Void
	{
		hash_.set (key, value);
	}
	public function removeObjectForKey (key:String)
	{
		hash_.remove (key);
	}
	public function removeObjectsForKeys (keys:Array<String>)
	{
		for (key in keys)
			removeObjectForKey ( key );
	}
	public function removeAllObjects ()
	{
		hash_ = new Hash<Dynamic>();
	}
}


/*typedef TString = {
	var key :String;
	var value :String;
}
typedef TNumber = {
	var key :String;
	var value :Float;
	var floatValue :Float;
	var intValue :Int;
}
typedef TDate = {
	var key :String;
	var value :Date;
}
typedef TData = {
	var key :String;
	var value :Dynamic;
}
typedef TBoolean = {
	var key :String;
	var value :Bool;
}
typedef TDictionary = {
	var key :String;
	var value :Array<T>;
}
typedef TArray = {
	var key :String;
	var value :Array<T>;
}
enum T {
	TString;
	TNumber;
	TDate;
	TData;
	TBoolean;
	TDictionary;
	TArray;
}
*/