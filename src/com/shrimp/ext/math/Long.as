package com.shrimp.ext.math
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

	public class Long
	{
		public var high:uint;

		public var low:uint;

		public function Long(high:uint = 0, low:uint = 0)
		{
			this.high = high;
			this.low = low;
		}

		public static function read(data:IDataInput):Long
		{
			var l:Long = new Long(0, 0);
			l.high = data.readUnsignedInt();
			l.low = data.readUnsignedInt();
			return l;
		}

		public function write(data:IDataOutput):void
		{
			data.writeUnsignedInt(high);
			data.writeUnsignedInt(low);
		}

		public function toString():String
		{
			//大数进制转换，按16,24,24位分段相除
			var remainder:Vector.<uint> = new Vector.<uint>();
			var quotient:Vector.<uint>;
			var result:Vector.<int> = new Vector.<int>();
			remainder[0] = high >>> 16;
			remainder[1] = ((high & 0xFF) << 8) | (low >>> 24);
			remainder[2] = low & 0xFFF;

			do
			{
				quotient = new Vector.<uint>();
				var divisor:uint = 0;
				var tmp:int;

				for(var i:int = 0; i < remainder.length; i++)
				{
					divisor += remainder[i];
					tmp = int(divisor / 10);

					if(tmp != 0)
						quotient.push(tmp);
					tmp = divisor % 10;
					divisor = tmp << 24;
				}
				result.push(tmp);
				remainder = quotient;
			} while(remainder.length > 0);
			return result.reverse().join("");
		}

		private static var zero:Vector.<String> = new Vector.<String>(8);
		{
			init();
		}

		private static function init():void
		{
			var str:String = "";

			for(var i:int = 8; i >= 1; i--)
			{
				zero[i] = str;
				str += "0";
			}
		}

		/**
		 * 转成16进制字符串
		 * @return
		 *
		 */
		public function toHex():String
		{
			var tmpHigh:String = high.toString(16);
			var tmpLow:String = low.toString(16);
			return tmpHigh + zero[tmpLow.length] + tmpLow;
		}

		/**
		 * 16进制字符串转成Long
		 * @return
		 *
		 */
		public static function hexToLong(hex:String):Long
		{
			var high:uint = 0;
			var low:uint = 0;

			var len:int = hex.length - 8;

			if(len > 0)
			{
				high = int('0x' + hex.substr(0, len))
				low = int('0x' + hex.substring(len))
			}
			else
			{
				low = int('0x' + hex);
			}

			return new Long(high, low);
		}

		public function isEqual(l:Long):Boolean
		{
			if(l == null)
			{
				return false;
			}
			else
			{
				return (l.high == high && l.low == low);
			}
		}

		public function add(v:uint):void
		{
			low += v;

			if(low < v)
				high += 1;
		}

		public function subtract(v:uint):void
		{
			var rl:uint = low - v;

			if(rl > low)
			{
				low = ~rl;
				high--;
			}
			else
			{
				low = rl;
			}
		}

		public function diff(v:Long):uint
		{
			var rl:uint = low - v.low;
			return rl > low ? ~rl : rl;
		}
	}
}

