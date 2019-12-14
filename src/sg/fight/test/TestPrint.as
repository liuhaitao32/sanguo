package sg.fight.test
{
	import laya.display.Sprite;
	import laya.ui.TextArea;
	import laya.utils.Browser;
	import sg.manager.EffectManager;
	
	/**
	 * ...
	 * @author zhuda
	 */
	public class TestPrint
	{
		private static const NUM:int = 3;
		
		private static var _instance:TestPrint = null;
		
		public static function get instance():TestPrint
		{
			return _instance ||= new TestPrint();
		}
		public static var visible:Boolean = false;
		
		///记录当前起点时间
		private var times:Object = new Object();
		public var textAreaArr:Array;
		
		public function TestPrint()
		{
			this.textAreaArr = [];
			//this.addChild(EffectManager.loadAnimation('glow001'));
			for (var i:int = 0; i < NUM; i++)
			{
				var textArea:TextArea;
				textArea = new TextArea();
				textArea.alpha = i == 1?1:0.8;
				textArea.color = i == 1?'#44dd44':'#ffffff';
				textArea.strokeColor = '#333333';
				textArea.font = 'Microsoft YaHei';
				//textArea.fontSize = 15;
				//textArea.stroke = 3;
				//textArea.autoSize = true;
				textArea.leading = 2;
				textArea.width = 210;
				textArea.height = 2000;
				textArea.x = i * 210 + 5;
				textArea.y = 140;
				textArea.text = '';
				textArea.mouseEnabled = false;
				this.textAreaArr.push(textArea);
				//this.addChild(textArea);
			}
			this.showAll(TestPrint.visible);
			//this.textArea.text = 'ok\n';
			
		}
		
		/**
		 * 获取当前运行时间
		 */
		public function timeStart(key:String):void
		{
			var time:Number = Browser.now();
			this.times[key] ||= {start: 0, runTime: 0, maxTime: 0, intervalTime: time};
			this.times[key].start = time;
		}
		
		/**
		 * 获取当前运行时间，并且默认刷在中间区域显示
		 */
		public function timeEnd(key:Object):Object
		{
			var time:Number = Browser.now();
			var temp:Object = this.times[key];
	
			temp.runTime = time - temp.start;
			//每运行10000毫秒 进行重新的maxTime采样！
			if (time - temp.intervalTime >= 10000)
			{
				temp.intervalTime = time;
				temp.maxTime = 0;
			}
			temp.maxTime = Math.max(temp.runTime, temp.maxTime);
			this.print(key + '  ' + temp.runTime + 'ms');
			//this.print(key + ':' + temp.runTime + 'ms\t(max:\t' + temp.maxTime);

			return temp;
		}
		
		public function getTextArea(index:int):TextArea
		{
			return this.textAreaArr[index];
		}
		
		public function isShow():Boolean
		{
			//return this.visible;
			return this.getTextArea(0).visible;
		}
		public function showAll(bool:Boolean):void
		{
			//this.visible = bool;
			for (var i:int = 0; i < NUM; i++)
			{
				var textArea:TextArea = this.getTextArea(i);
				textArea.visible = bool;
			}
		}
		
		/**
		 * 选择左中右其一，打印显示内容
		 */
		public function print(str:String, index:int = 1):void
		{
			//trace(str);
			
			var textArea:TextArea = this.getTextArea(index);
			Laya.stage.addChild(textArea);
			str = textArea.text + str + '\n';
			var len:int = str.length;
			if (len > 1000)
			{
				textArea.fontSize = 9;
				textArea.stroke = 1;
			}
			else if (len > 500)
			{
				textArea.fontSize = 12;
				textArea.stroke = 2;
			}
			else
			{
				textArea.fontSize = 15;
				textArea.stroke = 3;
			}
			
			textArea.text = str;
			//textArea.mouseEnabled = true;
			//this.textArea.changeText(this.textArea.text + str + '\n');
		
			//console.debug.apply(null, rest);
			//this.textArea.cacheAsBitmap();
		}
		
		public function clear(index:int = -1):void
		{
			if (index == -1)
			{
				for (var i:int = 0; i < NUM; i++)
				{
					this.clearOne(i);
				}
			}
			else
			{
				this.clearOne(index);
			}
		
		}
		
		private function clearOne(index:int = 1):void
		{
			var textArea:TextArea = this.getTextArea(index);
			textArea.text = '';
			
			index = Laya.stage.getChildIndex(textArea);
			if (index != -1)
			{
				Laya.stage.removeChildAt(index);
			}
		
		}
	
	}

}