//
// EaseExponentialOut
//
class CCEaseExponentialOut extends CCActionEase
{
function update (t:Float) :Void
{
	other.update: (t==1) ? 1 : (-powf(2, -10 * t/1) + 1);
}

public function reverse () :CCActionInterval
{
	return CCEaseExponentialIn.actionWithAction: other.reverse]];
}
}
