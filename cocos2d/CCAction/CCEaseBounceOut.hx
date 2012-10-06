/** EaseBounceOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
class CCEaseBounceOut extends CCEaseBounce
{

function update (t:Float) :Void
{
	var newT = this.bounceTime(t);	
	other.update ( newT );
}

public function reverse () :CCActionInterval
{
	return CCEaseBounceIn.actionWithAction( other.reverse() );
}

}