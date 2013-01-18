/** CCEaseBackIn action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
package cocos.action;

class CCEaseBackIn extends CCActionEase
{

override function update (t:Float) :Void
{
	var overshoot = 1.70158;
	other.update  (t * t * ((overshoot + 1) * t - overshoot));
}

override public function reverse () :CCActionInterval
{
	return CCEaseBackOut.actionWithAction ( other.reverse() );
}
}