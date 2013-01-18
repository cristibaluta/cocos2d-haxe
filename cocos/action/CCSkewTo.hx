/** Skews a CCNode object to given angles by modifying it's skewX and skewY attributes
 @since v1.0
 */
package cocos.action;

class CCSkewTo extends CCActionInterval
{
	var skewX_ :Float;
	var skewY_ :Float;
	var startSkewX_ :Float;
	var startSkewY_ :Float;
	var endSkewX_ :Float;
	var endSkewY_ :Float;
	var deltaX_ :Float;
	var deltaY_ :Float;

/** creates the action */
public function actionWithDuration (t:Float, sx:Float) :id skewY:(Float)sy;
/** initializes the action */
public function initWithDuration (t:Float, sx:Float) :id skewY:(Float)sy;
}
public function actionWithDuration (t:Float, sx:Float) :id skewY:(Float)sy 
{
	return new XXX().initWithDuration: t skewX:sx skewY:sy] autorelease];
}

public function initWithDuration (t:Float, sx:Float) :id skewY:(Float)sy 
{
	if( (this=super.initWithDuration:t]) ) {	
		endSkewX_ = sx;
		endSkewY_ = sy;
	}
	return this;
}


public function startWithTarget:(CCNode *)aTarget
{
	super.startWithTarget ( aTarget );
	
	startSkewX_ = target_.skewX;
	
	if (startSkewX_ > 0)
		startSkewX_ = fmodf(startSkewX_, 180.0);
	else
		startSkewX_ = fmodf(startSkewX_, -180.0);
	
	deltaX_ = endSkewX_ - startSkewX_;
	
	if ( deltaX_ > 180 ) {
		deltaX_ -= 360;
	}
	if ( deltaX_ < -180 ) {
		deltaX_ += 360;
	}
	
	startSkewY_ = target_.skewY;
		
	if (startSkewY_ > 0)
		startSkewY_ = fmodf(startSkewY_, 360.0);
	else
		startSkewY_ = fmodf(startSkewY_, -360.0);
	
	deltaY_ = endSkewY_ - startSkewY_;
	
	if ( deltaY_ > 180 ) {
		deltaY_ -= 360;
	}
	if ( deltaY_ < -180 ) {
		deltaY_ += 360;
	}
}

function update (t:Float) :Void
{
	target_.setSkewX: (startSkewX_ + deltaX_ * t ) ];
	target_.setSkewY: (startSkewY_ + deltaY_ * t ) ];
}

}
