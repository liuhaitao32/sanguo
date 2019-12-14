package sg.model
{
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.manager.FilterManager;
	import sg.cfg.ConfigColor;
	import sg.utils.StringUtil;
	import laya.maths.MathUtil;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import laya.net.URL;
	import sg.utils.ObjectUtil;

	/**
	 * ...
	 * @author
	 */
	public class ModelChat extends ModelBase{
		


		public static const EVENT_ADD_CHAT:String       = "event_add_chat";
		public static const EVENT_UPDATE_CHANNEL:String = "event_update_channel";
		public static const EVENT_UPDATE_BOTTOM:String  = "event_update_bottom";

		public static const EVENT_ADD_FACE:String       = "event_add_face";
		public static const EVENT_CLOSE_FACE:String     = "event_close_face";


		public static var channel_skin:Array=["ui/img_icon_41.png","ui/img_icon_40.png","ui/img_icon_39.png"];
		public var worldList:Array=[];
		public var guildList:Array=[];
		public var countryList:Array=[];
		public var sysList:Array=[];
		public var allList:Array=[];
		public var newMSG:Array=[];

		public static var channel_arr:Array=[Tools.getMsgById("_chat_text03"),Tools.getMsgById("_chat_text04"),Tools.getMsgById("_country75")];
		public static var channel_seleted:Array=[1,1,1,1];//当前显示频道
		public var cur_channel:Number=-1;//当前说话频道

		public var isNewBugMSG:Boolean=false;
		public var isNewMail:Boolean=false;

		private var mTimeYard1:Number=0;//比武大会消息1
		private var mTimeYard2:Number=0;//比武大会消息2

		private var mTimeYard3:Number=0;//比武大会消息3
		private var mTimeYard4:Number=0;//比武大会消息4
		private var mTimeYard5:Number=0;//比武大会消息5
		private var mTimeYard6:Number=0;//比武大会消息6

		public static var mCurUid:String = "";//当前打开的私聊界面的uid

		

		public function ModelChat(){
			
		}

		public function sendMSG(obj:Array):void{
			//[icon,type,key,["text",userData],time]
			/*
			var obj:Object={"channel":0,
							"type":0,
							"head":ModelManager.instance.modelUser.head,
							"uid":ModelManager.instance.modelUser.mUID,
							"official":ModelOfficial.getUserOfficer(ModelManager.instance.modelUser.mUID),
							"time":ConfigServer.getServerTimer(),
							"text":text};
							*/
			setAllList(obj);

			//return obj;
		}

		/**
		 * 获取聊天记录缓存（登录时调用）
		 */
		public function getChatCache(arr:Array):void{
			var temp:Array=[];
			for(var i:int=0;i<arr.length;i++){
				var a:Array=arr[i];
				for(var j:int=0;j<a.length;j++){
					temp.push([a[j],Tools.getTimeStamp(a[j][4])]);
					//acceptMSG(a[j]);
					//trace(temp);
				}
			}
			var local:Array=getLocalCache();
			for(var l:int=0;l<local.length;l++){
				temp.push([local[l],local[l][4]]);
			}
			temp.sort(MathUtil.sortByKey("1"),true,true);
			for(var k:int=0;k<temp.length;k++){
				acceptMSG(temp[k][0]);
			}
		}

		public function acceptMSG(obj:Array):void{
			if(obj[1]==0){//除了系统消息外  做一下屏蔽字处理
				var s:String = obj[3][0];
				Platform.shieldFont(s,new Handler(this,function():void{
					var cloneObj:Object = ObjectUtil.clone(obj,true);
					s = FilterManager.instance.wordBan(s);
					obj[3][0] = faceHandler(s);
					acceptMsgHandler(obj,cloneObj);
				}),false);
			}else{
				acceptMsgHandler(obj,obj);
			}
		}

		private function acceptMsgHandler(obj:Array,cloneObj:Object):void{
			if(obj[0]==0){
				if(ModelGame.unlock(null,"chat_world").stop)
					return;
				setWorldList(obj,obj[1]!=0);
			}else if(obj[0]==1){	
				setCountryList(obj);
			}else if(obj[0]==2){
				setGuildList(obj);
			}
			
			if(newMSG.length>=5){
				newMSG.shift();
			}
			if(cloneObj[1]==0){
				var s:String = cloneObj[3][0];
				cloneObj[3][0] = faceHandler(s,16,16);
			}
			newMSG.push(cloneObj);

			this.event(ModelChat.EVENT_ADD_CHAT);
			this.event(ModelChat.EVENT_UPDATE_BOTTOM);
		}

		/**
		 * 表情id列表
		 */
		private static var sFaceObj:Object;//{"id":"type"} = {"wx":"1"}
		public static function initFaceObj():void{
			sFaceObj = {};
			var cfg:Object = ConfigServer.system_simple.cfg_face;
			if(cfg){
				var a:Object = {};
				for(var s:String in cfg){
					for(var i:int=0;i<cfg[s].ids.length;i++){
						a[cfg[s].ids[i]] = s;
					}
				}
				sFaceObj = a;
			}
		}

		private function faceHandler(str:String,_w:Number=0,_h:Number=0):String{
			if(this.isOpenFace() == false){
				return str;
			}

			var cfgObj:Object = ModelChat.sFaceObj;
			for(var s:String in cfgObj){
				var id:String = s;
				var type:String = cfgObj[s];
				var ss:String = '{'+ id +'}';
				var path:String = URL.formatURL('face/'+id+'.png'); 
				var size:Array = ConfigServer.system_simple.cfg_face ? ConfigServer.system_simple.cfg_face[type].size : [25,25];
				var _width:Number = _w ? _w : size[0];
				var _height:Number = _h ? _h : size[1];
				str = str.replace(new RegExp(ss, "g"),"<img src='"+path+"' style='width:"+_width+"px; height:"+_height+"px; padding:0px 2px 0px 2px'></img>");
			}
			return str;
		}

		/**
		 * 文字处理 非永久卡用户直接返回
		 */
		public function faceFliter(s:String):String{
			if(this.isOpenFace() == false){
				return s;
			}
			for(var key:String in sFaceNameObj){
				var ss:String = sFaceNameObj[key];
				if(sFaceObj[ss] && sFaceObj[ss]+""==2+""){
					if(ModelManager.instance.modelUser.member_check==0) 
						continue;
				}
				var s1:String = '/'+key+"/";
				var s2:String = '{'+ss+'}';
				s = s.replace(new RegExp(s1, "g"),s2);
			}
			return s;
		}

		public static var sFaceIdObj:Object;//{"key":"name"}={"wx":"微笑"}
		public static function getFaceName(id:String):String{
			var s:String = '';
			if(!sFaceIdObj) sFaceIdObj = {};
			if(sFaceIdObj[id]){
				s = sFaceIdObj[id];
			}else{
				s = Tools.getMsgById('face_'+id);
				sFaceIdObj[id] = s;
			}
			return s;
		}

		public static var sFaceNameObj:Object;//{"name":"key"}={"微笑":"wx"}
		public static function initFaceNameObj():void{
			var cfgArr:Object = ModelChat.sFaceObj;
			if(!sFaceNameObj) sFaceNameObj = {};
			for(var s:String in cfgArr){
				var _id:String = s;
				var _name:String = Tools.getMsgById('face_'+s);
				sFaceNameObj[_name] = _id;
			}
		}

		/**
		 * 表情功能是否开放
		 */
		public function isOpenFace():Boolean{
			var o:Object = ConfigServer.system_simple.cfg_face;
			if(o && Tools.getDictLength(o)>0){
				return true;
			}
			return false;
		}

		//====================================================


		public function setAllList(obj:Array):void{
			if(obj!=null){
				obj["sort"]=(obj[4] is Number) ? obj[4] : Tools.getTimeStamp(obj[4]);
				this.allList.push(obj);
			}
		}

		public function setGuildList(obj:Array):void{
			if(obj!=null){
				obj["sort"]=(obj[4] is Number) ? obj[4] : Tools.getTimeStamp(obj[4]);
				this.guildList.push(obj);
			}
		}

		public function setWorldList(obj:Array,isSys:Boolean = false):void{
			if(obj!=null){
				obj["sort"]=(obj[4] is Number) ? obj[4] : Tools.getTimeStamp(obj[4]);
				if(isSys) this.sysList.push(obj);
				else this.worldList.push(obj);
			}
		}

		public function setCountryList(obj:Array):void{
			if(obj!=null){
				obj["sort"]=(obj[4] is Number) ? obj[4] : Tools.getTimeStamp(obj[4]);
				this.countryList.push(obj);
			}
		}

		/**
		 * 系统消息处理
		 */
		public function sysMessage(re:Array):String{//re=[0,key1,key2,[data],time] data = [前几位是数据,+名字、国家、头像、官职]
			var s:String="";
			var arr:Array=re[3];
			var config_sys:Object=ConfigServer.system_simple.system_massage;
			var re_arr:Array=re[3];
			//trace("sys msg--",re);
			var cname:String="";
			var hname:String="";
			var country_name:String="";
			if(re[1]=="1"){//发送本地信息
				return re[2];
			}else if(re[1]=="country_call"){//我军正在挑战异族入侵
				s=Tools.getMsgById("guild_pve",[(re[2]+1)+"",re[3][0]+""]);
			}else{ 
				if(re[1]=="hero_star"){				
					arr=[re_arr[3],ModelHero.getHeroName(re_arr[0],re_arr[2]==1?true:false)];				
				}else if(re[1]=="hero_skill"){					
					arr=[re_arr[4],ModelHero.getHeroName(re_arr[0],re_arr[3]==1?true:false),ModelSkill.getSkillName(re_arr[1]),re_arr[2]];				
				}else if(re[1]=="look_star"){					
					arr=[re_arr[1],Tools.getMsgById(ConfigServer.star[re_arr[0]].name)];			
				}else if(re[1]=="guild_atkcity"){					
					cname="<span href='"+re_arr[3]+"'>"+ModelCityBuild.getCityName(re_arr[3])+"</span>";
					arr=[cname,re_arr[0],re_arr[1],re_arr[2]];			
				}else if(re[1]=="cityfight_def_victory" || re[1]=="cityfight_victory"){
					cname="<span href='"+re_arr[0]+"'>"+ModelCityBuild.getCityName(re_arr[0])+"</span>";
					if(re[1]=="cityfight_def_victory"){
						country_name=StringUtil.htmlFontColor(Tools.getMsgById("country_"+re_arr[2]),ConfigServer.world.COUNTRY_COLORS[re_arr[2]]);
					}else if(re[1]=="cityfight_victory"){
						country_name=StringUtil.htmlFontColor(Tools.getMsgById("country_"+re_arr[3]),ConfigServer.world.COUNTRY_COLORS[re_arr[3]]);
					}
					arr=[country_name,cname];			
				}else if(re[1]=="guild_corps"){
					cname="<span href='"+re_arr[1]+"'>"+ModelCityBuild.getCityName(re_arr[1])+"</span>";
					arr=[re_arr[2],cname];
				}else if(re[1]=="limit_free"){
					var a:Array=ModelManager.instance.modelProp.getRewardProp(re_arr[0]);
					arr=[re_arr[1],ModelItem.getItemName(a[0][0])+"x"+a[0][1]];
				}else if(re[1]=="pk_user_first"){
					country_name=StringUtil.htmlFontColor(Tools.getMsgById("country_"+re_arr[0]),ConfigServer.world.COUNTRY_COLORS[re_arr[0]]);
					arr=[country_name,re_arr[1]];
				}else if(re[1]=="build_ballista"){
					country_name=StringUtil.htmlFontColor(Tools.getMsgById("country_"+re_arr[0]),ConfigServer.world.COUNTRY_COLORS[re_arr[0]]);
					var car_name1:String=ConfigServer.country_pvp.ballista[re_arr[1]]?Tools.getMsgById(ConfigServer.country_pvp.ballista[re_arr[1]].name):"";
					arr=[country_name,car_name1];
				}else if(re[1]=="kill_ballista"){
					country_name=StringUtil.htmlFontColor(Tools.getMsgById("country_"+re_arr[0]),ConfigServer.world.COUNTRY_COLORS[re_arr[0]]);
					var t1:String=re_arr[0]>2 ? "" : ModelOfficial.getOfficerName(re_arr[1],ModelOfficial.getInvade(re_arr[0]));
					var t2:String=re_arr[0]>2 ? "" : re_arr[2];
					var t3:String=StringUtil.htmlFontColor(Tools.getMsgById("country_"+re_arr[3]),ConfigServer.world.COUNTRY_COLORS[re_arr[3]]);
					var car_name2:String=Tools.getMsgById(ConfigServer.country_pvp.ballista[re_arr[4]].name);
					arr=[country_name,t1,t2,t3,car_name2];
				}else if(re[1]=="pk_yard"){
					if(re[2]=="6"){
						arr=[re_arr[1]];
					}
				} else if(re[1]=="auction_end"){
					arr = re_arr;
					if(re[2] == "3"){
						var hid:String = re_arr[1].awaken[0];
						var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
						var heroName:String = Tools.getMsgById(md.name);
						var giftName:String = Tools.getMsgById('550029', [heroName]);
						arr = [arr[0], giftName];
					}
				} else if(re[1]=="equip_box"){
					if(re_arr[1] && re_arr[1]["equip"]){
						var temp:Array = re_arr[1]["equip"];
						arr = [re_arr[0],ModelEquip.getName(temp[0],0)];
					}else{
						arr = ["",""];
					}
				} else if(re[1]=="equip_enhance"){
					var ename:String = ModelEquip.getName(re_arr[0],0);
					var elv:int = re_arr[2];
					s = StringUtil.substituteWithColor(ename,ConfigColor.FONT_COLORS[elv],ConfigColor.FONT_COLORS[elv]);
					arr = [re_arr[3],s,re_arr[1]];
				}else if(re[1]=="arena_newmaster"){
					country_name = StringUtil.htmlFontColor(Tools.getMsgById("country_"+re_arr[0]),ConfigServer.world.COUNTRY_COLORS[re_arr[0]]);
					arr = [country_name,re_arr[1],Tools.getMsgById(ModelArena.textArr[re_arr[2]])];
				}else if(re[1]=="arena_winner"){
					country_name = StringUtil.htmlFontColor(Tools.getMsgById("country_"+re_arr[2]),ConfigServer.world.COUNTRY_COLORS[re_arr[2]]);
					arr = [country_name,re_arr[1],Tools.getMsgById(ModelArena.textArr[re_arr[0]])];
				}else if(re[1]=="arena_kill"){
					country_name = StringUtil.htmlFontColor(Tools.getMsgById("country_"+re_arr[1]),ConfigServer.world.COUNTRY_COLORS[re_arr[1]]);
					arr = [Tools.getMsgById(ModelArena.textArr[re_arr[0]]),country_name,re_arr[2]];
				}

				var obj:*=config_sys[re[1]] ? config_sys[re[1]][re[2]] : null;
				if(obj){
					s=Tools.getMsgById(obj.info,arr);
				}
			}
			return s;
		}

		/**
		 * 发送本地消息到聊天窗口 
		 * arr是系统杂项配置system_massage 
		 * [频道,key,key下的key,文字配置里需要的数据,time]
		 */
		public function sendLocalMessage(arr:Array):void{
			acceptMSG(arr);
		}

		/**
		 * 发送本地消息到聊天窗口 
		 * @param	msg 要推送的文字。
		 * @param	channel 频道 0 世界 1 国家 2 栋梁
		 */
		public function sendLocalTxt(msg:String, channel:int = 0):void {
			acceptMSG([channel, "1", msg, null, ConfigServer.getServerTimer()]);
		}




		/**
		 * 本地发送世界消息的时间
		 */
		public function initLocalMsgTime():void{
			mTimeYard1=mTimeYard2=mTimeYard3=mTimeYard4=mTimeYard5=mTimeYard6=0;
			var o1:Object=ConfigServer.system_simple.system_massage.pk_yard;
			var now:Number=ConfigServer.getServerTimer();
			if(o1){
				if(ModelClimb.isChampionStartSeason()){
					var arr:Array = ConfigServer.pk_yard.combat_time;
					var n:Number=ModelClimb.getChampionStartTimer();
					var len:int = arr.length-1;
					var ms:Number = 0;
					var n1:Number=0;
					var n2:Number=0;
					var n3:Number=0;

					for(var i1:int = 0;i1 < len;i1++){
						for(var j1:int = 0;j1<arr[i1].length;j1++){
							ms+=arr[i1][j1]*Tools.oneMinuteMilli;
						}
					}
					n1=n+ms;
					ms+=arr[6][0]*Tools.oneMinuteMilli;
					ms+=arr[6][1]*Tools.oneMinuteMilli;
					n2=n+ms;
					ms+=arr[6][2]*Tools.oneMinuteMilli;
					n3=n+ms+30*Tools.oneMillis;

					//trace("--------------现在时间：",Tools.dateFormat(now));
					//trace("--------------开始时间：",Tools.dateFormat(n));
					//trace("--------------押注时间：",Tools.dateFormat(n1));
					//trace("--------------决赛时间：",Tools.dateFormat(n2));
					//trace("--------------决出冠军：",Tools.dateFormat(n3));
				}
			}
			if(o1){
				var curSeason:Number=ModelManager.instance.modelUser.getGameSeason();
				for(var s:String in o1){
					if(s=="1" || s=="2"){
						var need:Array=o1[s].need;
						if(need[0]==curSeason){
							var dt:Date=new Date(now);
							this["mTimeYard"+s]= (new Date(dt.getFullYear(),dt.getMonth(),dt.getDate(),need[1][0],need[1][1])).getTime();// now+Tools.getYearDis(need[0],need[1]);
							
						}
						
					}
					switch(s){
						case "3":
						this["mTimeYard"+s]=(now-10*Tools.oneMinuteMilli>n) ? 0 : n;
						break;
						case "4":
						this["mTimeYard"+s]=(now-10*Tools.oneMinuteMilli>n1) ? 0 : n1;
						break;
						case "5":
						this["mTimeYard"+s]=(now-10*Tools.oneMinuteMilli>n2) ? 0 : n2;
						break;
						case "6":
						this["mTimeYard"+s]=(now-10*Tools.oneMinuteMilli>n3) ? 0 : n3;
						break;
					}
				}
			}
			//trace("==============开始提醒：",Tools.dateFormat(this["mTimeYard"+1]));
			//trace("==============结束提醒：",Tools.dateFormat(this["mTimeYard"+2]));

		}
		/**
		 * 检查是否能发送本地消息
		 */
		public function checkLoacalMessage():void{
			var now:Number=ConfigServer.getServerTimer();
			for(var i:int=1;i<=6;i++){
				var n:Number=this["mTimeYard"+i];
				if(n!=0 && now>n){
					this["mTimeYard"+i]=0;
					if(i==6){
						NetSocket.instance.send("get_champion_user",{},new Handler(this,function(np:NetPackage):void{
							var a:Array=np.receiveData;
							ModelManager.instance.modelChat.sendLocalMessage([0,"pk_yard",6+"",a?a:["",""],n]);
						}));
					}else{
						sendLocalMessage([0,"pk_yard",i+"",null,n]);

					}
				}
			}
		}

		/**
		 * 登录时检查是否需要写入本地聊天缓存
		 */
		private function getLocalCache():Array{
			var arr:Array=[];
			var now:Number=ConfigServer.getServerTimer();
			var dis:Number=10*Tools.oneMinuteMilli;
			for(var i:int=1;i<=6;i++){
				var n:Number=this["mTimeYard"+i];
				if(n!=0 && now>n){
					this["mTimeYard"+i]=0;
					if(now-n<dis){
						var a:Array=ModelManager.instance.modelUser.champion_user;
						if(i==6){
							arr.push([0,"pk_yard",i+"",a?a:["",""],n]);
						}else{
							arr.push([0,"pk_yard",i+"",null,n]);
						}	
					}
				}
			}

			//trace("--------------",Tools.dateFormat(now));
			//trace("--------------",Tools.dateFormat(n1));
			//trace("--------------",Tools.dateFormat(n2));
			return arr;
		}

		public function findUerCallBack(np:*,type:int = 0):void{
			ModelChat.mCurUid = type == 0 ? "" : "1";
			if(np.receiveData is Boolean && !np.receiveData){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_text100"));
			}else{
				var data:Object=ModelManager.instance.modelUser.getChatDataById(np.receiveData.uid);
				if(!data){
					var user:ModelUser=ModelManager.instance.modelUser;
					var a:Array=[];
					var b:Array=[np.receiveData,"",ConfigServer.getServerTimer(),true];
					a.push(b);
					ModelManager.instance.modelUser.setChatData(a);
					data=ModelManager.instance.modelUser.getChatDataById(np.receiveData.uid);
				}
				ViewManager.instance.showView(ConfigClass.VIEW_MAIL_PERSONAL,data);
			}
		}

	}

}