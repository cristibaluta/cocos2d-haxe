/** Fades an object that implements the CCRGBAProtocol protocol. It modifies the opacity from the current value to a custom one.
 @warning This action doesn't support "reverse"
 */
class CCFadeTo extends CCActionInterval
{
var toOpacity_ :Float;
var fromOpacity_ :Float;

/** creates an action with duration and opactiy */
public static function actionWithDuration (duration:Float, opacity:Float) :CCFadeTo
{
	var a = new CCFadeTo();
		a.initWithDurationAndOpacity (duration, opacity);
	return a;
}

/** initializes the action with duration and opacity */
public function initWithDurationAndOpacity (duration:Float, opacity:Float) :CCActionInterval
{
	super.initWithDuration(duration);
	toOpacity_ = opacity;
	
	return this;
}

override public function startWithTarget(aTarget:Dynamic)
{
	super.startWithTarget ( aTarget );
	fromOpacity_ = target_.opacity;//CCRGBAProtocol
}

override function update (t:Float) :Void
{
	target_.setOpacity (fromOpacity_ + ( toOpacity_ - fromOpacity_ ) * t);
}
}
