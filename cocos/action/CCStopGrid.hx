/** CCStopGrid action.
 Don't call this action if another grid action is active.
 Call if you want to remove the the grid effect. Example:
 Sequence.actions:Lens....], StopGrid.action], null];
 */
package cocos.action;

class CCStopGrid extends CCActionInstant
{
//
override public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );

	if ( this.target.grid && this.target.grid.active ) {
		this.target.grid.setActive ( false );
		
//		[this.target] setGrid: null];
	}
}
}