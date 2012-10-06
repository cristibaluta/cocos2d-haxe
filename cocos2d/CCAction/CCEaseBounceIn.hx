//
// EaseBounceIn
//
/** CCEaseBounceIn action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
*/
class CCEaseBounceIn extends CCEaseBounce
{

function update (t:Float) :Void
{
	var newT :Float = 1 - this.bounceTime:1-t];	
	other.update ( newT );
}

public function reverse () :CCActionInterval
{
	return CCEaseBounceOut.actionWithAction: other.reverse]];
}

}