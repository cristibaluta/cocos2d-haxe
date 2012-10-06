/** CCShuffleTiles action
 Shuffle the tiles in random order
 */
class CCShuffleTiles extends CCTiledGrid3DAction
{
	var seed :Int;
	var tilesCount :Int;
	int *tilesOrder;
	void *tiles;
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
		tiles = null;
	}
	
	return this;
}


public function release () :Void
{
	if ( tilesOrder ) tilesOrder = null;
	if ( tiles ) tiles = null;
	super.release();
}

public function shuffle (array:Int, len:Int) :Void
{
	var i :Int;
	for( i = len - 1; i >= 0; i-- )
	{
		var j :Int = rand() % (i+1);
		var v :Int = array[i];
		array[i] = array[j];
		array[j] = v;
	}
}

-(CC_GridSize)getDelta ( pos:CC_GridSize )
{
	var pos2 :CGPoint;
	
	var idx :Int = pos.x * gridSize_.y + pos.y;
	
	pos2.x = tilesOrder[idx] / (int)gridSize_.y;
	pos2.y = tilesOrder[idx] % (int)gridSize_.y;
	
	return new CC_GridSize(pos2.x - pos.x, pos2.y - pos.y);
}

public function placeTile (pos:CC_GridSize t:Tile) :Void
{
	ccQuad3	coords = this.originalTile ( pos );
	
	var step :CGPoint = target_.grid step];
	coords.bl.x += (int)(t.position.x * step.x);
	coords.bl.y += (int)(t.position.y * step.y);

	coords.br.x += (int)(t.position.x * step.x);
	coords.br.y += (int)(t.position.y * step.y);

	coords.tl.x += (int)(t.position.x * step.x);
	coords.tl.y += (int)(t.position.y * step.y);

	coords.tr.x += (int)(t.position.x * step.x);
	coords.tr.y += (int)(t.position.y * step.y);

	this.setTile (pos, coords);
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	
	if ( seed != -1 )
		srand(seed);
	
	tilesCount = gridSize_.x * gridSize_.y;
	tilesOrder = (int*)malloc(tilesCount*sizeof(int));
	int i, j;
	
	for( i = 0; i < tilesCount; i++ )
		tilesOrder[i] = i;
	
	this.shuffle ( tilesOrder, tilesCount );
	
	tiles = malloc(tilesCount*sizeof(Tile));
	var tileArray :Tile = (Tile*)tiles;
	
	for( i = 0; i < gridSize_.x; i++ )
	{
		for( j = 0; j < gridSize_.y; j++ )
		{
			tileArray.position = new CGPoint (i,j);
			tileArray.startPosition = new CGPoint (i,j);
			tileArray.delta = this.getDelta:new CC_GridSize(i,j);
			tileArray++;
		}
	}
}

function update (time:Float) :Void
{
	int i, j;
	
	var tileArray :Tile = (Tile*)tiles;
	
	for( i = 0; i < gridSize_.x; i++ )
	{
		for( j = 0; j < gridSize_.y; j++ )
		{
			tileArray.position = ccpMult( new CGPoint (tileArray.delta.x, tileArray.delta.y), time);
			this.placeTile:new CC_GridSize(i,j) tile:*tileArray];
			tileArray++;
		}
	}
}

}