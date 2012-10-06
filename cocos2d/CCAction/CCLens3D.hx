/** CCLens3D action */
class CCLens3D extends CCGrid3DAction
{
	var position_ :CGPoint;
	var positionInPixels_ :CGPoint;
	var radius_ :Float;
	var lensEffect_ :Float;
	var dirty_ :Bool;
}

/** lens effect. Defaults to 0.7 - 0 means no effect, 1 is very strong effect */
public var lensEffect (get_lensEffect, set_lensEffect) :Float;
/** lens center position in Points */
public var position (get_position, set_position) :CGPoint;

/** creates the action with center position in Points, radius, a grid size and duration */
public static function actionWithPosition ( pos:CGPoint, r:Float, gridSize:CC_GridSize, d:Float ) :id;
/** initializes the action with center position in Points, radius, a grid size and duration */
public function initWithPosition ( pos:CGPoint, r:Float, gridSize:CC_GridSize, d:Float ) :id;
//
public var lensEffect (get_lensEffect, set_lensEffect) :;

public static function actionWithPosition ( pos:CGPoint, r:Float, gridSize:CC_GridSize ) :id duration ( d:Float )
{
	return new XXX().initWithPosition:pos radius:r grid:gridSize duration:d] autorelease];
}

public function initWithPosition ( pos:CGPoint, r:Float, gSize:CC_GridSize ) :id duration ( d:Float )
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		position_ = new CGPoint (-1,-1);
		this.position = pos;
		radius_ = r;
		lensEffect_ = 0.7;
		dirty_ = true;
	}
	
	return this;
}

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithPosition ( position_, radius_, gridSize_, duration_ );
	return copy;
}

public function setPosition ( pos:CGPoint )
{
	if( ! pos.equalToPoint(position_) ) {
		position_ = pos;
		positionInPixels_.x = pos.x * CCConfig.CC_CONTENT_SCALE_FACTOR;
		positionInPixels_.y = pos.y * CCConfig.CC_CONTENT_SCALE_FACTOR;
		
		dirty_ = true;
	}
}

public function position () :CGPoint
{
	return position_;
}
	
function update (time:Float) :Void
{
	if ( dirty_ )
	{
		int i, j;
		
		for( i = 0; i < gridSize_.x+1; i++ )
		{
			for( j = 0; j < gridSize_.y+1; j++ )
			{
				CC_Vertex3F	v = this.originalVertex:new CC_GridSize(i,j);
				var vect :CGPoint = CGPointExtension.sub(positionInPixels_, new CGPoint (v.x,v.y));
				var r :Float = CGPointExtension.length(vect);
				
				if ( r < radius_ )
				{
					r = radius_ - r;
					var pre_log :Float = r / radius_;
					if ( pre_log == 0 ) pre_log = 0.001;
					var l :Float = logf(pre_log) * lensEffect_;
					var new_r :Float = expf( l ) * radius_;
					
					if ( CGPointExtension.length(vect) > 0 )
					{
						vect = ccpNormalize(vect);
						var new_vect :CGPoint = ccpMult(vect, new_r);
						v.z += CGPointExtension.length(new_vect) * lensEffect_;
					}
				}
				
				this.setVertex:new CC_GridSize(i,j) vertex ( v );
			}
		}
		
		dirty_ = false;
	}
}

}