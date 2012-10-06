//
// EaseSineIn
//
class CCEaseSineIn extends CCActionEase
{
function update (t:Float) :Void
{
	other.update:-1*Math.cos(t * CCMacros.M_PI_2) +1];
}

public function reverse () :CCActionInterval
{
	return CCEaseSineOut.actionWithAction: other.reverse]];
}
}