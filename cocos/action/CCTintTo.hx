/** Tints a CCNode that implements the CCNodeRGB protocol from current tint to a custom one.
 @warning This action doesn't support "reverse"
 @since v0.7.2
*/
package cocos.action;

class CCTintTo extends CCActionInterval
{
	to_ :CC_Color3B;
	from_ :CC_Color3B;
}
/** creates an action with duration and color */
public function actionWithDuration (duration:Float, red:Float) :id green:(Float)green blue:(Float)blue;
/** initializes the action with duration and color */
public function initWithDuration (duration:Float, red:Float) :id green:(Float)green blue:(Float)blue;

public function actionWithDuration (t:Float, r:Float) :id green:(Float)g blue ( b:Float )
{
	return [[(CCTintTo*)[ this alloc] initWithDuration:t red:r green:g blue:b] autorelease];
}

-(id) initWithDuration: (Float) t red:(Float)r green:(Float)g blue ( b:Float )
{
	if( (this=super.initWithDuration:t] ) )
		to_ = ccc3(r,g,b);
	
	return this;
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	from_ = tn.color;
}

function update (t:Float) :Void
{
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	tn.setColor:ccc3(from_.r + (to_.r - from_.r) * t, from_.g + (to_.g - from_.g) * t, from_.b + (to_.b - from_.b) * t);
}
}
