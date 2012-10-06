/** Moves a CCNode object to a parabolic position simulating a jump movement by modifying it's position attribute.
*/ 
import objc.CGPoint;
	
class CCJumpTo extends CCJumpBy
{

public static function  actionWithDuration (duration:Float, position:CGPoint, height:Float, jumps:Int) :CCJumpTo {
	return new CCJumpTo (duration, position, height, jumps);
}

override public function startWithTarget (aTarget:Dynamic)//CCNode
{
	super.startWithTarget ( aTarget );
	delta_ = new CGPoint ( delta_.x - startPosition_.x, delta_.y - startPosition_.y );
}

}
