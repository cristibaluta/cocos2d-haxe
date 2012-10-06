/** CCAccelDeccelAmplitude action */
class CCAccelDeccelAmplitude extends CCActionInterval
{
	var 		rate_ :Float;
	var other_ :CCActionInterval;
}

/** amplitude rate */
public var rate (get_rate, set_rate) :Float;

/** creates the action with an inner action that has the amplitude property, and a duration time */
public static function actionWithAction (action:CCAction,  duration:(Float)d;
/** initializes the action with an inner action that has the amplitude property, and a duration time */
-(id)initWithAction (action:CCAction,  duration:(Float)d;

//
public var rate (get_rate, set_rate) :;

public static function actionWithAction (action:CCAction,  duration ( d:Float )
{
	return new XXX().initWithAction:action duration:d ] autorelease];
}

-(id)initWithAction:(CCAction *)action duration ( d:Float )
{
	if ( (this = super.initWithDuration:d]) )
	{
		rate_ = 1.0;
		other_ = (CCActionInterval*)action.retain;
	}
	
	return this;
}

public function release () :Void
{
	other_.release();
	super.release();
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	other_.startWithTarget ( target_ );
}

function update (time:Float) :Void
{
	var f :Float = time*2;
	
	if (f > 1)
	{
		f -= 1;
		f = 1 - f;
	}
	
	other_.setAmplitudeRate:powf(f, rate_);
	other_.update ( time );
}

public function reverse () :CCActionInterval
{
	return CCAccelDeccelAmplitude.actionWithAction:other_.reverse] duration ( duration_ );
}

}