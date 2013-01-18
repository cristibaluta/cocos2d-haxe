/** Places the node in a certain position
 */
package cocos.action;

class CCPlace extends CCActionInstant
{
var position :CGPoint;
//
public static function actionWithPosition ( pos:CGPoint ) :CCPlace
{
	return new CCPlace().initWithPosition ( pos );
}

public function initWithPosition ( pos:CGPoint ) :CCPlace
{
	super.init();
	position = pos;
	
	return this;
}

public function startWithTarget (aTarget:Dynamic )
{
	super.startWithTarget ( aTarget );
	cast(target_, CCNode).position = position;
}
}