/** CCOrbitCamera action
 Orbits the camera around the center of the screen using spherical coordinates
 */
class CCOrbitCamera extends CCActionCamera
{
	var radius_ :Float;
	var deltaRadius_ :Float;
	var angleZ_ :Float;
	var deltaAngleZ_ :Float;
	var angleX_ :Float;
	var deltaAngleX_ :Float;
	
	var radZ_ :Float;
	var radDeltaZ_ :Float;
	var radX_ :Float;
	var radDeltaX_ :Float;
	
//
public function actionWithDuration (t:Float, r:Float) :id deltaRadius:(Float) dr angleZ:(Float)z deltaAngleZ:(Float)dz angleX:(Float)x deltaAngleX ( dx:Float )
{
	return new CCOrbitCamera().initWithDuration (t, r, dr, z, dz, x, dx);
}

public function copy () :CCOrbitCamera
{
	return new CCOrbitCamera().initWithDuration ( duration_, radius_, deltaRadius_, angleZ_, deltaAngleZ_, angleX_, deltaAngleX_ );
}


public function initWithDuration (t:Float, r:Float) :id deltaRadius:(Float) dr angleZ:(Float)z deltaAngleZ:(Float)dz angleX:(Float)x deltaAngleX ( dx:Float )
{
	if((this=super.initWithDuration:t]) ) {
	
		radius_ = r;
		deltaRadius_ = dr;
		angleZ_ = z;
		deltaAngleZ_ = dz;
		angleX_ = x;
		deltaAngleX_ = dx;

		radDeltaZ_ = (Float)CC_DEGREES_TO_RADIANS(dz);
		radDeltaX_ = (Float)CC_DEGREES_TO_RADIANS(dx);
	}
	
	return this;
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	var r, zenith, azimuth :Float;
	
	this.sphericalRadius: &r zenith:&zenith azimuth:&azimuth];
	
#if 0 // isnan() is not supported on the simulator, and isnan() always returns false.
	if( isnan(radius_) )
		radius_ = r;
	
	if( isnan( angleZ_) )
		angleZ_ = (Float)CC_RADIANS_TO_DEGREES(zenith);
	
	if( isnan( angleX_ ) )
		angleX_ = (Float)CC_RADIANS_TO_DEGREES(azimuth);
#end

	radZ_ = (Float)CC_DEGREES_TO_RADIANS(angleZ_);
	radX_ = (Float)CC_DEGREES_TO_RADIANS(angleX_);
}

public function update ( dt:Float )
{
	var r :Float = (radius_ + deltaRadius_ * dt) *CCCamera.getZEye;
	var za :Float = radZ_ + radDeltaZ_ * dt;
	var xa :Float = radX_ + radDeltaX_ * dt;

	var i :Float = Math.sin(za) * Math.cos(xa) * r + centerXOrig_;
	var j :Float = Math.sin(za) * Math.sin(xa) * r + centerYOrig_;
	var k :Float = Math.cos(za) * r + centerZOrig_;

	target_.camera.setEye (i,j,k);	
}

public function sphericalRadius (newRadius:Float, zenith:Float, azimuth:Float) :Void
{
	var ex, ey, ez, cx, cy, cz, x, y, z :Float;
	var r :Float; // radius
	var s :Float;
	
	var camera :CCCamera = target_.camera;
		camera.eye (&ex, &ey, &ez);
		camera.center (&cx, &cy, &cz);
	
	x = ex-cx;
	y = ey-cy;
	z = ez-cz;
	
	r = Math.sqrt( x*x + y*y + z*z);
	s = Math.sqrt( x*x + y*y);
	if(s==0.0)
		s = FLT_EPSILON;
	if(r==0.0)
		r = FLT_EPSILON;

	*zenith = acosf( z/r);
	if( x < 0 )
		*azimuth = (Float)M_PI - aMath.sin(y/s);
	else
		*azimuth = aMath.sin(y/s);
					
	*newRadius = r / CCCamera.getZEye();					
}
}
