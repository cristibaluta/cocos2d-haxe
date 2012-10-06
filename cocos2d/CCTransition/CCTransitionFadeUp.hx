/** CCTransitionFadeUp:
 * Fade the tiles of the outgoing scene from the bottom to the top.
 */
class CCTransitionFadeUp extends CCTransitionFadeTR
{
//
public function actionWithSize (v:CC_GridSize) :CCActionInterval
{
	return CCFadeOutUpTiles.actionWithSize ( v, duration_ );
}
}
