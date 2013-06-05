/**  Rotates a CCNode object to a certain angle by modifying it's
 rotation attribute.
 The direction will be decided by the shortest angle.
*/ 
class CCRotateTo extends CCActionInterval
{
	var dstAngle_ :Float;
	var startAngle_ :Float;
	var diffAngle_ :Float;
}
/** creates the action */
public function actionWithDuration (duration:Float, angle:Float) :id;
/** initializes the action */
public function initWithDuration (duration:Float, angle:Float) :id;
}

public function actionWithDuration (t:Float, a:Float) :id
{	
	return new XXX().initWithDuration:t angle:a ] autorelease];
}

public function initWithDuration (t:Float, a:Float) :id
{
	if( (this=super.initWithDuration: t]) )
		dstAngle_ = a;
	
	return this;
}


public function startWithTarget:(CCNode *)aTarget
{
	super.startWithTarget ( aTarget );
	
	startAngle_ = target_.rotation;
	if (startAngle_ > 0)
		startAngle_ = fmodf(startAngle_, 360.0);
	else
		startAngle_ = fmodf(startAngle_, -360.0);
	
	diffAngle_ =dstAngle_ - startAngle_;
	if (diffAngle_ > 180)
		diffAngle_ -= 360;
	if (diffAngle_ < -180)
		diffAngle_ += 360;
}
function update (t:Float) :Void
{
	target_.set_rotation: startAngle_ + diffAngle_ * t];
}
}
