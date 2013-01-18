/** Hide the node
 */
package cocos.action;

class CCHide extends CCActionInstant
{
override public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	cast(target_, CCNode).visible = false;
}

override public function reverse () :CCFiniteTimeAction
{
	return CCShow.action();
}
}