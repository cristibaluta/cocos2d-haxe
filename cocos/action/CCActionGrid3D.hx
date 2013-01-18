/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 On-Core
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */
import cocos.CCActionGrid;
import cocos.CCMacros;

using cocos.support.CGPointExtension;


/** CCWaves3D action */
class CCWaves3D extends CCGrid3DAction
{
var waves :Int;
var amplitude :Float;
var amplitudeRate :Float;


/** amplitude of the wave */
public var amplitude (get_amplitude, set_amplitude) :Float;
/** amplitude rate of the wave */
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :Float;

public static function actionWithWaves ( wav:Int, amp:Float, gridSize:CCGridSize, d:Float ) :id;
public function initWithWaves ( wav:int, amp:Float, gridSize:CCGridSize, d:Float ) :id;

}

////////////////////////////////////////////////////////////

/** CCFlipX3D action */
class CCFlipX3D extends CCGrid3DAction
{
}

/** creates the action with duration */
public static function  actionWithDuration:(Float)d;
/** initizlies the action with duration */
public function initWithDuration (d:Float) :id

}

////////////////////////////////////////////////////////////

/** CCFlipY3D action */
class CCFlipY3D extends CCFlipX3D
{
}

}

////////////////////////////////////////////////////////////

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
public static function actionWithPosition ( pos:CGPoint, r:Float, gridSize:CCGridSize, d:Float ) :id;
/** initializes the action with center position in Points, radius, a grid size and duration */
public function initWithPosition ( pos:CGPoint, r:Float, gridSize:CCGridSize, d:Float ) :id;

}

////////////////////////////////////////////////////////////

/** CCRipple3D action */
class CCRipple3D extends CCGrid3DAction
{
	var position_ :CGPoint;
	var positionInPixels_ :CGPoint;
	var radius_ :Float;
	var waves_ :Int;
	var amplitude_ :Float;
	var amplitudeRate_ :Float;
}

/** center position in Points */
public var position (get_position, set_position) :CGPoint;
/** amplitude */
public var amplitude (get_amplitude, set_amplitude) :Float;
/** amplitude rate */
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :Float;

/** creates the action with a position in points, radius, number of waves, amplitude, a grid size and duration */
public static function actionWithPosition ( pos:CGPoint, r:Float, wav:int, amp:Float, gridSize:CCGridSize, d:Float ) :id;
/** initializes the action with a position in points, radius, number of waves, amplitude, a grid size and duration */
public function initWithPosition ( pos:CGPoint, r:Float, wav:int, amp:Float, gridSize:CCGridSize, d:Float ) :id;

}

////////////////////////////////////////////////////////////

/** CCShaky3D action */
class CCShaky3D extends CCGrid3DAction
{
	int randrange;
	var shakeZ :Bool;
}

/** creates the action with a range, shake Z vertices, a grid and duration */
public static function actionWithRange ( range:int, shakeZ:Bool, gridSize:CCGridSize, d:Float ) :id;
/** initializes the action with a range, shake Z vertices, a grid and duration */
public function initWithRange ( range:int, shakeZ:Bool, gridSize:CCGridSize, d:Float ) :id;

}

////////////////////////////////////////////////////////////

/** CCLiquid action */
class CCLiquid extends CCGrid3DAction
{
	int waves;
	var amplitude :Float;
	var amplitudeRate :Float;

}

/** amplitude */
public var amplitude (get_amplitude, set_amplitude) :Float;
/** amplitude rate */
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :Float;

/** creates the action with amplitude, a grid and duration */
public static function actionWithWaves ( wav:int, amp:Float, gridSize:CCGridSize, d:Float ) :id;
/** initializes the action with amplitude, a grid and duration */
public function initWithWaves ( wav:int, amp:Float, gridSize:CCGridSize, d:Float ) :id;

}

////////////////////////////////////////////////////////////

/** CCWaves action */
class CCWaves extends CCGrid3DAction
{
	var waves :Int;
	var amplitude :Float;
	var amplitudeRate :Float;
	var vertical :Bool;
	var horizontal :Bool;
}

/** amplitude */
public var amplitude (get_amplitude, set_amplitude) :Float;
/** amplitude rate */
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :Float;

/** initializes the action with amplitude, horizontal sin, vertical sin, a grid and duration */
public static function actionWithWaves ( wav:int, amp:Float, h:Bool, v:Bool, gridSize:CCGridSize, d:Float ) :id;
/** creates the action with amplitude, horizontal sin, vertical sin, a grid and duration */
public function initWithWaves ( wav:int, amp:Float, h:Bool, v:Bool, gridSize:CCGridSize, d:Float ) :id;

}

