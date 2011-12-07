package com.smp.bitmap{
	
	import flash.geom.Point;
	import flash.filters.ConvolutionFilter;
	
	import ascb.util.ArrayUtilities;
	
	import com.smp.common.math.CoordinatesUtils;
	
	
	public class FilterUtils{
		
		public function FilterUtils(){
			
		}
		
		/**
		 * @example	_newImageData.applyFilter(_imageData, new Rectangle(0, 0, _imageData.width, _imageData.height), new Point(0,0), FilterUtils.motionBlur(new Point(_origin[0], _origin[1]), new Point(_destination[0], _destination[1])));
		 *
		 * @param	startPoint
		 * @param	endPoint
		 * @param	angle
		 * @return
		 */
		
		public static function motionBlur(startPoint:Point = null, endPoint:Point = null, angle:Number = 0):ConvolutionFilter {
			
			var _angle:Number;
			
			if(startPoint != null && endPoint != null){
				_angle = CoordinatesUtils.getDirectionFactor(startPoint, endPoint);
			}else{
				_angle = angle;
			}
			
			var matrix:Array = [];
			
			//converts radians to degrees
			//but keeps the inverted mode, because the matrix is oposed to the direction of movement
			
			if(_angle < 0){
				_angle = 8 + _angle;
			}

			_angle = Math.round(_angle);

			if(_angle == 0 || _angle == 8){
				matrix = FilterTypes.MOTION_BLUR_LEFT
			}else if(_angle == 1){
				matrix =  FilterTypes.MOTION_BLUR_UPLEFT
			}if(_angle == 2){
				matrix =  FilterTypes.MOTION_BLUR_UP
			}if(_angle == 3){
				matrix =  FilterTypes.MOTION_BLUR_UPRIGHT
			}if(_angle == 4){
				matrix =  FilterTypes.MOTION_BLUR_RIGHT
			}if(_angle == 5){
				matrix =  FilterTypes.MOTION_BLUR_DOWNRIGHT
			}if(_angle == 6){
				matrix =  FilterTypes.MOTION_BLUR_DOWN
			}if(_angle == 7){
				matrix =  FilterTypes.MOTION_BLUR_DOWNLEFT
			}
			
			if (matrix.length > 0) {
				return FilterUtils.getFilter(matrix);
			}
			
			return null;
			
			
			
			//por ver .......
			/*
			
			//obtem os factores de deslocação da matriz
			var eixoX:Number = Math.round(Math.sin(angulo));
			var eixoY:Number = -Math.round(Math.sin(angulo));
			
			//cria matriz de 81 elementos
			var matriz:Array = new Array();
		
			var count:Number = 0;
			for(var i=0; i<9; i++){
				if(i==5+eixoY){
					for(j=0; j<9; j++){
						matriz[count] = 1;
						count++;
					}
				}else{
					for(var j=0; j<9; j++){
						if(j==5+eixoX){
							matriz[count] = 1;
						}else{
							matriz[count] = 0;
						}
						count++;
					}
					
				}
			}
			return matriz;
			
			*/
			
		}
		
		public static function sharpen(smoothness:uint = 8):ConvolutionFilter 
		{
			var arr:Array = FilterTypes.SHARPEN;
			arr[12] = smoothness;
			return FilterUtils.getFilter(arr);
		}
		
		public static function getFilter(matrix:Array):ConvolutionFilter 
		{
			var size:Number = Math.sqrt(matrix.length);
			return new ConvolutionFilter(size, size, matrix, ArrayUtilities.sum(matrix));;
		}

		
	}
}