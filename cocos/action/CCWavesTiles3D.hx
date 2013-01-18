/** CCWavesTiles3D action. */
package cocos.action;

class CCWavesTiles3D extends CCTiledGrid3DAction
{
	var waves :Int;
	var amplitude :Float;
	var amplitudeRate :Float;
}
//
public var amplitude (get_amplitude, set_amplitude) :;
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :;

public static function actionWithWaves ( wav:Int, amp:Float, gridSize:CC_GridSize, d:Float )
{
	return new CCWavesTiles3D().initWithWaves (wav, amp, gridSize, d);
}

public function initWithWaves ( wav:Int, amp:Float, gSize:CC_GridSize, d:Float )
{
	super.initWithSize (gSize, d);
	waves = wav;
	amplitude = amp;
	amplitudeRate = 1.0;
	
	return this;
}

function update (time:Float) :Void
{
	int i, j;
	
	for( i = 0; i < gridSize_.x; i++ )
	{
		for( j = 0; j < gridSize_.y; j++ )
		{
			var coords :ccQuad3 = this.originalTile ( new CC_GridSize(i,j));
			
			coords.bl.z = (Math.sin(time*Math.PI*waves*2 + (coords.bl.y+coords.bl.x) * .01) * amplitude * amplitudeRate );
			coords.br.z	= coords.bl.z;
			coords.tl.z = coords.bl.z;
			coords.tr.z = coords.bl.z;
			
			this.setTile ( new CC_GridSize(i,j) coords ( coords ));
		}
	}
}

}