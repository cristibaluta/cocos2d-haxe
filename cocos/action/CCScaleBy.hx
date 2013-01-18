/** Scales a CCNode object a zoom factor by modifying it's scale attribute.
*/
class CCScaleBy extends CCScaleTo
{
}
}
public function startWithTarget:(CCNode *)aTarget
{
	super.startWithTarget ( aTarget );
	deltaX_ = startScaleX_ * endScaleX_ - startScaleX_;
	deltaY_ = startScaleY_ * endScaleY_ - startScaleY_;
}

public function reverse () :CCActionInterval
{
	return [this.class] actionWithDuration:duration_ scaleX:1/endScaleX_ scaleY:1/endScaleY_];
}
}
