package sg.model
{
	import sg.map.utils.Vector2D;
	import sg.model.ModelBase;
	import laya.utils.Utils;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.scene.constant.EventConstant;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.utils.ObjectSingle;
	import sg.cfg.ConfigClass;
	import sg.manager.ViewManager;
	import laya.events.Event;
	import sg.net.NetMethodCfg;
	import laya.ui.Button;
	import sg.manager.AssetsManager;
	import sg.view.effect.BuildingFuncOpen;
	import sg.map.model.MapModel;
	import sg.view.map.ViewEstateQuickly;
	import sg.view.map.ViewEventTalk;
	import sg.view.map.ViewCreditResult;
	import sg.activities.model.ModelFreeBuy;
	import laya.display.Sprite;
	import laya.ui.Image;
	import sg.guide.model.ModelGuide;
	import sg.boundFor.GotoManager;
	import sg.activities.model.ModelHappy;
	import sg.manager.QueueManager;
	import laya.maths.MathUtil;
	import sg.utils.StringUtil;
	import sg.cfg.ConfigApp;

	/**
	 * ...
	 * @author
	 */
	public class ModelGame extends ModelBase{

		//
		public static const EVENT_NEW_DAY_COM_ON:String = "event_new_day_com_on";//新得一天,通告一次
		public static const EVENT_SERVER_SELECT_CHANGE:String = "event_server_select_change";
		//
		public static const EVENT_HERO_LV_EXP_CHANGE:String = "event_hero_lv_exp_change";
		public static const EVENT_HERO_SKILL_CHANGE:String = "event_hero_skill_change";
		public static const EVENT_HERO_TROOP_EDIT_UI_CHANGE:String = "event_hero_troop_edit_ui_change";
		//
		public static const EVENT_PK_TIMES_CHANGE:String = "event_pk_times_change";//
		public static const EVENT_OFFICE_RIGHT_CHANGE:String = "event_office_right_change";//
		public static const EVENT_CHAMPION_BET_CHANGE:String = "event_champion_bet_change";//比武大会,押注状态/

		public static const EVENT_TROOP_SELECT_TRUE:String = "event_troop_select_true";////
		//
		public static const EVENT_TASK_RED:String = "event_task_red";//任务red
		public static const EVENT_TASK_WORK_CHANGE:String = "event_task_work_change";//政务,状态改变
		public static const EVENT_TASK_WORK_GET_OR_DEL:String = "event_task_work_get_or_del";//政务,状态改变2
		public static const EVENT_TASK_MAIN_CLOSE_VIEW:String = "event_task_main_close_view";//任务主界面关闭
		public static const EVENT_TASK_WORK_CONQUEST_OPEN_MAP:String = "event_task_work_conquest_open_map";//政务,跳转大地图
		public static const EVENT_TASK_WORK_CONQUEST_OPEN_INSIDE:String = "event_task_work_conquest_open_inside";//政务,跳转封地
		//
		public static const EVENT_REAL_NAME_CHECK_TIRED_TIME:String = "event_real_name_check_tired_time";//实名提示时间
		//异族入侵
		public static const EVENT_PK_NPC_CHECK_MODEL:String = "event_pk_npc_check_model";//异族入侵检查数据
		public static const EVENT_ALIEN_FIGHT_START:String = "event_alien_fight_start";//异族入侵开始战斗
		public static const EVENT_ALIEN_FIGHT_END:String = "event_alien_fight_end";//异族入侵战斗 结束
		public static const EVENT_CAPTAIN_FIGHT_START:String = "event_captain_fight_start";//异族入侵战斗 结束
		public static const EVENT_CAPTAIN_FIGHT_END:String = "event_captain_fight_end";//异族入侵战斗 结束

		public static const EVENT_UPDAET_BUG_MSG:String = "event_update_bug_msg";

		public static const EVENT_ADD_ESTATE:String = "event_add_estate";
		public static const EVENT_REMOVE_ESTATE:String = "event_remove_estate";
		public static const EVENT_FIGHT_LOG_CHANGE:String = "event_fight_log_change";//战报有变化
		public static const EVENT_CREDIT_CHANGE:String = "event_CREDIT_change";//战功奖励变化
		public static const EVENT_BUFFS_ORDER_3_4_CHANGE:String = "event_buffs_order_3_4_change";//攻城令/守城令
		public static const EVENT_BUFFS_ORDER_5_CHANGE:String = "event_buffs_order_5_change";//
		public static const EVENT_BUFFS_ORDER_CORPS_CHANGE:String = "event_buffs_order_corps_change";//
		public static const EVENT_STAGE_LOCK_UNLOCK:String = "event_stage_lock_unlock";//全局屏蔽
		public static const EVENT_CHECK_NPC_INFO:String = "event_check_npc_info";//检查斥候情报红点
		
		public static const EVENT_MAYOR_UDPATE:String = "event_mayor_update";//更新太守。
		
		//
		public static const EVENT_PAY_END:String = "event_pay_end";//充值结束
		public static const EVENT_PAY_LIST_UPDATE:String = "event_pay_list_update";
		// 天下大势改变
		public static const EVENT_INVADE_CHANGE:String = "event_invade_change";

		public static const EVENT_SHOW_BALLISTA_MSG:String = "event_show_ballista_msg";

		public static const EVENT_CLOSE_EQUIP_MAIN:String  = "event_close_equip_main";
		public static const EVENT_UPDATE_EQUIP_MAIN:String = "event_update_equip_main";

		//朝廷密旨收到服务器推送时派发
		public static const EVENT_NEW_TASK_PUSH:String = "event_new_task_push";

		public static const EVENT_CLICK_ARENA_CLIP:String = "event_click_arena_clip";
		//
		public static const map_troop_status_str:Array = [
			Tools.getMsgById("_public161"),
			Tools.getMsgById("_public162"),//"行军中",
			Tools.getMsgById("_public163"),//"撤回中",
			Tools.getMsgById("_public164")//"野战中"
		];
		//
		public var isInside:Boolean = false;
		public var gameTimer:Number = 0;
		public var gameTipsTimer:Number = -1;
		public var gameTipsTimerDes:Number = 10;
		public var creatNewTroopID:Object = {};
		public function ModelGame(){
			getRecords();
			getCoinByOffice();
			buildCityBuildHandler();
			chatHandler();
			creditSettleHandler();
			//guildJoinRegisterHandler();
			//guildOutRegisterHandler();
			//guildNoticeChange();
			//guildApplication();
			//guildAlienChange();
			clubAlienFight();
			clubAlienChange();
			guildRedBagUpdate();
			bugMSGHandler();
			updateUserHandler();
			pushMsgHandler();

			mailGiftMsg();
			freeBuyMsg();
			getEstateMSG();
			pushTask();
			pushEffort();
			pushAuction();
			pushNewTask();

			QueueManager.instance.on(QueueManager.EVENT_CLOSE_PANEL,this,queueCallBack);
		}

		private function queueCallBack(vid:String):void{
			QueueManager.instance.showNext(vid);
		}

		/**
		 * 在哪里??
		 */
		public function getMapType():int{
			return isInside?2:1;
		}
		/**
		 * 初始化我国的产业
		 */
		public function initEstate():void{
			var config_city:Object=ConfigServer.city;
			for(var cid:String in config_city){
				if(ModelOfficial.checkCityIsMyCountry(cid)){
					var estate:Array=config_city[cid].estate;
					if(estate){
						for(var i:int=0;i<estate.length;i++){
							getModelEstate(cid,i);
						}
					}
				}else{
					var user_estate:Object=ModelManager.instance.modelUser.estate;
					for(var j:int=0;j<user_estate.length;j++){
						var obj_estate:Object=user_estate[j];
						if(obj_estate.city_id==cid){
							if(obj_estate.active_hid){
								getModelEstate(cid,obj_estate.estate_index);
							}
						}
					}
				}
			}	
			// //trace("=============================",ModelEstate.myCountryEstates);	
		}
		
		/**
		 * 增加了一个产业
		 */
		public function addEstate(cid:String,index:int):void{
			if(ConfigServer.city[cid].estate && ConfigServer.city[cid].estate[index]){
				var me:ModelEstate = getModelEstate(cid,index);
				this.event(ModelGame.EVENT_ADD_ESTATE,me);
				////trace("gameModel 增加了一个产业");
			}
		}

		/**
		 * 放弃产业 
		 * @parm index=-1时 放弃这个城市所有产业
		 */
		public function removeEstate(cid:*,index:int=-1):void{
			var me:ModelEstate;
			if(index==-1){
				for(var s:String in ModelEstate.myCountryEstates){
					me=ModelEstate.myCountryEstates[s];
					if(me.city_id==cid+""){
						if(me.active_hid==""){
							delete ModelEstate.myCountryEstates[s];
							me.event(ModelGame.EVENT_REMOVE_ESTATE,me);
							////trace("gameModel",cid+" 所有产业被移除");
						}
					}
				}
			}else{
				if(ModelEstate.myCountryEstates.hasOwnProperty(cid+"_"+index)){
					me=ModelEstate.myCountryEstates[cid+"_"+index];
					if(me.city_id==cid+""){
						delete ModelEstate.myCountryEstates[s];
						me.event(ModelGame.EVENT_REMOVE_ESTATE,me);
						////trace("gameModel 放弃产业",cid+"_"+index);
					}
				}
			}
		}

		public function updateMyEstateStatus():void{
			for(var i:int=0;i<ModelManager.instance.modelUser.estate.length;i++){
				var obj:Object=ModelManager.instance.modelUser.estate[i];
				var estate:ModelEstate=ModelEstate.myCountryEstates[obj.city_id+"_"+obj.estate_index];
				if(estate){
					//trace("==============",Tools.dateFormat(estate.next_harvest_time));
					if(estate.next_harvest_time!=-1 && ConfigServer.getServerTimer()>estate.next_harvest_time){
						estate.event(ModelEstate.EVENT_ESTATE_UPDATE);//可收割推送
						estate.getNextHarvestTime();
					}
					
					var hero:ModelMapHero=estate.estateHero;
					if(hero && !hero.is_send_event && hero.getTime()<=ConfigServer.getServerTimer()){
						estate.event(ModelEstate.EVENT_ESTATE_UPDATE);//完成任务推送
						ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,{"user":{"estate":""}});//通知红点刷新
						hero.is_send_event=true;
					}
				}
				
			}
			/*
			for(var s:String in ModelEstate.myCountryEstates){
				var estate:ModelEstate=ModelEstate.myCountryEstates[s];
				if(estate.next_harvest_time!=-1 && ConfigServer.getServerTimer()>estate.next_harvest_time){
					estate.event(ModelEstate.EVENT_ESTATE_UPDATE);//可收割推送
					estate.getNextHarvestTime();
				}

				var hero:ModelMapHero=estate.estateHero;
				if(hero && !hero.is_send_event && hero.getTime()<=ConfigServer.getServerTimer()){
					estate.event(ModelEstate.EVENT_ESTATE_UPDATE);//完成任务推送
					ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,{"user":{"estate":""}});//通知红点刷新
					hero.is_send_event=true;
				}
			}*/
		}

		public function updateMyVisitStatus():void{
			for(var s:String in ModelVisit.visitModels){
				var visit:ModelVisit=ModelVisit.visitModels[s];
				if(!visit.isSendMSG && visit.visitHero){
					var n1:Number=ConfigServer.getServerTimer();
					var n2:Number=visit.visitHero.getTime();
					if(n1>=n2){
						ModelVisit.updateData(s);
						ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,{"user":{"visit":""}});//通知红点刷新
						visit.isSendMSG=true;
						////trace("visit完成推送");
					}
				}
			}
		}

		public function updateNewVisit():void{//新的一天刷新
			////trace("新的一天了！更新所有visit");
			for(var s:String in ModelVisit.visitModels){
				var visit:ModelVisit=ModelVisit.visitModels[s];
				visit.clear();
			}
			getCityVisit();
		}

		public function updateMyCityBuildStatus():void{
			for(var s:String in ModelCityBuild.cityBuildModels){
				var obj:Object=ModelCityBuild.cityBuildModels[s];
				for(var ss:String in obj){
					var cityBuild:ModelCityBuild=(obj[ss] as ModelCityBuild);
					if(!cityBuild["send"] && cityBuild.cityBuildHero){
						var n1:Number=ConfigServer.getServerTimer();
						var n2:Number=cityBuild.cityBuildHero.getTime();
						if(n1>=n2){
							cityBuild["send"]=1;
							cityBuild.event(ModelCityBuild.EVENT_UPDATE_CITY_BUILD);
							ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,{"user":{"city_build":""}});//通知红点刷新
							////trace("citybuild完成推送");
						}
					}
				}
				
			}
		}

		/**
		 * 初始化民情数据（先调接口）
		 */
		public function initFtask():void{
			ModelFTask.ftaskModels={};
			for(var s:String in ModelManager.instance.modelUser.ftask){	
				if(ConfigServer.city[s].pctask_id && ModelOfficial.checkCityIsMyCountry(s)){
					if(ModelManager.instance.modelUser.ftask[s][0]==-1){
					//	//trace(s+"已完成民情 不初始化了");
					}else{
						ModelFTask.ftaskModels[s]=new ModelFTask(s);
					}
					
				}
			}
			this.event(ModelFTask.EVENT_INIT_FTASK);
			//trace("=====================打印当前所有民情model",ModelFTask.ftaskModels);
		}

		public function addFtask(cid:String):void{
			if(!ModelFTask.ftaskModels.hasOwnProperty(cid)){
				if(ModelManager.instance.modelUser.ftask[cid][0]!=-1){
					var md:ModelFTask=getModelFtask(cid);
					ModelFTask.ftaskModels[cid]=md;
					this.event(ModelFTask.EVENT_ADD_FTASK,md);
					////trace("添加新的民情model",cid,md.status);
				}
			}
		}

		public function removeFtask(cid:String):void{
			if(ModelFTask.ftaskModels.hasOwnProperty(cid)){
				var md:ModelFTask=ModelFTask.ftaskModels[cid];
				////trace(cid+"移除这个model",md.status);
				delete ModelFTask.ftaskModels[cid];
				md.event(ModelFTask.EVENT_REMOVE_FTASK,md);	
			}
		}

		/**
		 * 跳过新手引导检查已完成的民情 并移除
		 */
		public function checkFtask():void{
			var obj:Object=ModelManager.instance.modelUser.ftask;
			for(var k:String in ModelFTask.ftaskModels){
				if(obj[k] && obj[k][0]==-1){
					removeFtask(k);
				}
			}
		}



		/*
		 ##################################   获取model    ####################################
		 */

		/**
		 * 获取 产业 model
		 */
		public function getModelEstate(cid:String,index:int):ModelEstate{
			var new_estate:ModelEstate;
			var key:String = cid + "_" + index;
			if(!ModelEstate.estateModels.hasOwnProperty(key)){	
				if(ConfigServer.city[cid].estate[index]!=null){
					ModelEstate.estateModels[key]=new ModelEstate(cid,index);
					if(ModelOfficial.checkCityIsMyCountry(cid)){
						ModelEstate.myCountryEstates[key]=ModelEstate.estateModels[key];
					}else{
						var user_estate:Object=ModelManager.instance.modelUser.estate;
						for(var j:int=0;j<user_estate.length;j++){
							var obj_estate:Object=user_estate[j];
							if(obj_estate.city_id==cid && obj_estate.estate_index==index){
								ModelEstate.myCountryEstates[key]=ModelEstate.estateModels[key];
								break;
							}
						}
					}
				}else{
					////trace("前端error------getModelEstate错误",cid,index);
				}		
				
			}
			return ModelEstate.estateModels[key];
		}

		/**
		 * 获得 民情 model
		 */
		public function getModelFtask(cid:String):ModelFTask{
			if(!ModelFTask.ftaskModels.hasOwnProperty(cid)){
				ModelFTask.ftaskModels[cid]=new ModelFTask(cid);
			}
			return ModelFTask.ftaskModels[cid];
		}

		/**
		 * 获得 拜访 model
		 */
		public function getModelVisit(cid:String):ModelVisit{
			return ModelVisit.visitModels[cid];
				
		}

		/**
		 * 获取 英雄 model
		 */
		public function getModelHero(key:String):ModelHero{
			if(!key){
				return null;
			}
            if(!ModelHero.heroModels.hasOwnProperty(key)){
                ModelHero.heroModels[key] = new ModelHero();
				(ModelHero.heroModels[key] as ModelHero).initData(key,ConfigServer.hero[key]);
            }
            return ModelHero.heroModels[key] as ModelHero;			
		}

		/**
		 * 获取 英雄技能 model
		 */
		public function getModelSkill(key:String):ModelSkill{
			if(!key){
				return null;
			}			
            if(!ModelSkill.skillModels.hasOwnProperty(key)){
                ModelSkill.skillModels[key] = new ModelSkill();
				(ModelSkill.skillModels[key] as ModelSkill).initData(key,ModelSkill.getConfig(key));
            }
            return ModelSkill.skillModels[key] as ModelSkill;
        }

		/**
		 * 获取 商店 model
		 */
		public function getModelShop(key:String):ModelShop{
			if(!key){
				return null;
			}			
          	 if(!ModelShop.shopModels.hasOwnProperty(key)){
                ModelShop.shopModels[key] = new ModelShop();
				(ModelShop.shopModels[key] as ModelShop).initData(key);
            }
            return ModelShop.shopModels[key] as ModelShop;
        }

		

		/**
		 * 获取 装备宝物 model
		 */
		public function getModelEquip(key:String):ModelEquip{
			if(!key){
				return null;
			}			
            if(!ModelEquip.equipModels.hasOwnProperty(key)){
                ModelEquip.equipModels[key] = new ModelEquip();
				(ModelEquip.equipModels[key] as ModelEquip).initData(key,ModelEquip.getConfig(key));
            }
            return ModelEquip.equipModels[key] as ModelEquip;
        }

		/**
		 * 获取 星辰 model
		 */		
		public function getModelRune(key:String):ModelRune{
			if(!key){
				return null;
			}			
            if(!ModelRune.runeModels.hasOwnProperty(key)){
                ModelRune.runeModels[key] = new ModelRune();
				(ModelRune.runeModels[key] as ModelRune).initData(key,ModelRune.getConfig(key));
            }
            return ModelRune.runeModels[key] as ModelRune;
        }

		/**
		 * 获取 科技 model
		 */		
		public function getModelScience(key:String):ModelScience{
			if(!key){
				return null;
			}			
            if(!ModelScience.modelSciences.hasOwnProperty(key)){
                ModelScience.modelSciences[key] = new ModelScience();
				(ModelScience.modelSciences[key] as ModelScience).initData(key,ModelScience.getConfig(key));
            }
            return ModelScience.modelSciences[key] as ModelScience;
        }

		/*
		 ##################################以上  获取model    ####################################
		 */




		/*
		 ##################################    服务器推送消息    ####################################
		 */
		 
		 private function pushMsgHandler():void{
			NetSocket.instance.registerHandler("push_msg", new Handler(this, function(np:NetPackage):void{
				if (ModelGuide.forceGuide()){
					return;
				}
				var data:* = np.receiveData;
				var msg:String = data.msg;
				var code:int = data.code;
				if(code){
					msg += Tools.getObjValue(Tools.sMsgDic, "_push_msg_"+code, "");
				}
				ViewManager.instance.showAlert(msg,null,null,"",true);
			}));
		}

		private function updateUserHandler():void{
			NetSocket.instance.registerHandler("update_user",new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				// trace("=============服务器主动推送的刷新用户数据");
			}));
		}
		
		private function getRecords():void{
			NetSocket.instance.registerHandler("push_records",new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ModelHappy.instance.event(ModelHappy.EVENT_UPDATE_SPARTA);
			}));
		}

		private function getCoinByOffice():void{
			 NetSocket.instance.registerHandler("pay_son",new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showIcon({"coin":np.receiveData.add_coin},Laya.stage.width/2,Laya.stage.height/2);
				ViewManager.instance.showTipsTxt(Tools.getMsgById("530077",[np.receiveData.king_name,np.receiveData.add_coin]));
			}));
		}
		private function buildCityBuildHandler():void{
			NetSocket.instance.registerHandler("build_city_build",new Handler(this,function(np:NetPackage):void{
				ModelOfficial.updateCityBuild(np.receiveData);				
				this.event(EventConstant.UPDATE_BUILD, {cid:np.receiveData.cid, bid:np.receiveData.bid, name:np.receiveData.uname});
			}));
		}
		

		private function bugMSGHandler():void{
			NetSocket.instance.registerHandler("bug_msg",new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelChat.isNewBugMSG=true;
				ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,[{"user":""},true]);//通知红点刷新
				event(ModelGame.EVENT_UPDAET_BUG_MSG);
			}));
		}

		/**
		 * 聊天消息监听
		 */
		private function chatHandler():void{
			NetSocket.instance.registerHandler("chat",new Handler(this,function(np:NetPackage):void{
				////trace("=======收到聊天消息",np.receiveData);
				if(np.receiveData is Array){
					ModelManager.instance.modelChat.acceptMSG(np.receiveData);
					ModelManager.instance.modelOfficel.setCallCD(np.receiveData[5]);
					if(np.receiveData[1]=="build_ballista"){
						var s1:String=StringUtil.htmlFontColor(Tools.getMsgById("country_"+np.receiveData[3][0]),ConfigServer.world.COUNTRY_COLORS[np.receiveData[3][0]]);
						var s2:String=Tools.getMsgById(ConfigServer.country_pvp.ballista[np.receiveData[3][1]].name);
						this.event(EVENT_SHOW_BALLISTA_MSG,[np.receiveData[3][0], s1,s2]);//[国家名，建造车的名字]
						// trace("收到攻城车建造信息",s1,s2);
					}
				}else if(np.receiveData.msg){
					ViewManager.instance.showTipsTxt(np.receiveData.msg);
				}
			}));
		}

		/**
		 * 年度战功结算推送
		 */
		private function creditSettleHandler():void{
			NetSocket.instance.registerHandler("credit_settle",new Handler(this,function(np:NetPackage):void{
				//var data:Array=np.receiveData;
				ModelManager.instance.modelUser.credit_settle=np.receiveData;
				//ViewManager.instance.showView(["ViewCreditResult",ViewCreditResult],data);
			}));
		}

		private function guildJoinRegisterHandler():void{//加入军团成功
			NetSocket.instance.registerHandler("guild_application_pass",new Handler(this,guildJoinCallBack));
		}
		private function guildJoinCallBack(np:NetPackage):void{
			if(np.receiveData is Boolean){
				return;
			}
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ObjectSingle.getObjectByArr(ConfigClass.VIEW_GUILD_MAIN).event(ModelUser.EVENT_GUILD_APPLY_SUC);
		}
		private function guildOutRegisterHandler():void{//被踢出军团
			NetSocket.instance.registerHandler("guild_manage",new Handler(this,guildOutCallBack));
		}
		private function guildOutCallBack(np:NetPackage):void{
			if(np.receiveData is Boolean){
				return;
			}
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ObjectSingle.getObjectByArr(ConfigClass.VIEW_GUILD_MAIN).event(ModelUser.EVENT_GUILD_APPLY_SUC);
		}

		private function guildApplication():void{//有人申请加入（团长/副团长接收）
			NetSocket.instance.registerHandler("guild_application",new Handler(this,guildApplicationCallBack));
			
		}

		private function guildApplicationCallBack(np:NetPackage):void{
			if(np.receiveData is Boolean){
				//trace("有人申请入团");
				//ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips14"));
				ModelManager.instance.modelGuild.isShowRedPoint=true;
				ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,[{"guild":""},true]);//通知红点刷新
			}
			
		}

		private function guildNoticeChange():void{
			NetSocket.instance.registerHandler("change_guild_notice",new Handler(this,guildNoticeChangeCallBack));
		}

		private function guildNoticeChangeCallBack(np:NetPackage):void{
			//trace("军团消息被修改");
			if(!ModelGuild.isEditor){
				//ViewManager.instance.showTipsTxt("军团公告更新  请前往查看");
			}
			ModelGuild.isEditor=false;
		}

		private function clubAlienFight():void{//异邦来访 /开始
			NetSocket.instance.registerHandler("get_club_alien",new Handler(this,function(np:NetPackage):void{
				if(np.receiveData is Boolean){
					//trace("异邦来访信息有更改");
					NetSocket.instance.send("get_club_alien",{},Handler.create(this,function(pp:NetPackage):void{
						ModelManager.instance.modelUser.updateData(pp.receiveData);
						ModelManager.instance.modelClub.event(ModelClub.EVENT_ALIEN_MSG);
					}));
				}else{
					////trace("get_guild_alien推送了一条非boolean返回值的消息");
					//ModelManager.instance.modelUser.updateData(np.receiveData);
					//ModelManager.instance.modelGuild.event(ModelGuild.EVENT_ALIEN_MSG);	
				}
			}));					
		}

		private function clubAlienChange():void{//异邦来访  加入/退出
			NetSocket.instance.registerHandler("club_alien_join_quit",new Handler(this,function(np:NetPackage):void{
				if(np.receiveData){
					ModelManager.instance.modelClub.updateAlien(np.receiveData);
					ModelManager.instance.modelClub.event(ModelClub.EVENT_ALIEN_MSG);
					ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_BTM_BTN);
				}
			}));					
		}

		private function guildRedBagUpdate():void{//兵团里有人发红包了(有团员充值了就能收到)
			NetSocket.instance.registerHandler("get_club_redbag",new Handler(this,function(np:NetPackage):void{
				if(np.receiveData is Boolean){
					NetSocket.instance.send("get_club_redbag",{},new Handler(this,function(nnp:NetPackage):void{
						ModelManager.instance.modelUser.updateData(nnp.receiveData);
						ModelManager.instance.modelClub.event(ModelClub.EVENT_COUNTRY_REDBAG);
						ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,[{"country_club":""},true]);//通知红点刷新
					}));
				// trace("有国家红包了");
				}
			}));
		}

		/**
		 * 收到任务推送
		 */
		private function pushTask():void{
			NetSocket.instance.registerHandler("push_task", new Handler(this, function(np:NetPackage):void{
				// false && trace(">>>>>> 任务更新了！！！" + np.receiveData.user.task);
				ModelManager.instance.modelUser.updateData(np.receiveData);
			}));			
		}

		/**
		 * 收到成就推送
		 */
		private function pushEffort():void{
			NetSocket.instance.registerHandler("push_effort", new Handler(this, function(np:NetPackage):void{
				// false && trace(">>>>>> 成就更新了！！！" + np.receiveData.user.effort);
				ModelManager.instance.modelUser.updateData(np.receiveData);
			}));			
		}

		/**
		 * 收到拍卖推送
		 */
		private function pushAuction():void{
			NetSocket.instance.registerHandler("push_auction", new Handler(this, function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
			}));			
		}

		/**
		 * 收到密旨推送
		 */
		private function pushNewTask():void{
			NetSocket.instance.registerHandler("push_new_task", new Handler(this, function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ModelManager.instance.modelGame.event(EVENT_NEW_TASK_PUSH);
			}));			
		}


		private function mailGiftMsg():void{//收到系统邮件
			NetSocket.instance.registerHandler("gift_msg",new Handler(this,function(np:NetPackage):void{
				//trace(">>>>>> 收到邮件了！！！");
				ModelManager.instance.modelChat.isNewMail=true;
				ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,{"user":""});//通知红点刷新
				ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_MAIL_SYSTEM);
				if(ModelChat.mCurUid != ""){
					NetSocket.instance.send("get_msg",{},Handler.create(this,function(np:NetPackage):void{
						ModelManager.instance.modelUser.updateData(np.receiveData);
						ModelManager.instance.modelUser.setChatData(ModelManager.instance.modelUser.msg.usr);	
						ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_MAIL_CHAT_MAIN,ModelManager.instance.modelUser.msg.usr);
					}));
				}
			}));			
		}

		private function freeBuyMsg():void{
			NetSocket.instance.registerHandler("free_buy",new Handler(this,function(np:NetPackage):void{
				//trace(">>>>>>> free buy推送！！！");
				//ViewManager.instance.showTipsTxt("freeBuy推送了！！！！！！");
				NetSocket.instance.send("get_free_buy",{},new Handler(this,function(re:NetPackage):void{
					ModelManager.instance.modelUser.checkFreeBuy(re.receiveData);
					ModelManager.instance.modelUser.updateData(re.receiveData);
					
					ModelFreeBuy.instance.addData();
					//ModelManager.instance.modelUser.event(ModelUser.EVENT_ACT_TIME_OUT);
				}));
			}));
		}

		/**
		 * 产业变更推送
		 */
		private function getEstateMSG():void{
			NetSocket.instance.registerHandler("get_estate",new Handler(this,function(np:NetPackage):void{
				//ViewManager.instance.showTipsTxt("城市被攻陷  产业清理");
				ModelManager.instance.modelUser.updateData(np.receiveData);
				removeEstate(np.receiveData.city_id);
				//trace("==========城池丢失 产业清理",np.receiveData);
			}));
		}

		/*
		 ##################################    以上 服务器推送消息    ####################################
		 */




		/*
		 ##################################    登录时调用    ####################################
		 */
		public function heroCatchTimer(isFirst:Boolean=true):void{//登录时调用
			var fun:Function=function():void{
				var now:Number=ConfigServer.getServerTimer();
				var dt:Date=new Date(now);
				var m:Number=Tools.getFullHourDis();	
				Laya.timer.once(m + 1000, this, heroCatchTimer,[false]);
			};
			if(isFirst){
				ModelManager.instance.modelUser.updateData({"user":{"hero_catch":ModelManager.instance.modelUser.hero_catch}});
				fun();
			}else{
				NetSocket.instance.send("get_hero_catch",{},new Handler(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					fun();
				}));
			}
			
			
		}


		public function getCityVisit():void{//登录时调用
			if(ModelGame.unlock(null,"map_visit").stop){
				this.event(ModelVisit.EVENT_INIT_VISIT);
				return;
			}
			NetSocket.instance.send("get_city_visit",{},new Handler(this,function(re:NetPackage):void{
            	ModelOfficial.visit=re.receiveData;
				initVisit();
            //var refresh_time:Number=Tools.getTimeStamp(re.receiveData["refresh_time"]);
            //var now:Number=ConfigServer.getServerTimer();
            //delete re.receiveData["refresh_time"];
            ////trace(refresh_time+"   "+Tools.getTimeStyle(refresh_time-now)+"后调用get_city_visit");
            //Laya.timer.once(refresh_time-now,this,function():void{
            //	NetSocket.instance.send("get_city_visit",{},new Handler(this,this.reVisit));
            //	});
			}));
		}
		/**
		 * 初始化拜访数据（先调接口）
		 */
		public function initVisit():void{
			ModelVisit.visitModels={};
			for(var s:String in ModelOfficial.visit){
				if(s!="refresh_time"){
					ModelVisit.visitModels[s]=new ModelVisit(s,ModelOfficial.visit[s]);
					
				}
			}
			////trace("=========初始化visit",ModelVisit.visitModels);
			
			for(var ss:String in ModelManager.instance.modelUser.visit){
				if(!ModelVisit.visitModels.hasOwnProperty(ss)){
					var arr:Array=ModelManager.instance.modelUser.visit[ss];
					if(arr[0]!=null){
						ModelVisit.visitModels[ss]=new ModelVisit(ss,arr[1]);
					}
					//trace("=========初始化之前的visit",ModelVisit.visitModels[ss]);
				}
			}
			this.event(ModelVisit.EVENT_INIT_VISIT);
		}

		public function getFtaskData():void{//民情数据（登录调一次就行）
			//NetSocket.instance.send("get_ftask",{},Handler.create(this,function(np:NetPackage):void{
				//ModelManager.instance.modelUser.updateData(np.receiveData);
				//initFtask();
				//ViewManager.instance.showView(["ViewFTaskTest",ViewFTaskTest]);
			//}));
		}



		public function getMyguildData():void{
			if(ModelManager.instance.modelUser.guild_id){
				NetSocket.instance.send("get_my_guild",{},Handler.create(this,function(np:NetPackage):void{
					ModelManager.instance.modelGuild.setData(np.receiveData);
					var o:Object={};
					o["guild"]=np.receiveData;
					ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,[o,true]);
					ModelOfficial.buffs_check_open = true;
					ModelManager.instance.modelGame.event(ModelOfficial.EVENT_UPDATE_ORDER_ICON);
				}));
			}
			else{
				ModelOfficial.buffs_check_open = true;
				ModelManager.instance.modelGame.event(ModelOfficial.EVENT_UPDATE_ORDER_ICON);
			}
		}


		/*
		 ##################################   以上  登录时调用    ####################################
		 */


		/**
		 * 是否有部队 能 移动到 这个城市id
		 * cfgClass = 自己的子类(参考ViewAlienHeroSend),必须继承(ViewHeroSend)
		 * otherPa = 附加参数
		 * isOnly = 单选
		 * onlyHere = -1所有部队  0本城部队 1本城除外部队
		 */
		public function checkTroopToAction(id:*,cfgClass:Array = null,otherPa:* = null,isOnly:Boolean = false,onlyHere:Number = 0,power:Number = -1,fightType:Number = 3):Array{
			var cid:int = parseInt(id);
			var searchArr:Array = ModelManager.instance.modelTroopManager.getMoveCityTroop(cid,onlyHere);
			if(searchArr.length<=0 && fightType==1){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_country43"));
				return searchArr;
			}
			ViewManager.instance.showView(Tools.isNullObj(cfgClass)?ConfigClass.VIEW_HERO_SEND:cfgClass, [cid,searchArr,otherPa,isOnly,onlyHere,power,fightType]);
			return searchArr;
		}	
		/**
		 * 实名检查
		 */	
		public function checkRealNameTimeTips(gt:Number):void{
			this.gameTipsTimer = -1;//
			this.gameTimer = gt;
			this.checkGameTimeTips();
		}
		private function checkGameTimeTips():void{
			var unObj:Object = ModelGame.unlock(null,"tired_real_name");
			if(!getTieldOpen() || !unObj.visible){
				return;
			}
			var arr:Array = checkTired(this.gameTimer);
			//
			var tipNum:Number = arr[arr.length-1]*60;
			if(this.gameTimer>=tipNum && this.gameTimer>=this.gameTipsTimer){
				var isFirst:Boolean = this.gameTipsTimer<0;
				if(this.gameTimer%tipNum == 0){
					this.gameTipsTimer = (Math.ceil(this.gameTimer/tipNum)+1)*tipNum;
				}
				else{
					this.gameTipsTimer = Math.ceil(this.gameTimer/tipNum)*tipNum;
				}
				if(!isFirst){
					//派发提升消息
					this.event(EVENT_REAL_NAME_CHECK_TIRED_TIME,[this.gameTimer,arr[arr.length-2]]);
				}
			}
			Laya.timer.clear(this,this.checkGameTimeTipsTimer);
			Laya.timer.once(this.gameTipsTimerDes*Tools.oneMillis,this,this.checkGameTimeTipsTimer);
		}
		private function checkGameTimeTipsTimer():void{
			this.gameTimer+=this.gameTipsTimerDes;
			this.checkGameTimeTips();
		}
		/**
		 * 检查 异族入侵
		 */
		public function checkPKnpc():void{
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_PK_NPC,{},Handler.create(this,function(vo:NetPackage):void{
				ModelManager.instance.modelUser.updateData(vo.receiveData);
				this.checkPKnpcTimer(0);
				this.checkPKnpcCaptain(false);
				// this.checkPKnpcFightTimerStart();
			}));
			//
		}
		public function checkPKnpcTimer(firstTimer:Number = 0):void{
			Laya.timer.clear(this,this.checkPKnpc);
			if(firstTimer>0){
				Laya.timer.once(firstTimer,this,this.checkPKnpc);
				return;
			}
			var len:int = ConfigServer.pk_npc.alien_time.length;
			var nowMs:Number = ConfigServer.getServerTimer();
			var now0:Date = new Date(nowMs);
			now0.setHours(0);
			now0.setMinutes(0);
			now0.setSeconds(0);
			now0.setMilliseconds(0);
			var now0ms:Number = now0.getTime();
			var stepMs:Number = 0;
			var index:int = 0;
			for(var i:int = 0; i < len; i++)
			{
				stepMs = ConfigServer.pk_npc.alien_time[i][0]*Tools.oneHourMilli+ConfigServer.pk_npc.alien_time[i][1]*Tools.oneMinuteMilli;
				if(nowMs<(now0ms+stepMs)){
					index = i;
					break;
				}
			}
			var des:Number = (now0ms+stepMs) - nowMs;
			if(des<=0){
				stepMs = (24+ConfigServer.pk_npc.alien_time[0][0])*Tools.oneHourMilli+ConfigServer.pk_npc.alien_time[0][1]*Tools.oneMinuteMilli;
				des = (now0ms+stepMs) - nowMs;
			}	
			//异族入侵---下一次刷新间隔-
			if(des>0){
				Laya.timer.once(des+1000,this,this.checkPKnpc);
			}
		}
		/**
		 * 检查 异族入侵 战斗中的 队伍 状态
		 */
		public function checkPKnpcFightTimerStatus():void{
			var alienAll:Object = ModelClimb.alien_my();
			var pkmd:ModelClimb;
			var num:Number = 0;
			for(var key:String in alienAll)
			{
				if(!ModelClimb.pk_npc_models.hasOwnProperty(key)){
					ModelClimb.pk_npc_models[key] = pkmd = new ModelClimb();
					pkmd.pk_npc_setData(key);
					pkmd.pk_npc_init();
					num+=1;
				}
			}
			//
			if(ModelClimb.captain_my().length>0){
				if(ModelClimb.captain_curr().length>0){
					if(ModelClimb.captain_curr_timer()>0){
						if(!ModelClimb.pk_npc_models.hasOwnProperty("captain")){
							ModelClimb.pk_npc_models["captain"] = pkmd = new ModelClimb();
							pkmd.pk_npc_setData("captain");
							pkmd.pk_npc_init();
							num+=1;
						}
					}
				}
			}
			// if(!this.isInside){
				// if(num>0){
					ModelManager.instance.modelGame.event(EVENT_PK_NPC_CHECK_MODEL,[ModelClimb.pk_npc_models,"captain"]);
					ModelTask.npcInfo_check();
				// }
			// }
		}
		/**
		 * 检查名将来袭
		 */
		public function checkPKnpcCaptain(sendNet:Boolean):void{
			Laya.timer.clear(this,this.checkPKnpcCaptain);
			if(sendNet){
				var _this:* = this;
				NetSocket.instance.send(NetMethodCfg.WS_SR_GET_PK_NPC,{},Handler.create(_this,function(vo:NetPackage):void{
					ModelManager.instance.modelUser.updateData(vo.receiveData);
					//
					_this.checkPKnpcCaptain(false);
				}));
			}
			else{
				var currEndTimer:Number = ModelClimb.captain_curr_timer();
				if(currEndTimer>0){
					var des:Number = currEndTimer - ConfigServer.getServerTimer();
					var desMin:Number = 20000;
					if(des>=0 && des>desMin){
						desMin = des;
					}
					Laya.timer.once(desMin,this,this.checkPKnpcCaptain,[true]);
				}
			}
		}
		public function getWorldLv():void
		{
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_WORLD_LV,{},Handler.create(this,function(re:NetPackage):void{
				ModelManager.instance.modelUser.updateData({user:{world_lv:re.receiveData}});
				ModelManager.instance.modelGame.event(ModelGame.EVENT_NEW_DAY_COM_ON);
			}));
		}
		/**
		 * 功能锁
		 */
		public static function unlock(btn:*,key:String,tips:Boolean = false):Object{
			// #[是否显示-1==完全不显示0==根据显示等级1==完全显示,显示等级0~n,是否灰色0~1,等级限制0~n],建筑类型,文字说明,[pf组]
			var oo:Object=ConfigServer.system_simple;
			var a:Array=ConfigServer.system_simple.func_open[key];
			if(a==null){
				trace("error  ",key);
				return {};
			}
			var bid:String = a[4];
			var lv:int= Tools.isNullString(bid)?1:ModelManager.instance.modelInside.getBuildingModel(bid).lv;
			var o:Object={};
			o["visible"] = (a[0]==1) ? true: ((a[0]<0) ? false : (lv >= a[1]));
			o["gray"]    = (a[2]==0) ? true : (lv<a[3]);
			o["stop"]    = (!o["visible"] || o["gray"]) ? true : false;//隐藏或置灰为true
			
			var _pf:Array = a[6];
			if(_pf && _pf.indexOf(ModelManager.instance.modelUser.pf)!=-1){
				o["visible"] = (a[0]==1) ? false : ((a[0]==-1) ? true : false);
				o["stop"]    = (!o["visible"] || o["gray"]) ? true : false;
				return o;
			}

			var s:String = "";
			if(o.gray){
				if(a[2]==0) s=Tools.getMsgById(a[5]+"");
				else s=Tools.isNullString(bid)?"":Tools.getMsgById("190008",[ModelManager.instance.modelInside.getBuildingModel(bid).getName(),a[3]]); 
			}	
			o["text"] = s;
			//
			if(btn){
				btn.gray=o.gray;
				btn.visible=o.visible;
				btn.off(Event.CLICK,ModelManager.instance.modelGame,ModelManager.instance.modelGame.click_unlock);
				if(btn.gray && s){
					btn.on(Event.CLICK,ModelManager.instance.modelGame,ModelManager.instance.modelGame.click_unlock,[s]);
				}
			}		
			//
			if(tips && o.gray && s != ""){
				ModelManager.instance.modelGame.click_unlock(s);
			}
			return o;
		}
		public function click_unlock(str:String):void
		{
			ViewManager.instance.showTipsTxt(str);
		}
		/**
		 * 红点,显示,删除
		 * @param spt red容器
		 * @param visible 是否显示
		 * @param xy 备用位置坐标[x,y];
		 */
		public static function redCheckOnce(spt:*,visible:Boolean = false,xy:Array = null):Boolean{
			var img:*;
			if(spt && spt.numChildren>0){
				img = spt.getChildByName("_red_check_img_");
			}
			if(visible && spt){
				if(!img){
					img = new Image(AssetsManager.getAssetsUI("bg_icon_03.png"));
					img.name = "_red_check_img_";
					spt.addChild(img);
					img.x = xy && xy[0] ? xy[0] : (spt.width-img.width);
					img.y = xy && xy[1] ?xy[1] : 0;
				}
			}
			else{
				if(img){
					(img as Image).removeSelf();
				}
			}
			return visible;
		}
		public static function getTieldOpen():Boolean{
			var b:Boolean = false;
			if(!Tools.isNullString(ModelManager.instance.modelUser.mUserCode)){
				//230000198311080916
				var year:Number = parseInt(ModelManager.instance.modelUser.mUserCode.substr(6,4));
				var mt:Number = parseInt(ModelManager.instance.modelUser.mUserCode.substr(10,2));
				var dt:Number = parseInt(ModelManager.instance.modelUser.mUserCode.substr(12,2));
				//
				var now:Date = new Date(ConfigServer.getServerTimer());
				var ny:Number = now.getFullYear();
				var nm:Number = now.getMonth()+1;
				var nd:Number = now.getDate();
				//
				var yd:Number = ny - year;
				//
				if(yd>18){

				}
				else if(yd == 18){
					if(mt>nm){

					}
					else if(mt == nm){
						if(dt>=nd){

						}
						else{
							b = true;
						}
					}
					else{
						b = true;
					}
				}
				else{
					b = true;
				}
				// //trace(year,mt,dt,ny,nm,nd);
			}
			else{
				b = true;
			}
			return b;
		}
		/**
		 * 快速 获取 疲劳 时间对应 配置
		 */
		public static function getTiredCfg():Array{
			if(getTieldOpen()){
				return checkTired(ModelManager.instance.modelGame.gameTimer);
			}
			return ConfigServer.system_simple.tired_point[0];
		}
		/**
		 * 快速 获取 当前收益率
		 */
		public static function getCurrProfitRate():Number{
			return getTiredCfg()[0];
		}
		/**
		 * 检测疲劳,时间,对应,配置
		 */
		public static function checkTired(cd:Number):Array{
			var cfg:Array = ConfigServer.system_simple.tired_point;
			var len:int = cfg.length;
			var gp:Array;
			var max:Number = 0;
			var min:Number = 0;
			for(var i:int = 0; i < len-1; i++)
			{
				gp = cfg[i];
				max = gp[2]*60;
				if(cd<max){
					break;
				}
			}
			return cfg[i];
		}



		/*####################以下  大地图上的点击方法调用########################*/

		/**
		 * 点击民情
		 */
		public static function clickFtask(cid:String):void{
			var c_city:Object=ConfigServer.city;
			var c_ftask:Object=ConfigServer.ftask;
			var u_ftask:Object=ModelManager.instance.modelUser.ftask;
			
			if(!c_city[cid].office_lv){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("msg_ModelGame_0"));
				return;
			}

			var olv:Number=c_city[cid].office_lv[ModelUser.getCountryID()];
			if(ModelManager.instance.modelUser.office<olv){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("msg_ModelGame_1")+ModelOffice.getOfficeName(olv)+Tools.getMsgById("msg_ModelGame_2"));
				return;
			}
			
			var tid:String=c_city[cid].pctask_id[ModelUser.getCountryID()][u_ftask[cid][0]];
			var is_get:Boolean=u_ftask[cid][1]==1;
			var is_finish:Boolean=u_ftask[cid][2]==1;
			if(is_get && !is_finish){
				ViewManager.instance.showView(ConfigClass.VIEW_FTASK_MAIN,cid);
			}else{
				var n:Number=(!is_get)?0:(is_finish)?1:0;
				var talk_arr:Array=["hero701",
								c_ftask.people_task[tid].pc_talk[0],
								c_ftask.people_task[tid].pc_talk[1][n]];
				ViewManager.instance.showHeroTalk([talk_arr],function():void{
					ViewManager.instance.showView(ConfigClass.VIEW_FTASK_MAIN,cid);
				});
			}

		}


		/**
		 * 点击地图上的英雄切磋
		 */
		public function clickHeroCatch(cid:String, v:Vector2D):void {
			var arr:Array=ModelManager.instance.modelUser.hero_catch.hero_list;
			var n:int=-1;
			for(var i:int=0;i<arr.length;i++){
				if(cid==arr[i][1]){
					n=i;
					break;
				}
			}
			if(n==-1){
				return;
			}
			ViewManager.instance.showView(ConfigClass.VIEW_HERO_CATCH,[n,v]);
		}



		/**
		 * 点击拜访中的英雄
		 */
		public function clickVisitHero(cid:String):void{
			var visitModel:ModelVisit=ModelVisit.visitModels[cid];
			var hid:String=visitModel.hid;
			var event_id:String=visitModel.event_id;
			if(event_id!=""){
				ViewManager.instance.showView(ConfigClass.VIEW_EVENT_TALK,[event_id,1,{"cid":visitModel.city_id}]);
			}else if(visitModel.isFinish()){
				
			}else{
				ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_HERO_INFO,[1,visitModel.city_id,null]);
			}
		}

		/**
		 * 点击城市建造的英雄
		 */
		public function clickCityBuildHero(hid:String):void{
			var o:Object={};
			var event_id:String=ModelHero.getEventById(2,hid);
			var is_finish:Boolean=ModelManager.instance.modelUser.isCityBuildFinish(o);
			var city_id:String="";
			var bid:String="";
			if(event_id!=""){
				ViewManager.instance.showView(ConfigClass.VIEW_EVENT_TALK,[event_id,2,{"cid":city_id,"bid":bid}]);
			}else if(is_finish){

			}else{
				ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_HERO_INFO,[2,city_id,{"cid":city_id,"bid":bid}]);
			}
		}



		/**
		 * 点击产业收割
		 */
		public function clickEstateHarvest():void{
			var arr:Array=ModelManager.instance.modelUser.getEstateHarverst();
			if(arr.length!=0){
				NetSocket.instance.send("estate_harvest",{},new Handler(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				}));
			}
		}

		/*####################以上  大地图上的点击方法调用########################*/
		


		public function clearHeroIcon():void
		{
			AssetsManager.mHeroBigIconAssets.clearAll();
			AssetsManager.mHeroSmIconAssets.clearAll();
		}

		public function checkBaseBuildUnlockFunc(bmd:ModelBuiding,index:int):void
		{
			if(bmd.isBase()){
				var arr:Array = bmd.unlockFunc(bmd.lv);
				var award:Boolean = true;
				if(arr){
					if(index<arr.length){
						award = false;
						ViewManager.instance.showViewEffect(BuildingFuncOpen.getEffect(bmd,index));
					}
				}
				var ab:Boolean = false;
				for(var key:String in ConfigServer.system_simple.building_lvup_reward)
				{
					if(award && bmd.lv == Number(key) && ConfigServer.system_simple.building_lvup_reward[key].hasOwnProperty("item088")){
						ab = true;
						ViewManager.instance.showView(ConfigClass.VIEW_HERO_CHOOSE);
						return;
					}
				}
				if(award && !ab){
					ModelGame.checkBaseBuildUpgradeGuide(bmd);
				}
			}
		}
		public static function checkBaseBuildUpgradeGuide(bmd:ModelBuiding):void{
			var reward:Object = ConfigServer.ploy['levelup']['reward'][bmd.lv];
            reward && GotoManager.boundForPanel(GotoManager.VIEW_BASE_LEVEL_UP, String(bmd.lv));
			reward || ModelGuide.executeGuide();
		}
		/*####################封地建筑等级增加次数的方法########################*/
		
		/**
		 * 获得商店购买次数 treasuer_shop
		 */
		public function getShopTimes(shopId:String,bId:String,blv:Number):Number{
			var o:Object=ConfigServer.shop;
			if(o.hasOwnProperty(shopId)){
				var oo:Object=o[shopId];
				if(oo.all_limit!=-1){
					if(oo.add_limit && bId==oo.add_limit[0]){
							return oo.all_limit+blv * oo.add_limit[1];
					}
				}
			}
			return oo.all_limit;
		}
		
		///显示小loading动画
		public static var isShowLoadingAni:Boolean = true;
		public static var sLockDic:Object = {};
		/**
		 * 屏幕锁屏
		 * @param key = 唯一标示
		 * @param lock = 锁/解锁
		 * @param forceUnlock = 强制解锁
		 */
		public static function stageLockOrUnlock(key:*,lock:Boolean,forceUnlock:Boolean = false):void{
			if(lock){
				ModelGame.sLockDic[key] = unlock;
				
			}
			else{
				if(ModelGame.sLockDic[key]){
					delete ModelGame.sLockDic[key];
				}
			}
			if(forceUnlock){
				ModelGame.sLockDic = {};
			}
			ModelManager.instance.modelGame.event(ModelGame.EVENT_STAGE_LOCK_UNLOCK,ModelGame.sLockDic);
		}

		/**
		 * 通过名称打开第一封邮件
		 */
		public function showMailByTitle(_title:String):void{
			NetSocket.instance.send("get_msg",{},Handler.create(this,function(np:NetPackage):void{
				var sysData:Array=[];
				var userData:Object=np.receiveData.user.msg;
				var a:Array=userData.sys;
				//var index:int=-1;
				for(var i:int=0;i<a.length;i++){
					var o:Object={};
					var d:Array=a[i];
					o["title"]=d[0];
					o["info"]=d[1];
					o["gift"]=d[2];
					o["time"]=d[3];
					o["paixu"]=Tools.getTimeStamp(d[3]);
					o["index"]=i;
					o["isOpen"]=d[4];
					sysData.push(o);
				}
				sysData.sort(MathUtil.sortByKey("paixu",true,false));
				for(var j:int=0;j<sysData.length;j++){
					if(sysData[j] && sysData[j].isOpen==0  && sysData[j].title==_title){
						ViewManager.instance.showView(ConfigClass.VIEW_MAIL_CONTENT,sysData[j]);
						//index=j;
						break;
					}
				}
				//if(index!=-1){
					//NetSocket.instance.send("accept_sys_gift_msg",{"msg_index":index},Handler.create(this,function(np:NetPackage):void{
					//	ModelManager.instance.modelUser.updateData(np.receiveData);
					//	ViewManager.instance.showRewardPanel(np.receiveData.gift_dict_list);
					//	ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_MAIL_SYSTEM);
					//}));
				//}
				
			}));
		}

		public static function toPay(pids:String):void{
			var payObj:Object;
			var payCfg:Object = ConfigServer.pay_config_pf[pids];
			var envN:Number = ConfigServer.system_simple.wx_pay_test?ConfigServer.system_simple.wx_pay_test:0;
			var ios_url:String = "";
			payObj = {
						pid:pids,
						zone:ModelManager.instance.modelUser.zone,
						uid:ModelManager.instance.modelUser.mUID,
						pf:ConfigApp.pf,
						buyQuantity:payCfg[0]*10,
						env:envN,
						cfg:payCfg,
						url:ios_url,
						channel:ConfigApp.pf_channel
					};	
			//	
			var isSelfPay:Boolean = ConfigApp.payIsSelf();
			//
			if(isSelfPay){
				ViewManager.instance.showView(ConfigClass.VIEW_PAY_SELF,payObj);
			}
			else{
				Platform.pay(payObj,false);
			}
		}
	}

}