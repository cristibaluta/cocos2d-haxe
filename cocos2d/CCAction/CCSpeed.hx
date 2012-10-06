/** Changes the speed of an action, making it take longer (speed>1)
 or less (speed<1) time.
 Useful to simulate 'slow motion' or 'fast forward' effect.
 @warning This action can't be Sequenceable because it is not an CCIntervalAction
 */
class CCSpeed extends CCAction
{
var innerAction_ :CCActionInterval;
var speed_ :Float;

/** alter the speed of the inner function in runtime */
public var speed (get_speed, set_speed) :Float;
public var innerAction (get_, set_) :CCActionInterval;


public static function actionWithAction (action:CCActionInterval, rate:Float)
{
	return new CCSpeed().initWithAction (action, rate);
}

public function initWithAction (action:CCActionInterval, r:Float)
{
	super.init();
	this.innerAction = action;
	speed_ = r;
	
	return this;
}


/*public function copyWithZone (zone:NSZone) :id
{
	var  copy :CCAction = [[this.class] allocWithZone: zone] initWithAction:[innerAction_.copy] autorelease] speed ( speed_ );
    return copy;
}*/

public function release () :Void
{
	innerAction_.release();
	super.release();
}

public function startWithTarget (aTarget:Dynamic) :Void
{
	super.startWithTarget ( aTarget );
	innerAction_.startWithTarget ( target_ );
}

public function stop () :Void
{
	innerAction_.stop();
	super.stop();
}

public function step (dt:Float) :Void
{
	innerAction_.step (dt * speed_);
}

public function isDone () :Bool
{
	return innerAction_.isDone();
}

public function reverse () :CCActionInterval
{
	return CCSpeed.actionWithAction (innerAction_.reverse(), speed_);
}
}
