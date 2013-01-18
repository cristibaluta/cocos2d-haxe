//
//  CGImageRef
//
//  Created by Baluta Cristian on 2011-11-05.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
package cocos.support;

import flash.display.Loader;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.net.URLStream;
import flash.net.URLRequest;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.utils.ByteArray;
import haxe.io.BytesData;


class UIImage {
	
	var loader :Loader;
	var imageStream :URLStream;
	var imageData :ByteArray;
	
	public var width :Int;
	public var height :Int;
	public var bitmap :Bitmap;
	public var bitmapData :BitmapData;
	
	dynamic public function onComplete () :Void {}
	dynamic public function onProgress () :Void {}
	dynamic public function onError () :Void {}
	
	
	public function new(){
		
		imageStream = new URLStream();
		imageStream.addEventListener( ProgressEvent.PROGRESS , imageStreamProgress );
		imageStream.addEventListener( Event.COMPLETE , imageStreamComplete );
		imageStream.addEventListener (ErrorEvent.ERROR, imageStreamError);
		imageStream.addEventListener (IOErrorEvent.IO_ERROR, imageStreamError);
		
		imageData = new ByteArray();
	}
	
	/**
	*  Async way of loading the image
	*/
	public function initWithContentsOfFile (path:String) :UIImage
	{
		trace("initWithContentsOfFile "+path);
		//if connected we need to stop that
		if (imageStream.connected)
			imageStream.close();
			imageStream.load ( new URLRequest( path ) );
		
		return this;
	}
	
	/**
	*  Sync way of loading the image (NOT REALLY)
	*/
	public function initWithData (data:BytesData) :UIImage
	{
		imageStreamComplete(null);
		
		return this;
	}
	
	
	function imageStreamProgress (e:ProgressEvent)
	{
		onProgress();
	}
	
	function imageStreamComplete (e:Event)
	{
		if (imageStream.connected )
			imageStream.readBytes( imageData, imageData.length );
		
		loader = new Loader();
		loader.contentLoaderInfo.addEventListener (Event.COMPLETE, loaderCompleteHandler);
		loader.loadBytes( imageData );
		
		if (imageStream.connected)
			imageStream.close();
	}
	
	function loaderCompleteHandler (e:Event) {
		
		width = Math.round (loader.content.width);
		height = Math.round (loader.content.height);
		
		#if neko
		bitmapData = new BitmapData (width, height, true, {rgb:0x000000, a:0});
		#else
		bitmapData = new BitmapData (width, height, true, 0x000000ff);
		#end
		bitmapData.draw ( loader.content );
		
		bitmap = new Bitmap (bitmapData, PixelSnapping.AUTO, true);
		
		onComplete();
	}
	
	function imageStreamError (_) {
		onError();
	}
	
	public function release () :Void
	{
		if (imageStream.connected)
			imageStream.close();
			imageStream.removeEventListener ( ProgressEvent.PROGRESS , imageStreamProgress );
			imageStream.removeEventListener ( Event.COMPLETE , imageStreamComplete );
			imageStream.removeEventListener ( ErrorEvent.ERROR, imageStreamError );
			imageStream.removeEventListener ( IOErrorEvent.IO_ERROR, imageStreamError );
		if (loader != null)
			loader.contentLoaderInfo.removeEventListener (Event.COMPLETE, loaderCompleteHandler);
		if (bitmapData != null)
			bitmapData.dispose();
		bitmap = null;
	}
}
