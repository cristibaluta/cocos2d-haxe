/** CCReuseGrid action */
class CCReuseGrid extends CCActionInstant
{
	int t_;
}
/** creates an action with the number of times that the current grid will be reused */
public static function  actionWithTimes: (int) times;
/** initializes an action with the number of times that the current grid will be reused */
-(id) initWithTimes: (int) times;
//
public static function actionWithTimes ( times:Int ) :id
{
	return new XXX().initWithTimes:times ] autorelease];
}

public function initWithTimes ( times:Int ) :id
{
	if ( (this = super.init]) )
		t_ = times;
	
	return this;
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );

	var myTarget :CCNode = (CCNode*) this.target;
	if ( myTarget.grid && myTarget.grid.active )
		myTarget.grid.reuseGrid += t_;
}

}