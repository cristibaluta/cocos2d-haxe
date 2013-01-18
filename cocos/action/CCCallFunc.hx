
package cocos.action;

/** Calls a 'callback'
 */
class CCCallFunc extends CCActionInstant
{
var targetCallback_ :Dynamic;
var selector_ :Dynamic;

public var targetCallback :Dynamic;

public static function actionWithTarget (target:Dynamic, selector:Dynamic) :CCCallFunc
{
	return new CCCallFuncO().initWithTargetSelector (target, selector);
}

public function initWithTargetSelector (t:Dynamic, s:Dynamic) :CCCallFunc
{
	super.init();
	targetCallback_ = t;
	selector_ = s;
	
	return this;
}

override public function toString () :String
{
	return "<CCCallFunc | Tag = "+tag+" | target = "+targetCallback_+" | selector = "+selector_+">";
}

override public function release () :Void
{
	targetCallback_.release();
	super.release();
}

override public function startWithTarget (aTarget:Dynamic)
{
	super.startWithTarget ( aTarget );
	this.execute();
}

public function execute ()
{
	targetCallback_.selector_();
}

}
