/** CCRipple3D action */
class CCRipple3D extends CCGrid3DAction
{
	var position_ :CGPoint;
	var positionInPixels_ :CGPoint;
	var radius_ :Float;
	var waves_ :Int;
	var amplitude_ :Float;
	var amplitudeRate_ :Float;
}

/** center position in Points */
public var position (get_position, set_position) :CGPoint;
/** amplitude */
public var amplitude (get_amplitude, set_amplitude) :Float;
/** amplitude rate */
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :Float;

/** creates the action with a position in points, radius, number of waves, amplitude, a grid size and duration */
public static function actionWithPosition ( pos:CGPoint, r:Float, wav:Int, amp:Float, gridSize:CC_GridSize, d:Float ) :id;
/** initializes the action with a position in points, radius, number of waves, amplitude, a grid size and duration */
public function initWithPosition ( pos:CGPoint, r:Float, wav:Int, amp:Float, gridSize:CC_GridSize, d:Float ) :id;
//
public var amplitude (get_amplitude, set_amplitude) :;
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :;

public static function actionWithPosition ( pos:CGPoint, r:Float, wav:Int, amp:Float, gridSize:CC_GridSize ) :id duration ( d:Float )
{
	return new XXX().initWithPosition:pos radius:r waves:wav amplitude:amp grid:gridSize duration:d] autorelease];
}

public function initWithPosition ( pos:CGPoint, r:Float, wav:Int, amp:Float, gSize:CC_GridSize, d:Float ) :id
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		this.position = pos;
		radius_ = r;
		waves_ = wav;
		amplitude_ = amp;
		amplitudeRate_ = 1.0;
	}
	
	return this;
}

public function position () :CGPoint
{
	return position_;
}

public function setPosition ( pos:CGPoint )
{
	position_ = pos;
	positionInPixels_.x = pos.x * CCConfig.CC_CONTENT_SCALE_FACTOR;
	positionInPixels_.y = pos.y * CCConfig.CC_CONTENT_SCALE_FACTOR;
}

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithPosition ( position_, radius_, waves_, amplitude_, gridSize_, duration_ );
	return copy;
}


function update (time:Float) :Void
{
	int i, j;
	
	for( i = 0; i < (gridSize_.x+1); i++ )
	{
		for( j = 0; j < (gridSize_.y+1); j++ )
		{
			CC_Vertex3F	v = this.originalVertex:new CC_GridSize(i,j);
			var vect :CGPoint = CGPointExtension.sub(positionInPixels_, new CGPoint (v.x,v.y));
			var r :Float = CGPointExtension.length(vect);
			
			if ( r < radius_ )
			{
				r = radius_ - r;
				var rate :Float = powf( r / radius_, 2);
				v.z += (Math.sin( time*(Float)M_PI*waves_2 + r * 0.1) * amplitude_ * amplitudeRate_ * rate );
			}
			
			this.setVertex:new CC_GridSize(i,j) vertex ( v );
		}
	}
}

}