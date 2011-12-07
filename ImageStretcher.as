package com.smp.bitmap
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ShaderFilter;
	import flash.text.TextField;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	
	import com.smp.common.display.MovieClipId;
	import com.smp.common.text.TextUtils;
	import com.smp.common.display.ShapeUtils;
	import com.smp.common.display.MovieClipUtilities;	
	
	
	
	public class ImageStretcher extends Sprite
	{
		
		
		private var _loader:URLLoader;
		private var _shader:Shader;
		private var _shaderFilter:ShaderFilter;
		
		private var _imageCont:Sprite;
		private var _imageDisplay:Bitmap;
		private var _bitmapData:BitmapData;
		
		private var _controlsCont:Sprite;
		
		private var _origins:Array;
		private var _destinations:Array;
		private var _debug:TextField;
		
		private var _activeControl:uint;
		
		public function ImageStretcher() {
			setup();
		}
		
		
		private function setup() {
			
			loadPixelBlender();
			
			_imageCont = new Sprite();
			addChild(_imageCont);
			
			_controlsCont = new Sprite();
			addChild(_controlsCont);
			
			_controlsCont.addEventListener(MouseEvent.MOUSE_OVER, function() { _controlsCont.visible = true;  } );
			_imageCont.addEventListener(MouseEvent.MOUSE_OVER, function() { _controlsCont.visible = true;  } );
			_imageCont.addEventListener(MouseEvent.MOUSE_OUT, function() { _controlsCont.visible = false; } );
			
			_debug = TextUtils.createTextField();
			_debug.x = 20;
			addChild(_debug);
			

		}
		
		private function loadPixelBlender() {
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(Event.COMPLETE, onPBReady);
			_loader.load(new URLRequest("assets/stretch_multiple_16.pbj"));
		}
		
		private function onPBReady(evt:Event ) {
			
			_shader = new Shader(_loader.data);
			_shaderFilter = new ShaderFilter(_shader);
			
			dispatchEvent(new Event(Event.COMPLETE));
		}

		
		public function setImage(image:Bitmap) 
		{
			
			if (_imageDisplay != null) {
				
				_imageCont.removeChild(_imageDisplay);
				_imageDisplay = null;
				
			}
			
			_imageDisplay = image;
			_bitmapData = _imageDisplay.bitmapData;
			var imgw:Number = _bitmapData.width;
			var imgh:Number = _bitmapData.height;
			
			_origins = [ [imgw/5, imgh/5], [imgw*2/5, imgh/5], [imgw*3/5, imgh/5], [imgw*4/5, imgh/5], [imgw/5, imgh*2/5], [imgw*2/5, imgh*2/5], [imgw*3/5, imgh*2/5], [imgw*4/5, imgh*2/5], [imgw/5, imgh*3/5], [imgw*2/5, imgh*3/5], [imgw*3/5, imgh*3/5], [imgw*4/5, imgh*3/5],[imgw/5, imgh*4/5], [imgw*2/5, imgh*4/5], [imgw*3/5, imgh*4/5], [imgw*4/5, imgh*4/5]];
			_destinations = [ [imgw/5, imgh/5], [imgw*2/5, imgh/5], [imgw*3/5, imgh/5], [imgw*4/5, imgh/5], [imgw/5, imgh*2/5], [imgw*2/5, imgh*2/5], [imgw*3/5, imgh*2/5], [imgw*4/5, imgh*2/5], [imgw/5, imgh*3/5], [imgw*2/5, imgh*3/5], [imgw*3/5, imgh*3/5], [imgw*4/5, imgh*3/5],[imgw/5, imgh*4/5], [imgw*2/5, imgh*4/5], [imgw*3/5, imgh*4/5], [imgw*4/5, imgh*4/5]];

			for (var i:uint = 0; i < _origins.length; i++) {
				_shader.data["origin"+(i+1)].value = _origins[i];
				_shader.data["destination"+(i+1)].value = _destinations[i];
			}
			
			_shaderFilter.shader = _shader;
			
			_imageCont.addChild(_imageDisplay);
			
			var j:uint;
			var mc:MovieClipId;
			
			if(_controlsCont.numChildren == 0){
				for ( j = 0; j < _origins.length; j++) 
				{
					mc = new MovieClipId();
					mc.id = j;
					mc.addChild(ShapeUtils.createCircle(5, 0xcccccc, 0.3, 0, 0, 1, 0x00cc00));
					mc.x = _origins[j][0];
					mc.y = _origins[j][1];
					_controlsCont.addChild(mc);
					MovieClipUtilities.setDraggable(mc, false, mc.x - 50, mc.y - 50, mc.x + 50, mc.y + 50, onControlDown, onControlUp);
				}
			}else {
				for ( j = 0; j < _origins.length; j++) 
				{
					mc = _controlsCont.getChildAt(j) as MovieClipId;
					mc.x = _origins[j][0];
					mc.y = _origins[j][1];
				}
			}
	
			
			_imageDisplay.filters = [_shaderFilter];	
			
		}
		
		private function onControlDown(obj:MovieClipId):void {
			
			_activeControl = obj.id;
			_debug.text = _activeControl.toString();
		}
		
		private function onControlUp(obj:MovieClipId):void {
			
			_destinations[_activeControl][0] = obj.x;
			_destinations[_activeControl][1] = obj.y;
			//_debug.text = _destinations[_activeControl][0].toString();
			processFilter();
		}
		
		
		
		private function processFilter():void 
		{
			for (var i:uint = 0; i < _origins.length; i++) {
				_shader.data["origin"+(i+1)].value = _origins[i];
				_shader.data["destination"+(i+1)].value = _destinations[i];
			}
			
			_shaderFilter.shader = _shader;
			_imageDisplay.filters = [_shaderFilter];			
			
		}
		
		public function getImageForOutput():Bitmap {
			
			var bmpdata:BitmapData = new BitmapData(_imageDisplay.bitmapData.width, _imageDisplay.bitmapData.height);
			bmpdata.draw(_imageDisplay, _imageDisplay.transform.matrix);
			return new Bitmap(bmpdata);
		}
		
	}
	
}