
package cocos.menu;

// -
// CCMenuItemSprite

/** CCMenuItemSprite accepts CCNode<CCRGBAProtocol> objects as items.
 The images has 3 different states:
 - unselected image
 - selected image
 - disabled image

 @since v0.8.0
 */
class CCMenuItemSprite extends CCMenuItem
{
var normalImage_ :CCNode;
var selectedImage_ :CCNode;
var disabledImage_ :CCNode;

// weak references

/** the image used when the item is not selected */
@property (nonatomic,readwrite,assign) CCNode<CCRGBAProtocol> *normalImage;
/** the image used when the item is selected */
@property (nonatomic,readwrite,assign) CCNode<CCRGBAProtocol> *selectedImage;
/** the image used when the item is disabled */
@property (nonatomic,readwrite,assign) CCNode<CCRGBAProtocol> *disabledImage;

/** creates a menu item with a normal and selected image*/
public static function itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite;
/** creates a menu item with a normal and selected image with target/selector */
public static function itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target (target:Dynamic) selector:(SEL)selector;
/** creates a menu item with a normal,selected  and disabled image with target/selector */
public static function itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target (target:Dynamic) selector:(SEL)selector;
/** initializes a menu item with a normal, selected  and disabled image with target/selector */
public function initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target (target:Dynamic) selector:(SEL)selector;

public var normalImage (get_normalImage, set_normalImage) :, selectedImage=selectedImage_, disabledImage=disabledImage_;

public static function itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite
{
	return this.itemFromNormalSprite ( normalSprite, selectedSprite, null, null, null );
}
public static function itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target (target:Dynamic) selector ( selector:Dynamic )
{
	return this.itemFromNormalSprite ( normalSprite, selectedSprite, null, target, selector );
}
public static function itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target (target:Dynamic) selector ( selector:Dynamic )
{
	return new XXX().initFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector] autorelease];
}
public function initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target (target:Dynamic) selector ( selector:Dynamic )
{
	if( (this=super.initWithTarget:target selector:selector]) ) {
		
		this.normalImage = normalSprite;
		this.selectedImage = selectedSprite;
		this.disabledImage = disabledSprite;
		
		this.setContentSize: normalImage_.contentSize]];
	}
	return this;	
}


public function setNormalImage (image:CCNode)
{
	if( image != normalImage_ ) {
		image.anchorPoint = new CGPoint (0,0);
		image.visible = true;
		
		this.removeChild ( normalImage_, true );
		this.addChild ( image );
		
		normalImage_ = image;
	}
}

public function setSelectedImage (image:CCNode)
{
	if( image != selectedImage_ ) {
		image.anchorPoint = new CGPoint (0,0);
		image.visible = false;
		
		this.removeChild ( selectedImage_, true );
		this.addChild ( image );
		
		selectedImage_ = image;
	}
}

public function setDisabledImage (image:CCNode)
{
	if( image != disabledImage_ ) {
		image.anchorPoint = new CGPoint (0,0);
		image.visible = false;
		
		this.removeChild ( disabledImage_, true );
		this.addChild ( image );
		
		disabledImage_ = image;
	}
}

// CCMenuItemImage - CCRGBAProtocol protocol
public function setOpacity ( opacity:Float )
{
	normalImage_.setOpacity ( opacity );
	selectedImage_.setOpacity ( opacity );
	disabledImage_.setOpacity ( opacity );
}

public function setColor ( color:CC_Color3B )
{
	normalImage_.setColor ( color );
	selectedImage_.setColor ( color );
	disabledImage_.setColor ( color );	
}

public function opacity () :Float
{
	return normalImage_.opacity;
}

public function color () :CC_Color3B
{
	return normalImage_.color;
}

public function selected ()
{
	super.selected();

	if( selectedImage_ ) {
		normalImage_.setVisible ( false );
		selectedImage_.setVisible ( true );
		disabledImage_.setVisible ( false );
		
	} else { // there is not selected image
	
		normalImage_.setVisible ( true );
		selectedImage_.setVisible ( false );
		disabledImage_.setVisible ( false );		
	}
}

public function unselected ()
{
	super.unselected();
	normalImage_.setVisible ( true );
	selectedImage_.setVisible ( false );
	disabledImage_.setVisible ( false );
}

public function setIsEnabled ( enabled:Bool )
{
	super.setIsEnabled ( enabled );

	if( enabled ) {
		normalImage_.setVisible ( true );
		selectedImage_.setVisible ( false );
		disabledImage_.setVisible ( false );

	} else {
		if( disabledImage_ ) {
			normalImage_.setVisible ( false );
			selectedImage_.setVisible ( false );
			disabledImage_.setVisible ( true );		
		} else {
			normalImage_.setVisible ( true );
			selectedImage_.setVisible ( false );
			disabledImage_.setVisible ( false );
		}
	}
}

}