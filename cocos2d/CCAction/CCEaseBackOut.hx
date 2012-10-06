//
// EaseBackOut
//
/** CCEaseBackOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
class CCEaseBackOut extends CCActionEase
{
	
function update (t:Float) :Void
{
	var overshoot :Float = 1.70158;
	
	t = t - 1;
	other.update (t * t * ((overshoot + 1) * t + overshoot) + 1);
}

public function reverse () :CCActionInterval
{
	return CCEaseBackIn.actionWithAction ( other.reverse() );
}
}