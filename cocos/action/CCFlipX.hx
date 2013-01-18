/** Flips the sprite horizontally
 @since v0.99.0
 */
package cocos.action;

class CCFlipX extends CCActionInstant
{
var flipX :Bool;

public static function actionWithFlipX ( x:Bool )
{
	return new CCFlipX().initWithFlipX ( x );
}

public function initWithFlipX ( x:Bool )
{
	super.init();
	flipX = x;
	
	return this;
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	cast(aTarget, CCSprite).setFlipX ( flipX );
}

public function reverse () :CCFiniteTimeAction
{
	return CCFlipX.actionWithFlipX ( !flipX );
}
}