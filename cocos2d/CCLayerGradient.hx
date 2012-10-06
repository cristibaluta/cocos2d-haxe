// -
// CCLayerGradient

/** CCLayerGradient is a subclass of CCLayerColor that draws gradients across
the background.

 All features from CCLayerColor are valid, plus the following new features:
 - direction
 - final color
 - interpolation mode

 Color is interpolated between the startColor and endColor along the given
 vector (starting at the origin, ending at the terminus).  If no vector is
 supplied, it defaults to (0, -1) -- a fade from top to bottom.

 If 'compressedInterpolation' is disabled, you will not see either the start or end color for
 non-cardinal vectors; a smooth gradient implying both end points will be still
 be drawn, however.

 If ' compressedInterpolation' is enabled (default mode) you will see both the start and end colors of the gradient.

 @since v0.99.5
 */
class CCLayerGradient extends CCLayerColor
{
var endColor_ :CC_Color3B;
var startOpacity_ :Float;
var endOpacity_ :Float;
var vector_ :CGPoint;
var compressedInterpolation_ :Bool;


/** The starting color. */
public var startColor (getStartColor, setStartColor) :CC_Color3B;
/** The ending color. */
public var endColor (get_endColor, set_endColor) :CC_Color3B;
/** The starting opacity. */
public var startOpacity (get_startOpacity, set_startOpacity) :Float;
/** The ending color. */
public var endOpacity (get_endOpacity, set_endOpacity) :Float;
/** The vector along which to fade color. */
public var vector (get_vector, set_vector) :CGPoint;
/** Whether or not the interpolation will be compressed in order to display all the colors of the gradient
	both in canonical and non canonical vectors
 Default: true
 */
public var compressedInterpolation (get_compressedInterpolation, set_compressedInterpolation) :Bool;



/** Creates a full-screen CCLayer with a gradient between start and end in the direction of v. */
public static function layerWithColor (start:CC_Color4B, end:CC_Color4B, ?v:CGPoint) :CCLayerGradient
{
    return new CCLayerGradient().initWithColor (start, end, v);
}

/** Initializes the CCLayer with a gradient between start and end in the direction of v. */
public function initWithColor (start:CC_Color4B, end:CC_Color4B, ?v:CGPoint) :CCLayerGradient
{
	if (v == null)
		v = new CGPoint(0, -1);
		
	endColor_.r = end.r;
	endColor_.g = end.g;
	endColor_.b = end.b;
	
	endOpacity_	= end.a;
	startOpacity_ = start.a;
	vector_ = v;
	
	start.a	= 255;
	compressedInterpolation_ = true;

	return super.initWithColor(start);
}

public function updateColor () :Void
{
    super.updateColor();

	var h :Float = CGPointExtension.length(vector_);
    if (h == 0)
		return;

	var c :Float = Math.sqrt(2);
    var u :CGPoint = new CGPoint (vector_.x / h, vector_.y / h);

	// Compressed Interpolation mode
	if( compressedInterpolation_ ) {
		var h2 :Float = 1 / ( Math.abs(u.x) + Math.abs(u.y) );
		u = ccpMult(u, h2 * c);
	}
	
	var opacityf :Float = opacity_/255.0;
	
    var S :CC_Color4B = {
		r:color_.r,
		g:color_.g,
		b:color_.b,
		a:startOpacity_opacityf
	};

    var E :CC_Color4B = {
		r:endColor_.r,
		g:endColor_.g,
		b:endColor_.b,
		a:endOpacity_opacityf
	};


    // (-1, -1)
	squareColors_[0].r = E.r + (S.r - E.r) * ((c + u.x + u.y) / (2.0 * c));
	squareColors_[0].g = E.g + (S.g - E.g) * ((c + u.x + u.y) / (2.0 * c));
	squareColors_[0].b = E.b + (S.b - E.b) * ((c + u.x + u.y) / (2.0 * c));
	squareColors_[0].a = E.a + (S.a - E.a) * ((c + u.x + u.y) / (2.0 * c));
    // (1, -1)
	squareColors_[1].r = E.r + (S.r - E.r) * ((c - u.x + u.y) / (2.0 * c));
	squareColors_[1].g = E.g + (S.g - E.g) * ((c - u.x + u.y) / (2.0 * c));
	squareColors_[1].b = E.b + (S.b - E.b) * ((c - u.x + u.y) / (2.0 * c));
	squareColors_[1].a = E.a + (S.a - E.a) * ((c - u.x + u.y) / (2.0 * c));
	// (-1, 1)
	squareColors_[2].r = E.r + (S.r - E.r) * ((c + u.x - u.y) / (2.0 * c));
	squareColors_[2].g = E.g + (S.g - E.g) * ((c + u.x - u.y) / (2.0 * c));
	squareColors_[2].b = E.b + (S.b - E.b) * ((c + u.x - u.y) / (2.0 * c));
	squareColors_[2].a = E.a + (S.a - E.a) * ((c + u.x - u.y) / (2.0 * c));
	// (1, 1)
	squareColors_[3].r = E.r + (S.r - E.r) * ((c - u.x - u.y) / (2.0 * c));
	squareColors_[3].g = E.g + (S.g - E.g) * ((c - u.x - u.y) / (2.0 * c));
	squareColors_[3].b = E.b + (S.b - E.b) * ((c - u.x - u.y) / (2.0 * c));
	squareColors_[3].a = E.a + (S.a - E.a) * ((c - u.x - u.y) / (2.0 * c));
}

public function getStartColor () :CC_Color3B
{
	return color_;
}

public function setStartColor (colors:CC_Color3B) :CC_Color3B
{
	this.setColor(colors);
}

public function setEndColor (colors:CC_Color3B) :CC_Color3B
{
    endColor_ = colors;
    this.updateColor();
}

public function setStartOpacity (o:Float) :Float
{
	startOpacity_ = o;
    this.updateColor();
}

public function setEndOpacity (o:Float) :Float
{
    endOpacity_ = o;
    this.updateColor();
}

public function setVector (v:CGPoint)
{
    vector_ = v;
    this.updateColor();
}

public function compressedInterpolation () :Bool
{
	return compressedInterpolation_;
}

public function setCompressedInterpolation (compress:Bool) :Void
{
	compressedInterpolation_ = compress;
	this.updateColor();
}
}