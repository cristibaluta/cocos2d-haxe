/** CCFadeOutTRTiles action
 Fades out the tiles in a Top-Right direction
 */
class CCFadeOutTRTiles extends CCTiledGrid3DAction
{
//
public function testFunc ( pos:CC_GridSize, time:Float ) :Float
{
	var n = ccpMult( new CGPoint (gridSize_.x,gridSize_.y), time) :CGPoint;
	if ( (n.x+n.y) == 0.0 )
		return 1.0;
	
	return powf( (pos.x+pos.y) / (n.x+n.y), 6 );
}

public function turnOnTile ( pos:CC_GridSize )
{
	this.setTile:pos coords:this.originalTile:pos]];
}

public function turnOffTile ( pos:CC_GridSize )
{
var coords :ccQuad3;	
	bzero(&coords, sizeof(ccQuad3));
	this.setTile ( pos, coords );
}

public function transformTile (pos:CC_GridSize, distance:Float) :Void
{
	ccQuad3	coords = this.originalTile ( pos );
	var step = [target_.grid] step] :CGPoint;
	
	coords.bl.x += (step.x / 2) * (1.0 - distance);
	coords.bl.y += (step.y / 2) * (1.0 - distance);

	coords.br.x -= (step.x / 2) * (1.0 - distance);
	coords.br.y += (step.y / 2) * (1.0 - distance);

	coords.tl.x += (step.x / 2) * (1.0 - distance);
	coords.tl.y -= (step.y / 2) * (1.0 - distance);

	coords.tr.x -= (step.x / 2) * (1.0 - distance);
	coords.tr.y -= (step.y / 2) * (1.0 - distance);

	this.setTile ( pos, coords );
}

function update (time:Float) :Void
{
	int i, j;
	
	for( i = 0; i < gridSize_.x; i++ )
	{
		for( j = 0; j < gridSize_.y; j++ )
		{
			var distance :Float = this.testFunc:new CC_GridSize(i,j) time ( time );
			if ( distance == 0 )
				this.turnOffTile:new CC_GridSize(i,j);
			else if ( distance < 1 )
				this.transformTile:new CC_GridSize(i,j) distance ( distance );
			else
				this.turnOnTile:new CC_GridSize(i,j);
		}
	}
}
}
