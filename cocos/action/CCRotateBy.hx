/** Rotates a CCNode object clockwise a number of degrees by modiying it's rotation attribute.
*/
class CCRotateBy extends CCActionInterval
{
	var angle_ :Float;
	var startAngle_ :Float;
}
/** creates the action */
public function actionWithDuration (duration:Float, deltaAngle:Float) :id;
/** initializes the action */
public function initWithDuration (duration:Float, deltaAngle:Float) :id;
}
public function actionWithDuration (t:Float, a:Float) :id
{	
	return new XXX().initWithDuration:t angle:a ] autorelease];
}

public function initWithDuration (t:Float, a:Float) :id
{
	if( (this=super.initWithDuration: t]) )
		angle_ = a;
	
	return this;
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	startAngle_ = target_.rotation;
}

function update (t:Float) :Void
{	
	// XXX: shall I add % 360
	target_.set_rotation: (startAngle_ +angle_ * t );
}

public function reverse () :CCActionInterval
{
	return [this.class] actionWithDuration:duration_ angle:-angle_];
}

}