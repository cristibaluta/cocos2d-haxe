/** CCFlipY3D action */
class CCFlipY3D extends CCFlipX3D
{
//
function update (time:Float) :Void
{
	var angle :Float = (Float)M_PI * time; // 180 degrees
	var mz :Float = Math.sin( angle );
	angle = angle / 2.0;     // x calculates degrees from 0 to 90
	var my :Float = Math.cos( angle );
	
	CC_Vertex3F	v0, v1, v, diff;
	
	v0 = this.originalVertex:new CC_GridSize(1,1);
	v1 = this.originalVertex:new CC_GridSize(0,0);
	
	Float	y0 = v0.y;
	Float	y1 = v1.y;
	var y :Float;
	CC_GridSize	a, b, c, d;
	
	if ( y0 > y1 )
	{
		// Normal Grid
		a = new CC_GridSize(0,0);
		b = new CC_GridSize(0,1);
		c = new CC_GridSize(1,0);
		d = new CC_GridSize(1,1);
		y = y0;
	}
	else
	{
		// Reversed Grid
		b = new CC_GridSize(0,0);
		a = new CC_GridSize(0,1);
		d = new CC_GridSize(1,0);
		c = new CC_GridSize(1,1);
		y = y1;
	}
	
	diff.y = y - y * my;
	diff.z = fabsf( floorf( (y * mz) / 4.0 ) );
	
	// bottom-left
	v = this.originalVertex ( a );
	v.y = diff.y;
	v.z += diff.z;
	this.setVertex ( a, v );
	
	// upper-left
	v = this.originalVertex ( b );
	v.y -= diff.y;
	v.z -= diff.z;
	this.setVertex ( b, v );
	
	// bottom-right
	v = this.originalVertex ( c );
	v.y = diff.y;
	v.z += diff.z;
	this.setVertex ( c, v );
	
	// upper-right
	v = this.originalVertex ( d );
	v.y -= diff.y;
	v.z -= diff.z;
	this.setVertex ( d, v );
}

}