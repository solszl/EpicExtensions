package com.shrimp.ext.guide
{
	/**
	 * 新手引导接口
	 * @author 振亮
	 *
	 */	
	public interface IGuideImpl
	{
		/**	设置引导数据*/
		function set guideData(data:GuideInfoData):void;
		/**	引导开始*/
		function start():void;
		/**	引导结束*/
		function over():void;
		/**	舞台大小发生变化的时候。重新布局引导*/
		function resize():void;
	}
}