////////////////////////////////////////////////////////////

/** CCTwirl action */
class CCTwirl extends CCGrid3DAction
{
	var position_ :CGPoint;
	var positionInPixels_ :CGPoint;
	var twirls_ :Int;
	var amplitude_ :Float;
	var amplitudeRate_ :Float;
}

/** twirl center */
public var position (get_position, set_position) :CGPoint;
/** amplitude */
public var amplitude (get_amplitude, set_amplitude) :Float;
/** amplitude rate */
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :Float;

/** creates the action with center position, number of twirls, amplitude, a grid size and duration */
public static function actionWithPosition ( pos:CGPoint, t:int, amp:Float, gridSize:CCGridSize, d:Float ) :id;
/** initializes the action with center position, number of twirls, amplitude, a grid size and duration */
public function initWithPosition ( pos:CGPoint, t:int, amp:Float, gridSize:CCGridSize, d:Float ) :id;

}








// -
// Waves3D

class CCWaves3D

public var amplitude (get_amplitude, set_amplitude) :;
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :;

public static function actionWithWaves ( wav:int, amp:Float, gridSize:CCGridSize ) :id duration ( d:Float )
{
	return new XXX().initWithWaves:wav amplitude:amp grid:gridSize duration:d] autorelease];
}

public function initWithWaves ( wav:int, amp:Float, gSize:CCGridSize, d:Float )
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		waves = wav;
		amplitude = amp;
		amplitudeRate = 1.0;
	}
	
	return this;
}

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithWaves ( waves, amplitude, gridSize_, duration_ );
	return copy;
}


function update (time:Float) :Void
{
	int i, j;
	
	for( i = 0; i < (gridSize_.x+1); i++ )
	{
		for( j = 0; j < (gridSize_.y+1); j++ )
		{
			CC_Vertex3F	v = this.originalVertex:new CCGridSize(i,j)];
			v.z += (Math.sin((Float)M_PI*time*waves*2 + (v.y+v.x) * .01f) * amplitude * amplitudeRate);
			this.setVertex:new CCGridSize(i,j) vertex ( v );
		}
	}
}
}

////////////////////////////////////////////////////////////

// -
// FlipX3D

class CCFlipX3D

public static function  actionWithDuration ( d:Float )
{
	return new XXX().initWithSize:new CCGridSize(1,1) duration:d] autorelease];
}

-(id) initWithDuration ( d:Float )
{
	return super.initWithSize:new CCGridSize(1,1) duration ( d );
}

public function initWithSize ( gSize:CCGridSize, d:Float ) :id
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
	var angle :Float = (Float)M_PI * time; // 180 degrees
	var mz :Float = Math.sin( angle );
	angle = angle / 2.0;     // x calculates degrees from 0 to 90
	var mx :Float = Math.cos( angle );
	
	CC_Vertex3F	v0, v1, v, diff;
	
	v0 = this.originalVertex:new CCGridSize(1,1)];
	v1 = this.originalVertex:new CCGridSize(0,0)];
	
	Float	x0 = v0.x;
	Float	x1 = v1.x;
	var x :Float;
	CCGridSize	a, b, c, d;
	
	if ( x0 > x1 )
	{
		// Normal Grid
		a = new CCGridSize(0,0);
		b = new CCGridSize(0,1);
		c = new CCGridSize(1,0);
		d = new CCGridSize(1,1);
		x = x0;
	}
	else
	{
		// Reversed Grid
		c = new CCGridSize(0,0);
		d = new CCGridSize(0,1);
		a = new CCGridSize(1,0);
		b = new CCGridSize(1,1);
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

////////////////////////////////////////////////////////////

// -
// FlipY3D

class CCFlipY3D

function update (time:Float) :Void
{
	var angle :Float = (Float)M_PI * time; // 180 degrees
	var mz :Float = Math.sin( angle );
	angle = angle / 2.0;     // x calculates degrees from 0 to 90
	var my :Float = Math.cos( angle );
	
	CC_Vertex3F	v0, v1, v, diff;
	
	v0 = this.originalVertex:new CCGridSize(1,1)];
	v1 = this.originalVertex:new CCGridSize(0,0)];
	
	Float	y0 = v0.y;
	Float	y1 = v1.y;
	var y :Float;
	CCGridSize	a, b, c, d;
	
	if ( y0 > y1 )
	{
		// Normal Grid
		a = new CCGridSize(0,0);
		b = new CCGridSize(0,1);
		c = new CCGridSize(1,0);
		d = new CCGridSize(1,1);
		y = y0;
	}
	else
	{
		// Reversed Grid
		b = new CCGridSize(0,0);
		a = new CCGridSize(0,1);
		d = new CCGridSize(1,0);
		c = new CCGridSize(1,1);
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

////////////////////////////////////////////////////////////

// -
// Lens3D

class CCLens3D

public var lensEffect (get_lensEffect, set_lensEffect) :;

public static function actionWithPosition ( pos:CGPoint, r:Float, gridSize:CCGridSize ) :id duration ( d:Float )
{
	return new XXX().initWithPosition:pos radius:r grid:gridSize duration:d] autorelease];
}

