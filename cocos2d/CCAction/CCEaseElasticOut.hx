//
// EaseElasticOut
//
/** Ease Elastic Out action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
class CCEaseElasticOut extends CCEaseElastic
{

function update (t:Float) :Void
{	
	var newT :Float = 0;
	if (t == 0 || t == 1) {
		newT = t;
		
	} else {
		var s :Float = period_ / 4;
		newT = Math.pow(2, -10 * t) * Math.sin( (t-s) * CCMacros.M_PI_X_2 / period_) + 1;
	}
	other.update ( newT );
}

public function reverse () :CCActionInterval
{
	return CCEaseElasticIn.actionWithAction (other.reverse(), period_);
}

}
