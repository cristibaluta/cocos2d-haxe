/** Base class for CCTiledGrid3D actions */
package cocos.action;

class CCTiledGrid3DAction extends CCGridAction
{
//
public function grid () :CCGridBase
{
	return CCTiledGrid3D.gridWithSize ( gridSize_ );
}

-(ccQuad3)tile ( pos:CC_GridSize )
{
	var g :CCTiledGrid3D = (CCTiledGrid3D *)target_.grid;
	return g.tile ( pos );
}

-(ccQuad3)originalTile ( pos:CC_GridSize )
{
	var g :CCTiledGrid3D = (CCTiledGrid3D *)target_.grid;
	return g.originalTile ( pos );
}

public function setTile (pos:CC_GridSize, coords:ccQuad3) :Void
{
	var g :CCTiledGrid3D = (CCTiledGrid3D *)target_.grid;
	g.setTile ( pos, coords );
}

}