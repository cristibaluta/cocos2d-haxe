//
// EaseElasticInOut
//
/** Ease Elastic InOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
class CCEaseElasticInOut extends CCEaseElastic
{
	
function update (t:Float) :Void
{
	var newT :Float = 0;
	
	if( t == 0 || t == 1 )
		newT = t;
	else {
		t = t * 2;
		if(! period_ )
			period_ = 0.3 * 1.5;
		var s :Float = period_ / 4;
		
		t = t -1;
		if( t < 0 )
			newT = -0.5 * powf(2, 10 * t) * Math.sin((t - s) * M_PI_X_2 / period_);
		else
			newT = powf(2, -10 * t) * Math.sin((t - s) * M_PI_X_2 / period_) * 0.5 + 1;
	}
	other.update ( newT );	
}

public function reverse () :CCActionInterval
{
	return CCEaseElasticInOut.actionWithAction: other.reverse] period ( period_ );
}

}