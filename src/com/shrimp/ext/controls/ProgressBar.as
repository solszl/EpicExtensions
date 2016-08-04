package com.shrimp.ext.controls
{
	import com.vhall.framework.app.manager.RenderManager;
	import com.vhall.framework.ui.controls.Image;
	import com.vhall.framework.ui.controls.UIComponent;
	import com.vhall.framework.ui.utils.ComponentUtils;

	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 进度条
	 * @author Sol
	 * @date 2016-08-04 00:11:30
	 */
	public class ProgressBar extends UIComponent
	{
		private var bg:Image;

		private var _track:Image;

		public function ProgressBar(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			_width = 200;
			_height = 14;
			super(parent, xpos, ypos);
		}

		override protected function createChildren():void
		{
			super.createChildren();
			_trackOffset = new Point(2, 2);

			bg = new Image(this);
			bg.source = ComponentUtils.genInteractiveRect(_width, _height, null, 0, 0, 0X000000);
			bg.rect = new Rectangle(2, 2, 2, 2);
			bg.width = _width;
			bg.height = _height;

			_track = new Image(this);
			_track.source = ComponentUtils.genInteractiveRect(10, 10, null, 0, 0, 0xFFFFFF);
			_track.rect = new Rectangle(2, 2, 2, 2);
			_track.setSize(10, 10);
			trackOffset = _trackOffset;
		}

		override public function set width(value:Number):void
		{
			super.width = value;
			bg.width = value;
		}

		override public function set height(value:Number):void
		{
			super.height = value;
			bg.height = height;
		}

		override public function setSize(w:Number, h:Number):void
		{
			super.setSize(w, h);
			bg.setSize(w, h);
		}

		override protected function sizeChanged():void
		{
			_track.width = value / max * (width - 2 * trackOffset.x);
			super.sizeChanged();
		}

		/** 设置背景*/
		public function set background(value:Object):void
		{
			bg.source = value;
		}

		/** 设置背景九宫格*/
		public function set backgroundRect(value:Rectangle):void
		{
			bg.rect = value;
		}

		/** 设置前景*/
		public function set track(value:Object):void
		{
			_track.source = value;
		}

		/** 设置前景九宫格*/
		public function set trackRect(value:Rectangle):void
		{
			_track.rect = value;
		}

		private var _trackOffset:Point;

		public function get trackOffset():Point
		{
			return _trackOffset;
		}

		/** 设置前景偏移*/
		public function set trackOffset(p:Point):void
		{
			_trackOffset = p;
			_track.move(p.x, p.y);
			RenderManager.getInstance().invalidate(invalidate);
		}

		/**	最大值*/
		public function get max():Number
		{
			return _max;
		}

		public function set max(value:Number):void
		{
			_max = value;
			RenderManager.getInstance().invalidate(invalidate);
		}

		/**	最小值*/
		public function get min():Number
		{
			return _min;
		}

		public function set min(value:Number):void
		{
			_min = value;
			RenderManager.getInstance().invalidate(invalidate);
		}

		/** 当前值*/
		public function get value():Number
		{
			return _value;
		}

		public function set value(value:Number):void
		{
			_value = value;
			RenderManager.getInstance().invalidate(invalidate);
		}


		private var _max:Number = 100;

		private var _min:Number = 0;

		private var _value:Number = 0;
	}
}