public function initWithPosition ( pos:CGPoint, r:Float, gSize:CCGridSize ) :id duration ( d:Float )
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
				var	v :CC_Vertex3F = this.originalVertex ( new CCGridSize (i,j));
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
				
				this.setVertex:new CCGridSize(i,j) vertex ( v );
			}
		}
		
		dirty_ = false;
	}
}

}

////////////////////////////////////////////////////////////

// -
// Ripple3D

class CCRipple3D

public var amplitude (get_amplitude, set_amplitude) :;
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :;

public static function actionWithPosition ( pos:CGPoint, r:Float, wav:int, amp:Float, gridSize:CCGridSize ) :id duration ( d:Float )
{
	return new XXX().initWithPosition:pos radius:r waves:wav amplitude:amp grid:gridSize duration:d] autorelease];
}

public function initWithPosition ( pos:CGPoint, r:Float, wav:int, amp:Float, gSize:CCGridSize, d:Float ) :id
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		this.position = pos;
		radius_ = r;
		waves_ = wav;
		amplitude_ = amp;
		amplitudeRate_ = 1.0;
	}
	
	return this;
}

public function position () :CGPoint
{
	return position_;
}

public function setPosition ( pos:CGPoint )
{
	position_ = pos;
	positionInPixels_.x = pos.x * CCConfig.CC_CONTENT_SCALE_FACTOR;
	positionInPixels_.y = pos.y * CCConfig.CC_CONTENT_SCALE_FACTOR;
}

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithPosition ( position_, radius_, waves_, amplitude_, gridSize_, duration_ );
	return copy;
}


function update (time:Float) :Void
{
	int i, j;
	
	for( i = 0; i < (gridSize_.x+1); i++ )
	{
		for( j = 0; j < (gridSize_.y+1); j++ )
		{
			CC_Vertex3F	v = this.originalVertex:new CCGridSize(i,j)];
			var vect :CGPoint = CGPointExtension.sub(positionInPixels_, new CGPoint (v.x,v.y));
			var r :Float = CGPointExtension.length(vect);
			
			if ( r < radius_ )
			{
				r = radius_ - r;
				var rate :Float = powf( r / radius_, 2);
				v.z += (Math.sin( time*(Float)M_PI*waves_2 + r * 0.1) * amplitude_ * amplitudeRate_ * rate );
			}
			
			this.setVertex:new CCGridSize(i,j) vertex ( v );
		}
	}
}

}

////////////////////////////////////////////////////////////

// -
// Shaky3D

class CCShaky3D

public static function actionWithRange ( range:int, sz:Bool, gridSize:CCGridSize ) :id duration ( d:Float )
{
	return new XXX().initWithRange:range shakeZ:sz grid:gridSize duration:d] autorelease];
}

public function initWithRange ( range:int, sz:Bool, gSize:CCGridSize ) :id duration ( d:Float )
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
			CC_Vertex3F	v = this.originalVertex:new CCGridSize(i,j)];
			v.x += ( rand() % (randrange*2) ) - randrange;
			v.y += ( rand() % (randrange*2) ) - randrange;
			if( shakeZ )
				v.z += ( rand() % (randrange*2) ) - randrange;
			
			this.setVertex:new CCGridSize(i,j) vertex ( v );
		}
	}
}

}

////////////////////////////////////////////////////////////

// -
// Liquid

class CCLiquid

public var amplitude (get_amplitude, set_amplitude) :;
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :;

public static function actionWithWaves ( wav:int, amp:Float, gridSize:CCGridSize ) :id duration ( d:Float )
{
	return new XXX().initWithWaves:wav amplitude:amp grid:gridSize duration:d] autorelease];
}

public function initWithWaves ( wav:int, amp:Float, gSize:CCGridSize ) :id duration ( d:Float )
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		waves = wav;
		amplitude = amp;
		amplitudeRate = 1.0;
	}
	
	return this;
}

