/** Skews a CCNode object by skewX and skewY degrees
 @since v1.0
 */
class CCSkewBy extends CCSkewTo
{
}
}
public function initWithDuration (t:Float, deltaSkewX:Float) :id skewY ( deltaSkewY:Float )
{
	if( (this=super.initWithDuration:t skewX:deltaSkewX skewY:deltaSkewY]) ) {	
		skewX_ = deltaSkewX;
		skewY_ = deltaSkewY;
	}
	return this;
}

public function startWithTarget:(CCNode *)aTarget
{
	super.startWithTarget ( aTarget );
	deltaX_ = skewX_;
	deltaY_ = skewY_;
	endSkewX_ = startSkewX_ + deltaX_;
	endSkewY_ = startSkewY_ + deltaY_;
}

public function reverse () :CCActionInterval
{
	return [this.class] actionWithDuration:duration_ skewX:-skewX_ skewY:-skewY_];
}
}
