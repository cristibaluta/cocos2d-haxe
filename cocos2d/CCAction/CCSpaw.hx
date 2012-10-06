/** Spawn a new action immediately
 */
class CCSpawn extends CCActionInterval
{
	var one_ :CCFiniteTimeAction;
	var two_ :CCFiniteTimeAction;
}
/** helper constructor to create an array of spawned actions */
public static function  actions: (CCFiniteTimeAction*) action1, ... NS_REQUIRES_NIL_TERMINATION;
/** helper contructor to create an array of spawned actions given an array */
public static function  actionsWithArray: (NSArray*) actions;
/** creates the Spawn action */
public static function  actionOne: (CCFiniteTimeAction*) one two:(CCFiniteTimeAction*) two;
/** initializes the Spawn action with the 2 actions to spawn */
public function initOne (one:CCFiniteTimeAction, two:CCFiniteTimeAction) :id;
}

public static function actions (action1:CCFiniteTimeAction)
{
	va_list params;
	va_start(params,action1);
	
	var now :CCFiniteTimeAction;
	var prev :CCFiniteTimeAction = action1;
	
	while( action1 ) {
		now = va_arg(params,CCFiniteTimeAction*);
		if ( now )
			prev = this.actionOne: prev two: now];
		else
			break;
	}
	va_end(params);
	return prev;
}

public static function actionsWithArray (actions:Array) :CCFiniteTimeAction
{
	var prev :CCFiniteTimeAction = actions[0];
	
	for (i in 1...actions.count)
	prev = this.actionOne (prev, actions[i];
	
	return prev;
}

public static function actionOne (one:CCFiniteTimeAction, two:CCFiniteTimeAction)
{	
	return new CCSpaw().initOne (one, two);
}

public function initOne (one:CCFiniteTimeAction, two:CCFiniteTimeAction)
{
	if (one!=null && two!=null) throw "Spawn: arguments must be non-null";
	if (one!=one_ && one!=two_) throw "Spawn: reinit using same parameters is not supported";
	if (two!=two_ && two!=one_) throw "Spawn: reinit using same parameters is not supported";

	var d1 = one.duration;
	var d2 = two.duration;	
	
	if( (this=super.initWithDuration: Math.max(d1,d2)] ) ) {

		// XXX: Supports re-init without leaking. Fails if one==one_ || two==two_
		one_.release();
		two_.release();

		one_ = one;
		two_ = two;

		if( d1 > d2 )
			two_ = CCSequence.actionOne (two, CCDelayTime.actionWithDuration (d1-d2));
		else if( d1 < d2)
			one_ = CCSequence.actionOne (one, CCDelayTime.actionWithDuration (d2-d1));
	}
	return this;
}

public function release () :Void
{
	one_.release();
	two_.release();
	super.release();
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	one_.startWithTarget ( target_ );
	two_.startWithTarget ( target_ );
}

public function stop () :Void
{
	one_.stop();
	two_.stop();
	super.stop();
}

function update (t:Float) :Void
{
	one_.update ( t );
	two_.update ( t );
}

public function reverse ():CCActionInterval
{
	return CCSpaw.actionOne (one_.reverse(), two_.reverse());
}

}
