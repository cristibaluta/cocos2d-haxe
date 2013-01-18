/** Repeats an action for ever.
 To repeat the an action for a limited number of times use the Repeat action.
 @warning This action can't be Sequenceable because it is not an IntervalAction
 */
package cocos.action;

class CCRepeatForever extends CCAction
{
	
var innerAction_ :CCActionInterval;
//
public static function actionWithAction (action:CCActionInterval) :CCRepeatForever
{
	return new CCRepeatForever().initWithAction( action );
}

public function initWithAction (action:CCActionInterval) :CCRepeatForever
{
	super.init();
	innerAction_ = action;

	return this;
}

public function copy () :CCAction
{
	return new CCRepeatForever().initWithAction ( innerAction_.copy() );
}

override public function release () :Void
{
	innerAction_.release();
	super.release();
}

override public function startWithTarget (aTarget:Dynamic)
{
	super.startWithTarget ( aTarget );
	innerAction_.startWithTarget ( target_ );
}

override public function step (dt:Float) :Void
{
	innerAction_.step( dt );
	if( innerAction_.isDone() ) {
		var diff = dt + innerAction_.duration - innerAction_.elapsed;
		innerAction_.startWithTarget(target_);
		
		// to prevent jerk. issue #390
		innerAction_.step(diff);
	}
}


override public function isDone () :Bool
{
	return false;
}

public function reverse () :CCAction
{
	return CCRepeatForever.actionWithAction ( untyped innerAction_.reverse() );
}
}
