
/**
 Progress from a percentage to another percentage
 @since v0.99.1
 */
class CCProgressFromTo extends CCActionInterval
{
var to_ :Float;
var from_ :Float;

//
public static function  actionWithDuration (t:Float, fromPercentage:Float, toPercentage:Float) :CCProgressFromTo
{
	return new CCProgressFromTo (t, fromPercentage, toPercentage);
}

public function new (t:Float, fromPercentage:Float, toPercentage:Float)
{
	super();
	super.initWithDuration(t);
	to_ = toPercentage;
	from_ = fromPercentage;
}

override public function reverse () :CCActionInterval
{
	return new CCActionInterval.actionWithDuration ( duration_, to_, from_ );
}

override public function startWithTarget (aTarget:Dynamic)
{
	super.startWithTarget ( aTarget );
}

override public function update (t:Float) :Void
{
	cast(target_, CCProgressTimer).setPercentage (from_ + ( to_ - from_ ) * t);
}

}
