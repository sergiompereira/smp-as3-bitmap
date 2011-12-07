package com.smp.bitmap
{
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
		
	import com.smp.common.display.MovieClipUtilities;
	import com.smp.common.display.ShapeUtils;
	
	
	
	public class  DistortImageUtil
	{
		/**
		 * 
		 * @see org.flashsandy.display
		 * 
		 * @example import org.flashsandy.display.DistortImageUtil;
					var bmpd:BitmapData = new MyLibraryImage(0,0);
					var image:Bitmap = new Bitmap(bmpd);
					DistortImageUtil.createCornerHandlers(this, image);
			
		 * @param	container
		 * @param	image
		 */
		public static function createCornerHandlers(container:DisplayObjectContainer, image:Bitmap, draggable:Boolean = false):void {
			
			/*
			 * Hierarquia:
			 * _mainContainer
			 * 		userImageContainer(não registado, var local a _onImageLoaded)
			 * 		_overlayContainer
			 * 			_distortedMaskContainer
			 * 			_distortControlersContainer
			 * 
			 * (_mascara não é adicionado à displaylist)
			 * 
			 * No upload, é removido o _distortControlersContainer e é feito o bitmap de _mainContainer.
			 */
			
			
			var _overlayContainer:MovieClip = new MovieClip();
			container.addChild(_overlayContainer);
			
			
			var _distortedImageContainer:MovieClip = new MovieClip();
			_overlayContainer.addChild(_distortedImageContainer);
			
			if(draggable) {
				MovieClipUtilities.setDraggable(_distortedImageContainer, false, 0, 0, 0, 0, null, onMaskMove);
			}
			
			var _distortControlersContainer:Sprite = new Sprite();
			_overlayContainer.addChild(_distortControlersContainer);
			
			
			var _distortControlersCollection:Array = new Array();
			for (var i:int = 0; i < 4; i++) {
				var mc:MovieClip = new MovieClip();
				mc.addChild(ShapeUtils.createCircle(5, 0xffffff, 0.5, 0, 0, 1, 0x999999));
				_distortControlersContainer.addChild(mc);
				MovieClipUtilities.setDraggable(mc);
				_distortControlersCollection.push(mc);
				
			}
			_distortControlersCollection[0].x = 0;
			_distortControlersCollection[0].y = 0;
			_distortControlersCollection[1].x = image.width;
			_distortControlersCollection[1].y = 0;
			_distortControlersCollection[2].x = image.width;
			_distortControlersCollection[2].y = image.height;
			_distortControlersCollection[3].x = 0;
			_distortControlersCollection[3].y = image.height;
			
		
            var _distortImage:DistortImage = new DistortImage(image.bitmapData.width, image.bitmapData.height, 3, 3);
           
			createDistortion();
            container.addEventListener(MouseEvent.MOUSE_UP, update);
			
			
			//internal functions 
			function onMaskMove(obj:MovieClip) {
				_distortControlersContainer.x  = _distortedImageContainer.x;
				_distortControlersContainer.y  = _distortedImageContainer.y;
				
			}
			
            function update (evt:MouseEvent):void {
                createDistortion();
			}
				
			function createDistortion()
			{
				 _distortedImageContainer.graphics.clear();

                _distortImage.setTransform(_distortedImageContainer.graphics, 
                                        image.bitmapData, 
                                        new Point(_distortControlersCollection[0].x, _distortControlersCollection[0].y),
										new Point(_distortControlersCollection[1].x, _distortControlersCollection[1].y),
										new Point(_distortControlersCollection[2].x, _distortControlersCollection[2].y),
										new Point(_distortControlersCollection[3].x, _distortControlersCollection[3].y)
										);
            }
            
		}
	}
	
}