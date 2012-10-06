/** An action that moves the target with a cubic Bezier curve to a destination point.
 @since v0.8.2
 */
class CCBezierTo extends CCBezierBy
{
public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	config_.controlPoint_1 = CGPointExtension.sub(config_.controlPoint_1, startPosition_);
	config_.controlPoint_2 = CGPointExtension.sub(config_.controlPoint_2, startPosition_);
	config_.endPosition = CGPointExtension.sub(config_.endPosition, startPosition_);
}
}
