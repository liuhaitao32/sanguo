package sg.model
{
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;

	/**
	 * ...
	 * @author
	 */
	public class ModelClub  extends ModelBase{
		
		public static var EVENT_ALIEN_MSG:String="event_alien_msg";//异邦来访信息
		//public static var EVENT_UPDATE_ALIEN_TROOP_INFO:String="event_update_alien_troop_info";//刷新部队信息界面
		public static var EVENT_COUNTRY_REDBAG:String="event_country_redbag";//有人充值 国家里有可领红包
		public static var EVENT_COUNTRY_ALIEN_RED:String="event_country_alien_red";//异邦红点

		//	异邦来访
		public var alien:Array;
		public var alien_log:Object;
		public var alien_lv:Number;
		public var alien_refresh_time:*;

		//  国家红包
		public var redbag:*;
		public var redbag_num:Number;
		private var _u_redbag_num:Number;
		

		public function set u_redbag_num(n:Number):void{
			_u_redbag_num=n;
		}

		/**
		 * 玩家已经领取的红包数
		 */
		public function get u_redbag_num():Number{
			return _u_redbag_num;
		}

		//每人至多上阵英雄
		public function get max_player_hero():Number{
			return ConfigServer.country_club.alien.playertroops;
		}

		//每关最大英雄数
		public function get max_hero():Number{
			return ConfigServer.country_club.alien.troops;
		}

		

		public function ModelClub(){
			
		}


		public function updateData(re:*):void{
			if(re){
				for(var s:String in re){
					if(this.hasOwnProperty(s)){
						this[s]=re[s];
					}
				}
			}
			if(re.hasOwnProperty("alien")){
				ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_BTM_BTN);
			}
		}

		/**
		 * 有人加入或者退出时  更新数据
		 */
		public function updateAlien(arr:Array):void{
			if(arr && this.alien){
				if(this.alien.hasOwnProperty(arr[0])){
					this.alien[arr[0]]=arr[1];
				}
			}
		}

		


		/**
		 * 这个部队里有几个我的英雄
		 */
		public function getMyHeroNum(lv:Number):Number{
			var n:Number=0;
			if(this.alien){
				var arr:Array=this.alien[lv]["team"][0]["troop"];
				for(var i:int=0;i<arr.length;i++){
					if(arr[i].uid==ModelManager.instance.modelUser.mUID){
						n+=1;
					}
				}
			}
			return n;
		}

		/**
		 * 获得开战时间
		 */
		public function getFightTimeByIndex(lv:Number):Number{
			if(this.alien){
				var arr:Array=this.alien[lv]["team"][0]["troop"];
				if(arr.length>0){
					var time:*=this.alien[lv].fight_time;
					if(time){
						return Tools.getTimeStamp(time);
					}
				}
			}
			return -1;
		}

		//获得最低战力
		public function getLowPower(lv:Number):Number{
			var obj:Object=ConfigServer.country_club.alien.instance[lv];
			if(obj && obj.hasOwnProperty("power")){
				return obj.power;
			}
			return 0;
		}

		/**
		 * 检测是否到开战时间
		 */
		public function checkFight():void{
			if(this.alien){
				var len:Number=this.alien.length;
				for(var i:int=0;i<len;i++){
					var n:Number=getFightTimeByIndex(i);
					if(n!=-1 && ConfigServer.getServerTimer()>n){
						trace("--ModelClub 自动开战");
						NetSocket.instance.send("get_club_alien",{},Handler.create(this,function(np:NetPackage):void{
							ModelManager.instance.modelUser.updateData(np.receiveData);
							ModelManager.instance.modelClub.event(ModelClub.EVENT_ALIEN_MSG);
						}));
						break;
					}
				}
			}
		}

		/**
		 * 是否有集结中的队伍
		 */
		public function hasPrepareTeam():Boolean{
			if(this.alien){
				var arr:Array=this.alien;
				for(var i:int=0;i<arr.length;i++){
					if(arr[i].lock==null && arr[i].team[0].troop.length>0){
						return true;
						break;
					}
				}
			}
			return false;
		}

		/**
		 * 检查最强战力英雄是否
		 */
		public function checkPowerCanFight():Boolean{
			var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(ModelHero.BEST_HID);
			var n:Number=ModelManager.instance.modelClub.getLowPower(0) * ConfigServer.country_club.alien.low_power;
			return hmd && hmd.getPower() > n;//最强战力的英雄 大于  第一个关卡最低战力的%几
		} 

		/**
		 * 是否在组队中
		 */
		public function isInTeam():Boolean{
			if(this.alien){
				var arr:Array=this.alien;
				for(var i:int=0;i<arr.length;i++){
					var a:Array=arr[i]["team"][0]["troop"];
					for(var j:int=0;j<a.length;j++){
						if(a[j].uid+""==ModelManager.instance.modelUser.mUID){
							return true;
						}
					}
				}
			}
			return false;
		}
	}

}