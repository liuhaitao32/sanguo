package sg.utils
{
	
import laya.events.Event;
import laya.html.dom.HTMLDivElement;
import laya.ui.Button;
import sg.utils.Tools

	import laya.display.Node;
	import laya.display.Sprite;
	import laya.maths.MathUtil;
	import laya.resource.Texture;
	import laya.ui.Component;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.utils.TestUtils;
	import sg.net.NetSocket;
	import sg.model.ModelUser;
	import sg.map.utils.ArrayUtils;
	import laya.ui.Label;
	import laya.ui.Image;
	import laya.ui.Box;
	import sg.zmPlatform.ConstantZM;
	import sg.manager.FilterManager;

	/**
	 * ...
	 * @author
	 */
	public class Tools{
		public static var sMsgDic:Object = {};
		public static var sMsgLocalDic:Object = null;
		public static const oneMillis:Number = 1000;
		public static const oneMinuteMilli:Number = 60*oneMillis;
		public static const oneHourMilli:Number = 60*oneMinuteMilli;
		public static const oneDayMilli:Number = 24*oneHourMilli;
		
		/**
		 * 得到浏览器参数
		 */
		public static function getURLexp(key:String):*{
			//if(Browser.onPC){
			if (Browser.window && Browser.window.location && Browser.window.location.search){
				var str:String = Browser.window.location.search.substr(1);
				var reg:* = new RegExp("(^|&)"+ key +"=([^&]*)(&|$)");
				var arr:Array = str.match(reg);
				
				if(arr) {
					return unescape(arr[2]);
				} else {
					return null;
				} 
			}
			return null;
		}
		public static function getURLexpToObj(ruler:Array):Object{
			if (Browser.window && Browser.window.location && Browser.window.location.search){
				var str:String = Browser.window.location.search;
				str = str.substr(1,str.length);
				//
				var arr1:Array = str.split("&");
				var len:int = arr1.length;
				var arr2:Array = null;
				var data:Object = {};
				for(var i:int = 0; i < len; i++)
				{
					str = arr1[i];
					arr2 = str.split("=");
					if(arr2 && arr2.length>0 && str){
						if(ruler.indexOf(arr2[0])<0){
							data[arr2[0]]=arr2[1];
						}
					}
				}
				return data;
			}
			return null;
		}
		public static function signValue(data:Object):String
		{
			var str:String = "";
			var arr:Array = [];
			for(var key:String in data)
			{
				if(key!="sign"){
					arr.push(key);
				}
			}
			arr.sort();
			var len:int = arr.length;
			for(var i:int = 0; i < len; i++)
			{
				str+= data[arr[i]];
			}
			return Browser.window.md5(str);
		}
		/**
		 * 销毁显示对象
		 */
		public static function destroy(node:Node):void {
			if (node != null && !node.destroyed) node.destroy();
		}
		/**
		 * 获取品质颜色文字，白绿蓝紫金红
		 */
		public static function getColorInfo(index:int):String{
			return Tools.getMsgById(ConfigServer.system_simple.color_info[index]);
		}
		/**
		 * 判断是否存在文字配置
		 */
		public static function hasMsgById(id:*):Boolean{
			return Tools.sMsgDic.hasOwnProperty(id + "");
		}
		/**
		 * 获取server文字配置
		 * showEmpty=true，找不到配置就显示空，否则显示原串
		 */
		public static function getMsgById(id:*, arg:Array = null, showEmpty:Boolean = true):String{
			var indexStr:String = id+"";
			if(isNullString(indexStr)){
				return "";
			}
			if (TestUtils.isTestMsg == 1){
				return indexStr;
			}
			
			var str:String = getObjValue(sMsgDic,indexStr,showEmpty?"":indexStr);
			//var rpStr:String = "";
			if (!isNullString(str)){
				if (TestUtils.isTestMsg == 2){
					return replaceMsg(str, arg) + (Math.random()>0.2?(Math.random()>0.3?(Math.random()>0.5?'one two three':str+str):'123'):'');
				}
				else{
					return replaceMsg(str, arg);
				}	
			}
			else{
				str = getObjValue(sMsgLocalDic,indexStr,showEmpty?"":indexStr);
				if (!isNullString(str)){
					return replaceMsg(str, arg);
				}
				else{
					if(str!=""){
						str +=Tools.getMsgById("msg_Tools_0")+indexStr;
					}
				}
			}
			return str;
		}
		public static function replaceMsg(str:String,arg:Array = null):String{
			if (/\{country\}/.test(str)) {
				str = str.replace('{country}', ModelUser.country_name2[ModelUser.getCountryID()])
			}
			if(arg){
				for (var i:int = 0;i< arg.length;i++) {
					str = FunMsgByValue.msg_replace_func(str,i,arg[i]);
				}
			}
			return str;
		}
		public static function isNullString(str:*):Boolean{
			var b:Boolean = false;
			if(isNullObj(str) || str == "" || str == "undefined"){
				b = true;
			}
			return b;
		}
		public static function isNullObj(obj:*):Boolean{
			if(!obj || obj == undefined || obj == null){
				return true;
			}
			else{
				return false;
			}
		}
		public static function copyObj(s:Object):Object{
			return ObjectUtil.mergeObjects([s]);//JSON.parse(JSON.stringify(s));
		}
		/**
		 * 获取时间戳（毫秒）
		 */
		public static function getTimeStamp(data:Object):Number{
			var date:String = data?(data.hasOwnProperty("$datetime")?data["$datetime"]+"":""):"";
			if(date==""){
				return 0;
			}else{
				if(date.indexOf("-")>-1){
					// return Date["parse"](date.replace(" ","-"));
					var rt:String = date.replace(" ","-");
					rt = rt.replace(/:/g,"-");
					var arr:Array = rt.split("-");
					var dateObj:Date = new Date(arr[0],arr[1]-1,arr[2],arr[3],arr[4],arr[5]);
					return dateObj.getTime();
				}else{
					return Number(date);
				}
			}
			// return TimeHelper.getTime(data);
		}
		public static function getTimeDate(num:Number):Object{
			var dt:Date = new Date(num);
			return {"$datetime":dt.getFullYear()+"-"+(dt.getMonth()+1)+"-"+dt.getDate()+" "+dt.getHours()+":"+dt.getMinutes()+":"+dt.getSeconds()};
		}

		///传入起始时分和结束时分的数组，返回开启时间区间字符串
		public static function getOpenTimesInfo(timeArrs:Array):String{
			var i:int;
			var len:int = timeArrs.length;
			var str:String = '';
			for (i = 0; i < len; i++ ){
				var timeArr:Array = timeArrs[i];
				str += getOpenTimeInfo(timeArr);
				if (i<len-1){
					str += '，';
				}
			}
			return str;
		}
		
		/**
		 * 传入起始时分和结束时分的数组，返回开启时间区间字符串
		 * @param	timeArr [[11,30],[12,00]] 或 [11, 30, 12, 30]
		 */
		public static function getOpenTimeInfo(timeArr:Array):String {
			var hstr:String = Tools.getMsgById("_public108");//"时";
			var mstr:String = Tools.getMsgById("_public109");//"分";
			if (timeArr.length === 4) {
				timeArr = [timeArr.slice(0, 2), timeArr.slice(2, 4)];
			}
			if (timeArr.length === 2) {
				timeArr = timeArr.map(function(arr:Array):String {
					return arr[0] + hstr + (arr[1] > 0 ? arr[1] + mstr : '');
				});
				return Tools.getMsgById('surprise_13', timeArr);
			}
			return '';
		}

		/**
		 * 传入起始时分和结束时分的数组，返回开启时间区间字符串
		 * @param	days [5, 7] 开服第五天到第七天
		 * @param	showYear 显示年份
		 * @return 8月12日至8月14日
		 */
		public static function getOpenDaysInfo(days:Array, showYear:Boolean = false):String {
			if (days is Array) {
				var user:ModelUser = ModelManager.instance.modelUser;
				var gameDate:int = user.getGameDate();
				var currentTime:int = ConfigServer.getServerTimer();
				var currentDate:Date = new Date(currentTime);
				currentDate.setHours(23, 0, 0, 0);
				var baseTime:int = currentDate.getTime(); // 基准时间

				if (days.length === 1)    return Tools.day2Date(days[0], showYear, true);
				else return Tools.getMsgById('surprise_13', days.map(function(day:int):String { return Tools.day2Date(day, showYear, true);}));
			}
			return '';
		}

		/**
		 * 开服天数转日期
		 * @param	day 5 开服第五天
		 * @param	showYear 显示年份
		 * @param	chinese  以中文显示
		 * @return  2019年8月14日(2019-08-14,08-14)
		 */
		public static function day2Date(day:int, showYear:Boolean = false, chinese:Boolean = false):String {
			var user:ModelUser = ModelManager.instance.modelUser;
			var gameDate:int = user.getGameDate();
			var currentTime:int = ConfigServer.getServerTimer();
			var currentDate:Date = new Date(currentTime);
			currentDate.setHours(23, 0, 0, 0); // 取23点是为了避免与偏移值冲突
			var baseTime:int = currentDate.getTime(); // 基准时间
			var destTime:int = baseTime + (day - gameDate) * Tools.oneDayMilli;
			var d:Date = new Date(destTime);

			var _month:String = (d.getMonth()+1) < 10 ? "0"+(d.getMonth()+1) : (d.getMonth()+1)+"";;
			var _Date:String  = d.getDate()<10 ? "0"+d.getDate() : d.getDate()+"";
			var arr:Array = showYear ? [d.getFullYear(), _month, _Date]: [_month, _Date];
			
			if (chinese) {
				if (showYear) {
					return Tools.getMsgById('msg_Tools_1', arr);
				} else {
					return Tools.getMsgById('msg_Tools_8', arr);
				}
			} else {
				return arr.join('-');
			}
		}

		/**
		 * 
		 * type=2  x天x小时x分x秒 保留最大两位
		 * type=3  返回格式00:00:00 空位用0补齐
		 * type=4  完整的 x天x小时x分x秒
		 */
		public static function getTimeStyle(ms:Number,type:int = 2):String{
			if(ms<=0){
				return (type==2)?"---":"00:00:00";
			}
			var s:Number = Math.floor(ms*0.001);
			var m:Number = Math.floor(s/60);
			var h:Number = Math.floor(m/60);
			var d:Number = Math.floor(h/24);

			
			//
			var str:String = "";
			var icon:String = " : ";
			//
			var dstr:String = Tools.getMsgById("_public111");//"天";
			var hstr:String = Tools.getMsgById("_public108");//"时";
			var mstr:String = Tools.getMsgById("_public109");//"分";
			var sstr:String = Tools.getMsgById("_public112");//"秒";
			//
			if(type==2){
				if(d>0){
					h = (h%24);
					str=d+dstr+((h>0)?h+hstr:"");
				}
				else if(h>0){
					m = (m%60);
					str=h+hstr+((m>0)?m+mstr:"");
				}
				else if(m>0){
					s = (s%60);
					str=m+mstr+((s>0)?s+sstr:"");
				}
				else if(s>0){
					str=s+sstr;
				}
			}else if(type==3){
				var _h:String=h%24<10?"0"+h%24:h%24+"";
				var _m:String=m%60<10?"0"+m%60:m%60+"";
				var _s:String=s%60<10?"0"+s%60:s%60+"";
				if(d>0){
					str=(d*24+Number(_h))+":"+_m+":"+_s;
				}
				else if(h>0){
					str=_h+":"+_m+":"+_s;					
				}
				else if(m>0){
					str="00:"+_m+":"+_s;
				}
				else if(s>0){
					str="00:00:"+_s;
				}
			}else if(type==4){
				str = d+dstr+(h%24)+hstr+(m%60)+mstr+(s%60)+sstr;
			}
			return str;
		}
		
		/**
		 * 获取向上取整的整数，确保和服务端一致(取5位精度)
		 */
		public static function toCeil(value:Number):int{
			return Math.ceil(Number(value.toFixed(5)));
		}
		/**
		 * 获取保留有效位数的整数
		 */
		public static function numberFormat(value:Number, p:int = 0):String{
			if (!(value is Number)){
				return 'null';
			}
			if (p > 0 && Math.abs(value - Math.round(value))<0.0001){
				p = 0;
			}
			return value.toFixed(p);
		}
		/**
		 * 百分比格式化，p为最大保留小数位数
		 */
		public static function percentFormat(value:Number, p:int = 0):String{
			value *= 100;
			if (p > 0 && Math.abs(value - Math.round(value))<0.0001){
				p = 0;
			}
			return value.toFixed(p) + '%';
		}
		/**
		 * 时间格式化
		 */
		public static function dateFormat(dt:*,type:int=0):String{
			var ms:Number = 0;
			if(dt is Number){
				ms = dt;
			}
			else{
				ms = getTimeStamp(dt);
			}
			var d:Date=new Date(ms);
			var s:String="";
			if(dt!=null){
				var _hour:String=d.getHours()<10?"0"+d.getHours():d.getHours()+"";
				var _min:String=d.getMinutes()<10?"0"+d.getMinutes():d.getMinutes()+"";
				var _secend:String=d.getSeconds()<10?"0"+d.getSeconds():d.getSeconds()+"";



				if(type==0)
					//d.getFullYear()+"年"+(d.getMonth()+1)+"月"+d.getDate()+
					s = Tools.getMsgById("msg_Tools_1",[d.getFullYear(),(d.getMonth()+1),d.getDate()]) +_hour+":"+_min+":"+_secend;
				else if(type==1){
					var _month:String = (d.getMonth()+1) < 10 ? "0"+(d.getMonth()+1) : (d.getMonth()+1)+"";
					var _Date:String  = d.getDate()<10 ? "0"+d.getDate() : d.getDate()+"";
					s = d.getFullYear()+"-"+_month+"-"+_Date+" "+_hour+":"+_min+":"+_secend;
				}else if(type==2){
					s = _hour+":"+_min+":"+_secend;
				}
					
			}			
			return s;
		}

		public static function getObjValue(obj:*,key:*,v:*):*{
			if(obj){
				return obj.hasOwnProperty(key)?(obj[key]?obj[key]:v):v;
			}
			else{
				return v;
			}
		}

		/**
		 * 检测参数时间是不是今天
		 */
		public static function isNewDay(dt:*):Boolean {
			var num:Number = 0;
			if(dt is Number){
				num=dt;
			}else if(dt is Object){
				num=getTimeStamp(dt);
			}
			var ns:Number = gameDay0hourMs(ConfigServer.getServerTimer()); // 当前时间
			var st:Number = ns;
			var et:Number = ns+oneDayMilli; // 明天这个时间
			//
			if(num<st || num>=et){
				return true;
			}
		    return false;
		}

		/**
		 * 检测从现在到指定时间点需要的时间 时间没到返回正数，时间过了返回负数
		 */
		public static function getRemainTime(v:*):Number{
			return getTimeStamp(v) - ConfigServer.getServerTimer();
		}

		/**
		 * 今天还剩多长时间
		 */
		public static function getDayDisTime(nn:Number = 0):Number{
			var now:Number = nn==0 ? ConfigServer.getServerTimer() : nn;
			var n:Number = gameDay0hourMs(now);
			return n+oneDayMilli-now;
		}

		/**
		 * 偏移值转成【时，分】
		 */
		public static function deviationTime():Array{
			var d:Number = ConfigServer.system_simple ? ConfigServer.system_simple.deviation : 0;
			var n:Number = Math.floor(d/60);
			var m:Number = d%60;
			return [n,m];
		}
		/**
		 * 任何时间数据的,自己的零点ms+偏移时间ms
		 */
		public static function gameDay0hourMs(v:*):Number{
			var num:Number = 0;
			if(v is Number){
				num = v;
			}else if(v is Object){
				num = getTimeStamp(v);
			}		
			var d:Number = ConfigServer.system_simple.deviation*oneMinuteMilli;
			

			var dt:Date = new Date(num);
			dt.setHours(0);
			dt.setMinutes(0);
			dt.setSeconds(0);
			dt.setMilliseconds(0);
			var h0:Number = dt.getTime();
			var r:Number = num - h0;
			var re:Number = 0;
			if(r<d){
				re = h0-oneDayMilli+d;
			}
			else{
				re = h0+d;
			}
			return re;
		}
		public static function getGameServerStartTimer(zid:*):Number{
			var openServerTimer:Number = Tools.getTimeStamp(ConfigServer.zone[""+zid][2]);//testd.getTime();//
			//
			var rt:Number = 0;
			var rulerNum:Number = Tools.gameDay0hourMs(openServerTimer);
			if(openServerTimer<rulerNum){
				rt = (rulerNum - Tools.oneDayMilli);
			}
			else{
				rt = rulerNum;
			}
			return rt;
		}

		/**
		 * 距离某个季节的时间
		 */
		public static function getSeasonTimes(season:Number):Number{			
			var ns:Number = gameDay0hourMs(ConfigServer.getServerTimer());
			var dt:Date=new Date(ns);
			//trace(Tools.dateFormat(ns));
			var nn:Number=getYearDis(season,[dt.getHours(),dt.getMinutes()]);
			return nn;
		}

		/**
		 *几小时前   几天前 
		 */
		public static function howTimeToNow(time:Number):String{
			var n:Number=ConfigServer.getServerTimer()-time;
			//trace("==============",Tools.dateFormat(time));
			var nn:Number=0;
			if(n<oneHourMilli){
				nn=Math.ceil(n/oneMinuteMilli);
				return nn+Tools.getMsgById("msg_Tools_5");
			}else if(n>oneHourMilli && n<oneDayMilli){
				nn=Math.floor(n/oneHourMilli);
				return nn+Tools.getMsgById("msg_Tools_3");
			}else{
				nn=Math.floor(n/oneDayMilli);
				return nn+Tools.getMsgById("msg_Tools_2");
			}
			return "";
		}

		/**
	 	* 判断消耗品是否充足
	 	*/
		public static function isCanBuy(id:String,num:Number,showText:Boolean=true):Boolean{
			var name:String="";
			if(id == "coin" || id == "gold" || id == "food" || id == "wood" || id == "iron" || id =="merit"){
				if(ModelManager.instance.modelUser[id]<num){
					name=ModelManager.instance.modelProp.getItemProp(id).name;
					showText && ViewManager.instance.showTipsTxt(name+Tools.getMsgById("_public95")+num);
					return false;
				}else{
					return true;
				}
			}else{
				var o:Object=ModelManager.instance.modelUser.property;
				if(o[id]){
					if(o[id]>=num){
						return true;
					}
				}
				name=ModelManager.instance.modelProp.getItemProp(id).name;
				showText && ViewManager.instance.showTipsTxt(name+Tools.getMsgById("_public95")+num);
			}
			return false;
		}

		/**
		 * 获得货币名称
		 */
		public static function getNameByID(id:String):String{
			
			return ModelManager.instance.modelProp.getItemProp(id).name;
			/*
			var s:String="";
			switch(id)
			{
				case "coin":
					s=getMsgById("190005");//元宝
					break;
				case "gold":
					s=getMsgById("190001");//"银两";
					break;
				case "wood":
					s=getMsgById("190003");//"木材";
					break;
				case "food":
					s=getMsgById("190002");//"粮草";
					break;
				case "iron":
					s=getMsgById("190004");//"生铁";
					break;
				default:
					break;
			}
			return s;*/
		}

		/**
		 * 货币的数值显示
		 */
		public static function textSytle(num:Number):String{
			if(num>99999999){
				num=Math.floor(num/100000000);
				return num+Tools.getMsgById("msg_Tools_7");//"亿";
			}
			else if(num>9999999){
				num=Math.floor(num/10000000);
				return num+Tools.getMsgById("msg_Tools_4");
			}			
			else if(num>99999){
				num=Math.floor(num/10000);
				return num+Tools.getMsgById("msg_Tools_6");// "万";
			}			
			else{
				return num+"";
			}
			
		}

		/**
		 * 获得字典长度
		 */
		public static function getDictLength(dict:Object,isCheckMore:Boolean = false):Number{
			var n:Number=0;
			for each(var v:String in dict)
			{
				n+=1;
				if(isCheckMore){
					if(n>0){
						return n;
					}
				}
			}
			return n;
		}

		/**
		 *  时间间隔外,执行
		 */
		public static function runAtTimer(star:Number,ruler:Number,handler:Handler):Number{
			var now:Number = new Date().getTime();
			if((now-star)>=ruler){
				
				handler.run();
				return now;
			}
			return star;
		}
		public static function check1280Img(img:Sprite,ani:Boolean = false):void{
			if(ConfigApp.ratio>=ConfigApp.ratio_21){
				var w:Number = 1280/ConfigApp.ratio;
				var s:Number = Math.max(w,640)/Math.min(w,640);
				img.scale(s,s);
				// img.height = ConfigApp.height;
				// img.width = Math.floor(640*s);

			}
			if(!ani){
				(img as Component).centerX = 0;
				(img as Component).centerY = 0;
			}
		}
		public static const material_pay_index:Array = [
			"item",
			"merit",
			"gold",
			"food",
			"wood",
			"iron",
			"coin"
		];
		public static function getPayItemArr(pay:Object):Array{
			var arr:Array = [];
			var index:int = -1;
			for(var key:String in pay)
			{
				index = material_pay_index.indexOf((key.indexOf("item")>-1)?"item":key);
				arr.push({sortIndex:index,id:key,data:pay[key]});
			}
			//arr.sort(MathUtil.sortByKey("id"));
			arr.sort(MathUtil.sortByKey("sortIndex",false,true));
			return arr;
		}
		public static function isSameArr(arr0:Array,arr1:Array,sortB:Boolean = false):Boolean{
			var b:Boolean = false;
			if(arr0 && arr1){
				if(arr0.length == arr1.length){
					var len:int = arr0.length;
					if(sortB){
						arr0.sort();
						arr1.sort();
					}
					b = true;
					for(var i:int = 0; i < len; i++)
					{
						if(arr0[i]!=arr1[i]){
							b = false;
							break;
						}
						
					}
				}
			}
			return b;
		}
		/**
		 * 当前时间 和 ruler时间 是否是不同小时内
		 */
		public static function isDiffHour(now:Number,ruler:Number):Boolean{
			var nh:Number = Math.floor(now/oneHourMilli);
			var rh:Number = Math.floor(ruler/oneHourMilli);
			if(Math.abs(nh-rh)>0){
				return true;
			}
			return false;
		}
		/**
		 * 下一个整点 小时 ms
		 */
		public static function getMsNextHourMs(now:Number):Number{
			return (Math.floor(now/oneHourMilli)+1)*oneHourMilli;
		}
		/**
		 * 距离某个季节的某时刻剩余时间 end_day:季节0123   t_arr:[时,分]  now_num测试用的
		 */
		public static function getYearDis(end_day:Number,t_arr:Array,now_num:Number = 0):Number{
			
			var t:Number=0;

			var n:Number=now_num!=0 ? (Math.ceil(ModelManager.instance.modelUser.getGameTime(now_num)/Tools.oneDayMilli)-1)%4 : ModelManager.instance.modelUser.getGameSeason();//当前季节0123
			var now:Date=new Date( now_num!=0 ? now_num : ConfigServer.getServerTimer());
			var now_time:Number= now.getHours()*oneHourMilli+now.getMinutes()*oneMinuteMilli+now.getSeconds()*oneMillis+now.getMilliseconds();
			var end_time:Number=t_arr[0]*oneHourMilli+t_arr[1]*oneMinuteMilli;
			var deviation_time:Number = deviationTime()[0]*oneHourMilli + deviationTime()[1]*oneMinuteMilli;
			
			var dis_time0:Number = getDayDisTime(now_num);//现在距离偏移值时间
			var dis_time1:Number =  end_time > deviation_time ? oneDayMilli - (end_time - deviation_time) : deviation_time - end_time;

			var less_day:Number=0;
			var less_time:Number=0;
			//if(now_time>end_time){//过了时间
			if(dis_time0<dis_time1){//过了时间
				if(n==end_day){//当前季节
					less_day=3;
				}else if(n<end_day){//季节前
					less_day=end_day-n-1;
				}else if(n>end_day){//季节后
					less_day=4-(n-end_day+1);
				}
			}else{//还没到时间
				if(n==end_day){
					less_day=0;
				}else if(n<end_day){
					less_day=end_day-n;
				}else if(n>end_day){
					less_day=4-(n-end_day);
				}
			}
			less_time=now_time>end_time ? Tools.oneDayMilli-(now_time-end_time) : end_time-now_time;

			var m:Number=less_day*Tools.oneDayMilli+less_time;
			//trace(n,Tools.getTimeStyle(now_time),Tools.getTimeStyle(end_time),end_day,getTimeStyle(m));
			return m;
		}


		/**
		 * 获得距离第二天某点的时间  t_arr;[时,分]
		 */
		public static function getNextDayStamp(t_arr:Array):Number{
			var now_sea:Number=ModelManager.instance.modelUser.getGameSeason();//当前季节0123
			var now:Date=new Date(ConfigServer.getServerTimer());
			var now_time:Number=now.getHours()*oneHourMilli+now.getMinutes()*oneMinuteMilli+now.getSeconds()*oneMillis+now.getMilliseconds();
			var end_time:Number=t_arr[0]*oneHourMilli+t_arr[1]*oneMinuteMilli;
			if(now_time>end_time){
				return getYearDis(now_sea+1,t_arr);
			}else{
				return getYearDis(now_sea,t_arr);
			}
		}

		/**
		 * 距离今年结束还有多长时间
		 */
		public static function getNextYearStamp():Number{
			var arr:Array=Tools.deviationTime();
			return Tools.getYearDis(0,arr);
		}

		/**
		 * 获得现在距离整点的时间
		 */
		public static function getFullHourDis():Number{
			var now:Number=ConfigServer.getServerTimer();
			var dt:Date=new Date(now);
			return oneHourMilli - (dt.getMinutes()*oneMinuteMilli+dt.getSeconds()*oneMillis+dt.getMilliseconds());
		}

		/**
		 * 获得一个适配比例系数调整后的Y值
		 */
		public static function getAdaptationY(n_min:Number,n_max:Number):Number{
			//trace("===================",Laya.stage.height);
			return n_min + (Laya.stage.height-960)/(1280-960) * (n_max-n_min);
		}

		/**
		 * 用城市名字获得城市id （聊天功能中用到）
		 */
		public static function getCityIDByName(name:String):String{
			var s:String=" ";
			for(var key:String in ConfigServer.city){
				if(Tools.getMsgById(ConfigServer.city[key].name)==name){
					return key;
				}
			}
			return s;
		}

		/**
		 * 获得今天某个时刻的毫秒值（不受偏移值影响）
		 */
		public static function getToDayHourMill(arr:Array):Number{
			var now:Number=ConfigServer.getServerTimer();
			var dt:Date=new Date(now);
			var _year:Number=dt.getFullYear();
			var _mouth:Number=dt.getMonth();
			var _date:Number=dt.getDate();
			var _hour:Number=arr[0];
			var _min:Number=arr[1];

			var n:Number = arr[2] ? arr[2] : 0;//差几天
			var newDT:Date=new Date(_year,_mouth,_date,_hour,_min,0,0);
			return newDT.getTime() + n * Tools.oneDayMilli;
		}

		/**
		 * 获得今天(按开服天数算)某个时刻的毫秒值
		 * @param	arr 	[hour, min]
		 */
		public static function getTodayMillWithHourAndMinute(arr:Array):Number {
			var user:ModelUser = ModelManager.instance.modelUser;
			var tempTime:int = user.gameServerStartTimer + Tools.oneDayMilli * (user.getGameDate() - 1);
			var _date:Date = new Date(tempTime);
			_date.setHours(arr[0], arr[1], 0, 0);

			var _h:int = _date.getHours();
			var _m:int = _date.getMinutes();
			var _mill:int = _date.getTime();
			var deviation:Array = Tools.deviationTime();

			// 配置时间在偏移值之前则取第二天的这个时间(福将挑战时间2点)
			if (_h < deviation[0] || (_h === deviation[0] && _m < deviation[1])) {
				_mill += Tools.oneDayMilli;
			}
			return _mill;
		}

		/**
		 * 功能是否先提示,记录
		 */
		public static function setAlertIsDel(key:String):void{
			if(key){
				var local:Object=SaveLocal.getValue(SaveLocal.KEY_REPEAT_ALERT + ModelManager.instance.modelUser.mUID);
				if(local){
					local[key]=ConfigServer.getServerTimer();
				}else{
					local={};
					local[key]=ConfigServer.getServerTimer();
				}
				SaveLocal.save(SaveLocal.KEY_REPEAT_ALERT + ModelManager.instance.modelUser.mUID,local);
			}
		}
		public static function checkAlertIsDel(key:String):Boolean{
			var b:Boolean = false;
			if(key!=""){
				var local:Object=SaveLocal.getValue(SaveLocal.KEY_REPEAT_ALERT + ModelManager.instance.modelUser.mUID);
				if(local && local[key]){
					var n:Number=local[key];
					if(!Tools.isNewDay(n)){		
						b = true;
					}
				}
			}
			return b;
		}

		/**
		 * 获得一个随机数 从n1到(n2-1)中随机一个数 除了except外
		 */
		public static function getRandom(n1:Number,n2:Number,except:Array=null):Number{
			if(n1==n2){
				return n1;
			}
			if(!except) except=[];
			var n:Number=Math.random();
			var m:Number=Math.floor(Math.abs(n2-n1)*n);
			//trace(n1,n2,m);
			if(except.indexOf(m)==-1){
				return m;
			}else{
				getRandom(n1,n2,except);
			}
			return 0;
		}

		/**
		 * 检查输入的名字是否合法
		 */
		public static function checkNameInput(input:String, handler:Handler):void {
            input = StringUtil.trim(input); // 删除首尾空格	
			if (input.length < 2) { // 检查长度是否过短
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public128"));
				return;
            }
			Platform.shieldFont(input,handler);
		}

		/**
		 * 输入语言限制(昵称)
		 */
		public static function get langData():Array {
			var system_simple:Object = ConfigServer.system_simple;
			var pf:String = ConfigApp.pf;
			var langArr:Array = system_simple.input_lang_default;
			if (langArr is String) { // 兼容旧配置
				langArr = [langArr];
			}
			var lang_pf:Array = system_simple.input_lang_pf[pf];
			if (lang_pf is Array && lang_pf.length) {
				langArr = lang_pf;
			}

			// 中文: '\u4e00-\u9fa5' 日文: '\u0800-\u4e00' 韩文: '\uac00-\ud7ff'
			var name_limit:Object = system_simple.name_limit || { // 取名限制(限制输入的字符、单个字符所占长度, 允许的最大字符数)
                'zh': ['\u4e00-\u9fa5', 2, 5],
                'en': ['a-zA-Z·', 1, 10]
			};
			return langArr.map(function(lang:String):Array {
				var arr:Array = ['', 1, 10];
				name_limit[lang] &&  (arr = ObjectUtil.clone(name_limit[lang]) as Array);
				arr.unshift(lang);
				return arr;
			});
		}

		/**
		 * 根据配置规则判定是否可见
		 * @param pf 二维数组 [[],['h5_37']] 第0位数组 哪些平台可见 第1位数组 哪些平台不可见 优先检查第0位，且只有1个数组生效，两个都是空数组则返回true
		 * @return 是否可见
		 */
		public static function checkVisibleByPF(pf:Array):Boolean {
			if (!(pf is Array)) return true;
			var visibleArr:Array = pf[0];
			var disvisibleArr:Array = pf[1];
			var plat:String = ConfigApp.pf;
			if (ConstantZM.platform) {
				plat = ConstantZM.platform; // 阿拉丁 速易
			}
			if (visibleArr && visibleArr.length) {
				return visibleArr.indexOf(plat) !== -1;
			} else if (disvisibleArr && disvisibleArr.length) {
				return disvisibleArr.indexOf(plat) === -1;
			}
			return true;
		}

		/**
		 * 格式化时间字符串
		 * arr 由数字组成的数组
		 */
		public static function getTimeString(arr:Array):String {
			return arr.map(function(num:int):String {return StringUtil.padding(String(num),2,'0',false) }).join(':');
		}

		//=======================================================
		/**
		 * 文本框适配（两个文本框的时候）
		 */
		public static function textLayout(_label:Label,_com:*,_img:Image=null,_parent:Box=null):void{
			_label.width = _label.textField.textWidth;
			if(_parent) _label.x = 0;
			var _gap:Number = 4;
			if(_com is Label){
				var _label1:Label = _com as Label;
				if(_img){
					_img.x = _label.x + _label.width + _gap;
					_label1.width = _img.width;
					_label1.x = _img.x;
					_label1.align = 'center';
				}else{
					_label1.width = _label1.textField.textWidth;
					_label1.x = _label.x + _label.width + _gap;
					_label1.align = 'left';
				}

				if(_parent) _parent.width = _label.width + _label1.width + _gap;
				
			}else{
				_com.x = _label.x + _label.width + _gap*2;
				if(_img){
					if(_img.height<=_com.height){
						_img.x = _label.x + _label.width + _gap + 22;
					}else{
						_img.x = _label.x + _label.width + _gap;
						_com.x = _img.x + 10;
					}
				} 
				if(_parent && _img) _parent.width = _img.x + _img.width;
					
			}

		}

		//=======================================================
		/**
		 * 文本框适配(标题适配)
		 */
		public static function textLayout2(_label:Label,_img:Image,_imgSize:Number = 300,_imgAdd:Number = 250,_imgMax:Number=480,_center:Boolean = true):void{
			var _scaleX:Number = _img.scaleX;
			var _min:Number = _imgSize;
			var _max:Number = _imgMax;
			var _addNum:Number = _imgAdd;
			_label.width = _label.textField.textWidth;
			_img.width = _label.width/_scaleX + _addNum;
			
			if(_img.width < _min){
				_img.width = _min;
			}else if(_img.width > _max){
				_img.width = _max;
				_label.width = (_max - _addNum)*_scaleX;
				_label.align = 'center';
				_label.valign = 'middle';
				textFitFontSize(_label, null, _label.width);
			}

			if(_center){
				_img.centerX = _label.centerX = 0;
			}else{
				_label.x = (_img.width - _label.width)/2;
			}
		
		}

		/**
		 * 文本框适配（固定box大小  文字底图适配）
		 */
		public static function textLayout3(_label1:Label,_label2:Label,_img:Image,_parent:Box):void{
			var _gap:Number = 4;
			_label1.x = 0;
			_label1.width = _label1.textField.textWidth;
			if(_label1.width < _parent.width){
				_img.width = _parent.width - _label1.width - _gap;
				_img.x = _label1.width + _gap;
				_label2.width = _img.width;
				_label2.x = _img.x;
				_label2.align = 'center';
			}
		}
		
		
		/**
		 * 细节化文本框。在保持显示大小的前提下，减小文本框Scale，增大width、height、fontSize等，使之适配字号<11的文本仍可清晰显示。需要在调用textFitFontSize前调用此方法
		 * @param _spr 支持Label、Button、HTMLDivElement
		 * @param _scale 目标缩放比
		 */
		public static function textScale(_spr:Sprite, _scale:Number = 0.5):void{
			if (_spr.scaleY != _scale){
				var rate:Number = _scale / _spr.scaleY;
				var isChange:Boolean = false;

				if (_spr is Label){
					isChange = true;
					var _label:Label = _spr as Label;
					_label.height /= rate;
					_label.width /= rate;
					_label.fontSize = Math.ceil(_label.fontSize / rate);
					if (_label['originalFontSize']){
						_label['originalFontSize'] = _label['originalFontSize'] / rate;
					}
					if(_label.stroke)
						_label.stroke = Math.ceil(_label.stroke / rate);
					if(_label.leading)
						_label.leading = Math.ceil(_label.leading / rate);
				}else if (_spr is Button){
					isChange = true;
					var _btn:Button = _spr as Button;
					_btn.width /= rate;
					_btn.height /= rate;
					_btn.labelSize = Math.ceil(_btn.labelSize / rate);
					if(_btn.labelStroke)
						_btn.labelStroke = Math.ceil(_btn.labelStroke / rate);
					if(_btn.text.leading)
						_btn.text.leading = Math.ceil(_btn.text.leading / rate);
				}
				else if (_spr is HTMLDivElement){
					isChange = true;
					var _htmlDiv:HTMLDivElement = _spr as HTMLDivElement;
					_htmlDiv._width /= rate;
					_htmlDiv._height /= rate;
					_htmlDiv.style.fontSize = Math.ceil(_htmlDiv.style.fontSize / rate);
					if(_htmlDiv.style.leading)
						_htmlDiv.style.leading = Math.ceil(_htmlDiv.style.leading / rate);
				}
				
				if (isChange){
					_spr.scaleX *= rate;
					_spr.scaleY *= rate;
				}
			}
		}
		
		/**
		 * 单行文本框文字按最大宽度缩小适配字号，会自动记录原字号再考虑缩小。返回值为最终实际宽度（一旦调用本方法，认为必定单行，且自动高度水平居中）
		 * @param _spr 支持Label、Button、HTMLDivElement
		 * @param _info 传入的字符串。不输入时保持原文本。HTMLDivElement必须输入
		 * @param _maxWidth 是从父容器来看这个label的限制宽度，为0时取文本框自身宽度
		 * @param _minSize 最小字号（相对于自身缩放前）
		 * @param _autoChange 设为true，Label文字改变时自动调用。其他类型文本变化时需手动调用
		 * @param _autoValign 设为true，Label自动高度并垂直居中
		 */
		public static function textFitFontSize(_spr:Sprite, _info:String = null, _maxWidth:Number = 0, _minSize:int = 11, _autoChange:Boolean = true, _autoValign:Boolean = true):Number{
			var originalFontSize:int;
			var originalWidth:Number;
			var currWidth:Number;
			var _label:Label;
			var tempWidth:Number;
			var tempMinSize:int = Math.ceil(_minSize / _spr.scaleY);
			var scaleX:Number;
			
			if(_spr is Label){
				_label = _spr as Label;
				if (!_label['originalFontSize']){
					_label['originalFontSize'] = _label.fontSize;
				}
				originalFontSize = _label['originalFontSize'];
				_label.fontSize = originalFontSize;
				scaleX = Math.abs(_label.scaleX);
				
				if (_info){
					_label.text = _info;
					//_label.textField.text = _info;
				}
				if (_maxWidth <= 0){
					_maxWidth = (_label._width?_label._width:100) * scaleX;
				}
				_label.wordWrap = false;
				if(_autoValign){
					if (!_label._height){
						_label.height = originalFontSize;
					}
					if (_label.valign == 'top')
						_label.valign = 'middle';
				}
				
				currWidth = _label.textField.textWidth * scaleX;
				if (currWidth > _maxWidth){
					_label.fontSize = Math.max(tempMinSize, Math.floor(originalFontSize * _maxWidth / currWidth));
					currWidth = _label.textField.textWidth * scaleX;
				}
				if (_autoChange){
					//每次改变该文本值时，自动适配
					_label.off(Event.CHANGE, null, Tools.textFitFontSize);
					_label.on(Event.CHANGE, null, Tools.textFitFontSize, [_label, null, _maxWidth, _minSize, false]);
				}
			}
			else if (_spr is Button){
				var _btn:Button = _spr as Button;
				if (!_btn['originalFontSize']){
					_btn['originalFontSize'] = _btn.labelSize;
				}
				originalFontSize = _btn['originalFontSize'];
				if (_info){
					_btn.label = _info;
				}
				_label = new Label(_btn.label);
				_label.fontSize = originalFontSize;
				scaleX = Math.abs(_btn.scaleX);
				//_btn.labelSize = originalFontSize;
				if (_maxWidth <= 0){
					tempWidth = Math.min(_btn.width * 0.2, 30);
					//var sizeGrid:String = _btn.sizeGrid;
					//if (sizeGrid){
						////跳过9切片两边
						//var tempArr:Array = sizeGrid.split(',');
						//if(tempArr[1] && tempArr[3]){
							//extraWidth = tempArr[1] + tempArr[3];
						//}
					//}
					_maxWidth = (_btn.width - tempWidth) * scaleX;
				}
				
				currWidth = _label.textField.textWidth * scaleX;
				if (currWidth > _maxWidth){
					_btn.labelSize = Math.max(tempMinSize, Math.floor(originalFontSize * _maxWidth / currWidth));
					currWidth = _maxWidth;
				}
			}
			else if (_spr is HTMLDivElement){
				var _htmlDiv:HTMLDivElement = _spr as HTMLDivElement;
				if (!_htmlDiv['originalFontSize']){
					_htmlDiv['originalFontSize'] = _htmlDiv.style.fontSize;
				}
				if (!_info)_info = 'HTMLDivElement';
				if (!_htmlDiv['originalWidth']){
					_htmlDiv['originalWidth'] = _htmlDiv.width;
				}
				originalFontSize = _htmlDiv['originalFontSize'];
				originalWidth = _htmlDiv['originalWidth'];
				scaleX = Math.abs(_htmlDiv.scaleX);
				
				_htmlDiv._width = originalWidth;
				
				tempWidth = _htmlDiv._width;
				_htmlDiv.style.fontSize = originalFontSize;
				_htmlDiv.style.wordWrap = false;
				//_htmlDiv.width = Laya.stage.width;
				_htmlDiv.innerHTML = _info;
				if (_maxWidth <= 0){
					_maxWidth = tempWidth * scaleX;
				}
				
				currWidth = _htmlDiv.contextWidth * scaleX;
				if (currWidth > _maxWidth){
					_htmlDiv.style.fontSize = Math.max(tempMinSize, Math.floor(originalFontSize * _maxWidth / currWidth));
					_htmlDiv.innerHTML = _info;
					currWidth = _htmlDiv.contextWidth * scaleX;
				}
				_htmlDiv._width = originalWidth;
				//_htmlDiv.width = tempWidth;
			}
			//trace(_label, '   text: '+_label.text+'  已适配字号 '+ _label.fontSize);
			return currWidth;
		}
		
		
		/**
		 * 多行文本框文字按最大宽度缩小适配字号，此方法消耗较高，会缩小字体并考虑换行放入区域。返回值为最终实际高。一旦调用本方法，认为可换行
		 * @param _spr 支持Label、Button、HTMLDivElement
		 * @param _info 传入的字符串。不输入时保持原文本。Button、HTMLDivElement必须输入
		 * @param _maxWidth 是从父容器来看这个label的限制宽度，为0时取文本框自身宽度
		 * @param _maxHeight 是从父容器来看这个label的限制高度，已为0时取文本框自身高度
		 * @param _minSize 最小字号（相对于自身缩放前）
		 * @param _autoChange 设为true，Label文字改变时自动调用。其他类型文本变化时需手动调用
		 * @param _autoValign 设为true，Label自动高度并垂直居中
		 */
		public static function textFitFontSize2(_spr:Sprite, _info:String = null, _maxWidth:Number = 0, _maxHeight:Number = 0, _minSize:int = 11, _autoChange:Boolean = true, _autoValign:Boolean = true):Number{
			var originalFontSize:int;
			var currHeight:Number;
			var originalWidth:Number;
			var originalHeight:Number;
			var _label:Label;
			var tempWidth:Number;
			var tempHeight:Number;
			var currFontSize:int;
			var assessPower:Number = 0.5;
			var assessRate:Number = 1.1;
			var leading:int;
			var tempMinSize:int = Math.ceil(_minSize / _spr.scaleY);
			var scaleX:Number;
			
			if(_spr is Label){
				_label = _spr as Label;
				if (!_label['originalFontSize']){
					_label['originalFontSize'] = _label.fontSize;
				}
				originalFontSize = _label['originalFontSize'];
				scaleX = Math.abs(_label.scaleX);
				if (_info){
					_label.text = _info;
				}
				_label.fontSize = originalFontSize;
				if (_maxWidth <= 0){
					_maxWidth = (_label._width?_label._width:100) * scaleX;
				}
				if (_maxHeight <= 0){
					_maxHeight = (_label._height?_label._height:100) * _label.scaleY;
				}
				if(!_label.leading)
					_label.leading = 2;
					
				_label.wordWrap = true;
				if(_autoValign){
					if (!_label._height){
						_label.height = _maxHeight;
					}
					if (_label.valign == 'top')
						_label.valign = 'middle';
				}
				
				currFontSize = originalFontSize;
				while (true){
					//trace('尝试了label字号：'+currFontSize);
					_label.fontSize = currFontSize;
					currHeight = _label.textField.textHeight * _label.scaleY;
					if (currHeight <= _maxHeight || currFontSize <= tempMinSize){
						break;
					}
					else{
						currFontSize = Math.max(tempMinSize, Math.min(currFontSize-1, Math.ceil(currFontSize * Math.pow(_maxHeight / currHeight,assessPower) * assessRate)));
					}
				}
				if (_autoChange){
					//每次改变该文本值时，自动适配
					_label.off(Event.CHANGE, null, Tools.textFitFontSize2);
					_label.on(Event.CHANGE, null, Tools.textFitFontSize2, [_label, null, _maxWidth, _maxHeight, _minSize, false]);
				}
				
			}
			else if (_spr is Button){
				var _btn:Button = _spr as Button;
				if (!_btn['originalFontSize']){
					_btn['originalFontSize'] = _btn.labelSize;
				}
				originalFontSize = _btn['originalFontSize'];
				scaleX = Math.abs(_btn.scaleX);

				if (_maxWidth <= 0){
					tempWidth = Math.min(_btn.width * 0.2, 30);
					_maxWidth = (_btn.width - tempWidth) * scaleX;
				}
				if (_maxHeight <= 0){
					tempHeight = Math.min(_btn.height * 0.2, 10);
					_maxHeight = (_btn.height - tempHeight) * _btn.scaleY;
				}

				_label = new Label(_info);
				_label.wordWrap = true;
				_label.width = _maxWidth / scaleX;
				_label.leading = _btn.text.leading?_btn.text.leading:2;
				leading = _label.leading;
				
				currFontSize = originalFontSize;
				while (true){
					//trace('尝试了Button字号：'+currFontSize);
					_label.fontSize = currFontSize;
					currHeight = _label.textField.textHeight * _btn.scaleY;
					if (currHeight <= _maxHeight || currFontSize <= tempMinSize){
						break;
					}
					else{
						currFontSize = Math.max(tempMinSize, Math.min(currFontSize-1, Math.ceil(currFontSize * Math.pow(_maxHeight / currHeight,assessPower) * assessRate)));
					}
				}
				
				_btn.labelSize = currFontSize;
				_btn.text.leading = leading;
				_btn.label = _label.textField.lines.join('\n');

				//currWidth = _maxWidth;
				currHeight = _maxHeight;
			}
			else if (_spr is HTMLDivElement){
				var _htmlDiv:HTMLDivElement = _spr as HTMLDivElement;
				scaleX = Math.abs(_htmlDiv.scaleX);
				
				if (!_htmlDiv['originalFontSize']){
					_htmlDiv['originalFontSize'] = _htmlDiv.style.fontSize;
				}
				if (!_info)_info = 'HTMLDivElement';
				originalFontSize = _htmlDiv['originalFontSize'];
				if (!_htmlDiv['originalWidth']){
					_htmlDiv['originalWidth'] = _htmlDiv.width;
				}
				originalWidth = _htmlDiv['originalWidth'];
				if (!_htmlDiv['originalHeight']){
					_htmlDiv['originalHeight'] = _htmlDiv.height;
				}
				originalHeight = _htmlDiv['originalHeight'];
				
				_htmlDiv._width = originalWidth;
				_htmlDiv._height = originalHeight;
				
				tempWidth = originalWidth;
				tempHeight = originalHeight;
				
				_htmlDiv.style.wordWrap = true;
				if (!_htmlDiv.style.leading)
					_htmlDiv.style.leading = 2;
				leading = _htmlDiv.style.leading;
				_htmlDiv.innerHTML = _info;
				
				if (_maxWidth <= 0){
					_maxWidth = tempWidth * scaleX;
				}
				if (_maxHeight <= 0){
					_maxHeight = tempHeight * _htmlDiv.scaleY;
				}
				
				
				currFontSize = originalFontSize;
				while (true){
					//trace('尝试了HTML字号：'+currFontSize);
					_htmlDiv.style.fontSize = currFontSize;
					_htmlDiv.innerHTML = _info;
					currHeight = _htmlDiv.contextHeight * _htmlDiv.scaleY;
					if (currHeight <= _maxHeight || currFontSize <= tempMinSize){
						break;
					}
					else{
						currFontSize = Math.max(tempMinSize, Math.min(currFontSize-1, Math.ceil(currFontSize * Math.pow(_maxHeight / currHeight,assessPower) * assessRate)));
					}
				}
			}
			//trace(_label, '   text: '+_label.text+'  已适配字号 '+ _label.fontSize);
			return currHeight;
		}

		public static function resetHelpData():void {
			if (!TestUtils.sgDebug) {
				return;
			}

			var vm:ViewManager = ViewManager.instance,
				user:ModelUser = ModelManager.instance.modelUser,
				panel:* = vm.getCurrentPanel() || vm.getCurrentScene() || vm.mLayerMenu, // 当前显示的场景或弹板
				panelName:String = '';

			panel = panel && (panel.mFuncPanel || panel.mView) || panel; // 如果是场景的话继续取得场景中的主要显示对象（主要针对各个活动）
			panelName = panel ? panel.__class.name : '空'; // 获取panel的名称

			// 格式化偏移值时间 00:00
			const deviationTime:String = getTimeString(Tools.deviationTime());
			const uiName:String = panel && panel.__super ? panel.__super.name : ''; // 获取panel的名称
			const helpData:Array = [
				panelName,
				['UI', uiName.substring(0, uiName.length - 2)],
				['区ID', user.mergeZone],
				['UID', user.mUID],
				['pf', user.pf],
				['开服天数', user.getGameDate()],
				["偏移值",  deviationTime],
				['注册时间', Tools.dateFormat(user.add_time)],
				['调用接口', NetSocket.sMethodName],
				['发送参数', JSON.stringify(NetSocket.sSendData)]
			];
			Browser.window.sg_panel = panel;
			Browser.window.sg_user = user;
			Browser.window.sg_helpData = ArrayUtil.flat(helpData);
			Browser.window.parent.postMessage(helpData, '*');
		}
	}
}