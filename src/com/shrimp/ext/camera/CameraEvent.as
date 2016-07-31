package com.shrimp.ext.camera
{
	import flash.events.Event;

	public class CameraEvent extends Event
	{
		public static const HIT_BOUNDARY:String = 'hitBoundary';

		public static const SWAP_STARTED:String = 'swapStarted';

		public static const SWAP_FINISHED:String = 'swapFinished';

		public static const ZOOM_STARTED:String = 'zoomStarted';

		public static const ZOOM_FINISHED:String = 'zoomFinished';

		public static const SHAKE_STARTED:String = 'shakeStarted';

		public static const SHAKE_FINISHED:String = 'shakeFinished';

		public var boundary:String;

		public function CameraEvent(type:String, bubbles:Boolean = false)
		{
			super(type, bubbles);
		}
	}
}
