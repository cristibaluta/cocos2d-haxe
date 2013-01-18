/** CCShaky3D action */
package cocos.action;

class CCShaky3D extends CCGrid3DAction
{
	int randrange;
	var shakeZ :Bool;
}

public static function actionWithRange ( range:Int, sz:Bool, gridSize:CC_GridSize ) :id duration ( d:Float )
{
	return new XXX().initWithRange:range shakeZ:sz grid:gridSize duration:d] autorelease];
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

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithRange ( randrange, shakeZ, gridSize_, duration_ );
	return copy;
}

function update (time:Float) :Void
{
	int i, j;
	
	for( i = 0; i < (gridSize_.x+1); i++ )
	{
		for( j = 0; j < (gridSize_.y+1); j++ )
		{
			CC_Vertex3F	v = this.originalVertex:new CC_GridSize(i,j);
			v.x += ( rand() % (randrange*2) ) - randrange;
			v.y += ( rand() % (randrange*2) ) - randrange;
			if( shakeZ )
				v.z += ( rand() % (randrange*2) ) - randrange;
			
			this.setVertex:new CC_GridSize(i,j) vertex ( v );
		}
	}
}
}