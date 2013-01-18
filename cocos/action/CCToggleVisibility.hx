/** Toggles the visibility of a node
 */
package cocos.action;

class CCToggleVisibility extends CCActionInstant
{
public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	cast(target_, CCNode).visible = !cast(target_, CCNode).visible;
}
}