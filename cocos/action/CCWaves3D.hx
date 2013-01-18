/** CCWaves3D action */
package cocos.action;

class CCWaves3D extends CCGrid3DAction
{
var waves :Int;
var amplitude :Float;
var amplitudeRate :Float;


/** amplitude of the wave */
public var amplitude (get_amplitude, set_amplitude) :Float;
/** amplitude rate of the wave */
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :Float;

public static function actionWithWaves ( wav:Int, amp:Float, gridSize:CC_GridSize, d:Float ) :id;
public function initWithWaves ( wav:Int, amp:Float, gridSize:CC_GridSize, d:Float ) :id;
//
public var amplitude (get_amplitude, set_amplitude) :;
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :;

public static function actionWithWaves ( wav:Int, amp:Float, gridSize:CC_GridSize ) :id duration ( d:Float )
{
	return new XXX().initWithWaves:wav amplitude:amp grid:gridSize duration:d] autorelease];
}

public function initWithWaves ( wav:Int, amp:Float, gSize:CC_GridSize, d:Float )
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		waves = wav;
		amplitude = amp;
		amplitudeRate = 1.0;
	}
	
	return this;
}

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithWaves ( waves, amplitude, gridSize_, duration_ );
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
			v.z += (Math.sin((Float)M_PI*time*waves*2 + (v.y+v.x) * .01f) * amplitude * amplitudeRate);
			this.setVertex:new CC_GridSize(i,j) vertex ( v );
		}
	}
}

}