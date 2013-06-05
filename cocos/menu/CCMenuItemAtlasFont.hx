
package cocos.menu;

// -
// CCMenuItemAtlasFont

/** A CCMenuItemAtlasFont
 Helper class that creates a MenuItemLabel class with a LabelAtlas
 */
class CCMenuItemAtlasFont extends CCMenuItemLabel
{

/** creates a menu item from a string and atlas with a target/selector */
//public static function itemFromString: (String*) value charMapFile:(String*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap;

/** creates a menu item from a string and atlas. Use it with MenuItemToggle */
//public static function itemFromString: (String*) value charMapFile:(String*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb;

/** initializes a menu item from a string and atlas with a target/selector */
//public function initFromString: (String*) value charMapFile:(String*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb;

public static function itemFromString: (String*) value charMapFile:(String*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap
{
	return CCMenuItemAtlasFont.itemFromString ( value, charMapFile, itemWidth, itemHeight, startCharMap, null, null );
}

public static function itemFromString (value:String, charMapFile:String, itemWidth:Int, itemHeight:Int, startCharMap:String, target:Dynamic, selector:Dynamic)
{
	return new CCMenuItemAtlasFont().initFromString (value, charMapFile, itemWidth, itemHeight, startCharMap, target, selector);
}

public function initFromString (value:String, charMapFile:String, itemWidth:Int, itemHeight:Int, startCharMap:String, target:Dynamic, selector:Dynamic)
{
	if (value.length] != 0) throw "value length must be greater than 0";
	
	var label :CCLabelAtlas = new CCLabelAtlas().initWithString ( value, charMapFile, itemWidth, itemHeight, startCharMap );
	
	if (this == super.initWithLabel (label, target, selector)) {
		// do something ?
	}
	
	return this;
}

/*public function release () :Void
{
	super.release();
}*/
}