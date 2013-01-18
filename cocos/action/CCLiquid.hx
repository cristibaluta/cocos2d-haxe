/** CCLiquid action */
package cocos.action;

class CCLiquid extends CCGrid3DAction
{
	int waves;
	var amplitude :Float;
	var amplitudeRate :Float;

//
public var amplitude (get_amplitude, set_amplitude) :;
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :;

public static function actionWithWaves ( wav:Int, amp:Float, gridSize:CC_GridSize ) :id duration ( d:Float )
{
	return new XXX().initWithWaves:wav amplitude:amp grid:gridSize duration:d] autorelease];
}

public function initWithWaves ( wav:Int, amp:Float, gSize:CC_GridSize ) :id duration ( d:Float )
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		waves = wav;
		amplitude = amp;
		amplitudeRate = 1.0;
	}
	
	return this;
}

function update (time:Float) :Void
{
	int i, j;
	
	for( i = 1; i < gridSize_.x; i++ )
	{
		for( j = 1; j < gridSize_.y; j++ )
		{
			CC_Vertex3F	v = this.originalVertex:new CC_GridSize(i,j);
			v.x = (v.x + (Math.sin(time*(Float)M_PI*waves*2 + v.x * .01f) * amplitude * amplitudeRate));
			v.y = (v.y + (Math.sin(time*(Float)M_PI*waves*2 + v.y * .01f) * amplitude * amplitudeRate));
			this.setVertex:new CC_GridSize(i,j) vertex ( v );
		}
	}
}	

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithWaves ( waves, amplitude, gridSize_, duration_ );
	return copy;
}

}