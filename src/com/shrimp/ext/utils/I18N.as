package com.shrimp.ext.utils
{
	import flash.utils.Dictionary;

	/**
	 * 多语言管理
	 * @author Sol
	 * @date 2016-08-03 00:13:35
	 */
	public class I18N
	{
		private static var langMap:Dictionary;

		public static function init(lang:XML):void
		{
			langMap = new Dictionary();
		}

		public static function getString(key:String):String
		{
			return "";
		}

		public static function getEnumString():String
		{
			return "";
		}
	}
}
