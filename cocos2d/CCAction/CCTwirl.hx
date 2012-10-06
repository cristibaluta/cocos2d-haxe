/** CCTwirl action */

class CCTwirl extends CCGrid3DAction
{
	var position_ :CGPoint;
	var positionInPixels_ :CGPoint;
	var twirls_ :Int;
	var amplitude_ :Float;
	var amplitudeRate_ :Float;
//
public var amplitude (get_amplitude, set_amplitude) :;
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :;

public static function actionWithPosition ( pos:CGPoint, t:Int, amp:Float, gridSize:CC_GridSize, d:Float )
{
	return new XXX().initWithPosition:pos twirls:t amplitude:amp grid:gridSize duration:d] autorelease];
}

public function initWithPosition ( pos:CGPoint, t:Int, amp:Float, gSize:CC_GridSize, d:Float )
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		this.position = pos;
		twirls_ = t;
		amplitude_ = amp;
		amplitudeRate_ = 1.0;
	}
	
	return this;
}

public function setPosition ( pos:CGPoint )
{
	position_ = pos;
	positionInPixels_.x = pos.x * CCConfig.CC_CONTENT_SCALE_FACTOR;
	positionInPixels_.y = pos.y * CCConfig.CC_CONTENT_SCALE_FACTOR;
}

public function position () :CGPoint
{
	return position_;
}

function update (time:Float) :Void
{
	var i, j :Int;
	var c :CGPoint = positionInPixels_;
	
	for( i = 0; i < (gridSize_.x+1); i++ )
	{
		for( j = 0; j < (gridSize_.y+1); j++ )
		{
			var v :CC_Vertex3F = this.originalVertex ( new CC_GridSize(i,j) );
			
			var avg :CGPoint = new CGPoint (i-(gridSize_.x/2.0), j-(gridSize_.y/2.0));
			var r :Float = CGPointExtension.length( avg );
			
			var amp :Float = 0.1 * amplitude_ * amplitudeRate_;
			var a :Float = r * Math.cos( M_PI/2.0 + time * M_PI * twirls_ * 2 ) * amp;
			
			var cosA :Float = Math.cos(a);
			var sinA :Float = Math.sin(a);
			
			var d :CGPoint = {
				sinA * (v.y-c.y) + cosA * (v.x-c.x),
				cosA * (v.y-c.y) - sinA * (v.x-c.x)
			}
			
			v.x = c.x + d.x;
			v.y = c.y + d.y;
			
			this.setVertex ( new CC_GridSize(i,j), v );
		}
	}
}

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithPosition:position_
																	  twirls:twirls_
																   amplitude:amplitude_
																		grid:gridSize_
																	duration ( duration_ );
	return copy;
}
}