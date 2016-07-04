package com.shrimp.ext.guide
{
	import com.shrimp.ext.guide.impl.GuideCondition;
	import com.shrimp.ext.guide.impl.GuideForce;
	import com.shrimp.ext.guide.impl.GuideUnforce;
	import com.vhall.framework.log.Logger;

	/**
	 * 引导工厂
	 * @author 振亮
	 *
	 */
	public class GuideFactory
	{

		private static const force:GuideForce = new GuideForce();

		private static const unforce:GuideUnforce = new GuideUnforce();

		private static const condition:GuideCondition = new GuideCondition();

		public static function getGuide(type:int):IGuideImpl
		{
			switch(type)
			{
				case GuideType.FORCE:
					return force;
				case GuideType.UNFORCE:
					return unforce;
				case GuideType.CONDITION:
					return condition;
				default:
					Logger.getLogger("guide").info("unknown guide type:",type);
					return null;
			}
		}

		public function GuideFactory()
		{
		}
	}
}

