/** CCSplitRows action */
package cocos.action;

class CCSplitRows extends CCTiledGrid3DAction
{
	var rows :Int;
	var winSize :CGSize;
//
public static function actionWithRows ( r:Int, duration:Float ) :CCSplitRows
{
	return new CCSplitRows().initWithRows:r duration:d] autorelease];
}

public function initWithRows ( r:Int, d:Float ) :id{
	rows = r;
	return super.initWithSize:new CC_GridSize(1,r) duration ( d );
}

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithRows ( rows, duration_ );
	return copy;
}

public function startWithTarget (aTarget:Dynamic) :Void
{
	super.startWithTarget ( aTarget );
	winSize = CCDirector.sharedDirector().winSizeInPixels;
}

function update (time:Float) :Void
{
	int j;
	
	for( j = 0; j < gridSize_.y; j++ )
	{
		var coords :ccQuad3 = this.originalTile:new CC_GridSize(0,j);
		var direction = 1 :Float;
		
		if ( (j % 2 ) == 0 )
			direction = -1;
		
		coords.bl.x += direction * winSize.width * time;
		coords.br.x += direction * winSize.width * time;
		coords.tl.x += direction * winSize.width * time;
		coords.tr.x += direction * winSize.width * time;
		
		this.setTile:new CC_GridSize(0,j) coords ( coords );
	}
}

}