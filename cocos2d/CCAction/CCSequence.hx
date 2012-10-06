/** Runs actions sequentially, one after another
 */
class CCSequence extends CCActionInterval
{
	var actions_ :Array<CCFiniteTimeAction>;
	var split_ :Float;
	var last_ :Int;

/** helper contructor to create an array of sequenceable actions given an array */
public static function actions (actions:Array<CCFiniteTimeAction>) :CCFiniteTimeAction
{
	trace(actions.length);
	trace(actions[0]);
	trace(actions[1]);
	
	var now :CCFiniteTimeAction;
	var prev :CCFiniteTimeAction = actions[0];
	
	for (i in 1...actions.length)
		prev = actionOneTwo (prev, actions[i]);
	
	return prev;
}

/** creates the action */
public static function actionOneTwo (one:CCFiniteTimeAction, two:CCFiniteTimeAction) :CCSequence
{
	return new CCSequence().initOneTwo (one, two);
}


public function new () {
	super();
	actions_ = [];
}

/** initializes the action */
public function initOneTwo (one:CCFiniteTimeAction, two:CCFiniteTimeAction) :CCSequence
{
	if (one==null || two==null) throw "Sequence: arguments must be non-null";
	if (one==actions_[0] || one==actions_[1]) throw "Sequence: re-init using the same parameters is not supported";
	if (two==actions_[1] || two==actions_[0]) throw "Sequence: re-init using the same parameters is not supported";
		
	var d :Float = one.duration/1000 + two.duration/1000;trace(one.duration+", "+two.duration);
	
	super.initWithDuration(d);

	// XXX: Supports re-init without leaking. Fails if one==one_ || two==two_
/*	actions_[0].release();
	actions_[1].release();*/

	actions_[0] = one;
	actions_[1] = two;
	
	return this;
}


override public function release () :Void
{
	actions_[0].release();
	actions_[1].release();
	super.release();
}

override public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );	
	split_ = actions_[0].duration / duration;
	last_ = -1;
}

override public function stop () :Void
{
	actions_[0].stop();
	actions_[1].stop();
	super.stop();
}

override function update (t:Float) :Void
{
	var found :Int = 0;
	var new_t :Float = 0.0;
	
	if( t >= split_ ) {
		found = 1;
		if ( split_ == 1 )
			new_t = 1;
		else
			new_t = (t-split_) / (1 - split_ );
	} else {
		found = 0;
		if( split_ != 0 )
			new_t = t / split_;
		else
			new_t = 1;
	}
	
	if (last_ == -1 && found==1)	{
		actions_[0].startWithTarget ( target_ );
		actions_[0].update(1.0);
		actions_[0].stop();
	}

	if (last_ != found ) {
		if( last_ != -1 ) {
			actions_[last_].update(1.0);
			actions_[last_].stop();
		}
		actions_[found].startWithTarget ( target_ );
	}
	actions_[found].update(new_t);
	last_ = found;
}

override public function reverse () :CCFiniteTimeAction
{
	return CCSequence.actionOneTwo (actions_[1].reverse(), actions_[0].reverse());
}
}
