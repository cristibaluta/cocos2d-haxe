/** CCWaves action */
package cocos.action;

class CCWaves extends CCGrid3DAction
{
	var waves :Int;
	var amplitude :Float;
	var amplitudeRate :Float;
	var vertical :Bool;
	var horizontal :Bool;
//
public var amplitude (get_amplitude, set_amplitude) :;
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :;

public static function actionWithWaves ( wav:Int, amp:Float, h:Bool, v:Bool, gridSize:CC_GridSize ) :id duration ( d:Float )
{
	return new XXX().initWithWaves:wav amplitude:amp horizontal:h vertical:v grid:gridSize duration:d] autorelease];
}

public function initWithWaves ( wav:Int, amp:Float, h:Bool, v:Bool, gSize:CC_GridSize, d:Float ) :id
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		waves = wav;
		amplitude = amp;
		amplitudeRate = 1.0;
		horizontal = h;
		vertical = v;
	}
	
	return this;
}

function update (time:Float) :Void
{
	int i, j;
	
	for( i = 0; i < (gridSize_.x+1); i++ )
	{
		for( j = 0; j < (gridSize_.y+1); j++ )
		{
			CC_Vertex3F	v = this.originalVertex:new CC_GridSize(i,j);
			
			if ( vertical )
				v.x = (v.x + (Math.sin(time*(Float)M_PI*waves*2 + v.y * .01f) * amplitude * amplitudeRate));
			
			if ( horizontal )
				v.y = (v.y + (Math.sin(time*(Float)M_PI*waves*2 + v.x * .01f) * amplitude * amplitudeRate));
					
			this.setVertex:new CC_GridSize(i,j) vertex ( v );
		}
	}
}

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithWaves ( waves, amplitude, horizontal, vertical, gridSize_, duration_ );
	return copy;
}

}