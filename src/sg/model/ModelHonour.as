package sg.model
{
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.activities.model.ModelAfficheMerge;
	import sg.map.utils.ArrayUtils;
	import laya.ui.Box;
	import laya.ui.Image;
	import sg.view.com.ComPayType;
	import sg.utils.ArrayUtil;
	import sg.manager.AssetsManager;

	/**
	 * ...
	 * @author
	 */
	public class ModelHonour extends ModelBase{
		
		public static const EVENT_CHANGE_STATUS:String="event_hounour_change_status";

		private static var sModel:ModelHonour = null;
		
		public static function get instance():ModelHonour{
			return sModel ||= new ModelHonour();
		}

		public var mStatus:int;//状态 -1未开启   0即将开启   1赛季中   2赛季休息日

		public var mStartTime:int;//本次开始时间 等于0表示第一赛季还没开始
		public var mNextStartTime:int;//下一次开始时间
		public var mOverTime:int;//本次结束时间(可能为-1)
		public var mDayNum:int;//今天是赛季的第几天

		public static var taskTextArr:Array = [Tools.getMsgById('honour_text06'),Tools.getMsgById('honour_text07'),Tools.getMsgById('honour_text08'),Tools.getMsgById('honour_text09')];

		public function ModelHonour(){
			
		}

		public function initHounour():void{
			mDayNum = mStartTime = mNextStartTime = mOverTime = 0;
			mStatus = -1;
			if(isOpen()){
				//开服天数
				var loginDate:int = ModelManager.instance.modelUser.loginDateNum;
				var timeArr:Array = ConfigServer.honour.honour_last;
				mDayNum = loginDate % (timeArr[0] + timeArr[1]);
				var now:Number = ConfigServer.getServerTimer();

				if(ModelManager.instance.modelUser.honour_start_time == null){
					mStatus = 0;
					mOverTime = mNextStartTime - (timeArr[1] * Tools.oneDayMilli);
					mNextStartTime = now + (mDayNum * Tools.oneDayMilli) + Tools.getDayDisTime();
				}else{	
					mStartTime = Tools.getTimeStamp(ModelManager.instance.modelUser.honour_start_time);
					mOverTime = mStartTime + (timeArr[0] * Tools.oneDayMilli);
					mNextStartTime = mStartTime + ((timeArr[0]+timeArr[1]) * Tools.oneDayMilli); 
					if(now < mOverTime){
						mStatus = 1;
					}else{
						mStatus = 2;
					}	
				}
			}
			if(mOverTime<=0) mOverTime = -1;
			if(mOverTime != -1){
				var mergeTime:int = ModelAfficheMerge.instance.mergeTime;
				if(mergeTime>0 && mOverTime > mergeTime) mOverTime = mergeTime;
			}	
			if(isOpen()){
				trace('赛季第'+mDayNum+'天');
				trace('本赛季开始：',mStartTime > 0 ? Tools.dateFormat(mStartTime) : "");
				trace('本赛季结束：',mOverTime > 0 ? Tools.dateFormat(mOverTime) : "");
				trace('下个赛季开始时间：',Tools.dateFormat(mNextStartTime));
			}
		}

		/**
		 * 计时器  每秒调用
		 */
		public function updateHonour():void{

		}

		/**
		 * 功能是否开启
		 */
		public function isOpen():Boolean{
			return false;
			var b1:Boolean = false;
			if(ConfigServer.honour){
				var n1:Number = ConfigServer.honour["switch"] != null ?  ConfigServer.honour["switch"] : -1;
				var n2:Number = ModelManager.instance.modelUser.mergeNum;
				b1 = n1>=0 && n1 <= n2;
			}
			var b2:Boolean = !ModelGame.unlock(null,"honour").stop;
			return b1 && b2;
		}

		/**
		 * 获得任务列表
		 */
		public function getHonourTaskList():Array{
			var cfg:Object = ConfigServer.honour;
			var o:Object = ModelManager.instance.modelUser.honour_task;
			var arr:Array = [];
			for(var s:String in o){
				var a:Array = o[s] is Array ? o[s] : [];
				for(var i:int = 0;i<a.length;i++){
					var task:Array = a[i];
					var obj:Object = {};
					var cfgTask:Object = s == "chain_task" ? cfg.challenge_chain_box[task[0]] : cfg.challenge_limit_time_box[task[0]];
					obj["id"] = task[0];
					obj["index"] = i;
					obj["name"] = taskTextArr[s == "chain_task" ? i : 3] + Tools.getMsgById(cfgTask.name);
					obj["info"] = getTaskInfoByID(task[0],task[1]);
					obj["task_kind"] = s;
					var reward:Object = cfgTask.reward;
					obj["reward"] = ModelManager.instance.modelProp.getRewardProp(reward);
					obj["isGet"] = task[2] == 1;
					obj["isFinish"] = task[1] >= cfgTask.need[0];
					obj["sort"] = s == "chain_task" ? i : (10 + i);
					arr.push(obj);
				}
			}
			arr = ArrayUtils.sortOn(["sort"],arr,false,false);
			return arr;
		}

		/**
		 * 任务说明
		 */
		private function getTaskInfoByID(id:String,taskPro:int):String{
			var s:String = '';
			var cfgNeed:Array = [];
			var cfgTask:Object;
			if(ConfigServer.honour.challenge_chain_box[id]){
				cfgTask = ConfigServer.honour.challenge_chain_box[id];
				cfgNeed = (cfgTask["need"] as Array).concat();
				if(cfgNeed[1] && cfgNeed[1] == 1){
					var maxLv:int = 0;
					var heros:Object = ModelManager.instance.modelUser.honour_hero;
					for(var hid:String in heros){
						if(hid != "exp_max_hero" && hid != "total_lv"){
							if(heros[hid] > maxLv) maxLv = heros[hid];
						}
					}
					cfgNeed[0] = '(' + maxLv + '/' + cfgNeed[0] + ')';
					s = Tools.getMsgById(cfgTask.info,cfgNeed);
				}else{
					cfgNeed[0] = '(' + taskPro + '/' + (cfgNeed[1] ? cfgNeed[1] : cfgNeed[0]) + ')';
					s = Tools.getMsgById(cfgTask.info,cfgNeed);
				}
			}else{
				cfgTask = ConfigServer.honour.challenge_limit_time_box[id];
				s = Tools.getMsgById(cfgTask.info);
			}
			return s;
		}

		/**
		 * 有赛季等级的英雄列表
		 */
		public function getHeroList():Array{
			var arr:Array = [];
			var honour_hero:Object = ModelManager.instance.modelUser.honour_hero;
			for(var s:String in honour_hero){
				var o:Object = {};
				if(s!="exp_max_hero" && s!="total_lv"){
					o["hid"] = s;
					o["lv"] = honour_hero[s].lv;
					o["exp"] = honour_hero[s].exp;
					arr.push(o);
				}
			}
			arr = ArrayUtils.sortOn(["lv","exp"],arr,true);
			return arr;
		}

		/**
		 * 英雄的最大等级
		 */
		public function get maxLv():int{
			return ConfigServer.honour["honour_exp_"+ModelManager.instance.modelUser.mergeNum].length;
		}

		/**
		 * 赛季总等级
		 */
		public function get totalLv():int{
			if(ModelManager.instance.modelUser.honour_hero){
				if(ModelManager.instance.modelUser.honour_hero.total_lv){
					return ModelManager.instance.modelUser.honour_hero.total_lv;
				}
			}
			return 0;
		}

		/**
		 * 赛季历史列表
		 */
		public function getLogList():Array{
			var arr:Array = [];
			var userData:Array = ModelManager.instance.modelUser.honour_log;
			for(var i:int=0;i<userData.length;i++){
				var o:Object = {};
				var u:Object = userData[i];
				o["data"] = u;
				o["index"] = i;
				arr.push(o);
			}
			arr = ArrayUtils.sortOn(["index"],arr,true);
			return arr;
		}

		/**
		 * 赛季奖励的具体内容
		 */
		public function getReardList():Array{
			var arr:Array = [];
			var cfg:Array = ConfigServer.award[ConfigServer.honour["honour_reward_"+ModelManager.instance.modelUser.mergeNum][2]].range;
			var o:Object = {};
			for(var i:int=0;i<cfg.length;i++){
				o[cfg[i][0][0]] = cfg[i][0][1];
			}
			arr = ModelManager.instance.modelProp.getRewardProp(o);
			return arr;
		}

		/**
		 * 最大任务数量
		 */
		public function maxTaskNum():Number{
			var o:Object = ConfigServer.honour.challenge_chain_box;
			var n1:Number = o ? Tools.getDictLength(o) : 0;
			var n2:Number = ConfigServer.honour.challenge_limit_time[mDayNum] ? ConfigServer.honour.challenge_limit_time[mDayNum] : 0; 
			return n1 + n2;
		}

		/**
		 * 排名前几位
		 */
		public function get rankNum():Number{
			return ConfigServer.honour.honour_rank;
		}

		public static function honourIconUrl(lv:int):String{
			var cfg:Array = ConfigServer.honour.honour_icon;
			var s:String = 'honour_zhangong1.png';
			if(cfg){
				for(var i:int=cfg.length-1;i>=0;i--){
					if(lv>=cfg[i][0]){
						s = cfg[i][1]+'.png';
						break;
					}
				}
			}
			return AssetsManager.getAssetLater(s);

		}
		
	}

}