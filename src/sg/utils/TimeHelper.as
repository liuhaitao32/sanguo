package sg.utils {
	import sg.cfg.ConfigServer;
	/**
	 * 基于时间的整理 都可以放到这里来！
	 * @author light
	 */
	public class TimeHelper {
		
		public function TimeHelper() {
			
		}
		
		private static var countDownDic:Object = {};
		
		/**
		 * 
		 * @param	label Lable 或者Text类
		 * @param	totalTime 倒计时时间（毫秒）
		 * @param	mode label显示的类型。。。 时分秒 或者天，或者各种的 
		 * @param	complete 完成回调
		 * @param	interval 间隔时间 默认是1秒倒计时。
		 */
		public static function countDown(label:*, totalTime:Number, mode:int = 2, complete:Function = null, interval:int = 1000):void {
			removeCountDown(label);
			var loopFun:Function = function():void {
				totalTime -= 1000;
				if (totalTime > 0) {
					label.text = Tools.getTimeStyle(totalTime, mode);
				} else {
					if (complete != null) complete.call();
					complete = null;
					removeCountDown(label);
				}
				
				
			}
			label.text = Tools.getTimeStyle(totalTime, mode);
			countDownDic[label] = loopFun;
			Laya.timer.loop(interval, label, loopFun);
		}
		
		
		public static function removeCountDown(label:*):void {
			if (countDownDic[label]) {
				Laya.timer.clear(label, countDownDic[label]);
				delete countDownDic[label];
			}
		}
		
        public static const TYPE_CHINESE:String = 'chinese';
        public static const TYPE_NORMAL:String = 'normal'; // 通用
		
		/**
		 * 格式化时间
		 * @param	milliseconds 毫秒
		 * @param	mode 模式 （默认返回中文字符串）
		 * @param	full 是否返回完整字符串 （模式为中文时生效，默认只包含两个时间）eg：3天2小时， 10分32秒
		 * @return	时间字符串
		 */
		public static function formatTime(milliseconds:int, mode:String = TYPE_CHINESE, full:Boolean = false):String {
            var str:String = '';
            milliseconds = milliseconds >= 0 ? milliseconds : 0;

			// 中文格式单位
            var str_d:String = Tools.getMsgById('_public111');
            var str_h:String = Tools.getMsgById('_public108');
            var str_m:String = Tools.getMsgById('_public109');
            var str_s:String = Tools.getMsgById('_public112');
            
			var s:Number = Math.floor(milliseconds * 0.001);
			var m:Number = Math.floor(s / 60);
			var h:Number = Math.floor(m / 60);
			var d:Number = Math.floor(h / 24);

            h %= 24;
            m %= 60;
            s %= 60;

			switch(mode) {
				case TYPE_NORMAL:
					var h_str:String = String(d*24 + h);
					h_str = h_str.length === 1 ? '0' + h_str : h_str; 
					str = h_str + ":" + StringUtil.padding(String(m), 2, '0', false) + ':' + StringUtil.padding(String(s), 2, '0', false);
					break;
				case TYPE_CHINESE:
					if (d) 		str = !full ? (d + str_d + h + str_h) : (d + str_d + h + str_h + m + str_m + s + str_s);
					else if (h)	str = !full ? (h + str_h + m + str_m) : (h + str_h + m + str_m + s + str_s);
					else if (m)	str = (m + str_m + s + str_s);
					else		str = s + str_s;
					break;
				default:
					console.warn('TimeHelper formatTime');
					break;
			}
			return str;
		}

		/**
		 * 根据时区转换显示的时间
		 * @param	ms 毫秒
		 * @return	时间字符串 eg: 08：30
		 */
		public static function changeTimeByTimezone(ms:int):Date {
			var offset:int = (-(ConfigServer.system_simple.server_time_zone || 8) * 60 - (new Date().getTimezoneOffset())) * Tools.oneMinuteMilli;
			var date:Date = new Date(ms + offset);
			return date;
		}
		
		
		public static function changeZoneStrOne(str:String):String {			
			//00:00;
			var arr2:Array = str.split(/\:|：/g);
			var d1:Date = new Date();
			d1.setHours(parseInt(arr2[0]));
			
			d1 = changeTimeByTimezone(d1.getTime());
			str = StringUtil.padding(String(d1.getHours()), 2, '0', false);
			if (arr2.length == 2) {
				str += ":" + arr2[1];
			}
			return str;
		}
		
		public static function changeZoneStr(str:String):String {
			str = str.replace(/!-(\S+?)-!/g, function(str1, str2):String{
				str2 = TimeHelper.changeZoneStrOne(str2)
				return str2;
			});
			return str;
		}
		
	}

}