
/** Repeats an action a number of times.
 * To repeat an action forever use the CCRepeatForever action.
 */
package cocos.action;

class CCRepeat extends CCActionInterval
{
	var times_ :Int;
	var total_ :Int;
	var innerAction_ :CCFiniteTimeAction;
}

/** Inner action */
public var innerAction (get_innerAction, set_innerAction) :CCFiniteTimeAction;

/** creates a CCRepeat action. Times is an integer between 1 and MAX_UINT */
public static function  actionWithAction:(CCFiniteTimeAction*)action times: (Int)times;
/** initializes a CCRepeat action. Times is an integer between 1 and MAX_UINT */
public function initWithAction (action:CCFiniteTimeAction, times:Int) :CCRepeat;


public var innerAction (get_innerAction, set_innerAction) :;

public static function  actionWithAction:(CCFiniteTimeAction*)action times ( times:Int )
{
	return new XXX().initWithAction:action times:times] autorelease];
}

public function initWithAction (action:CCFiniteTimeAction, times:Int) :id
{
	var d :Float = action.duration] * times;

	if( (this=super.initWithDuration: d ]) ) {
		times_ = times;
		this.innerAction = action;

		total_ = 0;
	}
	return this;
}

public function release () :Void
{
	innerAction_.release();
	super.release();
}

public function startWithTarget (aTarget:Dynamic )
{
	total_ = 0;
	super.startWithTarget ( aTarget );
	innerAction_.startWithTarget ( aTarget );
}

public function stop () :Void
{    
    innerAction_.stop;
	super.stop();
}


// issue #80. Instead of hooking step:, hook update: since it can be called by any 
// container action like Repeat, Sequence, AccelDeccel, etc..
public function update:(Float) dt
{
	var t :Float = dt * times_;
	if( t > total_+1 ) {
		innerAction_.update ( 1.0 );
		total_++;
		innerAction_.stop;
		innerAction_.startWithTarget ( target_ );
		
		// repeat is over ?
		if( total_== times_ )
			// so, set it in the original position
			innerAction_.update ( 0 );
		else {
			// no ? start next repeat with the right update
			// to prevent jerk (issue #390)
			innerAction_.update (  t-total_ );
		}

	} else {
		
		var r :Float = fmodf(t, 1.0);
		
		// fix last repeat position
		// else it could be 0.
		if( dt== 1.0) {
			r = 1.0;
			total_++; // this is the added line
		}
		innerAction_.update: MIN(r,1);
	}
}

public function isDone () :Bool
{
	return ( total_ == times_ );
}

- (CCActionInterval *) reverse
{
	return [this.class] actionWithAction:innerAction_.reverse] times ( times_ );
}
}
