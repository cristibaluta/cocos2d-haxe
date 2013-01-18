/** CCJumpTiles3D action.
 A sin function is executed to move the tiles across the Z axis
 */
package cocos.action;

class CCJumpTiles3D extends CCTiledGrid3DAction
{
	int jumps;
	var amplitude :Float;
	var amplitudeRate :Float;
//
public var amplitude (get_amplitude, set_amplitude) :;
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :;

public static function actionWithJumps ( j:Int, amp:Float, gridSize:CC_GridSize ) :id duration ( d:Float )
{
	return new XXX().initWithJumps:j amplitude:amp grid:gridSize duration:d] autorelease];
}

public function initWithJumps ( j:Int, amp:Float, gSize:CC_GridSize ) :id duration ( d:Float )
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		jumps = j;
		amplitude = amp;
		amplitudeRate = 1.0;
	}
	
	return this;
}

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithJumps ( jumps, amplitude, gridSize_, duration_ );
	return copy;
}


function update (time:Float) :Void
{
	int i, j;
	
	var sinz :Float =  (Math.sin((Float)M_PI*time*jumps*2) * amplitude * amplitudeRate );
	var sinz2 :Float = (Math.sin((Float)M_PI*(time*jumps*2 + 1)) * amplitude * amplitudeRate );
	
	for( i = 0; i < gridSize_.x; i++ )
	{
		for( j = 0; j < gridSize_.y; j++ )
		{
			var coords :ccQuad3 = this.originalTile:new CC_GridSize(i,j);
			
			if ( ((i+j) % 2) == 0 )
			{
				coords.bl.z += sinz;
				coords.br.z += sinz;
				coords.tl.z += sinz;
				coords.tr.z += sinz;
			}
			else
			{
				coords.bl.z += sinz2;
				coords.br.z += sinz2;
				coords.tl.z += sinz2;
				coords.tr.z += sinz2;
			}
			
			this.setTile:new CC_GridSize(i,j) coords ( coords );
		}
	}
}

}