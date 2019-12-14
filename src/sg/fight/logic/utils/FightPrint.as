package sg.fight.logic.utils
{
	import laya.display.Node;
	import laya.display.Sprite;
	import sg.cfg.ConfigApp;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.test.TestFightData;
	import sg.manager.EffectManager;
	import sg.manager.ViewManager;
	import sg.map.utils.TestUtils;
	import sg.model.ModelHero;
	
	/**
	 * 战斗相关打印，可以通过集中手段屏蔽
	 * @author zhuda
	 */
	public class FightPrint
	{
		/**
		 * 将对象转为字符串
		 */
		public static function toString(obj:*):String
		{
			//FightUtils.print("正在检测 " + obj.constructor);
			//FightUtils.print("getClassName "+FightUtils.getClassName(obj));
			
			if (obj is Array)
			{
				var arr:Array = obj as Array;
				var len:int = arr.length;
				var str:String = '[';
				for (var i:int = 0; i < len; i++)
				{
					str += toString(arr[i]);
					if (i < len - 1)
					{
						str += ',';
					}
				}
				str = str + ']';
				return str;
			}
			//return obj.toString();
			var className:String = FightPrint.getClassName(obj);
			////TestPrint.instance.print("类型 " + className);
			//
			if (className == 'Object')
				return JSON.stringify(obj);
			
			return className;
		
		}
		/**
		 * 得到对战字符串
		 */
		public static function getFightRecordCompareVSStr(obj:Object):String
		{
			var vs:String = '';
			var troops:Array = obj.troop;
			var initObj:Object = obj.init?obj.init:obj;
			if (initObj && initObj.hasOwnProperty('fight_count'))
			{
				vs += '第' + (initObj.fight_count+1) + '战：';
			}
			if (troops){
				vs += '\n' + ModelHero.getHeroName(troops[0].hid)+'vs'+ModelHero.getHeroName(troops[1].hid)+'  ';
			}
			return vs;
		}
		
		/**
		 * 打印战斗初始化js是否一致
		 */
		public static function showFightInitJSCompare(b:Boolean, clientInitJS:Object, serverInitJS:Object):void
		{
			if (TestUtils.isTestShow || ConfigApp.testFightType)
			{
				var vs:String = getFightRecordCompareVSStr(serverInitJS);
				var str:String = b ? "initJS一致" : "对比initJS不一致，以上为不一致内容";
				trace(vs + str);
				//console.error(vs + str);

				//ViewManager.instance.showTipsTxt(str);
				if (!b)
				{
					trace("\n客户端initJS：\n", clientInitJS, "\n服务端initJS：\n", serverInitJS);
				}
			}
		}

		/**
		 * 打印战斗结果对象是否一致
		 */
		public static function showFightRecordCompare(b:Boolean, clientRecord:Object, serverRecord:Object):void
		{
			if (TestUtils.isTestShow)
			{
				var vs:String = getFightRecordCompareVSStr(serverRecord);
				var str:String = b ? "战报一致" : "对比战报不一致！！！";
				if (b){
					trace(vs + str);
				}
				else{
					console.error(vs + str +((b)?"":"以上为不一致内容"));
				}

				ViewManager.instance.showTipsTxt(str, b ? 0.5:3);
				if (!b)
				{
					//console.error("对比战报不一致！！！");
					trace("\n客户端战报：\n", clientRecord, "\n服务端战报：\n", serverRecord);
				}
				else{
					if (clientRecord.hasOwnProperty('rnd')){
						trace("结束rnd:" +clientRecord.rnd);
					}
				}
			}
		}
		
		/**
		 * 获得对象的构造函数名称
		 */
		public static function getClassName(obj:*):String
		{
			return obj.constructor.name;
		}
		/**
		 * 获得从根目录到当前对象的路径
		 */
		public static function getPathStr(node:Node, str:String = ''):String
		{
			var currStr:String = getClassName(node);
			if (node.name)
				currStr += '|' + node.name;
			if (node.parent){
				return getPathStr(node.parent, str) + ' >> ' + currStr;
			}
			return currStr;
		}

		
		/**
		 * 获得打印颜色(纯客户端使用)
		 */
		public static function getPrintColor(teamIndex:int, mixColor:String = null, mixRate:Number = 0.5):String
		{
			var color:String = teamIndex == 0?'#007799':'#AA6600';
			if (mixColor){
				color = EffectManager.mixColor(color, mixColor, mixRate);
			}
			return color;
		}
		/**
		 * 打印
		 */
		public static function print(str:String, data:* = null, color:String = null):void
		{
			if (color){
				console.log('%c'+str, 'color:'+color+';');
			}
			else{
				console.log(str);
			}
			if (data != null)
			{
				console.log(data);
				//str += '\n' + FightPrint.toString(data);
			}
		}
		
		/**
		 * 判断并打印
		 */
		public static function checkPrint(type:String, str:String, data:* = null):void
		{
			if (check(type))
			{
				print(str, data);
			}
		}
		
		/**
		 * 判断是否可打印
		 */
		public static function check(type:String):Boolean
		{
			if (ConfigFight.printTypes[type] == 1)
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 打印
		 */
		//public static function trace(str:String, data:* = null, color:String = null):void
		//{
			//
		//}
	
	}

}