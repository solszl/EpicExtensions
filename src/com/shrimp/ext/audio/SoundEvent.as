package com.shrimp.ext.audio
{
	import flash.events.Event;

	public class SoundEvent extends Event
	{
		/**	声音播放完毕*/
		public static const PLAY_COMPLETE:String = "sound_play_complete";

		/**	声音加载完毕*/
		public static const LOAD_COMPLETE:String = "sound_play_complete";

		public static const LOAD_FAILED:String = "sound_load_failed";

		public function SoundEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}

