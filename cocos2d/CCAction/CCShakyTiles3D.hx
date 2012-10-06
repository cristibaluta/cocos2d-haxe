/** CCShakyTiles3D action */
class CCShakyTiles3D extends CCTiledGrid3DAction
{
	var randrange :Int;
	var shakeZ :Bool;
//
public static function actionWithRange ( range:Int, shakeZ:Bool, gridSize:CC_GridSize ) :id duration ( d:Float )
{
	return new XXX().initWithRange:range shakeZ:shakeZ grid:gridSize duration:d] autorelease];
}

public function initWithRange ( range:Int, sz:Bool, gSize:CC_GridSize ) :id duration ( d:Float )
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		randrange = range;
		shakeZ = sz;
	}
	
	return this;
}

function update (time:Float) :Void
{
	int i, j;
	
	for( i = 0; i < gridSize_.x; i++ )
	{
		for( j = 0; j < gridSize_.y; j++ )
		{
			var coords :ccQuad3 = this.originalTile:new CC_GridSize(i,j);

			// X
			coords.bl.x += ( rand() % (randrange*2) ) - randrange;
			coords.br.x += ( rand() % (randrange*2) ) - randrange;
			coords.tl.x += ( rand() % (randrange*2) ) - randrange;
			coords.tr.x += ( rand() % (randrange*2) ) - randrange;

			// Y
			coords.bl.y += ( rand() % (randrange*2) ) - randrange;
			coords.br.y += ( rand() % (randrange*2) ) - randrange;
			coords.tl.y += ( rand() % (randrange*2) ) - randrange;
			coords.tr.y += ( rand() % (randrange*2) ) - randrange;

			if( shakeZ ) {
				coords.bl.z += ( rand() % (randrange*2) ) - randrange;
				coords.br.z += ( rand() % (randrange*2) ) - randrange;
				coords.tl.z += ( rand() % (randrange*2) ) - randrange;
				coords.tr.z += ( rand() % (randrange*2) ) - randrange;
			}
						
			this.setTile:new CC_GridSize(i,j) coords ( coords );
		}
	}
}

}