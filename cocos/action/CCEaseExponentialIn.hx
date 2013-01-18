//
// EaseExponentialIn
//
class CCEaseExponentialIn extends CCActionEase
{
function update (t:Float) :Void
{
	other.update: (t==0) ? 0 : powf(2, 10 * (t/1 - 1)) - 1 * 0.001];
}

public function reverse () :CCActionInterval
{
	return CCEaseExponentialOut.actionWithAction: other.reverse]];
}
}