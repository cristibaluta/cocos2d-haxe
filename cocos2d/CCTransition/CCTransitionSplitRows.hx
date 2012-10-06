/** CCTransitionSplitRows:
 The odd rows goes to the left while the even rows goes to the right.
 */
class CCTransitionSplitRows extends CCTransitionSplitCols
{
//
public function action () :CCActionInterval
{
	return CCSplitRows.actionWithRows:3 duration:duration_/2.0];
}
}