/** Calls a 'callback' with the node as the first argument.
 N means Node
 */
package cocos.action;

class CCCallFuncN extends CCCallFunc
{
override public function execute ()
{
	targetCallback_.performSelector ( selector_, target_ );
}
}