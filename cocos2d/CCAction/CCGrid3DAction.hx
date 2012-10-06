/** Base class for CCGrid3D actions.
 Grid3D actions can modify a non-tiled grid.
 */
class CCGrid3DAction extends CCGridAction
{
//
public function grid () :CCGridBase
{
	return CCGrid3D.gridWithSize ( gridSize_ );
}

public function vertex ( pos:CC_GridSize ) :CC_Vertex3F
{
	var g :CCGrid3D = (CCGrid3D *)target_.grid;
	return g.vertex ( pos );
}

public function originalVertex ( pos:CC_GridSize ) :CC_Vertex3F
{
	var g :CCGrid3D = (CCGrid3D *)target_.grid;
	return g.originalVertex ( pos );
}

public function setVertex (pos:CC_GridSize, vertex:CC_Vertex3F) :Void
{
	var g :CCGrid3D = (CCGrid3D *)target_.grid;
	g.setVertex ( pos, vertex );
}

}