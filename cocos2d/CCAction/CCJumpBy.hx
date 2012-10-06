/** Moves a CCNode object simulating a parabolic jump movement by modifying it's position attribute.
*/
import objc.CGPoint;

class CCJumpBy extends CCActionInterval
{
	var startPosition_ :CGPoint;
	var delta_ :CGPoint;
	var height_ :Float;
	var jumps_ :Int;

/** creates the action */
public static function  actionWithDuration (duration:Float, position:CGPoint, height:Float, jumps:Int) :CCJumpBy {
	return new CCJumpBy (duration, position, height, jumps);
}


/** initializes the action */
public function new (duration:Float, position:CGPoint, height:Float, jumps:Int)
{
	super();
	super.initWithDuration ( duration );
	
	delta_ = position;
	height_ = height;
	jumps_ = jumps;
}

override public function copy () :CCActionInterval
{
	return new CCJumpBy (duration/1000, delta_, height_, jumps_);
}

override public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	startPosition_ = cast (target_, CCNode).getPosition();
}

override function update (t:Float) :Void
{
	// Sin jump. Less realistic
//	var y :Float = height_ * Math.abs( Math.sin(t * CCMacros.M_PI * jumps_ ) );
//	y += delta.y * t;
//	var x :Float = delta.x * t;
//	target.setPosition: new CGPoint ( startPosition.x + x, startPosition.y + y );	
	
	// parabolic jump (since v0.8.2)
	var frac :Float = (t * jumps_) % 1.0; //fmodf( t * jumps_, 1.0 );
	var y :Float = height_ * 4 * frac * (1 - frac);
	y += delta_.y * t;
	var x :Float = delta_.x * t;
	target_.setPosition ( new CGPoint ( startPosition_.x + x, startPosition_.y - y ) );
	
}

override public function reverse () :CCFiniteTimeAction
{
	return new CCJumpBy ( duration/1000, new CGPoint (-delta_.x,-delta_.y), height_, jumps_ );
}

}
