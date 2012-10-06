/** Flips the sprite vertically
 @since v0.99.0
 */
class CCFlipY extends CCActionInstant
{
	var flipY :Bool;
//
public static function actionWithFlipY ( y:Bool ) :CCFlipY
{
	return new CCFlipY().initWithFlipY ( y );
}

public function initWithFlipY ( y:Bool ) :CCFlipY
{
	super.init();
	flipY = y;
	
	return this;
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	cast (aTarget, CCSprite).setFlipY ( flipY );
}

public function reverse () :CCFiniteTimeAction
{
	return CCFlipY.actionWithFlipY ( !flipY );
}
}
