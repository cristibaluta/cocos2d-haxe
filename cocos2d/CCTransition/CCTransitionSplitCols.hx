/** CCTransitionSplitCols:
 The odd columns goes upwards while the even columns goes downwards.
 */
class CCTransitionSplitCols extends CCTransitionScene <CCTransitionEaseScene>
{

override public function onEnter ()
{
	super.onEnter();

	inScene_.visible = false;
	
	var split :id = this.action;
	var seq :id = CCSequence.actions:
				split,
				CCCallFunc.actionWithTarget:this selector:@selector(hideOutShowIn)],
				split.reverse],
				null
			  ];
	this.runAction: CCSequence.actions:
			   this.easeActionWithAction:seq],
			   CCCallFunc.actionWithTarget:this selector:@selector(finish)],
			   CCStopGrid.action],
			   null]
	 ];
}

public function action () :CCActionInterval
{
	return CCSplitCols.actionWithCols:3 duration:duration_/2.0];
}

public function easeActionWithAction (action:CCActionInterval) :CCActionInterval
{
	return CCEaseInOut.actionWithAction (action, 3.0);
}
}