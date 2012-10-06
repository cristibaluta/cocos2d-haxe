/** CCTransitionFadeDown:
 * Fade the tiles of the outgoing scene from the top to the bottom.
 */
class CCTransitionFadeDown extends CCTransitionFadeTR
{
//
public function actionWithSize (v:CC_GridSize) :CCActionInterval
{
	return CCFadeOutDownTiles.actionWithSize ( v, duration_ );
}
}
