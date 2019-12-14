package sg.view.menu
{
	import laya.events.Event;
	import sg.boundFor.GotoManager;
	import sg.cfg.ConfigClass;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelGame;
	import sg.model.ModelOfficial;
	import sg.model.ModelUser;
	import sg.task.view.ViewTaskStory;
	import sg.utils.Tools;

	import ui.menu.bottomUI;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import sg.view.chat.ViewChatMain;
	import sg.manager.LoadeManager;
	import sg.model.ModelChat;
	import sg.model.ModelAlert;
	import laya.display.Sprite;
	import sg.manager.FilterManager;
	import sg.view.season.ViewSeasonPanel;
	import laya.utils.Ease;
	import sg.model.ModelHero;
	import sg.cfg.ConfigServer;
	import sg.cfg.ConfigApp;
	import laya.ui.Box;
	import laya.maths.Rectangle;

	
	/**
	 * 主界面，下部按钮s
	 * @author
	 */
	public class ViewMenuBottom extends bottomUI
	{

		private var arr_season:Array = ["icon_season1.png","icon_season2.png","icon_season3.png","icon_season4.png"];
		public function ViewMenuBottom()
		{
			//
			this.mouseThrough = true;
			//
			this.btn_hero.on(Event.CLICK, this, this.onClick, [this.btn_hero]);
			this.btn_shop.on(Event.CLICK, this, this.onClick, [this.btn_shop]);
			this.btn_bag.on(Event.CLICK, this, this.onClick, [this.btn_bag]);
			this.btn_team.on(Event.CLICK, this, this.onClick, [this.btn_team]);
			this.btn_fight.on(Event.CLICK, this, this.onClick, [this.btn_fight]);
			this.btn_more.on(Event.CLICK, this, this.onClick, [this.btn_more]);
			this.btn_mng.on(Event.CLICK,this,this.onClick,[this.btn_mng]);
			//
			this.btn_map1.on(Event.CLICK, this, this.onClick, [this.btn_map1]);
			this.btn_map2.on(Event.CLICK, this, this.onClick, [this.btn_map2]);
			//
			this.btn_mayor.on(Event.CLICK, this, this.onClick, [this.btn_mayor]);
			this.btn_train.on(Event.CLICK, this, this.onClick, [this.btn_train]);
			//
			this.btn_task.on(Event.CLICK, this, this.onClick, [this.btn_task]);

			this.btn_alien.on(Event.CLICK, this, this.onClick, [this.btn_alien]);
			this.btn_chat.on(Event.CLICK, this, this.onClick, [this.btn_chat]);

			this.btn_season.on(Event.CLICK, this, this.onClick, [this.btn_season]);
			this.btn_build.on(Event.CLICK, this, this.onClick, [this.btn_build]);

			this.btn_train.visible = this.btn_mayor.visible = false;
			this.chat_btn.visible=this.chat_country.visible=this.chat_info.visible=this.chat_name.visible=false;
			//
			ModelManager.instance.modelGame.on(ModelGame.EVENT_TASK_WORK_CONQUEST_OPEN_MAP,this,this.checkMapShow);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_TASK_WORK_CONQUEST_OPEN_INSIDE,this,this.checkInsideShow);
			//
			ModelManager.instance.modelUser.on(ModelUser.EVENT_UPDATE_BTM_BTN,this,this.checkGuildAlien);			
			//
			ModelManager.instance.modelChat.on(ModelChat.EVENT_UPDATE_BOTTOM,this,setComchat);
			//
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,this.checkRed);

			ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_UPDATE_IMPEACH,this,this.checkRedImpeach);
			//
			this.iMayor.text = Tools.getMsgById("_lht20");
			this.iTrain.text = Tools.getMsgById("_public173");
			this.iTask.text = Tools.getMsgById("add_task");
			this.iBuild.text = Tools.getMsgById("_public91");
			//this.iAlien.text = Tools.getMsgById("add_guild5");
			this.iMore.text = Tools.getMsgById("_lht21");
			this.mapName.text = Tools.getMsgById("_public117");//"大地图" : "封地";
			this.iMap2.text = Tools.getMsgById("_public116");
			this.heroLabel.text = Tools.getMsgById("_hero1");		
			this.fightLabel.text = Tools.getMsgById("_climb50");		
			this.bagLabel.text = Tools.getMsgById("_bag_text01");		
			this.shopLabel.text = Tools.getMsgById("_shop_text01");		
			this.guildLabel.text = Tools.getMsgById("_country16");		
			this.heromagLabel.text = Tools.getMsgById("_estate_text12");		

			setComchat();
			if(ConfigApp.isPC){
				var box1:Box = this.getChildByName("box_bottom") as Box;
				box1.mouseThrough = true;
				box1.left = box1.right = 0;
				this.btn_hero.right = 140 + (this.btn_hero.width+30)*0;
				this.btn_fight.right = 140 + (this.btn_hero.width+30)*1;
				this.btn_bag.right = 140 + (this.btn_hero.width+30)*2;
				this.btn_shop.right = 140 + (this.btn_hero.width+30)*3;
				this.btn_team.right = 140 + (this.btn_hero.width+30)*4;
				this.btn_more.right = 140 + (this.btn_hero.width+30)*5;

				this.btn_more.width = this.btn_hero.width;
				this.btn_more.height = this.btn_hero.height;
				this.iMore.centerY = 30;				

				this.btn_hero.bottom = this.btn_fight.bottom = this.btn_bag.bottom = this.btn_shop.bottom = this.btn_team.bottom = this.btn_more.bottom = 6;	
				
				this.btn_season.bottom = 120;
				this.btn_season.right = 10;

				this.btn_map1.right = 10;
				this.btn_map2.right = 10;

				this.bottom_bg.visible = false;
				this.btn_chat.visible = false;
				this.chat_bg.visible = false;

				var box2:Box = this.getChildByName("box_task") as Box;
				box2.centerX = 0;
				box2.bottom = 20;
			}
		}

		override public function set x(value:Number):void {
			super.x = 0;
		}
		
		override public function init():void
		{
			this.checkStatusBtnMap(false);
			this.checkOfficerOrder();
			this.checkGuildAlien();
			this.checkTask();
			this.checkRedImpeach();
			this.checkRed({},true);
			this.checkRed({"country_club":""},true);
			EffectManager.tweenLoop(this.imgAlien, {scaleX:1.1, scaleY:1.1}, 1000, Ease.sineInOut, null, 50, -1);
		}

		private function checkRedImpeach():void{
			ModelGame.redCheckOnce(this.btn_team,ModelAlert.red_country_all());
        }

		private function checkRed(re:Object,focre:Boolean = false):void{
			if(Tools.isNullObj(re)){return;}
			var userRe:Object = {};
			if(re.hasOwnProperty("user")){
				userRe = re.user;
			}	
			else{
				if(!focre){
					return;
				}
			}		
			var a:Number = new Date().getTime();
			if(focre || userRe.hasOwnProperty("equip") || userRe.hasOwnProperty("skill") || userRe.hasOwnProperty("hero") || userRe.hasOwnProperty("star") || userRe.hasOwnProperty("prop")){
				ModelGame.redCheckOnce(this.btn_hero,ModelAlert.red_hero_all());
			}

			if(focre || userRe.hasOwnProperty("prop")){
				ModelGame.redCheckOnce(this.btn_bag,ModelAlert.red_bag_check());
			}

			ModelGame.redCheckOnce(this.btn_team,ModelAlert.red_country_all());
			ModelGame.redCheckOnce(this.btn_more,ModelAlert.red_more_all());
			if(re.hasOwnProperty("country_club")){
				//ModelGame.redCheckOnce(this.btn_team,ModelAlert.red_country_all());
			}
			else{
				//ModelGame.redCheckOnce(this.btn_more,ModelAlert.red_more_all());
			}

			if(focre || userRe.hasOwnProperty("gtask") || userRe.hasOwnProperty("task")){
				ModelGame.redCheckOnce(this.btn_task,ModelAlert.red_task_all());
			}

			if(focre || userRe.hasOwnProperty("pve_records") || userRe.hasOwnProperty("climb_records") || userRe.hasOwnProperty("pk_records")){
				ModelGame.redCheckOnce(this.btn_fight,ModelAlert.red_pve_pvp_all());
			}
			if(focre || userRe.hasOwnProperty("visit") || userRe.hasOwnProperty("estate") || userRe.hasOwnProperty("city_build")){
				ModelGame.redCheckOnce(this.btn_mng,ModelAlert.red_hero_task());
			}
			if(focre || userRe.hasOwnProperty("year_credit") || userRe.hasOwnProperty("credit_get_gifts")){
				//ModelGame.redCheckOnce(this.btn_credit,ModelAlert.red_credit_gift());
				//ModelManager.instance.modelGame.event(ModelGame.EVENT_CREDIT_CHANGE);
			}
			if(focre || userRe.hasOwnProperty("home")){
				onChange();
			}
			//Trace.log("---检查red耗时 --",userRe,new Date().getTime() - a);
		}
		public function checkTask():void{
			new ViewTaskStory(this.title, this.taskPanel, this.btn_reward, this.btn_hintReward, this.content);
		}
		override public function onChange(type:* = null):void
		{
			if (type == 1)
			{
				this.visible = true;
			}
			else if (type == 2)
			{
				this.visible = true;
			}
			else if (type == 3)
			{
				this.visible = false;
			}
			ModelGame.unlock(this.btn_task, "task");
			ModelGame.unlock(this.btn_more, "more");
			//ModelGame.unlock(this.btn_team, "guild_main");
			ModelGame.unlock(this.btn_shop, "shop");
			ModelGame.unlock(this.btn_team, "more_country");
		}
		private function onClick(obj:*):void{
			if(obj.gray){
				return;
			}
			switch(obj){
				case this.btn_hero:
					ViewManager.instance.showView(ConfigClass.VIEW_HERO_MAIN);
					break;
				case this.btn_shop:
					//ViewManager.instance.showShopScene(0);	
					GotoManager.boundForPanel(GotoManager.VIEW_SHOP);				
					//ViewManager.instance.showView(ConfigClass.VIEW_SHOP_MAIN);
					break;
				case this.btn_bag:
					ViewManager.instance.showView(ConfigClass.VIEW_BAG_MAIN);
					break;
				case this.btn_team:
					//ViewManager.instance.showView(ConfigClass.VIEW_GUILD_MAIN);
					ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_MAIN);
					break;
				case this.btn_map1:
					// this.checkStatusBtnMap();
					GotoManager.instance.boundForHome();
					break;
				case this.btn_map2:
					// this.checkStatusBtnMap();
					GotoManager.instance.boundForMap();
					break;
				case this.btn_fight:
					ViewManager.instance.showView(ConfigClass.VIEW_FIGHT_MENU);
					break;
				case this.btn_more:
					ViewManager.instance.showView(ConfigClass.VIEW_MORE_MAIN);
					break;
				case this.btn_mayor:
					var cid:String = ModelOfficial.isCityMayor(ModelManager.instance.modelUser.mUID,ModelUser.getCountryID());
					if(!Tools.isNullString(cid)){
						GotoManager.boundFor({type:1,cityID:cid,state:1});
					}
					// ViewManager.instance.showView(ConfigClass.VIEW_OFFICER_ORDER_A,["buff_corps",-1]);
					break;
				case this.btn_train:
					ViewManager.instance.showView(ConfigClass.VIEW_OFFICER_ORDER_A,["buff_country1",-1]);
					break;	
				case this.btn_task:
					ViewManager.instance.showView(ConfigClass.VIEW_TASK_MAIN);
					break;
				case this.btn_mng:
					ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_HERO,[[1]]);
					break;
				case this.btn_alien:
					GotoManager.boundForPanel(GotoManager.VIEW_COUNTRY_MAIN,"3");
					break;	
				case this.btn_chat:
					ViewManager.instance.showView(["ViewChatMain",ViewChatMain]);
					break;													
				case this.btn_season:
					ViewManager.instance.showView(["ViewSeasonPanel",ViewSeasonPanel]);	
					break;
				case this.btn_build:
					ViewManager.instance.showView(ConfigClass.VIEW_OFFICER_ORDER_A,["buff_country2",-1]);
					break;													
			}
		}
		private function checkStatusBtnMap(change:Boolean = true,inside:int = -1):void{
			
			//if(change){
				//LoadeManager.fakeLoad(1);
			//}
			ViewManager.instance.event(ViewManager.EVENT_MAP_IN_OUT,[change,inside]);
			//
			this.btn_map1.visible=!ModelManager.instance.modelGame.isInside;
			this.btn_map2.visible=ModelManager.instance.modelGame.isInside;
			//this.placeIcon.skin = AssetsManager.getAssetsUI(ModelManager.instance.modelGame.isInside ? "img_icon_28_1.png" : "img_icon_28.png");
		}
		private function checkMapShow():void{
			this.checkStatusBtnMap(false,0);
			}
		private function checkInsideShow():void{
			this.checkStatusBtnMap(false,1);
		}
		private function checkOfficerOrder(bb:Boolean = false):void
		{
			this.timer.clear(this,this.checkOfficerOrder);
			this.timer.once(1000,this,this.checkOfficerOrder,[true]);			
			// this.tSeason.text = "";//ModelManager.instance.modelUser.getSeasonName();
			this.imgSeason.skin = AssetsManager.getAssetsUI(arr_season[ModelManager.instance.modelUser.getGameSeason()]);
			//
			//
			if(!ModelOfficial.countries){
				return;
			}
			var b:Boolean = bb;
			if(ModelManager.instance.modelGame.isInside){
				b = false;
			}
			this.btn_mayor.visible = b;
			this.btn_train.visible = b;
			this.btn_build.visible = b;
			//
			if(b){
				//检测 是不是 太守
				this.btn_mayor.visible = !Tools.isNullString(ModelOfficial.isCityMayor(ModelManager.instance.modelUser.mUID,ModelUser.getCountryID()));
				//检测 是不是 祭酒
				this.btn_train.visible = ModelOfficial.isTrain(ModelManager.instance.modelUser.mUID)>-1;
				//检查 是不是 主簿 (但是如果是祭酒的话就不查了)
				this.btn_build.visible = this.btn_train.visible ? false : ModelOfficial.isBuilder(ModelManager.instance.modelUser.mUID)>-1;
			}
			if (this.btn_mayor.visible){
				this.btn_mayor.x = 0;
				this.btn_train.x = this.btn_mayor.x + this.btn_mayor.width + 6;
			}
			else{
				this.btn_train.x = 0;
			}
			if(this.btn_build.visible) this.btn_build.x = this.btn_train.x;
		}
		
		public function showHeroManager():Boolean{
			var arr:Array=ModelManager.instance.modelUser.getEstateManagerArr();
			if(arr.length!=0){
				return true;
			}
			return false;
		}


		public function checkGuildAlien():void{
			this.btn_mng.visible = showHeroManager();
			var b0:Boolean=ModelManager.instance.modelInside.getBuildingModel("building001").lv>=5;
			var b1:Boolean=b0 ? ModelManager.instance.modelClub.hasPrepareTeam() : false;
			var b2:Boolean=b1 ? ModelManager.instance.modelClub.checkPowerCanFight() : false;
			this.btn_alien.visible=b2;
			
			if(this.btn_mng.visible){
				this.btn_alien.y=this.btn_mng.y-this.btn_alien.height-10;
			}else{
				this.btn_alien.y=this.btn_mng.y;
			}
		}



		public function setComchat():void{
			var newMsg:Array=ModelManager.instance.modelChat.newMSG;
			var arr:Array = newMsg.length==0 ? [] : newMsg[newMsg.length-1];
			
			if(ConfigApp.isPC){
				if(this.getChildByName("comChat")==null){
					//var comChat:ComChat = new ComChat();
					var comChat:ComChat2 = new ComChat2();
					comChat.name = "comChat";
					comChat.bottom = 2;
					comChat.left = 2;	
					this.addChild(comChat);
				}
				return;
			}

			if(arr.length==0){
				return;
			}

			this.chat_btn.visible = this.chat_info.visible = true;
			this.chat_info.style.color = "#ffffff";
			this.chat_info.style.fontSize = this.chat_name.fontSize;
			this.chat_info.style.wordWrap = false;
			this.chat_btn.skin = ModelChat.channel_skin[arr[0]];
			//this.chat_btn.label=ModelChat.channel_arr[arr[0]];
			this.chat_btn.label=arr[0]==0 && arr[1]!=0 ? Tools.getMsgById("_chat_text18") : ModelChat.channel_arr[arr[0]];
			var b:Boolean=arr[1]==0;//是否是系统消息
			if(b){
				//this.chat_name.text=arr[3][1][1]+":  ";
				this.chat_name.text = '';
				var uname:String = arr[3][1][1]+": ";
				this.chat_info.innerHTML = uname + arr[3][0];//FilterManager.instance.wordBan(arr[3][0]);
				this.chat_country.setCountryFlag(arr[3][1][2]);
				this.chat_name.visible = this.chat_country.visible=true;
				this.chat_pan.x = this.chat_name.x;//this.chat_name.x + this.chat_name.width;
			}else{
				this.chat_name.visible = this.chat_country.visible=false;
				this.chat_pan.x = this.chat_btn.x+this.chat_btn.width+4;
				var s:String = ModelManager.instance.modelChat.sysMessage(arr);
				this.chat_info.innerHTML = s;//FilterManager.instance.Exec(s,1);
			}
			this.chat_info.style.valign = 'middle';
			this.chat_info.x     = this.chat_info.y = 0;
			this.chat_pan.width  = this.btn_chat.width-this.chat_pan.x;
			this.chat_info.width = this.chat_pan.width;
		}
		
	}

}