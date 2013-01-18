/** Executes an action in reverse order, from time=duration to time=0

 @warning Use this action carefully. This action is not
 sequenceable. Use it as the default "reversed" method
 of your own actions, but using it outside the "reversed"
 scope is not recommended.
*/
package cocos.action;

class CCReverseTime extends CCActionInterval
{
var other_ :CCFiniteTimeAction;


/** creates the action */
public static function actionWithAction (action:CCFiniteTimeAction) :CCFiniteTimeAction
{
	// casting to prevent warnings
	return new CCReverseTime().initWithAction ( action );
}

/** initializes the action */
public function initWithAction (action:CCFiniteTimeAction) :CCFiniteTimeAction
{
	if (action == null) throw "CCReverseTime: action should not be null";
	if (action == other_) throw "CCReverseTime: re-init doesn't support using the same arguments";

	super.initWithDuration ( action.duration );
	// Don't leak if action is reused
	//other_.release();
	other_ = action;
	
	return this;
}


override public function release () :Void
{
	other_.release();
	super.release();
}

override public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	other_.startWithTarget ( target_ );
}

override public function stop () :Void
{
	other_.stop();
	super.stop();
}

override function update ( t:Float )
{
	other_.update ( 1-t );
}

override public function reverse () :CCFiniteTimeAction
{
	return cast other_.reverse();
}
}
