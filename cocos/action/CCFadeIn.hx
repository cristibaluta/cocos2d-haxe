/** Fades In an object that implements the CCRGBAProtocol protocol. It modifies the opacity from 0 to 255.
 The "reverse" of this action is FadeOut
 */
package cocos.action;

class CCFadeIn extends CCActionInterval
{

function update (t:Float) :Void
{
	/*[(id<CCRGBAProtocol>) */target_.set_opacity ( 255 *t);
}

public function reverse () :CCActionInterval
{
	return CCFadeOut.actionWithDuration ( duration_ );
}
}
