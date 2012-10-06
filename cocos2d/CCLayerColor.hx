// -
// CCLayerColor

/** CCLayerColor is a subclass of CCLayer that implements the CCRGBAProtocol protocol.

 All features from CCLayer are valid, plus the following new features:
 - opacity
 - RGB colors
 */
import CCTypes;

class CCLayerColor extends CCLayer
{
var opacity_ :Float;
var color_ :CC_Color3B;
var squareVertices_ :CC_Vertex2F;
var squareColors_ :CC_Color4B;
var blendFunc_ :CC_BlendFunc;


/** Opacity: conforms to CCRGBAProtocol protocol */
public var opacity (get_opacity, null) :Float;
/** Opacity: conforms to CCRGBAProtocol protocol */
public var color (get_color, set_color) :CC_Color3B;
/** BlendFunction. Conforms to CCBlendProtocol protocol */
public var blendFunc (get_blendFunc, set_blendFunc) :CC_BlendFunc;


/** creates a CCLayer with color, width and height in Points*/
public static function layerWithColor (color:CC_Color4B, ?w:Null<Float>, ?h:Null<Float>) :CCLayerColor
{
	return new CCLayerColor().initWithColor (color, w, h);
}

/** initializes a CCLayer with color, width and height in Points */
public function initWithColor (color:CC_Color4B, ?w:Null<Float>, ?h:Null<Float>) :CCLayerColor
{
	super.init();
	
	var s :CGSize = CCDirector.sharedDirector().winSize();
	
	if (w == null)
		w = s.width;
	if (h == null)
		h = s.height;
		
	// default blend function
	blendFunc_ = { src:CC_BLEND_SRC, dst:CC_BLEND_DST };
	
	color_ = {
		r : color.r,
		g : color.g,
		b : color.b
	}
	opacity_ = color.a;
	
	for (i in 0...Math.round(sizeof(squareVertices_) / sizeof( squareVertices_[0]))) {
		squareVertices_[i].x = 0.0;
		squareVertices_[i].y = 0.0;
	}
	
	this.updateColor();
	this.setContentSize ( new CGSize(w, h) );
	
	return this;
}


// override contentSize
public function setContentSize (size:CGSize)
{
	squareVertices_[1].x = size.width * CCConfig.CC_CONTENT_SCALE_FACTOR;
	squareVertices_[2].y = size.height * CCConfig.CC_CONTENT_SCALE_FACTOR;
	squareVertices_[3].x = size.width * CCConfig.CC_CONTENT_SCALE_FACTOR;
	squareVertices_[3].y = size.height * CCConfig.CC_CONTENT_SCALE_FACTOR;
	
	super.setContentSize(size);
}

public function changeWidth (w:Float, ?h:Null<Float>) :Void
{
	if (h == null)
		h = contentSize_.height;
	this.setContentSize ( new CGSize (w, h) );
}

public function changeHeight (h:Float)
{
	this.setContentSize ( new CGSize (contentSize_.width, h) );
}

public function updateColor ()
{
	for (i in 0...4)
	{
		squareColors_[i].r = color_.r;
		squareColors_[i].g = color_.g;
		squareColors_[i].b = color_.b;
		squareColors_[i].a = opacity_;
	}
}

public function draw ()
{
	super.draw();

	// Default GL states: GL.TEXTURE_2D, GL.VERTEX_ARRAY, GL.COLOR_ARRAY, GL.TEXTURE_COORD_ARRAY
	// Needed states: GL.VERTEX_ARRAY, GL.COLOR_ARRAY
	// Unneeded states: GL.TEXTURE_2D, GL.TEXTURE_COORD_ARRAY
	glDisableClientState(GL.TEXTURE_COORD_ARRAY);
	glDisable(GL.TEXTURE_2D);

	glVertexPointer(2, GL.FLOAT, 0, squareVertices_);
	glColorPointer(4, GL.UNSIGNED_BYTE, 0, squareColors_);
	
	
	var newBlend :Bool = blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	
	else if( opacity_ != 255 ) {
		newBlend = true;
		glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
	}
	
	glDrawArrays(GL.TRIANGLE_STRIP, 0, 4);
	
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	// restore default GL state
	glEnableClientState(GL.TEXTURE_COORD_ARRAY);
	glEnable(GL.TEXTURE_2D);
}

// Protocols
// Color Protocol

public function set_color (color:CC_Color3B) :CC_Color3B
{
	color_ = color;
	this.updateColor();
	return color_;
}

public function setOpacity (o:Float) :Float
{
	opacity_ = o;
	this.updateColor();
	return o;
}

}
