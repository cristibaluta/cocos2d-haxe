//
// EaseSineInOut
//
class CCEaseSineInOut extends CCActionEase
{
function update (t:Float) :Void
{
	other.update:-0.5*(Math.cos( CCMacros.M_PI()*t) - 1);
}
}