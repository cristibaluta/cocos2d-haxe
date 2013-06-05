/** bezier configuration structure
 */
typedef struct _ccBezierConfig {
	//! end position of the bezier
	var endPosition :CGPoint;
	//! Bezier control point 1
	var controlPoint_1 :CGPoint;
	//! Bezier control point 2
	var controlPoint_2 :CGPoint;
} ccBezierConfig;

/** An action that moves the target with a cubic Bezier curve by a certain distance.
 */
class CCBezierBy extends CCActionInterval
{
	ccBezierConfig config_;
	var startPosition_ :CGPoint;
}

/** creates the action with a duration and a bezier configuration */
public function actionWithDuration (t:Float, c:ccBezierConfig) :id;

/** initializes the action with a duration and a bezier configuration */
public function initWithDuration (t:Float, c:ccBezierConfig) :id;
}


// Bezier cubic formula:
//	((1 - t) + t)3 = 1 
// Expands to… 
//   (1 - t)3 + 3t(1-t)2 + 3t2(1 - t) + t3 = 1 
static inline Float bezierat( Float a, Float b, Float c, Float d, Float t )
{
	return (powf(1-t,3) * a + 
			3*t*(powf(1-t,2))*b + 
			3*powf(t,2)*(1-t)*c +
			powf(t,3)*d );
}

//
// BezierBy
//
class CCBezierBy
public function actionWithDuration (t:Float, c:ccBezierConfig) :id
{	
	return new XXX().initWithDuration:t bezier:c ] autorelease];
}

public function initWithDuration (t:Float, c:ccBezierConfig) :id
{
	if( (this=super.initWithDuration: t]) ) {
		config_ = c;
	}
	return this;
}

public function copyWithZone (zone:NSZone) :id
{
	var  copy :CCAction = [[this.class] allocWithZone: zone] initWithDuration:this.duration] bezier ( config_ );
    return copy;
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	startPosition_ = [(CCNode*)target_ position];
}

function update (t:Float) :Void
{
	var xa :Float = 0;
	var xb :Float = config_.controlPoint_1.x;
	var xc :Float = config_.controlPoint_2.x;
	var xd :Float = config_.endPosition.x;
	
	var ya :Float = 0;
	var yb :Float = config_.controlPoint_1.y;
	var yc :Float = config_.controlPoint_2.y;
	var yd :Float = config_.endPosition.y;
	
	var x :Float = bezierat(xa, xb, xc, xd, t);
	var y :Float = bezierat(ya, yb, yc, yd, t);
	target_.set_position:  ccpAdd( startPosition_, new CGPoint (x,y));
}

public function reverse () :CCActionInterval
{
	ccBezierConfig r;

	r.endPosition	 = ccpNeg(config_.endPosition);
	r.controlPoint_1 = ccpAdd(config_.controlPoint_2, ccpNeg(config_.endPosition));
	r.controlPoint_2 = ccpAdd(config_.controlPoint_1, ccpNeg(config_.endPosition));
	
	var action :CCBezierBy = [this.class] actionWithDuration:this.duration] bezier ( r );
	return action;
}
}