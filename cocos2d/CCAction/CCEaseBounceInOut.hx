/** CCEaseBounceInOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
class CCEaseBounceInOut extends CCEaseBounce
{

function update (t:Float) :Void
{
	var newT = 0.0;
	if (t < 0.5) {
		t = t * 2;
		newT = (1 - this.bounceTime(1-t)) * 0.5;
	} else
		newT = this.bounceTime (t * 2 - 1) * 0.5 + 0.5;
	
	other.update ( newT );
}
}