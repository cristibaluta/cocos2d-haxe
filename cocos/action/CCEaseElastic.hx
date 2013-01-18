//
// EaseElastic
//
class CCEaseElastic extends CCActionEase
{
/** period of the wave in radians. default is 0.3 */
public var period :Float;


/** Creates the action with the inner action and the period in radians (default is 0.3) */
public static function actionWithAction (action:CCActionInterval, ?period:Float) :CCEaseElastic
{
	return new CCEaseElastic().initWithAction (action, period);
}

/** Initializes the action with the inner action and the period in radians (default is 0.3) */
public function initWithAction (action:CCActionInterval, ?period:Float=0.3) :CCEaseElastic
{
	super.initWithAction(action);
	this.period = period;
	
	return this;
}

public function reverse () :CCActionInterval
{
	throw "Override me";
	return null;
}

}
