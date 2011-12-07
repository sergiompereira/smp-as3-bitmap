package com.smp.bitmap{

	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;

	import flash.filters.ConvolutionFilter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	import com.smp.common.math.MathUtils;
	

	
	public class SmudgeImage extends Sprite {

		
		private var _mc:MovieClip;
		
		private var _convolutionFilter:ConvolutionFilter;
		private var _matriz:Array;

		private var _pt:Point;
		private var _rect:Rectangle;

		private var _imagemdata:BitmapData;
		private var _imagem:Bitmap;
		
		private var _imagemdataaux:BitmapData;
		private var _imagemaux:Bitmap;
		private var _imagemdataalpha:BitmapData;
		
		private var _brush:Number;
		private var _gradRatio:Number;
		
		private var _lastMousePosition:Point = new Point();
		private var _filterUtils:FilterUtils = new FilterUtils();
		
		private var _corOver:Number;
		private var _playing:Boolean = false;

		
		public function SmudgeImage(imagedata:BitmapData, brush:Number = 70) {

			_imagemdata =  imagedata;
			_imagem = new Bitmap(_imagemdata);

			_brush = brush;
			_gradRatio = MathUtils.scale(_brush, 0, 70, 0, 100);
			trace(_gradRatio)
			
			_pt = new Point();
			_rect = new Rectangle();

			_mc = new MovieClip();
			_mc.addChild(_imagem);
			addChild(_mc);

			_rect.width = _brush;
			_rect.height = _brush;
			
			//Cria o "pincél": um círculo com grandiente alpha radial
			var circulo:Shape = new Shape();
			
			with(circulo.graphics){
				beginGradientFill(GradientType.RADIAL, new Array(0xffffff, 0xffffff), new Array(1,0), new Array(0,_gradRatio));
				drawCircle(0,0,_brush/2);
				endFill();
			}
			
			_imagemdataaux =  new BitmapData(_brush,_brush,true, 1);			
			_imagemdataalpha = new BitmapData(_brush, _brush, true, 1);
			
			//para compensar a posição do círculo, centrada em (0,0)
			var matrix:Matrix = new Matrix();
			matrix.translate(_brush/2,_brush/2);
			
			_imagemdataalpha.draw(circulo, matrix);
			
			/*DEBUG
			_imagemaux = new Bitmap(_imagemdataaux);
			addChild(_imagemaux)
			*/
			
			start();
		}
		
		private function onMouseDown(evt:MouseEvent):void {
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			
			_lastMousePosition.x = mouseX;
			_lastMousePosition.y = mouseY;
		}
		private function onMouseUp(evt:MouseEvent):void {

			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		private function onMouseMove(evt:MouseEvent):void {
			
			
			_corOver = _imagemdata.getPixel(mouseX, mouseY);
			dispatchEvent(new Event(Event.CHANGE));
			
			_pt.x = mouseX-_brush/2;
			_pt.y = mouseY-_brush/2;
			_rect.x = mouseX-_brush/2;
			_rect.y = mouseY-_brush/2;

			_imagemdataaux.applyFilter(_imagemdata, _rect, new Point(0,0), FilterUtils.motionBlur(_lastMousePosition, new Point(mouseX, mouseY)));
			
			//DEBUG
			//_imagemdataaux.copyPixels(_imagemdataaux, new Rectangle(0,0,_brush,_brush), new Point(), _imagemdataalpha)
			
			_imagemdata.copyPixels(_imagemdataaux, new Rectangle(0,0,_brush,_brush), new Point(_pt.x,_pt.y), _imagemdataalpha)
		
			
			_lastMousePosition.x = mouseX;
			_lastMousePosition.y = mouseY;
			
		}
		
		public function get corOver():Number{
			return _corOver;
		}
		
		public function start():void{
			if(_playing == false){
				_playing = true;
				_mc.buttonMode = true;
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
				addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			}
		}
		
		public function stop():void{
			if(_playing == true){
				_playing = false;
				_mc.buttonMode = false;
				removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}
		
	}
}