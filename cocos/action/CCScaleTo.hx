
package cocos.action;

/** Scales a CCNode object to a zoom factor by modifying it's scale attribute.
 @warning This action doesn't support "reverse"
 */
class CCScaleTo extends CCActionInterval
{
	var scaleX_ :Float;
	var scaleY_ :Float;
	var startScaleX_ :Float;
	var startScaleY_ :Float;
	var endScaleX_ :Float;
	var endScaleY_ :Float;
	var deltaX_ :Float;
	var deltaY_ :Float;
	

/** creates the action with the same scale factor for X and Y */
public static function actionWithDuration (t:Float, s:Float) :CCScaleTo
{
	return new CCScaleTo().initWithDurationAndScale (t, s);
}

public function initWithDurationAndScale (t:Float, s:Float) :CCScaleTo
{
	super.initWithDuration(t);
	
	endScaleX_ = s;
	endScaleY_ = s;
	
	return this;
}


/** creates the action with and X factor and a Y factor */
public static function  actionWithDurationSXY (t:Float, scaleX:Float, scaleY:Float) :CCScaleTo 
{
	return new CCScaleTo().initWithDurationSXY ( t, scaleX, scaleY );
}
/** initializes the action with and X factor and a Y factor */
public function initWithDurationSXY (t:Float, sx:Float, sy:Float) :CCScaleTo
{
	super.initWithDuration(t);
	
	endScaleX_ = sx;
	endScaleY_ = sy;
	
	return this;
}


override public function startWithTarget(aTarget:Dynamic)
{
	super.startWithTarget ( aTarget );
	
	startScaleX_ = target_.scaleX;
	startScaleY_ = target_.scaleY;
	deltaX_ = endScaleX_ - startScaleX_;
	deltaY_ = endScaleY_ - startScaleY_;
}

override function update (t:Float) :Void
{
	target_.setScaleX ( startScaleX_ + deltaX_ * t );
	target_.setScaleY ( startScaleY_ + deltaY_ * t );
}
}

