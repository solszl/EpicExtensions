package com.shrimp.ext.camera
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 * 视差摄像机跟随
	 * @author Sol
	 * @date 2016-08-01 01:38:06
	 *
	 */
	public final class ParallaxCamera
	{
		public static var isForcePause:Boolean = false;

		private var _stage:Stage;

		private var _stageContainer:DisplayObject;

		private var _focusPosition:Point;

		private var _focusTracker:Point;

		private var _focusOrientation:Point;

		private var _focusCurrentLoc:Point;

		private var _focusLastLoc:Point;

		private var _focusDistX:Number;

		private var _focusDistY:Number;

		private var _focusTarget:*;

		private var _layersInfo:Dictionary; // each object(layer) contains keys of 'name', 'instance', 'ratio'

		private var _boundaryLayer:DisplayObject;

		private var _switch:Boolean;

		private var _targetLastX:Number;

		private var _targetLastY:Number;

		private var _targetCurrentX:Number;

		private var _targetCurrentY:Number;

		private var _zoomFactor:Number;

		private var _intensity:Number;

		private var _shakeTimer:int;

		private var _shakeDecay:Number;

		public var trackStep:uint;

		public var swapStep:uint;

		public var zoomStep:uint;

		private var _tempStep:uint;

		private var _step:uint;

		public var ignoreLeftBound:Boolean;

		public var ignoreRightBound:Boolean;

		public var ignoreTopBound:Boolean;

		public var ignoreBottomBound:Boolean;

		public var isFocused:Boolean;

		public var isSwaping:Boolean;

		public var isZooming:Boolean;

		public var isShaking:Boolean;

		public var enableCallBack:Boolean;

		private var _boundaryEvent:CameraEvent;

		private var _swapStartedEvent:CameraEvent;

		private var _swapFinishedEvent:CameraEvent;

		private var _zoomStartedEvent:CameraEvent;

		private var _zoomFinishedEvent:CameraEvent;

		private var _shakeStartedEvent:CameraEvent;

		private var _shakeFinishedEvent:CameraEvent;

		public function ParallaxCamera(aStage:Stage, aStageContainer:DisplayObject, aFocusTarget:*, aLayersInfo:Array, aAutoStart:Boolean = false)
		{
			_stage = aStage;
			_stageContainer = aStageContainer;
			_layersInfo = new Dictionary();

			focusTarget = aFocusTarget;

			_focusPosition = new Point();

			_focusTracker = new Point();
			_focusTracker.x = _focusTarget.x;
			_focusTracker.y = _focusTarget.y;

			_focusOrientation = new Point();
			_focusOrientation.x = _focusTarget.x;
			_focusOrientation.y = _focusTarget.y;

			_focusCurrentLoc = _focusTracker.clone();
			_focusLastLoc = _focusTracker.clone();

			for each(var obj:Object in aLayersInfo)
			{
				obj.ox = obj.instance.x;
				obj.oy = obj.instance.y;
				_layersInfo[obj.name] = obj;
			}

			_targetLastX = _targetCurrentX = focusTarget.x;
			_targetLastY = _targetCurrentY = focusTarget.y;

			// default step values, can be reset
			trackStep = 10;
			swapStep = 10;
			zoomStep = 10;

			_step = trackStep;
			_tempStep = trackStep;

			// default zoom factor
			_zoomFactor = _stageContainer.scaleX;

			// default focus is at the stage center
			setFocusPosition(_stage.stageWidth * .5, _stage.stageHeight * .5);

			// by default, the stage boundary is not set
			setBoundary();

			// create event instance
			_boundaryEvent = new CameraEvent(CameraEvent.HIT_BOUNDARY);
			_swapStartedEvent = new CameraEvent(CameraEvent.SWAP_STARTED);
			_swapFinishedEvent = new CameraEvent(CameraEvent.SWAP_FINISHED);
			_zoomStartedEvent = new CameraEvent(CameraEvent.ZOOM_STARTED);
			_zoomFinishedEvent = new CameraEvent(CameraEvent.ZOOM_FINISHED);
			_shakeStartedEvent = new CameraEvent(CameraEvent.SHAKE_STARTED);
			_shakeFinishedEvent = new CameraEvent(CameraEvent.SHAKE_FINISHED);

			if(aAutoStart)
				start();
			else
				pause();
		}

		public function set focusTarget(aFocusTarget:*):void
		{
			_focusTarget = aFocusTarget;
		}

		public function get focusTarget():*
		{
			return _focusTarget;
		}

		public function get zoomFactor():Number
		{
			return _zoomFactor;
		}

		private function get focusDist():Object
		{
			return {distX:_focusCurrentLoc.x - _focusLastLoc.x, distY:_focusCurrentLoc.y - _focusLastLoc.y};
		}

		private function get globalTrackerLoc():Point
		{
			var loc:Point;

			if(_focusTarget is Point)
				loc = _stageContainer.localToGlobal(_focusTracker);
			else if(_focusTarget is DisplayObject)
				loc = _focusTarget.parent.localToGlobal(_focusTracker);

			return loc;
		}

		public function getLayerByName(aName:String):DisplayObject
		{
			return _layersInfo[aName].instance;
		}

		public function start():void
		{
			_stage.addEventListener(Event.ENTER_FRAME, update);
			update(null);
			_switch = true;
		}

		public function pause():void
		{
			_stage.removeEventListener(Event.ENTER_FRAME, update);
			_switch = false;
		}

		public function destroy():void
		{
			_stage = null;
			_stageContainer = null;
			_boundaryLayer = null;
			_layersInfo = null;
			focusTarget = null;
			_boundaryEvent = null;
			_swapStartedEvent = null;
			_swapFinishedEvent = null;
			_zoomStartedEvent = null;
			_zoomFinishedEvent = null;
			_shakeStartedEvent = null;
			_shakeFinishedEvent = null;
		}

		public function setFocusPosition(aX:Number, aY:Number):void
		{
			_focusPosition.x = aX;
			_focusPosition.y = aY;
		}

		public function setBoundary(aLayer:DisplayObject = null):void
		{
			_boundaryLayer = aLayer;
		}

		public function jumpToFocus(aFocusTarget:* = null):void
		{
			if(aFocusTarget == null)
				aFocusTarget = _focusTarget;
			_focusCurrentLoc.x = _focusLastLoc.x = _focusTracker.x = _focusTarget.x;
			_focusCurrentLoc.y = _focusLastLoc.y = _focusTracker.y = _focusTarget.y;
			swapFocus(aFocusTarget, 1);
		}

		public function swapFocus(aFocusTarget:*, aSwapStep:uint = 10, aZoom:Boolean = false, aZoomFactor:Number = 1, aZoomStep:int = 10):void
		{
			_focusTarget = aFocusTarget;

			swapStep = Math.max(1, aSwapStep);
			_tempStep = trackStep;
			_step = swapStep;

			isSwaping = true;

			if(enableCallBack)
				_stage.dispatchEvent(_swapStartedEvent);

			if(aZoom)
				zoomFocus(aZoomFactor, aZoomStep);
		}

		public function zoomFocus(aZoomFactor:Number, aZoomStep:uint = 10):void
		{
			_zoomFactor = Math.max(0, aZoomFactor);

			zoomStep = Math.max(1, aZoomStep);

			isZooming = true;

			if(enableCallBack)
				_stage.dispatchEvent(_zoomStartedEvent);
		}

		public function shake(aIntensity:Number, aShakeTimer:int):void
		{
			_intensity = aIntensity;
			_shakeTimer = aShakeTimer;
			_shakeDecay = aIntensity / aShakeTimer;

			isShaking = true;

			if(enableCallBack)
				_stage.dispatchEvent(_shakeStartedEvent);
		}

		public function update(e:Event = null):void
		{
			// if paused then ignore the following code
			if(!_switch)
				return;

			if(isForcePause)
				return;

			// if focusTarget is set to null or not existing on stage, ignore the following code
			if(_focusTarget == null)
				return;

			if(_focusTarget is DisplayObject && _focusTarget.parent == null)
				return;

			// detect if it is tracking behind(or swaping to) the focus target
			if(Math.round((_focusTarget.x - _focusTracker.x) * (_focusTarget.y - _focusTracker.y)) == 0)
			{
				_tempStep = trackStep;
				_step = _tempStep;

				_focusTracker.x = _focusTarget.x;
				_focusTracker.y = _focusTarget.y;

				if(isSwaping)
				{
					isSwaping = false;

					if(enableCallBack)
						_stage.dispatchEvent(_swapFinishedEvent);
				}

				isFocused = true;
			}
			else
			{
				isFocused = false;
			}

			// update the location of the focusTracker
			_focusTracker.x += (_focusTarget.x - _focusTracker.x) / _step;
			_focusTracker.y += (_focusTarget.y - _focusTracker.y) / _step;

			// update the current and last tracking location
			_focusLastLoc.x = _focusCurrentLoc.x;
			_focusLastLoc.y = _focusCurrentLoc.y;
			_focusCurrentLoc.x = _focusTracker.x;
			_focusCurrentLoc.y = _focusTracker.y;

			// update the location of the focus target
			_targetLastX = _targetCurrentX;
			_targetLastY = _targetCurrentY;
			_targetCurrentX = focusTarget.x;
			_targetCurrentY = focusTarget.y;

			if(isZooming)
			{
				_stageContainer.scaleX += (_zoomFactor - _stageContainer.scaleX) / zoomStep;
				_stageContainer.scaleY += (_zoomFactor - _stageContainer.scaleY) / zoomStep;

				// detect if zooming finished
				if(Math.abs(_stageContainer.scaleX - _zoomFactor) < .01)
				{
					isZooming = false;
					_stageContainer.scaleX = _stageContainer.scaleY = _zoomFactor;

					if(enableCallBack)
						_stage.dispatchEvent(_zoomFinishedEvent);
				}
			}

			// nudge stage-container
			positionStageContainer();
			var testResult:Object = testBounds();

			// adjust parallax layers
			positionParallax(testResult);

			// shake
			if(isShaking)
			{
				if(_shakeTimer > 0)
				{
					_shakeTimer--;

					if(_shakeTimer <= 0)
					{
						_shakeTimer = 0;
						isShaking = false;

						if(enableCallBack)
							_stage.dispatchEvent(_shakeFinishedEvent);
					}
					else
					{
						_intensity -= _shakeDecay;

						_stageContainer.x = Math.random() * _intensity * _stage.stageWidth * 2 - _intensity * _stage.stageWidth + _stageContainer.x;
						_stageContainer.y = Math.random() * _intensity * _stage.stageHeight * 2 - _intensity * _stage.stageHeight + _stageContainer.y;
					}
				}
			}
		}

		private function testBounds():Object
		{
			var testResult:Object = {top:false, bottom:false, left:false, right:false};

			if(_boundaryLayer == null)
				return testResult;

			var stageBoundaryUpperLeft:Point = _boundaryLayer.parent.localToGlobal(new Point(_boundaryLayer.x, _boundaryLayer.y));
			var stageBoundaryLowerRight:Point = _boundaryLayer.parent.localToGlobal(new Point(_boundaryLayer.x + _boundaryLayer.width, _boundaryLayer.y + _boundaryLayer.height));
			var boundLeft:Number = stageBoundaryUpperLeft.x;
			var boundTop:Number = stageBoundaryUpperLeft.y;
			var boundRight:Number = stageBoundaryLowerRight.x;
			var boundBottom:Number = stageBoundaryLowerRight.y;

			//			trace( 'left:'+boundLeft+',right:'+boundRight+',up:'+boundTop+',down:'+boundBottom );

			if(boundLeft > 0)
			{
				if(!ignoreLeftBound)
				{
					_stageContainer.x += 0 - boundLeft;
				}

				if(enableCallBack)
				{
					_boundaryEvent.boundary = 'left';
					_stage.dispatchEvent(_boundaryEvent);
				}

				testResult.left = true;
			}

			if(boundRight < _stage.stageWidth)
			{
				if(!ignoreRightBound)
				{
					_stageContainer.x += _stage.stageWidth - boundRight;
				}

				if(enableCallBack)
				{
					_boundaryEvent.boundary = 'right';
					_stage.dispatchEvent(_boundaryEvent);
				}

				testResult.right = true;
			}

			if(boundTop > 0)
			{
				if(!ignoreTopBound)
				{
					_stageContainer.y += 0 - boundTop;
				}

				if(enableCallBack)
				{
					_boundaryEvent.boundary = 'top';
					_stage.dispatchEvent(_boundaryEvent);
				}

				testResult.top = true;
			}

			if(boundBottom < _stage.stageHeight)
			{
				if(!ignoreBottomBound)
				{
					_stageContainer.y += _stage.stageHeight - boundBottom;
				}

				if(enableCallBack)
				{
					_boundaryEvent.boundary = 'bottom';
					_stage.dispatchEvent(_boundaryEvent);
				}

				testResult.bottom = true;
			}

			return testResult;
		}

		private function positionStageContainer():void
		{
			_stageContainer.x += _focusPosition.x - globalTrackerLoc.x;
			_stageContainer.y += _focusPosition.y - globalTrackerLoc.y;
		}

		private function positionParallax(aTestResult:Object):void
		{
			var testResult:Object = aTestResult;
			var layer:DisplayObject;
			var layerOX:Number;
			var layerOY:Number;
			var ratio:Number;

			for each(var value:Object in _layersInfo)
			{
				layer = value.instance;
				layerOX = value.ox;
				layerOY = value.oy;
				ratio = value.ratio;

				var distX:Number = (_focusCurrentLoc.x - _focusOrientation.x) * ratio;
				var distY:Number = (_focusCurrentLoc.y - _focusOrientation.y) * ratio;

				if((!testResult.left && distX < 0) || (!testResult.right && distX > 0))
					layer.x = layerOX + distX;

				if((!testResult.top && distY < 0) || (!testResult.bottom && distY > 0))
					layer.y = layerOY + distY;
			}
		}
	}
}
