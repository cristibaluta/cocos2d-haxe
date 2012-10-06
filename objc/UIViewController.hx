//
//  UIViewController
//
//  Created by Baluta Cristian on 2011-12-15.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//

class UIViewController {
	
	public var view :Dynamic;
	public function setView (view:Dynamic) :Dynamic {
		this.view = view;
	}
	
	public function new(){
		super();
		init();
	}
	function init(){
		
	}
	public function destroy(){
		super.destroy();
	}
}
