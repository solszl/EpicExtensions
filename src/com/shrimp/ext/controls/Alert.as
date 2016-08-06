package com.shrimp.ext.controls
{
	import com.shrimp.ext.events.CloseEvent;
	import com.vhall.framework.app.manager.RenderManager;
	import com.vhall.framework.app.manager.StageManager;
	import com.vhall.framework.ui.container.Box;
	import com.vhall.framework.ui.controls.Button;
	import com.vhall.framework.ui.controls.Image;
	import com.vhall.framework.ui.controls.Label;
	import com.vhall.framework.ui.controls.UIComponent;
	import com.vhall.framework.ui.manager.PopupManager;
	import com.vhall.framework.ui.utils.ComponentUtils;

	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * 弹框
	 * @author Sol
	 * @date 2016-08-06 01:46:56
	 */
	public class Alert extends Box
	{
		public function Alert(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
		}

		private var lblTitle:Label;

		private var lblContent:Label;

		private var imgIcon:Image;

		private var buttonPool:Array = [];

		private static var alertPool:Array = [];

		private static var closeHandler:Function;

		private var buttonContainer:Sprite;

		private var buttons:Object = {};

		private static var okLabel:String = "确定";

		private static var cancelLabel:String = "取消";

		private static var yesLabel:String = "是";

		private static var noLabel:String = "否";

		public static const YES:uint = 0x0001;

		public static const NO:uint = 0x0002;

		public static const OK:uint = 0x0004;

		public static const CANCEL:uint = 0x0008;

		private static var flags:uint;

		override protected function createChildren():void
		{
			super.createChildren();

			lblTitle = new Label(this, 12, 8);
			lblTitle.fontSize = 13;
			lblTitle.bold = true;
			lblTitle.text = "title";

			lblContent = new Label(this, 90, 40);
			lblContent.text = "content";

			imgIcon = new Image(this, 50, 75);
			imgIcon.setSize(32, 32);
			imgIcon.source = null;

			drawBackground();

			buttonContainer = new Sprite();
			addChild(buttonContainer);
		}

		public static function show(title:String = "", content:String = "", flag:uint = Alert.OK, closeHandler:Function = null, icon:Object = null):Alert
		{
			closeHandler = closeHandler;
			flags = flag;
			var alert:Alert = alertPool.length > 0 ? alertPool.pop() : new Alert();
			alert.title = title;
			alert.content = content;
			alert.icon = icon;
			PopupManager.addPopup(alert, StageManager.stage);
			return alert;
		}

		private var _title:String;

		private var _content:String;

		private var _icon:Object;

		public function set title(value:String):void
		{
			_title = value;
			RenderManager.getInstance().invalidate(invalidate);
		}

		public function set content(value:String):void
		{
			_content = value;
			RenderManager.getInstance().invalidate(invalidate);
		}

		public function set icon(value:Object):void
		{
			_icon = value;
			RenderManager.getInstance().invalidate(invalidate);
		}

		override protected function invalidate():void
		{
			lblTitle.text = _title;
			lblContent.text = _content;
			imgIcon.source = _icon;
			generateButtons();
			super.invalidate();
		}

		override protected function updateDisplay():void
		{
			super.updateDisplay();
			var btnW:Number = buttonContainer.numChildren * 60 + (buttonContainer.numChildren - 1) * 5
			buttonContainer.x = (width - btnW) * .5;
			buttonContainer.y = height - 30 - 15;

			lblContent.y = height - lblContent.height >> 1;
			//			imgIcon.setSize(32, 32);
		}

		private function generateButtons():void
		{
			for each(var buttonItem:Button in buttons)
			{
				buttonContainer.removeChild(buttonItem);
				buttonItem.removeEventListener(MouseEvent.CLICK, clickHandler);
				buttonPool.push(buttonItem);
			}
			buttons = {};

			if(flags & Alert.OK)
			{
				buttons[Alert.OK] = createButton(Alert.okLabel, Alert.OK);
			}

			if(flags & Alert.CANCEL)
			{
				buttons[Alert.CANCEL] = createButton(Alert.cancelLabel, Alert.CANCEL);
			}

			if(flags & Alert.YES)
			{
				buttons[Alert.YES] = createButton(Alert.yesLabel, Alert.YES);
			}

			if(flags & Alert.NO)
			{
				buttons[Alert.NO] = createButton(Alert.noLabel, Alert.NO);
			}
		}

		private function clickHandler(event:MouseEvent):void
		{
			var button:Button = Button(event.currentTarget);
			PopupManager.removePopup(this);

			if(closeHandler != null)
			{
				var closeEvent:CloseEvent = new CloseEvent(CloseEvent.CLOSE, false, false, getDetailBy(button));
				closeHandler(closeEvent);
			}

			alertPool.push(this);
		}

		private function getDetailBy(button:Button):int
		{
			if(button == null)
			{
				return 0;
			}

			if((button.userData == null))
			{
				return 0;
			}

			return uint(button.userData);
		}

		private function createButton(label:String, eventKey:uint):Button
		{
			var button:Button = buttonPool.length > 0 ? buttonPool.pop() : new Button();
			button.skin = ComponentUtils.genInteractiveRect(76, 28, null, 0, 0, 0xfbfbfb, 1, 1, 0xd0cdcd);
			button.labelColor = "0x555555~0x555555~0xffffff";
			button.overSkin = ComponentUtils.genInteractiveRect(76, 28, null, 0, 0, 0xf34b46);
			button.downSkin = ComponentUtils.genInteractiveRect(76, 28, null, 0, 0, 0xf34b46);
			button.labelSize = 14;
			button.buttonMode = true;
			button.label = label;
			button.setSize(60, 30);
			button.x = buttonContainer.numChildren * (5 + 60);
			button.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			button.userData = eventKey;

			return Button(buttonContainer.addChild(button));
		}

		private function drawBackground():void
		{
			graphics.clear();
			// 灰色背景
			graphics.beginFill(0x000000, 0.15);
			graphics.drawRect(0, 0, 300, 180);
			graphics.endFill();
			// 白色背景
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect(3, 3, 294, 174);
			graphics.endFill();
			// 标题背景
			graphics.beginFill(0xF3F3F3);
			graphics.drawRect(3, 3, 294, 32);
			graphics.endFill();
		}
	}
}
