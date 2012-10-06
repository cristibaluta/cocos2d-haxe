/** CCTurnOffTiles action.
 Turn off the files in random order
 */
class CCTurnOffTiles extends CCTiledGrid3DAction
{
	var seed :Int;
	var tilesCount :Int;
	int *tilesOrder;
//
public static function actionWithSeed ( s:Int, gridSize:CC_GridSize ) :id duration ( d:Float )
{
	return new XXX().initWithSeed:s grid:gridSize duration:d] autorelease];
}

public function initWithSeed ( s:Int, gSize:CC_GridSize ) :id duration ( d:Float )
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		seed = s;
		tilesOrder = null;
	}
	
	return this;
}


public function release () :Void
{
	if ( tilesOrder ) tilesOrder = null;
	super.release();
}

public function shuffle (array:Int, len:Int) :Void
{
	var i = len - 1;
	while( i >= 0 ) {
		var j :Int = Math.random() % (i+1);
		var v:Int = array[i];
		array[i] = array[j];
		array[j] = v;
		i --;
	}
}

public function turnOnTile ( pos:CC_GridSize )
{
	this.setTile:pos coords:this.originalTile:pos]];
}

public function turnOffTile ( pos:CC_GridSize )
{
var coords :ccQuad3;
	
	bzero(&coords, sizeof(ccQuad3));
	this.setTile ( pos, coords );
}

public function startWithTarget (aTarget:Dynamic )
{
	int i;
	
	super.startWithTarget ( aTarget );
	
	if ( seed != -1 )
		srand(seed);
	
	tilesCount = gridSize_.x * gridSize_.y;
	tilesOrder = (int*)malloc(tilesCount*sizeof(int));

	for( i = 0; i < tilesCount; i++ )
		tilesOrder[i] = i;
	
	this.shuffle ( tilesOrder, tilesCount );
}

function update (time:Float) :Void
{
	int i, l, t;
	
	l = (int)(time * (Float)tilesCount);
	
	for( i = 0; i < tilesCount; i++ )
	{
		t = tilesOrder[i];
		var tilePos :CC_GridSize = new CC_GridSize( t / gridSize_.y, t % gridSize_.y );
		
		if ( i < l )
			this.turnOffTile ( tilePos );
		else
			this.turnOnTile ( tilePos );
	}
}

}