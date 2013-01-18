
package cocos.menu;

// -
// CCMenuItemLabel

/** An abstract class for "label" CCMenuItemLabel items 
 Any CCNode that supports the CCLabelProtocol protocol can be added.
 Supported nodes:
   - CCLabelBMFont
   - CCLabelAtlas
   - CCLabelTTF
*/
import cocos.CCTypes;
import cocos.action.CCAction;
import cocos.action.CCScaleTo;
import cocos.support.CGPoint;


class CCMenuItemLabel extends CCMenuItem
{

var label_ :CCNode;
var colorBackup :CC_Color3B;
var disabledColor_ :CC_Color3B;
var originalScale_ :Float;

/** the color that will be used to disable the item */
//public var disabledColor (get_disabledColor, set_disabledColor) :CC_Color3B;

/** Label that is rendered. It can be any CCNode that implements the CCLabelProtocol */
public var label :CCNode;


/** creates a CCMenuItemLabel with a Label, target and selector */
public static function itemWithLabelTargetSelector (label:CCNode, target:Dynamic, selector:Dynamic ) :CCMenuItemLabel
{
	return new CCMenuItemLabel().initWithLabel (label, target, selector);
}

/** creates a CCMenuItemLabel with a Label. Target and selector will be nulll */
public static function itemWithLabel (label:CCNode) :CCMenuItemLabel
{
	return new CCMenuItemLabel().initWithLabel (label, null, null);
}

/** initializes a CCMenuItemLabel with a Label, target and selector */
public function initWithLabel (label:CCNode, target:Dynamic, selector:Dynamic) :CCMenuItemLabel
{
	super.initWithTarget (target, selector);
	
	originalScale_ = 1;
	colorBackup = CCTypes.ccWHITE;
	disabledColor_ = CCTypes.ccc3 ( 126,126,126);
	setLabel ( label );
	
	return this;
}


public function getLabel () :CCNode
{
	return label_;
}
public function setLabel (label:CCNode) :CCNode
{
	if( label != label_ ) {
		this.removeChild ( label_, true );
		this.addChild ( label );
		
		label_ = label;
		label_.anchorPoint = new CGPoint (0,0);

		this.setContentSize ( label_.contentSize );
	}
	return label;
}

/** sets a new string to the inner label */
public function setString (string:String)
{
	//label_.setString ( string );
	this.setContentSize ( label_.contentSize );
}

override public function activate ()
{
	if(isEnabled) {
		this.stopAllActions();
		this.scaleX = originalScale_;
		this.scaleY = originalScale_;
		super.activate();
	}
}

override public function selected ()
{
	// subclass to change the default action
	if(isEnabled) {	
		super.selected();

		var action :CCAction = this.getActionByTag ( CCMenuItem.kZoomActionTag );
		if( action != null )
			this.stopAction ( action );
		else
			originalScale_ = this.scaleX;

		var zoomAction :CCAction = CCScaleTo.actionWithDuration (0.1, originalScale_ * 1.2);
		zoomAction.tag = CCMenuItem.kZoomActionTag;
		this.runAction ( zoomAction );
	}
}

override public function unselected ()
{
	// subclass to change the default action
	if(isEnabled) {
		super.unselected();
		this.stopActionByTag ( CCMenuItem.kZoomActionTag );
		var zoomAction :CCAction = CCScaleTo.actionWithDuration (0.1, originalScale_);
		zoomAction.tag = CCMenuItem.kZoomActionTag;
		this.runAction ( zoomAction );
	}
}

/** Enable or disabled the CCMenuItemFont
 @warning setIsEnabled changes the RGB color of the font
 */
public function setIsEnabled ( enabled:Bool )
{
	if( isEnabled != enabled ) {
/*		if(enabled == false) {
			colorBackup = label_.color;
			label_.setColor ( disabledColor_ );
		}
		else
			label_.setColor ( colorBackup );*/
	}
    
	isEnabled = enabled;
}

public function setOpacity ( opacity:Float )
{
	//label_.setOpacity ( opacity );
}
public function opacity () :Float
{
	//return label_.opacity;
	return 1;
}
public function setColor ( color:CC_Color3B )
{
	//label_.setColor ( color );
}
public function color () :CC_Color3B
{
	//return label_.color;
	return null;
}
}
