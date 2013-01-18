/** CCFadeOutBLTiles action.
 Fades out the tiles in a Bottom-Left direction
 */
package cocos.action;

import cocos.support.CGPoint;

class CCFadeOutBLTiles extends CCFadeOutTRTiles
{
//
public function testFunc ( pos:CC_GridSize, time:Float ) :Float
{
	var n = ccpMult ( new CGPoint (gridSize_.x, gridSize_.y), (1.0-time));
	if ( (pos.x+pos.y) == 0 )
		return 1.0;
	
	return Math.pow ( (n.x+n.y) / (pos.x+pos.y), 6 );
}
}