package sg.model
{
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.guide.model.ModelGuide;
	import sg.manager.ViewManager;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.view.arena.ViewArenaMain;
	import sg.view.arena.ViewArenaReward;
	import sg.fight.FightMain;
	import sg.scene.view.MapCamera;
	import sg.map.model.entitys.EntityCity;
	import sg.map.model.MapModel;

	/**
	 * ...
	 * @author
	 */
	public class ModelArena extends ViewModelBase{
		
		public var cfg:Object;
		public var arena:Object;

		public var mTime0:Number;//预告时间
		public var mTime1:Number;//开始竞猜时间
		public var mTime2:Number;//结束竞猜&开始攻擂
		public var mTime3:Number;//结束攻擂
		public var mTime4:Number;//最后查看时间
		private var mPushTime:Number;//推送时间

		public var mOpenTimes:Number;//开启次数
		
		public var mItemId:String; 
		public var mTotalGet:Number;//
		public var mJoinNum:Number = -1;//


		public static var imgArr:Array = ["","icon_leitai_zi7","icon_leitai_zi6","icon_leitai_zi5","icon_leitai_zi8","icon_leitai_zi4","icon_leitai_zi3","icon_leitai_zi2","icon_leitai_zi1"];
		public static var textArr:Array = ["","500100","500101","500102","500121","500103","500104","500105","500106"];
		public static var textArr_S:Array = ["","_hero3","_hero4","_hero5","other_0","skill_type_simple_0","skill_type_simple_1","skill_type_simple_2","skill_type_simple_3"];

		public static var nameArr:Array = ["","_hero6","_hero7","_hero8","90005","skill_type_0","skill_type_1","skill_type_2","skill_type_3"];
		
		public static var EVENT_UPDATE_ARENA:String = "event_update_arena";
		public static var EVENT_UPDATE_BTN_STATUS:String = "event_update_btn_status";
		public static var EVENT_GET_ITEM:String = "event_get_item";//获得道具
		public static var EVENT_CLOSE_REWARD:String = "event_close_reward";
		public static var EVENT_UPDATE_ARENA_CLIP:String = "event_update_arena_clip";//更新大地图雕像
		public static var EVENT_FINAL_WINNER:String = "event_final_winner";//决出最终擂主
		public static var sModel:ModelArena = null;
		public static function get instance():ModelArena {
			return sModel ||= new ModelArena();
		}

		public function ModelArena(){
			NetSocket.instance.on(NetSocket.EVENT_SOCKET_RECEIVE_TO,this,this.event_socket_receive_to);
		}

		private function event_socket_receive_to(re:Object,isMe:Boolean):void
        {
            var method:String = re.method;
            var receiveData:Object = re.data;
            if(Tools.isNullObj(receiveData)){
                return;
            }
            if(receiveData.hasOwnProperty("msg")){
                return;
            }

            switch(method)
            {
                case "push_pk_arena":

					var oldWinner:Array = [];
					for(var i:int=0;i<4;i++){
						var o:Object = ModelArena.instance.arena.arena_list[i];
						var _uid:String = "";
						if(o && o.user_list[0] && o.user_list[0].uid){
							_uid = o.user_list[0].uid;
						}
						oldWinner.push(_uid);
					}

					this.arena = receiveData;

					var now:Number = ConfigServer.getServerTimer();
					if(now>this.mTime3){//过了结束时间了
						for(var j:int=0;j<4;j++){
							var temp:Object = ModelArena.instance.arena.arena_list[j];
							if(temp && temp.user_list[0] && temp.user_list[0].uid){
								if(temp.user_list[0].uid != oldWinner[j]){
									this.event(EVENT_FINAL_WINNER,j);
								}
							}
						}
					}

					if(receiveData.all_done){//全部结束
						this.event(EVENT_UPDATE_BTN_STATUS);
						this.event(EVENT_UPDATE_ARENA_CLIP);
						var arr:Array = cfg.show[3];
						ViewManager.instance.showHeroTalk([arr],null);
						var _entity:EntityCity = MapModel.instance.arenas[4];
						if(_entity) MapCamera.lookAtGrid(_entity.mapGrid, 500);	
					}
					if(mJoinNum!=-1){
						NetSocket.instance.send("get_arena_log",{"arena_index":mJoinNum,"log_index":0},Handler.create(this,function(np:NetPackage):void{
							if(np.receiveData["pk_data"]){
								np.receiveData["pk_data"]["is_mine"] = false;
							}
							FightMain.startBattle(np.receiveData, this, null);
						}));
					}
					mJoinNum = -1;

					this.event(EVENT_UPDATE_ARENA);

					checkArenaData();
					break;
				case "get_pk_arena":
					this.arena = receiveData;          
					checkArenaData();
					break;
				case "w.get_info":
					cfg = ConfigServer.arena;
					mItemId = cfg.pool_item;
					mTotalGet = 0;
					this.arena = receiveData.pk_arena;
					initUserData();
					initArenaData();
					this.event(EVENT_UPDATE_BTN_STATUS);
					break;
				case "push_arena_item":
					this.event(EVENT_CLOSE_REWARD);
					//act:0 攻擂成功  1 攻擂失败  2 猜中黑马  3 守擂每分钟增加  4 擂主结算
					var n:Number = receiveData.act;
					ModelManager.instance.modelUser.updateData(receiveData);
					if(n == 3){
						if(receiveData.gift_dict[mItemId]){
							mTotalGet+=receiveData.gift_dict[mItemId];
						}
					}
					this.event(EVENT_GET_ITEM,receiveData);
					break;
			}
		}

		/**
		 * 奖池刷新时间
		 */
		public function getItemTime():Number{
			var n:Number = arena.item_time ? Tools.getTimeStamp(arena.item_time) : 0;
			return n;
		}


		/**
		 * get_info接口的时候初始化一次
		 */
		private function initUserData():void{
			//arena = ModelOfficial.arena ? ModelOfficial.arena : null;
			mPushTime = mTime0 = mTime1 = mTime2 = mTime3 = mTime4 = 0;
			// if(this.active && cfg.time){
			// 	var dt:Date = new Date(ConfigServer.getServerTimer());
			// 	mTime1   = (new Date(dt.getFullYear(),dt.getMonth(),dt.getDate(),cfg.time[0][0],cfg.time[0][1])).getTime();
			// 	mTime2   = (new Date(dt.getFullYear(),dt.getMonth(),dt.getDate(),cfg.time[1][0],cfg.time[1][1])).getTime();
			// 	mTime3   = (new Date(dt.getFullYear(),dt.getMonth(),dt.getDate(),cfg.time[2][0],cfg.time[2][1])).getTime();
			// 	mTime0 = mTime1 - cfg.time_notice*Tools.oneMillis;
			// }
			if(this.arena && this.arena.if_open == true && this.arena.all_done==false){
				mTime1   = Tools.getTimeStamp(this.arena.dark_time);
				mTime2   = Tools.getTimeStamp(this.arena.start_time);
				mTime3   = Tools.getTimeStamp(this.arena.end_time);
				mTime4   = mTime3 + (cfg.time_add ? cfg.time_add*Tools.oneMinuteMilli : 0);
				mTime0 = mTime1 - cfg.time_notice*Tools.oneMillis;
			}


			setPushTime();
		}
		/**
		 * 打印时间  测试用
		 */
		private function showTime():void{
			
			trace("====显示按钮时间",Tools.dateFormat(mTime0));
			trace("====开始竞猜时间",Tools.dateFormat(mTime1));
			trace("====开始攻擂时间",Tools.dateFormat(mTime2));
			trace("====攻擂结束时间",Tools.dateFormat(mTime3));
			trace("====查看结束时间",Tools.dateFormat(mTime4));
		}

		/**
		 * 下次开启时间
		 */
		public function nextOpenTime():Number{
			var n:Number = 0;
			var cfgTime:Array = cfg.time;
			var isMerge:Boolean = ModelManager.instance.modelUser.isMerge;
			var loginDate:Number = ModelManager.instance.modelUser.loginDateNum - 1;

			var first_day:Number = isMerge ? cfg.expand_day[1]  : cfg.expand_day[0];
			var cycle_num:Number = cfg.gap;
			if(first_day==-1) return 0;
			var dt:Date = new Date(ConfigServer.getServerTimer());
			n = (new Date(dt.getFullYear(),dt.getMonth(),dt.getDate(),cfg.time[0][0],cfg.time[0][1])).getTime();
			if(this.active==false){
				if(loginDate<first_day){//第一次开启时间	
					n += (first_day-loginDate)*Tools.oneDayMilli;
				}else{
					n += (n-first_day)%cycle_num*Tools.oneDayMilli;
				}
			}else{
				n += cycle_num*Tools.oneDayMilli;
			}
			//trace("=============",new Date(n));
			return n;
		}

		/**
		 * 设置推送面板时间
		 */
		private function setPushTime():void{
			var now:Number = ConfigServer.getServerTimer();
			if(this.active==false){
				mPushTime = 0;
			}else if(now<mTime0){
				mPushTime = mTime0;//预告时间
			}else if(now>=mTime0 && now<mTime1){
				mPushTime = mTime1;//竞猜时间
			}else if(now>=mTime1 && now<mTime2){
				mPushTime = mTime2;//开始时间
			}else if(now>=mTime2 && now<mTime3){
				mPushTime = mTime3;//结束时间
			}else if(now>=mTime3 && now<mTime4){
				mPushTime = mTime4;//查看时间
			}else{
				mPushTime = 0;
			}
		}
		/**
		 * 当前状态 0未开启  1预告时间  2竞猜时间  3攻擂时间  4结束时间   5最后查看时间
		 */
		public function get status():Number{
			var n:Number = 0;
			var now:Number = ConfigServer.getServerTimer();
			if(this.active==false){
				n = 0;
			}else if(now>=mTime0 && now<mTime1){
				n = 1;
			}else if(now>=mTime1 && now<mTime2){
				n = 2;
			}else if(now>=mTime2 && now<mTime3){
				n = 3;
			}else if(now>=mTime3 && now<mTime4){
				n = 4;
			}else if(now>=mTime4){
				n = 5;
			}
			return n;
		}

		/**
		 * 是否结束
		 */
		public function isOver():Boolean{
			var now:Number = ConfigServer.getServerTimer();
			var b0:Boolean = this.active;
			var b1:Boolean = mTime3 == 0 || now>=mTime3;
			var b2:Boolean = true;
			if(this.arena){
				for(var i:int=0;i<this.arena.arena_list.length;i++){
					if(this.arena.arena_list[i].user_list[1].length!=0){
						b2 = false;
						break;
					}
				}
			}
			return b0 && b1 && b2;
		}

		/**
		 * 今天是否有擂台赛
		 */
		override public function get active():Boolean {
			mOpenTimes = 0;
			cfg = ConfigServer.arena;
			if(cfg==null) return false;
			
			var isMerge:Boolean = ModelManager.instance.modelUser.isMerge;
			var loginDate:Number = ModelManager.instance.modelUser.loginDateNum;

			var first_day:Number = isMerge ? cfg.expand_day[1]  : cfg.expand_day[0];
			var cycle_num:Number = cfg.gap;//isMerge ? cfg.gap[1]  : cfg.gap[0];

			if(first_day == -1) return false;

			var n:Number = loginDate-1;
			if(n == first_day){
				mOpenTimes = 1;
				return true;
			}
			
			if(n>first_day){
				mOpenTimes = 1;
				if((n-first_day)%cycle_num==0){
					mOpenTimes = 1 + (n-first_day)/cycle_num;
					return true;
				}
			}
			
			return false;
		}


		/**
		 * 显示推送面板
		 */
		public function showPushView():void{

			if(ModelGuide.forceGuide()) return;
			if(this.active==false) return;

			updateArenaData();
			if(this.mPushTime==0) return;

			var now:Number=ConfigServer.getServerTimer();
			if(now>=mPushTime){
				var n:Number = this.status;
				if(n==1){
					this.event(ModelArena.EVENT_UPDATE_BTN_STATUS);
				}else{
					var arr:Array = [];
					if(n==2){//开始竞猜
						arr = cfg.show[0];
						sendChatMsg("arena_start");
						this.event(EVENT_UPDATE_ARENA_CLIP);
					}else if(n==3){//竞猜结束 & 攻擂开始
						sendChatMsg("arena_attack");
						arr = cfg.show[1];
					}else if(n==4){//结束
						if(this.isOver()){
							this.event(EVENT_UPDATE_BTN_STATUS);
							this.event(EVENT_UPDATE_ARENA_CLIP);
							var _entity:EntityCity = MapModel.instance.arenas[4];
							if(_entity) MapCamera.lookAtGrid(_entity.mapGrid, 500);	
							arr = cfg.show[3];
						}else{
							arr = cfg.show[2];
						}

						for(var i:int=0;i<4;i++){
							var o:Object = ModelArena.instance.arena.arena_list[i];
							if(o && o.user_list[0]){
								var winner_time:Number = Tools.getTimeStamp(o.user_list[0].win_time);
								if(winner_time < this.mTime3){//成为擂主时间<结束时间  在时间结束时成为最终擂主
									this.event(EVENT_FINAL_WINNER,i);
								}
							}
						}
					}else if(n==5){
						this.event(EVENT_UPDATE_BTN_STATUS);
					}
					var m:Number = n==2 ? this.cfg.dark_horse[0] : 0;
					if(arr && arr.length!=0){
						if(m!=0){
							if(arr[3]==null){
								arr.push([m]);
							}else{
								arr[3]=[m];
							}
						}
						ViewManager.instance.showHeroTalk([arr],null);
					}
				}
				setPushTime();
			}
		}


		/**
		 * 上阵部队数
		 */
		public function fightNum():Number{
			var arr:Array = cfg['number_'+ModelManager.instance.modelUser.mergeNum];
			var loginDate:Number = ModelManager.instance.modelUser.loginDateNum;
			
			for(var i:int = arr.length-1;i>=0;i--){
				if(loginDate>=arr[i][0]){
					return arr[i][1];
				}
			}
			return 0;
		}

		/**
		 * 剩余次数
		 */
		public function joinNum():Number{
			var user:Object = ModelManager.instance.modelUser.arena;
			var cfg_num:Array = cfg.num;
			if(user){
				var n:Number = Tools.getTimeStamp(user.join_time);
				var now:Number = ConfigServer.getServerTimer();
				var nn:Number = Math.floor((now-n)/(cfg_num[1]*Tools.oneMillis));
				if( nn > cfg_num[0]){
					return cfg_num[0];
				}else{
					return nn;
				}
			}
			return cfg_num[0];
		}


		override public function get redPoint():Boolean {
			return false;
		}

		public function getTxt():String {
			var n:Number = ConfigServer.getServerTimer();
			var s:String = '';
			var m:Number = 0;
			var t:Number = this.status;
			switch(t){
				case 0:
					s = "arena_text27";//"未开启";
					break;
				case 1:
					m = this.mTime1;
					s = "arena_text28";//"距离开始竞猜:";
					break;
				case 2://竞猜
					m = this.mTime2;
					s = "arena_text29";//"距离竞猜结束:";
					break;

				case 3://攻擂
					m = this.mTime3;
					s = "arena_text30";//"距离攻擂结束:";
					break;

				case 4://结束
					if(this.isOver() == false){
						s = "arena_text31";//"攻擂结算...";
					}else{
						s = "arena_text32";//"攻擂结束...";
					}
					break;
				// case 5://结束后的查看时间
				// 	s = "arena_text32";//"攻擂结束...";
				// 	break;
			}
			s = m==0 ? Tools.getMsgById(s) : Tools.getMsgById(s,[Tools.getTimeStyle(m-n)]);
			return s;
		}

		public function getArenaGroup():Array{
			//var n:Number = this.mOpenTimes - 1;
			//var m:Number = n<cfg.arena_group.length ? n : n % cfg.arena_group.length;
			//return cfg.arena_group[m] ? cfg.arena_group[m] : cfg.arena_group[0];
			var arr:Array = [];
			var a:Array = this.arena.arena_list;
			for(var i:int=0;i<a.length;i++){
				arr.push(a[i].type);
			}
			return arr;
		}

		/**
		 * 获得奖池数
		 */
		public function getArenaItemNum(index:int):Number{
			if(arenaData && arenaData[index]){
				return arenaData[index].item_num[0];
			}
			return 0;
		}

		/**
		 * 挑战者buff
		 */
		public function challengerBuff(index:int):Number{
			var o:Object = arena.arena_list[index].user_list[0];
			if(o){
				var now:Number = ConfigServer.getServerTimer();
				var n:Number = (now - Tools.getTimeStamp(o.win_time))/1000;//守擂时间(秒)
				var arr:Array = cfg.challenger;
				for(var i:int=arr.length-1;i>=0;i--){
					if(n>=arr[i][0]){
						return arr[i][1];
					}
				}
			}
			
			return 0;
		}

		/**
		 * 
		 */
		public static function hasNextFight(arena_index:int,log_index:int):Boolean{
			var o:Object = ModelArena.instance.arena.arena_list[arena_index];
			if(o.user_list[0]!=null){
				if(log_index < o.log_len-1){
					return true;
				}
			}
			return false;
		}

		public function foreshowTips():void {
			cfg.show[4] && ViewManager.instance.showHeroTalk([cfg.show[4]]);
		}


		/**
		 * 打开面板
		 */
		public static function showView(n:Number = 0):void{
			var b:Boolean = false;
			var boo:Boolean = false;
			if(ModelArena.instance.active){
				if(ModelArena.instance.status>=2 && ModelArena.instance.isOver()==false){
					if(ModelArena.instance.getArenaGroup().indexOf(n)!=-1){
						b = true;
					}
				}
			}
			if(b){
				boo = true;
				NetSocket.instance.send("get_pk_arena",{},Handler.create(null,function(np:NetPackage):void{
					ModelArena.instance.arena = np.receiveData;
					ViewManager.instance.showView(["ViewArenaMain",ViewArenaMain],n);
				}));
			}else{
				var o:Object = getArenaData();
				if(o && o[n]){
					ModelManager.instance.modelUser.selectUserInfo(o[n].uid);
					boo = true;
				}
			}
			if(!boo){
				ModelManager.instance.modelGame.event(ModelGame.EVENT_CLICK_ARENA_CLIP,n-1);
			}
			
		}

		public static function getArenaData():Object{
			if(ModelArena.instance.arena==null) return {};

			var o:Object = ModelArena.instance.arena.top_one;
			var a:Array = ModelArena.instance.arena.arena_list;
			var arr:Array = [];
			var b:Boolean = false;
			var sta:Number = ModelArena.instance.status;
			if(sta == 2 || sta == 3){
				b = true;
			}else if(sta == 4 && !ModelArena.instance.isOver()){
				b = true;
			}
			if(b){
				for(var i:int=0;i<a.length;i++){
					arr.push(a[i].type);
				}
			}
			
			var obj:Object = {};
			for(var s:String in o){
				if(arr.indexOf(Number(s))==-1){
					obj[s] = o[s];
				}
			}
			return obj;
		}

		/**
		 * 擂台商店是否打开
		 */
		public function openShop():Boolean{
			cfg = ConfigServer.arena;
			if(cfg==null) return false;
			var b:Boolean = ModelManager.instance.modelUser.loginDateNum-1 >= cfg.expand_day[0];
			return getLight() && b;
		}

		/**
		 * 李闯专用
		 */
		public function getLight():Boolean{
			cfg = ConfigServer.arena;
			if(cfg==null) return false;
			
			var isMerge:Boolean = ModelManager.instance.modelUser.isMerge;
			var first_day:Number = isMerge ? cfg.expand_day[1]  : cfg.expand_day[0];

			return first_day!=-1;
		}




		//========================================================================

		private var arenaData:Object;
		/**
		 * 给聊天用的
		 */
		private function initArenaData():void{
			var a:Array = this.arena.arena_list;
			var now:Number = ConfigServer.getServerTimer();
			var n:Number = now>this.mTime2 ? getItemTime() + this.cfg.pool_add[0]*1000 : mTime2 + this.cfg.pool_add[0]*1000;
			arenaData = {};

			var arr1:Array = [];
			if(ConfigServer.system_simple.system_massage.hasOwnProperty("arena_pool_max")){
				var o1:Object = ConfigServer.system_simple.system_massage.arena_pool_max;
				for(var j:int=1;j<5;j++){
					if(o1[j+""]){
						arr1.push(o1[j+""].need[0]);
					}else{
						break;
					}
				}
			}
			if(arr1.length==0) arr1.push(99999);

			var arr2:Array = [];
			if(ConfigServer.system_simple.system_massage.hasOwnProperty("arena_cha_add")){
				var o2:Object = ConfigServer.system_simple.system_massage.arena_cha_add;
				for(var k:int=1;k<5;k++){
					if(o2[k+""]){
						arr2.push(o2[k+""].need[0]);
					}else{
						break;
					}
				}
			}
			if(arr2.length==0) arr2.push(99999);

			for(var i:int=0;i<a.length;i++){
				var o:Object = a[i];
				
				arenaData[i] = {"item_num":[o.item_num,-1], 
								"buff_num":[challengerBuff(i),-1],
								"type":a[i].type,
								"count":0,
								"num":a[i].item_num,
								"need_item":arr1,
								"need_buff":arr2,
								"refresh_time":n,
								"top_id":o.user_list[0] ? o.user_list[0].uid : ""};
			}

		}
		/**
		 * 每秒调用
		 */
		private function updateArenaData():void{
			if(status==3){//攻擂时间
				var now:Number = ConfigServer.getServerTimer();
				if(arenaData){
					for(var s:String in arenaData){
						var i:int = Number(s);
						var arr1:Array = arenaData[s]["item_num"];
						var _count:Number = arenaData[s].count;
						var _time:Number = arenaData[s].refresh_time;
						
						var darkNum:Number = this.arena.dark_arena_index == i ? this.cfg.dark_horse[1] : 1;
						arr1[0] = arenaData[s].num + _count*this.cfg.pool_add[1]*darkNum;

						if(now>_time){
							_count++;
							_time = getItemTime() + (_count+1)*this.cfg.pool_add[0]*1000;
						}
						arenaData[s].count = _count;
						arenaData[s].refresh_time = _time;

						var need1:Array = arenaData[s].need_item;
						if(arr1[1]==-1 || arr1[1] < need1.length-1){
							var len1:Number = arr1[1]+1;
							for(var j:int=need1.length-1;j>=len1;j--){
								if(arr1[0]>=need1[j]){
									arr1[1] = j;
									sendChatMsg("arena_pool_max",i);
									break;
								}
							}
						}

						var arr2:Array = arenaData[s]["buff_num"];
						var n2:Number = challengerBuff(i);
						arr2[0] = n2;
						var need2:Array = arenaData[s].need_buff;
						if(arr2[1]==-1 || arr2[1] < need2.length-1){
							var len2:Number=arr2[1]+1;
							for(var k:int=need2.length;k>=len2;k--){
								if(arr2[0]==need2[k]){
									arr2[1] = k;
									sendChatMsg("arena_cha_add",i);
									break;
								}
							}
						}
					}
				}
			}
		}

		private function checkArenaData():void{
			if(arenaData){
				for(var s:String in arenaData){
					var o1:Object = arenaData[s];
					var o2:Object = this.arena.arena_list[Number(s)];
					o1["num"] = o2.item_num;
					var arr1:Array = o1["item_num"];
					var need1:Array = o1.need_item; 
					var len1:Number = arr1[1]+1;
					for(var j:int=need1.length-1;j>=len1;j--){
						if(arr1[0]>=need1[j]){
							arr1[1] = j;
							break;
						}
					}

					o1["count"] = 0;
					o1["refresh_time"] = this.getItemTime() + this.cfg.pool_add[0]*1000;

					if(o2.user_list[0]){
						if(o1.top_id != o2.user_list[0].uid){//擂主变化
							o1["top_id"] = 	o2.user_list[0].uid;

							var arr2:Array = o1["buff_num"];
							var need2:Array = o1.need_buff;
							arr2[1] = -1;
							for(var k:int=0;k<need2.length;k++){
								if(arr2[0]==need2[k]){
									arr2[1] = k;
									break;
								}
							}
						}
					}					
				}
			}
		}

		
		public function sendMsg(s:String,o:Object):void{
			NetSocket.instance.send(s,o,null);
		}

		/**
		 * 发送本地聊天消息
		 */
		public function sendChatMsg(key:String,obj:*=null):void{
			if(ConfigServer.system_simple.system_massage.hasOwnProperty(key)){
				//[频道,key,key下的key,文字配置里需要的数据,time]
				var o:Object = ConfigServer.system_simple.system_massage[key];
				var now:Number = ConfigServer.getServerTimer();
				var arr:Array = [];
				var n:Number = 0;
				switch(key){
					case "arena_start"://竞猜开始
						arr = [this.cfg.dark_horse[0]];
						break;
					case "arena_attack"://攻擂开始
						break;
					case "arena_cha_add"://buff增加
						var o1:Object = arenaData[obj];
						n = o1.buff_num[1]+1;
						arr = [Tools.getMsgById(ModelArena.textArr[o1.type]),o1.buff_num[0]*100+"%"];
						break;
					case "arena_pool_max"://奖池增加
						var o2:Object = arenaData[obj];
						n = o2.item_num[1]+1;
						arr = [Tools.getMsgById(ModelArena.textArr[o2.type]),o2.need_item[o2.item_num[1]]];
						break;
				}
				ModelManager.instance.modelChat.sendLocalMessage([o[n].icon,key,n+"",arr,now]);

			}
		}


		private function testFun():void{
			var _entity:EntityCity = MapModel.instance.arenas[4];
			MapCamera.lookAtGrid(_entity.mapGrid, 500);	
		}

	}

}