package com.shrimp.ext.guide
{
	import com.vhall.framework.app.manager.StageManager;
	import com.vhall.framework.log.Logger;

	import flash.events.Event;

	public class GuideService
	{
		/**	新手引导执行完毕的时候 调取的回调*/
		public var allFinishCallBK:Function;

		private static var _instance:GuideService;

		// 引导的所有数据
		private var _guides:Array = null;

		// 当前的引导方式
		private var _currentGuide:IGuideImpl;

		// 当前步骤
		private var _currentIndex:int;

		public static function getInstance():GuideService
		{
			if(!_instance)
			{
				_instance = new GuideService();
			}
			return _instance;
		}

		public function GuideService()
		{
			if (_instance)
			{
				throw new Error("GuideServices instance has already been constructed!");
			}

			_instance=this;
			StageManager.stage.addEventListener(Event.RESIZE, onStageResize);
		}

		/**	开始新手引导*/		
		public function start():void
		{
			next();
		}

		/**	上一步新手引导*/
		public function lastStep():void
		{
			goto(--_currentIndex);
			_currentIndex++;
		}

		/**	下一步*/
		public function next():void
		{
			goto(_currentIndex);
			_currentIndex++;
		}

		/**	跳转到指定步骤*/
		public function gotoStep(value:int):void
		{
			_currentIndex = value;
			goto(_currentIndex);
			_currentIndex++;
		}

		public function dispose():void
		{
			_currentIndex = -1;
			_currentGuide.over();
			_currentGuide = null;
			_guides = [];
		}

		/**	拿到当前引导实现*/
		public function getCurrentGuide():IGuideImpl
		{
			return this._currentGuide;
		}

		/**	拿到当前引导的总步数*/
		public function getGuideCount():int
		{
			return this._guides.length;
		}

		/**	拿到当前捕鼠引导数据*/
		public function getCurrentData():GuideInfoData
		{
			return this._guides[_currentIndex];
		}

		private function onStageResize(e:Event = null):void
		{
			// 重绘引导
			this._currentGuide.resize();
		}

		private function goto(value:int):void
		{
			// 数据不合理，移除销毁
			if(value >= getGuideCount() || value ==-1)
			{
				dispose();
				if(allFinishCallBK != null)
				{
					allFinishCallBK();
					allFinishCallBK = null;
				}
			}

			var data:GuideInfoData = this._guides[value];
			if(data == null)
			{
				Logger.getLogger("guide").info("guide data is null");
				return;
			}

			this._currentGuide.guideData = data;
			this._currentGuide.start();

		}

	}
}

