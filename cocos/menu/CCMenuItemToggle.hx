
package cocos.menu;

/** A CCMenuItemToggle
 A simple container class that "toggles" it's inner items
 The inner itmes can be any MenuItem
 */
class CCMenuItemToggle extends CCMenuItem
{
var selectedIndex_ :Int;
var subItems_ :Array<CCMenuItem>;
var opacity_ :Float;
var color_ :CC_Color3B;

/** conforms with CCRGBAProtocol protocol */
public var opacity (get_opacity, null) :Float;
/** conforms with CCRGBAProtocol protocol */
public var color (get_color, null) :CC_Color3B;
/** returns the selected item */
public var selectedIndex (get_selectedIndex, set_selectedIndex) :Int;
/** Array<> that contains the subitems. You can add/remove items in runtime, and you can replace the array with a new one.
 @since v0.7.2
 */
public var subItems (get_subItems, set_subItems) :Array<>;

/** creates a menu item from a list of items with a target/selector */
public static function itemWithTarget (t:Dynamic, sel:Dynamic, items:Array<CCMenuItem>) 
{
	return new CCMenuItemToggle().initWithTarget (t, sel, items);
}

/** initializes a menu item from a list of items with a target selector */
public static function initWithTarget (t:Dynamic, sel:Dynamic, items:Array<CCMenuItem>) 
{
	super.initWithTarget (t, sel);
	
	this.subItems = Array<>.arrayWithCapacity ( 2 );
	
	var z :Int = 0;
	var i :CCMenuItem = item;
	while(i) {
		z++;
		subItems_.push ( i );
		i = va_arg(args, CCMenuItem*);
	}
	
	selectedIndex_ = IntMax;
	this.setSelectedIndex ( 0 );
	
	return this;
}

public function release () :Void
{
	subItems_.release();
	super.release();
}

public function setSelectedIndex ( index:Int )
{
	if( index != selectedIndex_ ) {
		selectedIndex_ = index;
		this.removeChildByTag ( kCurrentItem, false );
		
		var item :CCMenuItem = subItems_.objectAtIndex ( selectedIndex_ );
		this.addChild ( item, 0, kCurrentItem );
		
		var s :CGSize = item.contentSize;
		this.setContentSize: s];
		item.position = new CGPoint ( s.width/2, s.height/2 );
	}
}

public function selectedIndex () :Int
{
	return selectedIndex_;
}


public function selected ()
{
	super.selected();
	subItems_.objectAtIndex ( selectedIndex_ ).selected;
}

public function unselected ()
{
	super.unselected();
	subItems_.objectAtIndex ( selectedIndex_ ).unselected;
}

public function activate ()
{
	// update index
	if( isEnabled_ ) {
		var newIndex :Int = (selectedIndex_ + 1) % subItems_.count;
		this.setSelectedIndex ( newIndex );

	}

	super.activate();
}

public function setIsEnabled ( enabled:Bool )
{
	super.setIsEnabled ( enabled );
	for(CCMenuItem* item in subItems_)
		item.setIsEnabled ( enabled );
}

public function selectedItem () :CCMenuItem
{
	return subItems_.objectAtIndex ( selectedIndex_ );
}

// CCMenuItemToggle - CCRGBAProtocol protocol

public function setOpacity ( opacity:Float )
{
	opacity_ = opacity;
	for(CCMenuItem<CCRGBAProtocol>* item in subItems_)
		item.setOpacity ( opacity );
}

public function setColor ( color:CC_Color3B )
{
	color_ = color;
	for(item in subItems_)
		item.setColor ( color );
}
}
