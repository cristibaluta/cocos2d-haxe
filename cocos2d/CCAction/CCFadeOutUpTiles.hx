/** CCFadeOutUpTiles action.
 Fades out the tiles in upwards direction
 */
class CCFadeOutUpTiles extends CCFadeOutTRTiles
{
//
public function testFunc ( pos:CC_GridSize, time:Float ) :Float
{
	var n = ccpMult(new CGPoint (gridSize_.x, gridSize_.y), time) :CGPoint;
	if ( n.y == 0 )
		return 1.0;
	
	return powf( pos.y / n.y, 6 );
}

public function transformTile (pos:CC_GridSize, distance:Float) :Void
{
	ccQuad3	coords = this.originalTile ( pos );
	var step :CGPoint = [target_.grid] step];
	
	coords.bl.y += (step.y / 2) * (1.0 - distance);
	coords.br.y += (step.y / 2) * (1.0 - distance);
	coords.tl.y -= (step.y / 2) * (1.0 - distance);
	coords.tr.y -= (step.y / 2) * (1.0 - distance);
	
	this.setTile ( pos, coords );
}
}