//
// EeseIn
//
class CCEaseIn extends CCEaseRateAction
{
function update (t:Float) :Void
{
	other.update: powf(t,rate);
}
}
