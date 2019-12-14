package sg.model
{
	import laya.ui.Label;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.utils.StringUtil;
	import sg.cfg.ConfigColor;

	/**
	 * ...
	 * @author
	 */
	public class ModelGuild extends ModelBase{

		
		public static var EVENT_ALIEN_MSG:String="event_alien_msg";//异邦来访信息
		public static var EVENT_UPDATE_ALIEN:String="event_update_alien";//只刷面板  不调接口
		public static var EVENT_GUILD_NAME:String="event_guild_name";//军团改名
		public static var EVENT_UPDATE_ALIEN_TROOP_INFO:String="event_update_alien_troop_info";
		public static var EVENT_UPDATE_RED:String="event_update_red";//刷新tab红点

		public static var EVENT_UPDATE_PVE:String="event_update_pve";//刷新pve的编组		

		public static var isEditor:Boolean=false;

		public static var post_name:Array=[Tools.getMsgById("_guild_text08"),Tools.getMsgById("_guild_text09"),Tools.getMsgById("troopOfficial-1"),Tools.getMsgById("_guild_text28")];	
		public static var tab_key:Array=["guild_info","guild_achi","guild_member","guild_res","guild_shop","guild_alien"];

		public static var kill_achi_arr:Array=["30","31","32"];
		public static var build_achi_arr:Array=["27","28","29"];

		public static var job1_num:Number=ConfigServer.guild.configure.deputy;//副团长数量
		public static var job2_num:Number=ConfigServer.guild.configure.elite;//精英成员数量
		public static var total_num:Number=ConfigServer.guild.configure.maxpeople;//最大成员数
		public static var total_news:Number=ConfigServer.guild.configure.news;//最大msg报存数
		
		public var alien_max_troops:Number=0;//最多季节英雄
		public var alien_max_hero:Number=0;//单人最多上阵英雄
		
		
		public var leader:String;//团长id
		public var vice_id:Array=[];
		public var name:String;
		
		public var id:String;
		public var member_num:Number;

		public var kill_num:Number;
		public var build_num:Number;
		public var die_num:Number;
		public var runaway_num:Number;

		public var week_kill:Number;
		public var week_build:Number;
		public var week_die:Number;
		public var week_runaway:Number;

		public var pay_money:Number;

		public var coin:Number;
		public var gold:Number;
		public var food:Number;
		public var daily_coin:Number;
		public var daily_gold:Number;
		public var daily_food:Number;

		public var attack_num:Number;//最佳进攻军团次数
		public var guard_num:Number;//最佳防守军团次数
		public var week_attack:Number;
		public var week_guard:Number;

		public var adult_num:Number;//太守数量
		public var effort:Object;//军团成就
		public var add_time:*;//军团创建时间
		public var king_uids:Array;//军团成员中成为君王的次数		

		public var depot_reward:Array;//年度奖励
		public var msg:Array;

		public var alien:Array;
		public var alien_refresh_time:*;
		public var alien_lv:Number;
		public var alien_log:Object;

		public var u_dict:Object;//成员列表
		public var application:Object;//申请人列表
		public var recharge:Array;
		public var redbag:Array;

		public var alienCallCD:Object={};//召集cd
		public var alienCD:Number=30;

		public var isShowRedPoint:Boolean=false;


		public function ModelGuild(){
			
		}

		


		public function setData(re:*):void{
			
			member_num=Tools.getDictLength(re.u_dict);
			for(var s:String in re){
				if(this.hasOwnProperty(s)){
					this[s]=re[s];
				}
				if(s=="u_dict"){
					setViceId(re[s]);
				}
			}
			if(re.hasOwnProperty("alien")){
				ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_BTM_BTN);
			}
			this.id=re.gid+"";
			alien_max_troops=ConfigServer.guild.alien.troops;
			alien_max_hero=ConfigServer.guild.alien.playertroops;
		}

		public function updateData(re:*):void{
			for(var s:String in re){
				if(this.hasOwnProperty(s)){
					this[s]=re[s];
				}
				if(s=="u_dict"){
					setViceId(re[s]);
				}
			}
			if(re.hasOwnProperty("alien")){
				ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_BTM_BTN);
			}
			this.event(ModelGuild.EVENT_UPDATE_RED);
		}

		/**
		 * 获得副团长id
		 */
		private function setViceId(obj:Object):void{
			vice_id=[];
			for(var s:String in obj){
				var arr:Array=obj[s];
				if(arr[0]==1){
					vice_id.push(s);
				}
			}
		}

		/**
		 * 是否是团长或者副团长
		 */
		public function isLeadOrVice(id:*):Boolean{
			if(id+"" == leader){
				return true;
			}
			if(vice_id.indexOf(id+"")!=-1){
				return true;
			}
			return false;
		}
		
		/**
		 * 获得军团对应弱点的显示信息数组
		 */
		static public function getWeakArray(key:String):Array{
			if(key){
				var config_weak:Array=ConfigServer.country_club.alien.weak.type;
				for(var j:int=0;j<config_weak.length;j++){
					var a:Array=config_weak[j][0];
					if(a[0]==key){
						return a;
					}
				}
			}
			return null;
		}

		/**
		 * 获得军团成立时间
		 */
		public function getAddDays():Number{
			var now:Number=ConfigServer.getServerTimer();
			var n:Number=now-Tools.getTimeStamp(add_time);
			var m:Number=Math.ceil(n/(24*60*60*1000));
			return m;
		}

		/**
		 * 
		 */
		public function getNeedNum(key:String):Number{
			var n:Number=0;
			switch(key){
				case "days":
					n=getAddDays();
				break;
				case "people":
					n=this.member_num;
				break;
				case "adult":
					n=adult_num;
				break;
				case "king":
					n=king_uids.length;
				break;
				case "attack":
					n=attack_num;
				break;
				case "guard":
					n=guard_num;
				break;
				case "make":
					n=build_num;
				break;
				case "kill":
					n=kill_num;
				break;
				case "week_make":
					n=week_build;
				break;
				case "week_kill":
					n=week_kill;
				break;
			}
			return n;
		}


		public static function getAchiName(id:String):String{
			if(ConfigServer.guild.achievement[id]){
				return Tools.getMsgById(ConfigServer.guild.achievement[id].name);
			}
			return "";
		}


		public function getStatistics():Array{
			var arr:Array=[{text:Tools.getMsgById("_guild_text75"),num:kill_num,week_num:week_kill},
			{text:Tools.getMsgById("_guild_text76"),num:build_num,week_num:week_kill},
			{text:Tools.getMsgById("_guild_text77"),num:die_num,week_num:week_die},
			{text:Tools.getMsgById("_guild_text78"),num:attack_num,week_num:week_attack},
			{text:Tools.getMsgById("_guild_text79"),num:guard_num,week_num:week_guard},
			{text:Tools.getMsgById("_guild_text80"),num:runaway_num,week_num:week_runaway}];
			return arr;
		}

		public function getMemberName(uid:String):String{
			if(this.u_dict.hasOwnProperty(uid)){
				return u_dict[uid][1];
			}
			return "";
		}

		/**
		 * 日期
		 */
		public static function htmlStr0(obj:Object):String{
			var s1:String=StringUtil.htmlFontColor(Tools.dateFormat(obj.msg_time,0), ConfigColor.FONT_COLORS[2]);	
			return s1;
		}
		public static function htmlStr1(obj:Object):String{
			var s2:String="<span href=''>"+ModelCityBuild.getCityName(obj.data[1])+"</span>";
			var s3:String=obj.data[2];//StringUtil.htmlFontColor(obj.data[2]+"", ConfigColor.FONT_COLORS[1]);
			var s4:String=obj.data[3];//StringUtil.htmlFontColor(obj.data[3]+"", ConfigColor.FONT_COLORS[1]);
			var s5:String=obj.data[4];//StringUtil.htmlFontColor(obj.data[4]+"", ConfigColor.FONT_COLORS[1]);
			var s:String=Tools.getMsgById("500087",[s2,s3,s4,s5]);			
			return s;
		}

		public static function htmlStr2(obj:Object):String{			
			var s2:String=ModelGuild.getAchiName(obj.data[0]);//StringUtil.htmlFontColor(ModelGuild.getAchiName(obj.data[0]),ConfigColor.FONT_COLORS[1]);
			var s:String=Tools.getMsgById("500090",[s2]);
			return s;
		}

		public static function htmlStr3(obj:Object):String{
			var s1:String=ModelManager.instance.modelGuild.getMemberName(obj.data[0]+"");//StringUtil.htmlFontColor(ModelManager.instance.modelGuild.getMemberName(obj.data[0]+""), ConfigColor.FONT_COLORS_OTHER[0]);
			var s2:String=ModelUser.country_name2[ModelUser.getCountryID()]; 
			var s3:String=ModelOfficial.getOfficerName(obj.data[1]);
			var s:String=Tools.getMsgById("500089",[s1,s2,s3]);
			return s;
		}

		public static function htmlStr4(obj:Object):String{
			var s1:String=ModelManager.instance.modelGuild.getMemberName(obj.data[0]+"");//StringUtil.htmlFontColor(ModelManager.instance.modelGuild.getMemberName(obj.data[0]+""), ConfigColor.FONT_COLORS_OTHER[0]);
			var s2:String="<span href=''>"+ModelCityBuild.getCityName(obj.data[1])+"</span>"; 	
			var s:String=Tools.getMsgById("500088",[s1,s2]);
			return s;
		}
		public static function htmlStr5(obj:Object):String{
			var s1:String=obj.data[0]+"";//StringUtil.htmlFontColor(obj.data[0]+"", ConfigColor.FONT_COLORS[4]);
			var s2:String=ModelOfficial.getOfficerName(obj.data[1]);//StringUtil.htmlFontColor(ModelOfficial.getOfficerName(obj.data[1]),ConfigColor.FONT_COLORS[4]);
			var s3:String=ModelManager.instance.modelProp.getItemProp(obj.data[2]).name;
			var s4:String=obj.data[3]+"";//StringUtil.htmlFontColor(obj.data[3]+"", ConfigColor.FONT_COLORS[1]);
			var s:String=Tools.getMsgById("500095",[s2,s1,s4,s3]);
			return s;
		}


		public function getAlienLastTime(lv:Number):Number{
			if(alienCallCD.hasOwnProperty(lv+"")){
				var n:Number=alienCallCD[lv+""];
				var now:Number=ConfigServer.getServerTimer();
				if(now-(alienCD*1000)>=n){
					delete alienCallCD[lv+""];
					return 0;
				} else{
					return Math.floor(((alienCD*1000)-(now-n))/1000);
				}
			}
			return 0;
		}


		public function getMemberHeadById(id:String):String{
			if(u_dict.hasOwnProperty(id)){
				return ModelUser.getUserHead(u_dict[id][7]);
			}
			return ModelUser.getUserHead(null);
		}
	}

}