function update (time:Float) :Void
{
	int i, j;
	
	for( i = 1; i < gridSize_.x; i++ )
	{
		for( j = 1; j < gridSize_.y; j++ )
		{
			CC_Vertex3F	v = this.originalVertex:new CCGridSize(i,j)];
			v.x = (v.x + (Math.sin(time*(Float)M_PI*waves*2 + v.x * .01f) * amplitude * amplitudeRate));
			v.y = (v.y + (Math.sin(time*(Float)M_PI*waves*2 + v.y * .01f) * amplitude * amplitudeRate));
			this.setVertex:new CCGridSize(i,j) vertex ( v );
		}
	}
}	

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithWaves ( waves, amplitude, gridSize_, duration_ );
	return copy;
}

}

////////////////////////////////////////////////////////////

// -
// Waves

class CCWaves

public var amplitude (get_amplitude, set_amplitude) :;
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :;

public static function actionWithWaves ( wav:int, amp:Float, h:Bool, v:Bool, gridSize:CCGridSize ) :id duration ( d:Float )
{
	return new XXX().initWithWaves:wav amplitude:amp horizontal:h vertical:v grid:gridSize duration:d] autorelease];
}

public function initWithWaves ( wav:int, amp:Float, h:Bool, v:Bool, gSize:CCGridSize, d:Float ) :id
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		waves = wav;
		amplitude = amp;
		amplitudeRate = 1.0;
		horizontal = h;
		vertical = v;
	}
	
	return this;
}

function update (time:Float) :Void
{
	int i, j;
	
	for( i = 0; i < (gridSize_.x+1); i++ )
	{
		for( j = 0; j < (gridSize_.y+1); j++ )
		{
			CC_Vertex3F	v = this.originalVertex:new CCGridSize(i,j)];
			
			if ( vertical )
				v.x = (v.x + (Math.sin(time*(Float)M_PI*waves*2 + v.y * .01f) * amplitude * amplitudeRate));
			
			if ( horizontal )
				v.y = (v.y + (Math.sin(time*(Float)M_PI*waves*2 + v.x * .01f) * amplitude * amplitudeRate));
					
			this.setVertex:new CCGridSize(i,j) vertex ( v );
		}
	}
}

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithWaves ( waves, amplitude, horizontal, vertical, gridSize_, duration_ );
	return copy;
}

}

////////////////////////////////////////////////////////////

// -
// Twirl

class CCTwirl

public var amplitude (get_amplitude, set_amplitude) :;
public var amplitudeRate (get_amplitudeRate, set_amplitudeRate) :;

public static function actionWithPosition ( pos:CGPoint, t:int, amp:Float, gridSize:CCGridSize, d:Float )
{
	return new XXX().initWithPosition:pos twirls:t amplitude:amp grid:gridSize duration:d] autorelease];
}

public function initWithPosition ( pos:CGPoint, t:int, amp:Float, gSize:CCGridSize, d:Float )
{
	if ( (this = super.initWithSize:gSize duration:d]) )
	{
		this.position = pos;
		twirls_ = t;
		amplitude_ = amp;
		amplitudeRate_ = 1.0;
	}
	
	return this;
}

public function setPosition ( pos:CGPoint )
{
	position_ = pos;
	positionInPixels_.x = pos.x * CCConfig.CC_CONTENT_SCALE_FACTOR;
	positionInPixels_.y = pos.y * CCConfig.CC_CONTENT_SCALE_FACTOR;
}

public function position () :CGPoint
{
	return position_;
}

function update (time:Float) :Void
{
	var i, j :Int;
	var c :CGPoint = positionInPixels_;
	
	for( i = 0; i < (gridSize_.x+1); i++ )
	{
		for( j = 0; j < (gridSize_.y+1); j++ )
		{
			var v :CC_Vertex3F = this.originalVertex ( new CCGridSize(i,j) );
			
			var avg :CGPoint = new CGPoint (i-(gridSize_.x/2.0), j-(gridSize_.y/2.0));
			var r :Float = CGPointExtension.length( avg );
			
			var amp :Float = 0.1 * amplitude_ * amplitudeRate_;
			var a :Float = r * Math.cos( M_PI/2.0 + time * M_PI * twirls_ * 2 ) * amp;
			
			var cosA :Float = Math.cos(a);
			var sinA :Float = Math.sin(a);
			
			var d :CGPoint = {
				sinA * (v.y-c.y) + cosA * (v.x-c.x),
				cosA * (v.y-c.y) - sinA * (v.x-c.x)
			}
			
			v.x = c.x + d.x;
			v.y = c.y + d.y;
			
			this.setVertex ( new CCGridSize(i,j), v );
		}
	}
}

public function copyWithZone (zone:NSZone) :id
{
	var copy :CCGridAction = [[this.class] allocWithZone:zone] initWithPosition:position_
																	  twirls:twirls_
																   amplitude:amplitude_
																		grid:gridSize_
																	duration ( duration_ );
	return copy;
}


}
