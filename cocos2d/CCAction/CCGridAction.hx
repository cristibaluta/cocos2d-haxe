import CCActionInterval;
import CCActionInstant;
import CCActionGrid;
import CCGrid;
import CCTypes;
import CCDirector;

/** Base class for Grid actions */
class CCGridAction extends CCActionInterval
{
public var gridSize :CC_GridSize;


public static function actionWithSize ( size:CC_GridSize, d:Float ) :CCGridAction
{
	return new CCGridAction().initWithSize (size, d);
}

public function initWithSize ( gSize:CC_GridSize, d:Float ) :CCGridAction
{
	super.initWithDuration(d);
	gridSize = gSize;
	
	return this;
}

override public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );

	var newgrid :CCGridBase = this.grid();
	var t :CCNode = target_;
	var targetGrid :CCGridBase = t.grid;
	
	if ( targetGrid != null && targetGrid.reuseGrid > 0 )
	{
		if (targetGrid.active && 
			targetGrid.gridSize.width == gridSize.x && 
			targetGrid.gridSize.height == gridSize.y && 
			Std.is (targetGrid, Type.typeof(newgrid)) )
			
			targetGrid.reuse();
		else
			trace("GridBase Cannot reuse grid");
	}
	else
	{
		if ( targetGrid != null && targetGrid.active )
			targetGrid.active = false;
		
		t.grid = newgrid;
		t.grid.active = true;
	}	
}

public function grid () :CCGridBase
{
	throw "GridBase. Abstract class needs implementation";
	return null;
}

override public function reverse () :CCFiniteTimeAction
{
	return cast CCReverseTime.actionWithAction ( this );
}

}