package sg.view.menu
{
	import sg.view.ViewPanel;
	import ui.menu.userUI;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.manager.EffectManager;
	import laya.display.Animation;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.view.map.ViewCityBuildMain;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.model.ModelTask;
	import sg.model.ModelClimb;
	import sg.model.ModelOfficial;
	import laya.ui.Image;
	import sg.manager.AssetsManager;
	import sg.boundFor.GotoManager;
	import sg.net.NetMethodCfg;
	import sg.model.ModelGame;
	import sg.model.ModelAlert;
	import sg.guide.model.ModelGuide;
	import sg.scene.constant.EventConstant;
	import sg.map.model.entitys.EntityCity;
	import sg.view.country.ViewOrderTips;
	import sg.model.ModelEstate;
	import sg.model.ModelCountryPvp;
	import laya.utils.Tween;
	import sg.model.ModelBlessHero;
	import sg.cfg.ConfigApp;
	import sg.model.ModelNewTask;

	/**
	 * ...
	 * @author
	 */
	public class ViewMenuUser extends userUI{
		
		public var creditRed:Boolean=false;
		private var ani:Animation;
		public function ViewMenuUser(){

			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,this.refresh,[false]);
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE_POWER,this,this.refresh_power);
			ModelManager.instance.modelGame.on(ModelOfficial.EVENT_UPDATE_ORDER_ICON,this,this.checkOrders);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_FIGHT_LOG_CHANGE,this,this.checkRed,[1]);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_CHECK_NPC_INFO,this,this.checkNpcInfo);
			ModelManager.instance.modelGame.on(ModelBlessHero.UPDATE_DATA,this,this.checkNpcInfo);
			//ModelManager.instance.modelGame.on(ModelGame.EVENT_CREDIT_CHANGE,this,this.checkRed,[2]);
			ModelManager.instance.modelGame.on(ModelNewTask.EVENT_NEW_TASK_UPDATE,this,this.checkRed,[3]);
			//
			this.mouseThrough = true;
			this.boxTop.mouseThrough = true;

			this.btnNpcInfo.visible = false;
			//
			this.b1.on(Event.CLICK,this,this.click,[1]);
			this.btn_zong.on(Event.CLICK,this,this.click,[2]);
			this.btn_credit.on(Event.CLICK,this,this.click,[3]);
			this.btnNpcInfo.on(Event.CLICK,this,this.click,[4]);
			this.btn_log.on(Event.CLICK,this,this.click,[5]);
			//
			this.heroIcon.on(Event.CLICK, this, click, [6]);
			this.btnCountry.on(Event.CLICK, this, click, [7]);
			this.btn_estate.on(Event.CLICK, this, click, [8]);		

			this.btnNewTask.on(Event.CLICK,this, click ,[9]);
			//
			if(!ConfigApp.isPC){
				var tempAni:Animation = EffectManager.loadAnimation("world_light");//这是一道光
				tempAni.x = this.stage.width*0.5;
				this.addChildAt(tempAni, 0);
			}
			//
			this.refresh(true);
			//
			this.iZong.text = Tools.getMsgById("_lht17");
			this.iCredit.text = Tools.getMsgById("_lht18");
			//this.iLog.text = Tools.getMsgById("_lht19");

			ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_HIDE_GOLD_ESTATE,this,eventCallBack,[false]);
			ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_SHOW_GOLD_ESTATE,this,eventCallBack,[true]);
			eventCallBack(true);

			v_box.refreshBox();
			
			if(ConfigApp.isPC){
				v_box.right = 150;
				btnCountry.right = 175;
				btnNpcInfo.right = 243;
				btnNewTask.right = 311;
			}

			checkRed(3);//朝廷密旨红点
		}

		//只有登录和襄阳战结束时调用一次
		private function eventCallBack(b:Boolean):void{
			var arr:Array=ModelOfficial.xyz_estate_add;
			var bb:Boolean=false;
			if(arr){
				for(var i:int=0;i<arr.length;i++){
					var o:Object = ModelOfficial.cities[arr[i][0]];
					if(o && o.country==ModelManager.instance.modelUser.country){
						bb=true;
						break;
					}
				}
			}
			if(b && bb){
				this.imgCoin.visible=this.imgCoin0.visible=true;
				coinTween(false);
			}
			else{
				this.imgCoin.visible=this.imgCoin0.visible=false;
			}

		}

		private function coinTween(b:Boolean):void{
			var n:Number=b?0.5:1;
			Tween.to(this.imgCoin,{alpha:n},800,null,new Handler(this,function():void{
				coinTween(!b);
			}));
		}

		private function checkRed(type:Number):void{
			switch(type)
			{
				case 1:
					ModelGame.redCheckOnce(this.btn_log,true,[this.btn_log.width-20,0]);
					break;
				case 2:
					ModelGame.redCheckOnce(this.btn_credit,creditRed,[this.btn_credit.width-20,0]);
					if(ani==null){
						ani=EffectManager.loadAnimation("glow_credit");
					}
					ani.x=this.BoxAin.width/2;
					ani.y=this.BoxAin.height/2;
					this.BoxAin.addChild(ani);
					ani.visible=creditRed;
					break;	

				case 3:
					if(this.btnNewTask.visible && !this.btnNewTask.gray){
						ModelGame.redCheckOnce(this.btnNewTask, ModelManager.instance.modelNewTask.redPoint(),[this.btnNewTask.width-20,0]);
					}
					break;		
				default:
					break;
			}
		}


		/**
		 * 斥候情报
		 */
		public function checkNpcInfo():void
		{
			//ModelGame.redCheckOnce(this.btnNpcInfo,ModelTask.npcInfo_checkByTimer());
			ModelTask.checkBlessHero();
			var b1:Boolean=ModelTask.fire_num>0;//点火城市个数
			var b2:Boolean=ModelTask.thief_num>0;//黄巾军
			var b3:Boolean=ModelTask.buffs_num>0;//各种令的个数
			var b4:Boolean=ModelTask.country_army_num>0;//护国军数
			var b5:Boolean=ModelTask.bless_hero_num>0;//福将
			ModelGame.redCheckOnce(this.btnNpcInfo,b1 || b2 || b3 || b4 || b5);
			
			//
			//this.btnNpcInfo.visible = (ModelTask.npcInfo_pk_arr.length+ModelTask.npcInfo_thief_arr.length)>0 && !ModelGuide.forceGuide();
			this.btnNpcInfo.visible = true;// ModelTask.npcInfo_thief_arr.length>0 && !ModelGuide.forceGuide();
			if(this.btnNpcInfo.visible){
				this.btnNpcInfo.visible = !ModelManager.instance.modelGame.isInside;
			}
			var tt:Number = 15;
			tt = ConfigServer.system_simple.npc_info_time?ConfigServer.system_simple.npc_info_time:tt;
			//
			this.timer.clear(this,this.checkNpcInfo);
			this.timer.once(tt*Tools.oneMillis,this,this.checkNpcInfo);
		}
		/**
		 * 各种令
		 */
		public function checkOrders():void{
			var sb:Boolean = ModelOfficial.checkOrderBuffs();
			if(sb){
				this.boxOrder.destroyChildren();
				var item:ItemOrder;
				var i:Number = 0;
				for(var key:String in ModelOfficial.buffs_dic){
					item = new ItemOrder(key);
					item.x = i*52;
					this.boxOrder.addChild(item);
					i+=1;
				}
			}
			var tt:Number = 15;
			tt = ConfigServer.system_simple.order_check_time ? ConfigServer.system_simple.order_check_time : tt;		
			this.timer.clear(this,this.checkOrders);
			this.timer.once(tt*Tools.oneMillis,this,this.checkOrders);

			// 检查天下大势红点
			ModelGame.redCheckOnce(this.btnCountry, ModelOfficial.checkInvadeWill());
		}



		override public function onChange(type:* = null):void{
			if(type == 1){
				this.visible = true;
			}
			else if(type == 2){
				this.visible = true;
			}
			else if(type == 3){
				this.visible = false;
			}
			this.btn_zong.visible = ModelManager.instance.modelGame.isInside;
			this.boxRight.visible = this.boxMap.visible = !ModelManager.instance.modelGame.isInside;
			//this.btn_log.visible = this.bgCredit.visible = this.testMap.visible = this.btn_credit.visible = !ModelManager.instance.modelGame.isInside;
			if(this.btnNpcInfo.visible){
				this.btnNpcInfo.visible = !ModelManager.instance.modelGame.isInside;
			}
			this.btnCountry.visible = !ModelManager.instance.modelGame.isInside;
			v_box.visible = !ModelManager.instance.modelGame.isInside;

			this.btnNewTask.visible = !ModelManager.instance.modelGame.isInside &&  ModelManager.instance.modelNewTask.isOpen();
			if(this.btnNewTask.visible){
				ModelGame.unlock(this.btnNewTask,"new_task");
			}

			// 战功按钮上的特效
			var user:ModelUser = ModelManager.instance.modelUser;
			var glowName:String = 'glow_sale';
			var anim:Animation = btn_credit.getChildByName(glowName) as Animation;
			if (user.getLv() >= 3 && user.credit_lv === 0 && !user.isMerge && !ModelGuide.checkGuideDataWithKey('credit_guide')) {
				if (!anim) {
					anim = EffectManager.loadAnimation(glowName);
					anim.scale(0.39, 0.35);
					anim.pos(btn_credit.width * 0.5, btn_credit.height * 0.5);
					btn_credit.addChild(anim);
					anim.name = glowName;
				}
			}
			else if (anim) {
				btn_credit.removeChild(anim);
			}
		}
		public function refresh(power:Boolean):void{
			this.tName.text    = ModelManager.instance.modelUser.uname;
			Tools.textFitFontSize(this.tName);
			this.country.setCountryFlag(ModelUser.getCountryID());//.setData("",ModelUser.country_name[ModelUser.getCountryID()]);
			this.tOffice.text  = ModelManager.instance.modelUser.officeModel.getName();
			this.tOffice.width = this.tOffice.displayWidth;
			if(power) this.refresh_power(ModelManager.instance.modelUser.getPower());
			
			this.tLv.text     = ModelManager.instance.modelUser.getLv()+"";
			var arr:Array     = ModelManager.instance.modelUser.getCreditArr();
			creditRed         = ModelAlert.red_credit_gift();
			this.tCredit.text = arr[0]==-1 ? Tools.getMsgById("_public153") : arr[1]+"";

			var n:Number      = (arr[1]-arr[0])/(arr[2]-arr[0]);
			this.creditPan.height = creditRed || arr[0]==-1 ? 40 : 30 * ( n > 1 ? 1 : n) + 5;
			checkRed(2);
			this.heroIcon.setHeroIcon(ModelManager.instance.modelUser.getHead(1));
			// this.btn_estate.visible = !ModelGame.unlock(null,"estate").stop;
			this.testate.text = Tools.getMsgById("_lht67",[ModelManager.instance.modelUser.estate.length,ModelEstate.getTotalVacancy()]);
			//v_box.refreshBox();
		}
		private function refresh_power(power:Number):void
		{
			this.comPower.setNum(power);
			//this.tPower.text = power+"";
		}
		private function click(type:int):void{
			var _this:* = this;
			switch(type)
			{
				case 1:
					GotoManager.boundForPanel(GotoManager.VIEW_OFFICE_MAIN,"",null,{lock:true});
					break;
				case 2:
					ViewManager.instance.showView(ConfigClass.VIEW_TIMER);
					break;	
				case 3:
					ViewManager.instance.showView(ConfigClass.VIEW_CREDIT_MAIN);
					break;		
				case 4:
					ViewManager.instance.showView(ConfigClass.VIEW_NPC_INFO);
					break;	
				case 5:
					NetSocket.instance.send(NetMethodCfg.WS_SR_GET_FIGHT_LOG,{},Handler.create(_this,function(re:NetPackage):void{
						ModelGame.redCheckOnce(_this.btn_log,false);
						ViewManager.instance.showView(ConfigClass.VIEW_FIGHT_LOG,re.receiveData);
					}));
					break;	
				case 6:
					ModelManager.instance.modelUser.selectUserInfo(ModelManager.instance.modelUser.mUID);
						break;	
				case 7:
					ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_INVADE_MAIN);
					break;	
				case 8:
					GotoManager.boundForPanel(GotoManager.VIEW_ESTATE_MAIN,"",null,{lock:true});
					break;	
				case 9:
					if(ModelGame.unlock(null,"new_task").stop){
						return;
					}
					ViewManager.instance.showView(ConfigClass.VIEW_NEW_TASK_MAIN);
					break;																		 	
				default:
					break;
			}
		}
	}

}