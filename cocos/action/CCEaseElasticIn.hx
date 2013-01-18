//
// EaseElasticIn
//
/** Ease Elastic In action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
class CCEaseElasticIn extends CCEaseElastic
{
	
function update (t:Float) :Void
{	
	var newT :Float = 0;
	if (t == 0 || t == 1)
		newT = t;
		
	else {
		var s :Float = period_ / 4;
		t = t - 1;
		newT = -powf(2, 10 * t) * Math.sin( (t-s) *M_PI_X_2 / period_);
	}
	other.update ( newT );
}

public function reverse () :CCActionInterval
{
	return CCEaseElasticOut.actionWithAction: other.reverse] period ( period_ );
}

}