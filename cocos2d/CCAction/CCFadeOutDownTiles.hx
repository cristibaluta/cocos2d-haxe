/** CCFadeOutDownTiles action.
 Fades out the tiles in downwards direction
 */
class CCFadeOutDownTiles extends CCFadeOutUpTiles
{
//
public function testFunc ( pos:CC_GridSize, time:Float ) :Float
{
	var n = ccpMult(new CGPoint (gridSize_.x,gridSize_.y), (1.0 - time)) :CGPoint;
	if ( pos.y == 0 )
		return 1.0;
	
	return powf( n.y / pos.y, 6 );
}
}