/** CCEaseBackInOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
package cocos.action;

class CCEaseBackInOut extends CCActionEase
{

function update (t:Float) :Void
{
	var overshoot :Float = 1.70158 * 1.525;
	
	t = t * 2;
	if (t < 1)
		other.update ((t * t * ((overshoot + 1) * t - overshoot)) / 2);
	else {
		t = t - 2;
		other.update ((t * t * ((overshoot + 1) * t + overshoot)) / 2 + 1);
	}
}
}