/** Base class for Easing actions with rate parameters
 */
class CCEaseRateAction extends  CCActionEase
{
var rate :Float;

/** rate value for the actions */
public var rate (get_rate, set_rate) :Float;
/** Creates the action with the inner action and the rate parameter */
public static function  actionWithAction: (CCActionInterval*) action rate:(Float)rate;
/** Initializes the action with the inner action and the rate parameter */
public function initWithAction (action:CCActionInterval) :id rate:(Float)rate;

public var rate (get_rate, set_rate) :;
public static function  actionWithAction: (CCActionInterval*) action rate ( aRate:Float )
{
	return new XXX().initWithAction: action rate:aRate] autorelease ];
}

public function initWithAction (action:CCActionInterval) :id rate ( aRate:Float )
{
	if( (this=super.initWithAction:action ]) )
		this.rate = aRate;
	
	return this;
}

public function release () :Void
{
	super.release();
}

public function reverse () :CCActionInterval
{
	return [this.class] actionWithAction: other.reverse] rate:1/rate];
}

}
