/** Moves a CCNode object to the position x,y. x and y are absolute coordinates by modifying it's position attribute.
*/
package cocos.action;

import cocos.support.CGPoint;
import cocos.support.CGPointExtension;


class CCMoveTo extends CCActionInterval
{
var endPosition_ :CGPoint;
var startPosition_ :CGPoint;
var delta_ :CGPoint;

/** creates the action */
public static function actionWithDuration (duration:Float, position:CGPoint) :CCMoveTo
{
	return new CCMoveTo().initWithDurationAndPosition (duration, position);
}
/** initializes the action */
public function initWithDurationAndPosition (duration:Float, position:CGPoint) :CCMoveTo
{
	super.initWithDuration ( duration );
	endPosition_ = position;
	
	return this;
}

override public function startWithTarget (aTarget:Dynamic /*CCNode*/)
{
	super.startWithTarget ( aTarget );
	startPosition_ = cast (target_, CCNode).position;// Cast the target because accessing position on a Dynamic is not working
	delta_ = CGPointExtension.sub( endPosition_, startPosition_ );
}

override public function update (t:Float) :Void
{
	trace("update "+t);
	trace(target_);
/*	trace(delta_);*/
	if (target_ != null)
	try {
		target_.setPosition ( new CGPoint ( (startPosition_.x + delta_.x * t ), (startPosition_.y + delta_.y * t)));
	}
	catch(e:Dynamic){trace(e);}
}
}