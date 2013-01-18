/** Blinks a CCNode object by modifying it's visible attribute
*/
package cocos.action;

class CCBlink extends CCActionInterval
{
var times_ :Int;

/** creates the action */
public static function actionWithDuration ( duration:Float, blinks:Int ) :CCBlink
{
	return new CCBlink (duration, blinks);
}

public function new ( duration:Float, blinks:Int )
{
	super();
	super.initWithDuration ( duration );
	times_ = blinks;
}

override public function copy () :CCActionInterval
{
	return new CCBlink (duration/1000, times_);
}

override function update (t:Float) :Void
{
	if( ! this.isDone() ) {
		var slice :Float = 1.0 / times_;
		var m :Float = t % slice;
		target_.setVisible (m > slice/2) ? true : false;
	}
}

override public function reverse () :CCFiniteTimeAction
{
	return new CCBlink (duration/1000, times_);
}
}
