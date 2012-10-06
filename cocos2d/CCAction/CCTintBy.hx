/** Tints a CCNode that implements the CCNodeRGB protocol from current tint to a custom one.
 @since v0.7.2
 */
class CCTintBy extends CCActionInterval
{
	GLshort deltaR_, deltaG_, deltaB_;
	GLshort fromR_, fromG_, fromB_;
}
/** creates an action with duration and color */
public function actionWithDuration (duration:Float, deltaRed:GLshort) :id green:(GLshort)deltaGreen blue:(GLshort)deltaBlue;
/** initializes the action with duration and color */
public function initWithDuration (duration:Float, deltaRed:GLshort) :id green:(GLshort)deltaGreen blue:(GLshort)deltaBlue;

public function actionWithDuration (t:Float, r:GLshort) :id green:(GLshort)g blue ( b:GLshort )
{
	return [[(CCTintBy*)[ this alloc] initWithDuration:t red:r green:g blue:b] autorelease];
}

public function initWithDuration (t:Float, r:GLshort) :id green:(GLshort)g blue ( b:GLshort )
{
	if( (this=super.initWithDuration: t] ) ) {
		deltaR_ = r;
		deltaG_ = g;
		deltaB_ = b;
	}
	return this;
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	color :CC_Color3B = tn.color;
	fromR_ = color.r;
	fromG_ = color.g;
	fromB_ = color.b;
}

function update (t:Float) :Void
{
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	tn.setColor:ccc3( fromR_ + deltaR_ * t, fromG_ + deltaG_ * t, fromB_ + deltaB_ * t);
}

public function reverse () :CCActionInterval
{
	return CCTintBy.actionWithDuration:duration_ red:-deltaR_ green:-deltaG_ blue:-deltaB_];
}
}
