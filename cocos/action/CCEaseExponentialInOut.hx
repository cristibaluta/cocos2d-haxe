//
// EaseExponentialInOut
//
class CCEaseExponentialInOut extends CCActionEase
{
function update (t:Float) :Void
{
	t /= 0.5;
	if (t < 1)
		t = 0.5 * powf(2, 10 * (t - 1));
	else
		t = 0.5 * (-powf(2, -10 * (t -1) ) + 2);
	
	other.update ( t );
}
}