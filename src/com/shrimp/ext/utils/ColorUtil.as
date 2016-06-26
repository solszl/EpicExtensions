package com.shrimp.ext.utils
{
	import com.shrimp.ext.color.ColorMatrix;

	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;

	/**
	 * 颜色工具类
	 * @author 振亮
	 *
	 */
	public class ColorUtil
	{

		// 普通
		private static const defaultTransform:ColorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);

		// 变灰
		private static const fadeFilter:ColorMatrixFilter = new ColorMatrixFilter([1 / 3, 1 / 3, 1 / 3, 0, 0, 1 / 3, 1 / 3, 1 / 3, 0, 0, 1 / 3, 1 / 3, 1 / 3, 0, 0, 0, 0, 0, 1, 0]);

		// 高亮
		private static const highLightTransform:ColorTransform = new ColorTransform(1, 1, 1, 1, 50, 50, 0, 0);

		/**
		 * 褪色
		 * @param obj
		 *
		 */
		public static function fade(obj:DisplayObject):void
		{
			defade(obj);
			var filters:Array = obj.filters;
			filters.push(fadeFilter);
			obj.filters = filters;
			obj.transform.colorTransform = new ColorTransform(0.8, 0.8, 0.8, 1, 10, 10, 10, 0);
		}

		/**
		 * 恢复颜色
		 * @param obj
		 *
		 */
		public static function defade(obj:DisplayObject):void
		{
			var filters:Array = obj.filters;

			for(var i:int = 0; i < filters.length; i++)
			{
				var colorFilter:ColorMatrixFilter = filters[i] as ColorMatrixFilter;

				// 如果不是ColorMatrixFilter则跳过
				if(colorFilter == null)
					continue;
				// 如果与变灰滤镜相同则删除
				var flag:Boolean = true;
				var cMatrix:Array = colorFilter.matrix;
				var fMatrix:Array = fadeFilter.matrix;

				for(var j:int = 0; j < 20; j++)
				{
					if(cMatrix[j] != fMatrix[j])
					{
						flag = false;
						break;
					}
				}

				if(flag)
				{
					filters.splice(i, 1);
					break;
				}
			}
			obj.filters = filters;
			obj.transform.colorTransform = defaultTransform;
		}

		/**
		 * 添加阴影
		 * @param obj
		 *
		 */
		public static function addShadow(obj:DisplayObject):void
		{
			var filter:DropShadowFilter = new DropShadowFilter(4, 55, 0, 0.5, 2, 2, 1);
			var filters:Array = obj.filters;
			filters.push(filter);
			obj.filters = filters;
		}

		/**
		 * 添加外发光
		 * @param obj
		 * @param color
		 *
		 */
		public static function addRing(obj:DisplayObject, color:uint):void
		{
			if(obj)
			{
				var filters:Array = obj.filters;
				var filter:GlowFilter

				for(var i:String in filters)
				{
					if(filters[i] is GlowFilter)
					{
						filter = filters[i];
						break;
					}
				}

				if(filter)
				{
					filter.color = color;
				}
				else
				{
					filter = new GlowFilter(color, 1, 3, 3, 6, 2, false);
					filters.push(filter);
				}

				obj.filters = filters;
			}
		}

		/**
		 * 移除外发光
		 * @param obj
		 *
		 */
		public static function removeRing(obj:DisplayObject):void
		{
			if(obj && obj.filters)
			{
				for(var i:int = 0; i < obj.filters.length; i++)
				{
					if(obj.filters[i] is GlowFilter)
					{
						var filers:Array = obj.filters;
						filers.splice(i, 1);
						obj.filters = filers;
					}
				}
			}
		}

		/**
		 * uint转16进制字符串
		 * @param color
		 * @return
		 *
		 */
		public static function toHex(color:uint):String
		{
			return "#" + color.toString(16);
		}

		/**
		 * 字符串转uint
		 * @param color
		 * @return
		 *
		 */
		public function fromHex(color:String):uint
		{
			return uint(color.replace("#", "0x"));
		}

		/**
		 * 增加饱和度
		 * @param displayObject
		 * @param params
		 *
		 */
		public static function addSaturation(displayObject:DisplayObject, params:int):void
		{
			var cm:ColorMatrix = new ColorMatrix();
			cm.adjustSaturation(params);
			displayObject.filters = [new ColorMatrixFilter(cm)];
		}

		/**
		 * 增加对比度
		 * @param displayObject
		 * @param params
		 *
		 */
		public static function addContrast(displayObject:DisplayObject, params:int):void
		{
			var cm:ColorMatrix = new ColorMatrix();
			cm.adjustContrast(params);
			displayObject.filters = [new ColorMatrixFilter(cm)];
		}

		/**
		 * 增加亮度
		 * @param displayObject
		 * @param params
		 *
		 */
		public static function addBrightness(displayObject:DisplayObject, params:int):void
		{
			var cm:ColorMatrix = new ColorMatrix();
			cm.adjustBrightness(params);
			displayObject.filters = [new ColorMatrixFilter(cm)];
		}

		/**
		 * 增加颜色
		 * @param displayObject
		 * @param bright
		 * @param contrast
		 * @param saturation
		 * @param hue
		 *
		 */
		public static function addColor(displayObject:DisplayObject, bright:int = 0, contrast:int = 0, saturation:int = 0, hue:int = 0):void
		{
			var cm:ColorMatrix = new ColorMatrix();
			cm.adjustColor(bright, contrast, saturation, hue);
			displayObject.filters = [new ColorMatrixFilter(cm)];
		}

		/**
		 * 移除所有附加颜色
		 * @param displayObject
		 *
		 */
		public static function removeAllFilter(displayObject:DisplayObject):void
		{
			var cm:ColorMatrix = new ColorMatrix();
			cm.reset();
			displayObject.filters = [new ColorMatrixFilter(cm)];
		}
	}
}

