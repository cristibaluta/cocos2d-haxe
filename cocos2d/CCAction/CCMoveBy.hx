/**  Moves a CCNode object x,y pixels by modifying it's position attribute.
 x and y are relative to the position of the object.
 Duration is is seconds.
*/
import objc.CGPoint;

class CCMoveBy extends CCMoveTo
{

/** creates the action */
public static function actionWithDuration (duration:Float, position:CGPoint) :CCMoveBy {
	return cast ( new CCMoveBy().initWithDurationAndPosition (duration, position));
}
/** initializes the action */
override public function initWithDurationAndPosition (duration:Float, position:CGPoint) :CCMoveTo {
	super.initWithDurationAndPosition (duration, position);
	delta_ = position;
	return this;
}

override public function copy () :CCActionInterval
{
	return cast ( new CCMoveBy().initWithDurationAndPosition (duration, delta_));
}

override public function startWithTarget (aTarget:Dynamic /*CCNode*/)
{
	var dTmp :CGPoint = delta_;
	super.startWithTarget ( aTarget );
	delta_ = dTmp;
}

override public function reverse () :CCFiniteTimeAction
{
	return CCMoveBy.actionWithDuration (duration/1000, new CGPoint (-delta_.x, -delta_.y));
}

}
