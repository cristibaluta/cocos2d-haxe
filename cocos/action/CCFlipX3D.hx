/** CCFlipX3D action */
class CCFlipX3D extends CCGrid3DAction
{
//
public static function  actionWithDuration ( d:Float )
{
	return new XXX().initWithSize:new CC_GridSize(1,1) duration:d] autorelease];
}

-(id) initWithDuration ( d:Float )
{
	return super.initWithSize:new CC_GridSize(1,1) duration ( d );
}

public function initWithSize ( gSize:CC_GridSize, d:Float ) :id
{
	if ( gSize.x != 1 || gSize.y != 1 )
	{
		NSException.raise:"FlipX3D" format:"Grid size must be (1,1)"];
	}
	
	return super.initWithSize ( gSize, d );
}

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithSize ( gridSize_, duration_ );
	return copy;
}


function update (time:Float) :Void
{
	var angle :Float = CCMacros.M_PI() * time; // 180 degrees
	var mz :Float = Math.sin( angle );
	angle = angle / 2.0;     // x calculates degrees from 0 to 90
	var mx :Float = Math.cos( angle );
	
	CC_Vertex3F	v0, v1, v, diff;
	
	v0 = this.originalVertex:new CC_GridSize(1,1);
	v1 = this.originalVertex:new CC_GridSize(0,0);
	
	Float	x0 = v0.x;
	Float	x1 = v1.x;
	var x :Float;
	CC_GridSize	a, b, c, d;
	
	if ( x0 > x1 )
	{
		// Normal Grid
		a = new CC_GridSize(0,0);
		b = new CC_GridSize(0,1);
		c = new CC_GridSize(1,0);
		d = new CC_GridSize(1,1);
		x = x0;
	}
	else
	{
		// Reversed Grid
		c = new CC_GridSize(0,0);
		d = new CC_GridSize(0,1);
		a = new CC_GridSize(1,0);
		b = new CC_GridSize(1,1);
		x = x1;
	}
	
	diff.x = ( x - x * mx );
	diff.z = fabsf( floorf( (x * mz) / 4.0 ) );
	
// bottom-left
	v = this.originalVertex ( a );
	v.x = diff.x;
	v.z += diff.z;
	this.setVertex ( a, v );
	
// upper-left
	v = this.originalVertex ( b );
	v.x = diff.x;
	v.z += diff.z;
	this.setVertex ( b, v );
	
// bottom-right
	v = this.originalVertex ( c );
	v.x -= diff.x;
	v.z -= diff.z;
	this.setVertex ( c, v );
	
// upper-right
	v = this.originalVertex ( d );
	v.x -= diff.x;
	v.z -= diff.z;
	this.setVertex ( d, v );
}
}