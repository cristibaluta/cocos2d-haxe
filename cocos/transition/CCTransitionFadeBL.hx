/** CCTransitionFadeBL:
 Fade the tiles of the outgoing scene from the top-right corner to the bottom-left corner.
 */
class CCTransitionFadeBL extends CCTransitionFadeTR
{
//
public function actionWithSize (v:CC_GridSize) :CCActionInterval
{
	return CCFadeOutBLTiles.actionWithSize ( v, duration_ );
}
}