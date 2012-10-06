/** Calls a 'callback' with the node as the first argument.
 N means Node
 */
class CCCallFuncN extends CCCallFunc
{
override public function execute ()
{
	targetCallback_.performSelector ( selector_, target_ );
}
}