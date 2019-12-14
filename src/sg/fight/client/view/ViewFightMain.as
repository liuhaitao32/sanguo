package sg.fight.client.view
{
	import laya.display.Animation;
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigAssets;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.unit.ClientTeam;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.client.utils.FightLoad;
	import sg.fight.client.utils.FightViewUtils;
	import sg.fight.test.TestCopyright;
	import sg.fight.test.TestFight;
	import sg.manager.*;
	import sg.fight.test.TestFightData;
	import sg.utils.MusicManager;
	import sg.utils.Tools;
	import sg.view.ViewPanel;
	import sg.view.com.ItemBase;
	import ui.battle.fightMainUI;
	import sg.model.ModelUser;
	import sg.model.ModelArena;
	
	/**
	 * 战斗场景UI
	 * @author zhuda
	 */
	public class ViewFightMain extends fightMainUI			//baseUI
	{
		//public static var sceneStartY:Number;
		
		public var heroUI:ViewFightHero;
		public var roundUI:ViewFightRound;
		public var countryUI:ViewFightCountry;
		public var countryTeamBestUI:ViewFightCountryTeamBest;
		public var readyUI:ViewFightReady;
		
		public var lowerTools:ViewFightCountryTools;
		public var lowerPanel:ViewPanel;
		public var lowerUI:ItemBase;
		public var speedHS:ViewFightSpeedSlider;
		public var topUI:ItemBase;
		
		public var testUI:TestFight;
		
		///弹出信息层
		public var infoLayer:Sprite;
		///准备层
		public var readyLayer:Box;
		///弹出面板层
		public var popLayer:Box;
		///置顶特效层
		public var effectLayer:Sprite;
		///置顶提示层
		public var tipsLayer:Box;
		
		public var isFinish:Boolean;
		public var isCleared:Boolean;
		public var bgImg:Image;
		private var _sprArr:Array;
		
		public function ViewFightMain()
		{
			this.init();
		}
		
		override public function onAddedBase():void
		{
			this.initUI();
		}
		
		override public function onRemovedBase():void
		{
			Laya.stage.off('resize', this, this.onResize);
		}
		
		private function onResize():void
		{
			this.width = Laya.stage.width;
			this.height = Laya.stage.height;
			//console.log('size:', Laya.stage.width, Laya.stage.height);
			//Trace.log(this.stage.width+','+ this.stage.height);
			
			var h:Number = 0;
			var temp:Number = this.height / this.width;
			if (temp > 2)
			{
				h = (temp - 2) * 640;
			}
			//长屏幕，UI最高放置到背景边缘
			var hh:Number = ConfigFightView.TOP_UI_HEIGHT + h * 0.5;
			hh = Math.max(hh, ConfigFightView.TOP_UI_HEIGHT + ConfigApp.topVal);
			this.topUI.height = hh;
			this.topUI.y = ConfigApp.topVal;
			this.titleUI.height = hh - ConfigFightView.TOP_UI_HEIGHT;
			this.titleUI.y = ConfigApp.topVal;
			if (this.heroUI)
				this.heroUI.y = hh;
			if (this.roundUI)
				this.roundUI.y = hh;
			if (this.countryUI)
				this.countryUI.y = hh;
			if (this.countryTeamBestUI)
				this.countryTeamBestUI.y = hh;
			//底部
			hh = ConfigFightView.BOTTOM_UI_HEIGHT + h * 0.5;
			if (ConfigApp.isPC){
				this.bottomUI.visible = false;
			}
			else{
				this.bottomUI.height = hh;
			}
			if(this.lowerUI)
				this.lowerUI.bottom = hh;
			if(this.lowerPanel){
				this.lowerPanel.bottom = hh;
				if (ConfigApp.isPC){
					this.lowerPanel.width = 580;
				}
			}
			if(this.lowerTools)
				this.lowerTools.bottom = hh;
			if(this.speedHS)
				this.speedHS.bottom = hh;
				
			//this.bottomUI.btnTimeScale.y = - hh - 30;
			//this.topUI.alpha = 0.6;
			//this.bottomUI.alpha = 0.6;
		}

		
		/**
		 * 初始化UI
		 */
		private function initUI():void
		{
			ViewManager.instance.closePanel();
			
			this.mouseThrough = true;
			this.bottomUI.mouseEnabled = true;
			this.isFinish = false;
			this.isCleared = false;


			if (ConfigApp.testFightType == 2)
			{
				this.topUI = new ViewFightTestTop();
			}
			else
			{
				this.topUI = new ViewFightTop();
			}
			this.topUI.mouseEnabled = true;
			this.addChild(this.topUI);

		}

		/**
		 * 最终初始化UI（需要有战斗数据）
		 */
		public function updateTitle():void
		{
			var titleText:String;
			var clientBattle:ClientBattle = FightMain.instance.client;
			if (clientBattle.title)
			{
				titleText = clientBattle.title;
			}
			else if (clientBattle.city)
			{
				titleText = Tools.getMsgById('fightCountryTitle', [FightViewUtils.getCityName(clientBattle.city)]);
			}
			else if (clientBattle.arena_group)
			{
				titleText = Tools.getMsgById('arena_group_'+clientBattle.arena_group);
			}
			else
			{
				titleText = 'battle_mode_' + clientBattle.mode;
				titleText = Tools.getMsgById(titleText);
				if (!titleText)
				{
					titleText = '缺失模式'; 
				}
			}
			
			if (ConfigApp.testFightType == 1)
			{
				if(!ConfigFightView.showTest)
					titleText = Tools.getMsgById('fightCountryTitle', ['五丈原']);
				if(this.speedHS)
					this.speedHS.visible = ConfigFightView.showTest;
			}
			this.titleUI.titleLabel.text = titleText;
			this.titleUI.titleImg.width = this.titleUI.titleLabel.textField.textWidth + 110;
		}
		
		/**
		 * 最终初始化UI（需要有战斗数据）
		 */
		public function initEnd():void
		{
			var clientBattle:ClientBattle = FightMain.instance.client;
			this.updateTitle();

			if (ConfigApp.testFightType == 2)
			{
				//版号申请
				this.lowerPanel = new ViewFightTestHeroes();
				this.addChild(this.lowerPanel);
				
				this.countryUI = new ViewFightCountry(clientBattle.fireCountry, clientBattle.country, clientBattle.getTeamLength(0), clientBattle.getTeamLength(1), clientBattle.fightCount);
				this.addChild(this.countryUI);
			}
			else
			{
				if (clientBattle.isCountry)
				{
					var uid:int = -1;
					var uname:String;
					var teamIndex:int;
					var country:int;
					if (ConfigApp.testFightType != 0){
						//var clientTroop:ClientTroop = clientBattle.getClientTeam(1).getClientTroop(0);
						var userLog:Object = clientBattle.user_logs[TestFightData.testUid];
						if(userLog){
							uid = TestFightData.testUid;
							TestFightData.testUname = uname = userLog.uname;
							TestFightData.testCountry = country = userLog.country;
						}
					}
					else{
						uid = parseInt(ModelManager.instance.modelUser.mUID);
						uname = ModelManager.instance.modelUser.uname;
						country = ModelUser.getCountryID();
					}

					if (uid > 0){
						teamIndex = clientBattle.getTeamIndexByCountry(country);
						this.lowerPanel = new ViewFightCountryTurn(clientBattle,teamIndex, uid, uname, country);
						this.addChild(this.lowerPanel);
						
						//国战我可用的工具
						this.lowerTools = new ViewFightCountryTools(clientBattle);
						this.addChild(this.lowerTools);
					}
					
					this.lowerUI = new ViewFightLowerCountry(uid);
					
					this.countryUI = new ViewFightCountry(clientBattle.fireCountry, clientBattle.country, clientBattle.getTeamLength(0), clientBattle.getTeamLength(1), clientBattle.fightCount);
					this.countryUI.setBuffs(
						clientBattle.getCountryBuffValue(clientBattle.fireCountry, true),
						clientBattle.getCountryBuffValue(clientBattle.fireCountry, false),
						clientBattle.getCountryBuffValue(clientBattle.country, true),
						clientBattle.getCountryBuffValue(clientBattle.country, false)
					);
					if(clientBattle.tower){
						this.countryUI.setTower(clientBattle.tower[0], clientBattle.tower[1]);
					}else{
						this.countryUI.setTower(0, 0);
					}
					this.addChild(this.countryUI);
					
					this.countryTeamBestUI = new ViewFightCountryTeamBest(clientBattle, clientBattle.teamBest);
					this.addChild(this.countryTeamBestUI);
				}
				else
				{
					if (clientBattle.isWavePVE)
					{
						//战斗中奖励面板
						var waveTotal:int = clientBattle.isClimbPVE ? -1:clientBattle.getWaveTotal(true);
						this.lowerPanel = new ViewFightReward(clientBattle.reward, clientBattle.getWaveKill(true), waveTotal);
						this.addChild(this.lowerPanel);
					}
					
					this.lowerUI = new ViewFightLower();
					this.heroUI = new ViewFightHero();
					this.addChild(this.heroUI);
					
					this.roundUI = new ViewFightRound();
					this.addChild(this.roundUI);
				}
				this.addChild(this.lowerUI);
				this.lowerUI.init();
			}
			if (ConfigApp.testFightType){
				this.speedHS = new ViewFightSpeedSlider();
				this.addChild(this.speedHS);
				this.speedHS.init();
			}
			
			this.infoLayer = new Sprite();
			this.addChild(this.infoLayer);

			this.initBgAndPop();

			this.effectLayer = new Sprite();
			this.tipsLayer = new Box();
			this.tipsLayer.mouseEnabled = false;
			if (ConfigApp.testFightType == 1)
			{
				this.testUI = new TestFight(this.effectLayer);
				this.testUI.y = ConfigApp.topVal;
				this.addChild(this.testUI);
			}
			
			this.addChild(this.effectLayer);
			this.addChild(this.tipsLayer);
			
			Laya.stage.on('resize', this, this.onResize);
			this.onResize();
		}
		
		/**
		 * 初始化UI
		 */
		private function initBgAndPop():void
		{
			this.bgImg = new Image(AssetsManager.getAssetsUI('blueprogress.png'));
			this.bgImg.left = -200;
			this.bgImg.right = -200;
			this.bgImg.top = -200;
			this.bgImg.bottom = -200;
			this.bgImg.alpha = 0;
			this.addChild(this.bgImg);
			
			this.readyLayer = new Box();
			this.readyLayer.top = 0;
			this.readyLayer.bottom = 0;
			this.readyLayer.left = 0;
			this.readyLayer.right = 0;
			this.addChild(this.readyLayer);
			
			this.popLayer = new Box();
			this.popLayer.top = 0;
			this.popLayer.bottom = 0;
			this.popLayer.left = 0;
			this.popLayer.right = 0;
			this.popLayer.mouseThrough = true;
			this.addChild(this.popLayer);
		}
		
		public function updateReady():void
		{
			var readyTime:int = FightMain.instance.client.readyTime;
			if (readyTime > 0)
			{
				if (!this.readyUI)
				{
					this.readyUI = new ViewFightReady(readyTime);
					this.readyLayer.addChild(this.readyUI);
				}
				else
				{
					this.readyUI.update(readyTime);
				}
			}
			else
			{
				if (this.readyUI)
				{
					this.readyUI.hide();
				}
			}
		}
		/**
		 * 更新国战队伍之最
		 */
		public function updateCountryTeamBest(teamIndex:int):void
		{
			if (this.countryTeamBestUI){
				this.countryTeamBestUI.updateTeam(teamIndex);
			}
		}
		
		public function showStart():void
		{
			var ani:Animation = FightLoad.loadAnimation('world_start', '', 1);
			ani.pos(this.width * 0.5, this.height * 0.3);
			this.infoLayer.addChild(ani);
			//var startUI:ViewFightStart = new ViewFightStart();
			//this.addChild(startUI);
		}
		/**
		 * 微调速率
		 */
		public function changeSpeed(value:Number):void
		{
			if (this.speedHS){
				this.speedHS.hsSpeed.value+= value;
			}
		}
		

		/**
		 * 战斗结束后统一弹出
		 */
		public function checkFinish(delay:int = 800):void
		{
			if (this.isFinish) return;
			this.isFinish = true;
			
			var clientBattle:ClientBattle = FightMain.instance.client;
			var data:Object = clientBattle.record;
			//if (ConfigApp.testFightType == 0)
			//{
				//data = clientBattle.record;
			//}
			if(!data){
				data = clientBattle.getRecord();
			}

			var arr:Array = [];
			if (!clientBattle.isNoWin){
				this.checkWinOrLose(data.winner, arr);
			}
			
			var node:Node;
			var winner:int;

			if (clientBattle.isMatch){
				node = new ViewFightFinishMatch(data, !clientBattle.isNoWin,  delay);
				arr.push(node);
				if (clientBattle.isSandTable){
					node = new ViewFightFinishSandTable(data, clientBattle.gift, 0);
					arr.push(node);
				}
			}else if (clientBattle.isCountry){
				if (clientBattle.countryBattleWinner >= 0){
					winner = clientBattle.countryBattleWinner;
				}
				else{
					winner = data.winner;
				}
				node = new ViewFightFinishCountry(winner == 0? clientBattle.fireCountry:clientBattle.country, winner);
				arr.push(node);
			}
			else if (clientBattle.isCross){
				node = new ViewFightFinish(4);
				arr.push(node);
			}
			else if (clientBattle.isArena){
				winner = -1;
				if (clientBattle.record && clientBattle.canEndTime < ConfigServer.getServerTimer() / 1000){
					//已经正常结束，可以显示胜败
					winner = clientBattle.record.winner;
				}
				//有下一场攻擂，添加继续观战按钮，待补充
				//var hasNext:Boolean = Math.random() > 0.5;
				var hasNext:Boolean;
				if (ConfigApp.testFightType){
					hasNext = Math.random() > 0.5;
				}
				else{
					hasNext = ModelArena.hasNextFight(clientBattle.arena_index, clientBattle.log_index);
				}
				
				node = new ViewFightFinishArena(winner, (winner>=0 && hasNext), clientBattle.getSelfTeam());
				arr.push(node);
			}
			else{
				var type:int = 0;
				if (ConfigApp.testFightType == 2)
				{
					if (data.winner == 0)
					{
						TestCopyright.sendNextChapter();
						type = 2;
					}
					else
					{
						type = 3;
					}
				}else if (clientBattle.isWavePVE){
					type = 1;
				}
				node = new ViewFightFinish(type);
				arr.push(node);
			}
			arr.push(0);
			this.popViews(arr);
		}

		
		/**
		 * 弹出面板，并强制关闭之前的面板。如果该面板未设置单独下一步按钮，则点击任意位置下一步
		 */
		public function popView(spr:Sprite, time:int = 200):void
		{
			this.popViews([spr],time);
			
			//this.closePopView(false);
			//this.popLayer.addChild(spr);
			//this.popLayer.mouseEnabled = true;
		}
		/**
		 * 依次弹出面板，并强制关闭之前的面板
		 */
		public function popViews(sprArr:Array, time:int = 200, delay:int = 0):void
		{
			this.closePopView(time);
			this._sprArr = sprArr;
			Laya.timer.once(delay, this, this.nextView, [time]);
			Tween.to(this.bgImg, {alpha: 0.5}, time, null, Handler.create(this, function():void{
				this.bgImg.mouseEnabled = true;
			}), delay);
		}
		public function closePopView(noNext:Boolean = true, time:int = 200):void
		{
			this._sprArr = [];
			if (noNext){
				this.bgImg.mouseEnabled = false;
				this.bgImg.off(Event.CLICK, this, this.nextView);
				Tween.clearAll(this.bgImg);
				if(this.bgImg.alpha != 0){
					Tween.to(this.bgImg, {alpha: 0}, time);
				}
			}
			this.clearPopLayer();
		}
		
		private function nextView(time:int = 200):void
		{
			if (this.isCleared)
				return;
			this.clearPopLayer();
			
			if (this._sprArr.length == 0){
				this.closePopView();
				return;
			}
			var temp:* = this._sprArr.shift();
			if (temp == 0){
				FightViewUtils.onExit();
				return;
			};
			var spr:Sprite = temp as Sprite;
			this.showView(spr, time);
		}
		private function showView(spr:Sprite, time:int = 200):void
		{
			this.bgImg.off(Event.CLICK, this, this.nextView);
			if (spr is Animation)
			{
				if (spr['sound']){
					MusicManager.playSoundUI(spr['sound']);
				}
				Laya.timer.once(1500, this, this.nextView, [time]);
			}
			else{
				spr.mouseThrough = true;
				spr.alpha = 0;
				this.popLayer.mouseEnabled = false;
				Tween.to(spr, {alpha: 1}, time, null, Handler.create(this, function():void{
					this.popLayer.mouseEnabled = true;
					if(!spr['onlyClose']){
						this.bgImg.once(Event.CLICK, this, this.nextView, [time]);
					}
				}));
			}
			this.popLayer.addChild(spr);
		}

		private function clearPopLayer():void
		{
			var len:int = this.popLayer.numChildren;
			for (var i:int = 0; i < len; i++ ){
				var sprPop:Sprite = this.popLayer.getChildAt(i) as Sprite;
				Tween.to(sprPop, {alpha: 0}, 200, null, Handler.create(sprPop, sprPop.destroy));
			}
			this.popLayer.mouseEnabled = false;
		}
		/**
		 * 判定弹出胜负
		 */
		private function checkWinOrLose(winner:int,arr:Array):void
		{
			if (winner >= 0)
			{
				var aniName:String = winner == 0?ConfigAssets.WorldWinAniName:ConfigAssets.WorldLoseAniName;
				var ani:Animation = EffectManager.loadAnimation(aniName, '', 1);
				ani['sound'] = aniName;
				ani.pos(this.width * 0.5, this.height * 0.5);
				arr.push(ani);
			}
		}
		
		/**
		 * 弹出短暂的中央信息
		 */
		public function showTipsTxt(str:String,timeMax:Number = 2):void
		{
			ViewManager.instance.showTipsTxt(str, timeMax, this.tipsLayer);
		}

		/**
		 * 刷新战斗速率
		 */
		public function updateTimeScale():void
		{
			if (this.lowerUI)
				this.lowerUI.onChange();
		}
		
		/**
		 * 刷新顶部钱币
		 */
		public function updateTop():void
		{
			if (this.topUI)
				this.topUI.onChange();
		}
		
		/**
		 * 刷新下部面板
		 */
		public function updateLowerPanel(type:* = null):void
		{
			if (this.lowerPanel)
				this.lowerPanel.onChange(type);
			if (this.lowerTools){
				this.lowerTools.onChange(type);
			}
		}
		/**
		 * 刷新下部工具面板
		 */
		public function updateLowerTools(type:* = null):void
		{
			if (this.lowerTools){
				this.lowerTools.onChange(type);
			}
		}
		
		
		override public function clear():void
		{
			this.isCleared = true;
			if (this.testUI)
			{
				this.testUI.clear();
				this.testUI = null;
				//this.testUI.removeSelf();
			}
			this.destroyChildren();
			ViewManager.instance.closePanel();
		}
	}

}
