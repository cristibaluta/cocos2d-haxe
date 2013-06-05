//
// EaseSineOut
//
class CCEaseSineOut extends CCActionEase
{
function update (t:Float) :Void
{
	other.update:Math.sin(t * CCMacros.M_PI_2());
}

public function reverse () :CCActionInterval
{
	return CCEaseSineIn.actionWithAction: other.reverse]];
}
}