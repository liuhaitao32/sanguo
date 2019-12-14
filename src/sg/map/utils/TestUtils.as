package sg.map.utils 
{
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.ui.Button;
	import laya.utils.Browser;
	import laya.utils.Stat;
	import sg.scene.view.TestButton;
	/**
	 * ...
	 * @author light
	 */
	public class TestUtils 
	{
		/**
		 * 记录当前起点时间
		 */
		private static var times:Object = new Object();
		
		public static var text:Text = new Text();
		
		private static var _inited:Boolean = false;
		///显示游戏内调试信息
		public static var isTestShow:int = 0;
		///测试文本状态 0正常串 1ID串 2随机增长串
		public static var isTestMsg:int;
		public static var sgDebug:int = 0; // 开启调试 在融合地址中会开启
		
		public static function init():void {
			text.autoSize = true;
			text.fontSize = 18;
			text.color = "#FFFFFF";
			text.stroke = 2;
			text.strokeColor = "#000000";
			text.y = 300;
			Laya.timer.frameLoop(3, text, function():void {
				Laya.stage.addChild(text);
			});
		}
		
		public static function drawTest(sp:Sprite):void {
			var s:Sprite = new Sprite();
			s.graphics.drawCircle(0, 0, 50000, "FF0000");
			sp.addChild(s);
			s.alpha = 0.5;
		}
		
		public static function timeStart(obj:Object = null):void
		{
			if (isTestShow != 1) return;
			if (!_inited) {
				_inited = true;
				init();
			}
			
			if (null == obj)
				obj = "TestUtils";
			times[obj] ||= {start: 0, runTime: 0, maxTime: 0, intervalTime: Browser.now()};
			times[obj].start = Browser.now();
		}
		
		/**
		 * 获取当前运行时间
		 * @return
		 */
		public static function getRumTime(obj:Object = null):Number
		{
			if (isTestShow != 1) return 0;
			if (null == obj)
				obj = "TestUtils";
				
			text.text = ""; 
			for (var item:Object in times)
				{
					if (obj == item)
					{
						var time:Number = Browser.now();
						times[item].runTime = time - times[obj].start;
						//每运行100毫秒 进行重新的maxTime采样！
						if (time - times[item].intervalTime >= 2000)
						{
							times[item].intervalTime = Browser.now();
							times[item].maxTime = 0;
							
						}
						times[item].maxTime = Math.max(times[item].runTime, times[item].maxTime);
					}
					text.changeText(text.text + item + ":" + times[item].runTime + "ms\t(max:\t" + times[item].maxTime + ")\n");
				}
			return times[obj].runTime;
		}
		
		
		public static function downLoadTxt(str:String, name:String):void {
			 __JS__(
			"var a=document.createElement('a');a.setAttribute('href','data:text/html;gb2312,'+str);a.setAttribute('download',name + '.txt');a.setAttribute('target','_blank');a.style.display='none';a.click()");
			//w.close();  
		}
		
		
	}

}