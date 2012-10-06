// -
// CCMenuItemImage

/** CCMenuItemImage accepts images as items.
 The images has 3 different states:
 - unselected image
 - selected image
 - disabled image

 For best results try that all images are of the same size
 */
class CCMenuItemImage extends CCMenuItemSprite
{

/** creates a menu item with a normal and selected image*/
public static function itemFromNormalImage: (String*)value selectedImage:(String*) value2;
/** creates a menu item with a normal and selected image with target/selector */
public static function itemFromNormalImage: (String*)value selectedImage:(String*) value2 target:(id) r selector:(SEL) s;
/** creates a menu item with a normal,selected  and disabled image with target/selector */
public static function itemFromNormalImage: (String*)value selectedImage:(String*) value2 disabledImage:(String*) value3 target:(id) r selector:(SEL) s;
/** initializes a menu item with a normal, selected  and disabled image with target/selector */
public function initFromNormalImage: (String*) value selectedImage:(String*)value2 disabledImage:(String*) value3 target:(id) r selector:(SEL) s;

public static function itemFromNormalImage: (String*)value selectedImage:(String*) value2
{
	return this.itemFromNormalImage:value selectedImage:value2 disabledImage ( null, null, null );
}

public static function itemFromNormalImage: (String*)value selectedImage:(String*) value2 target:(id) t selector:(SEL) s
{
	return this.itemFromNormalImage:value selectedImage:value2 disabledImage ( null, t, s );
}

public static function itemFromNormalImage: (String*)value selectedImage:(String*) value2 disabledImage: (String*) value3
{
	return new XXX().initFromNormalImage:value selectedImage:value2 disabledImage:value3 target:null selector:null] autorelease];
}

public static function itemFromNormalImage: (String*)value selectedImage:(String*) value2 disabledImage: (String*) value3 target:(id) t selector:(SEL) s
{
	return new XXX().initFromNormalImage:value selectedImage:value2 disabledImage:value3 target:t selector:s] autorelease];
}

public function initFromNormalImage: (String*) normalI selectedImage:(String*)selectedI disabledImage: (String*) disabledI target:(id)t selector ( sel:Dynamic )
{
	CCNode<CCRGBAProtocol> *normalImage = CCSprite.spriteWithFile ( normalI );
	CCNode<CCRGBAProtocol> *selectedImage = null;
	CCNode<CCRGBAProtocol> *disabledImage = null;

	if( selectedI )
		selectedImage = CCSprite.spriteWithFile ( selectedI ); 
	if(disabledI)
		disabledImage = CCSprite.spriteWithFile ( disabledI );

	return this.initFromNormalSprite ( normalImage, selectedImage, disabledImage, t, sel );
}

}