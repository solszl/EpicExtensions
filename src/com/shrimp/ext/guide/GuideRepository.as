package com.shrimp.ext.guide
{
	import com.vhall.framework.log.Logger;
	import com.vhall.framework.ui.controls.UIComponent;
	import com.vhall.framework.ui.interfaces.IGuide;

	import flash.utils.Dictionary;

	/**
	 * 引导组建仓库
	 * @author 振亮
	 *
	 */
	public class GuideRepository
	{

		private static var _instance:GuideRepository;

		private static var _guideTargets:Dictionary;

		public static function getInstance():GuideRepository
		{
			if(!_instance)
			{
				_instance = new GuideRepository();
			}
			return _instance;
		}

		public function GuideRepository()
		{
			if(_instance)
			{
				throw new Error("GuideRepository instance has already been constructed!");
			}
			_instance = this;
			_guideTargets = new Dictionary();
		}

		/**
		 * 注册引导组件
		 * @param guideName
		 * @param comp
		 *
		 */		
		public function registComponent(comp:IGuide):void
		{
			if("" == comp.guideName)
			{
				throw new Error("can't regist guide component, guide name is null or empty!");
			}

			if(null == comp)
			{
				throw new Error("can't regist guide compoent, component is null");
			}

			var name:String = comp.guideName;
			var component:UIComponent = UIComponent(comp)
			_guideTargets[name] = component;
			Logger.getLogger('注册引导组件').info(name, component);
		}

		/**
		 * 通过引导名称卸载引导位置
		 * @param guideName
		 *
		 */
		public function unregistPosition(guideName:String):void
		{
			_guideTargets[guideName]=null;
			delete _guideTargets[guideName];
		}
	}
}

