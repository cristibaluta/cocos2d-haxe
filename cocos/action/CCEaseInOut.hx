//
// EaseInOut
//
class CCEaseInOut
{
function update (t:Float) :Void
{	
	var sign :Int =1;
	var r :Int = (int) rate;
	if (r % 2 == 0)
		sign = -1;
	t *= 2;
	if (t < 1) 
		other.update: 0.5 * powf (t, rate);
	else
		other.update: sign*0.5 * (powf (t-2, rate) + sign*2);	
}

// InOut and OutIn are symmetrical
public function reverse () :CCActionInterval
{
	return [this.class] actionWithAction: other.reverse] rate ( rate );
}

}