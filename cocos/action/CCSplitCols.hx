/** CCSplitCols action */
package cocos.action;

class CCSplitCols extends CCTiledGrid3DAction
{
	var cols :Int;
	var winSize :CGSize;
//
public static function actionWithCols ( c:Int, d:Float ) :CCSplitCols
{
	return new CCSplitCols().initWithCols (c, d);
}

public function initWithCols ( c:Int, d:Float ) :CCSplitCols
{
	cols = c;
	return super.initWithSize:new CC_GridSize(c,1) duration ( d );
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	winSize = CCDirector.sharedDirector().winSizeInPixels();
}

function update (time:Float) :Void
{
	for( i in 0...gridSize_.x )
	{
		var coords :CC_Quad3 = this.originalTile ( new CC_GridSize(i,0) );
		var direction :Float = 1;
		
		if ( (i % 2 ) == 0 )
			direction = -1;
		
		coords.bl.y += direction * winSize.height * time;
		coords.br.y += direction * winSize.height * time;
		coords.tl.y += direction * winSize.height * time;
		coords.tr.y += direction * winSize.height * time;
		
		this.setTile (new CC_GridSize(i,0), coords);
	}
}

}