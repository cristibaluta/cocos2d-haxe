/** Show the node
 */
class CCShow extends CCActionInstant
{
override public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	cast(target_, CCNode).visible = true;
}

override public function reverse () :CCFiniteTimeAction
{
	return CCHide.action;
}
}
