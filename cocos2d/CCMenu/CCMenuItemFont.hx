// -
// CCMenuItemFont

/** A CCMenuItemFont
 Helper class that creates a CCMenuItemLabel class with a Label
 */
class CCMenuItemFont extends CCMenuItemLabel
{
	var fontSize_ :Int;
	var  fontName_ :String;
}
/** set default font size */
+(void) setFontSize: (Int) s;

/** get default font size */
+(Int) fontSize;

/** set default font name */
+(void) setFontName: (String*) n;

/** get default font name */
+(String*) fontName;

/** creates a menu item from a string without target/selector. To be used with CCMenuItemToggle */
public static function itemFromString: (String*) value;

/** creates a menu item from a string with a target/selector */
public static function itemFromString: (String*) value target:(id) r selector:(SEL) s;

/** initializes a menu item from a string with a target/selector */
public function initFromString: (String*) value target:(id) r selector:(SEL) s;

/** set font size */
public function setFontSize: (Int) s;

/** get font size */
-(Int) fontSize;

/** set the font name */
public function setFontName: (String*) n;

/** get the font name */
-(String*) fontName;

+(void) setFontSize ( s:Int )
{
	_fontSize = s;
}

+(Int) fontSize
{
	return _fontSize;
}

+(void) setFontName: (String*) n
{
	if( _fontNameRelease )
		_fontName.release();
	
	_fontName = n.retain;
	_fontNameRelease = true;
}

+(String*) fontName
{
	return _fontName;
}

public static function itemFromString: (String*) value target:(id) r selector:(SEL) s
{
	return new XXX().initFromString: value target:r selector:s] autorelease];
}

public static function itemFromString: (String*) value
{
	return new XXX().initFromString: value target:null selector:null] autorelease];
}

public function initFromString: (String*) value target:(id) rec selector:(SEL) cb
{
	if (value.length] != 0) throw "Value length must be greater than 0";
	
	fontName_ = _fontName.copy;
	fontSize_ = _fontSize;
	
	var label :CCLabelTTF = CCLabelTTF.labelWithString ( value, fontName_, fontSize_ );

	if((this=super.initWithLabel:label target:rec selector:cb]) ) {
		// do something ?
	}
	
	return this;
}

public function recreateLabel ()
{
	var label :CCLabelTTF = CCLabelTTF.labelWithString (label_.string, fontName_, fontSize_);
	this.label = label;
}

public function setFontSize ( size:Int )
{
	fontSize_ = size;
	this.recreateLabel();
}

public function fontSize () :Int
{
	return fontSize_;
}

public function setFontName (fontName:String) 
{
	if (fontName_)
		fontName_.release();

	fontName_ = fontName.copy;
	this.recreateLabel();
}

public function fontName () :String
{
	return fontName_;
}

}