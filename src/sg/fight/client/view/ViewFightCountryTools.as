package sg.fight.client.view
{
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigColor;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.unit.ClientTeam;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.client.utils.FightEvent;
	import sg.fight.client.utils.FightSocket;
	import sg.fight.client.utils.FightTime;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelBuiding;
	import sg.model.ModelFightTask;
	import sg.model.ModelItem;
	import sg.model.ModelPrepare;
	import sg.model.ModelTroop;
	import sg.scene.constant.EventConstant;
	import sg.utils.Tools;
	import ui.battle.fightCountryToolsUI;
	import ui.com.payTypeUI;
	
	/**
	 * 国战我可用的工具
	 * @author zhuda
	 */
	public class ViewFightCountryTools extends fightCountryToolsUI
	{
		private var speedUpIndex:int;
		
		private var clientBattle:ClientBattle;
		
		public function ViewFightCountryTools(clientBattle:ClientBattle)
		{
			this.clientBattle = clientBattle;
			this.once(Event.ADDED, this, this.initUI);
			//this.initUI();
			this.onChange();

			this.tSpeedUp.text = Tools.getMsgById('200187');
			this.tCallCar.text = Tools.getMsgById('hero831');
		}
		
		public function initUI():void
		{
			this.once(Event.REMOVED, this, this.onRemoved);
			var cityCfg:Object = ConfigServer.city[this.clientBattle.city];
			this.boxSpeedUp.visible = ConfigServer.world.cityType[cityCfg.cityType].speedUp > 0;
			this.boxCallCar.visible = false;
			
			if (this.boxSpeedUp.visible){
				this.boxSpeedUp.on(Event.CLICK, this, this.onSpeedUp);
			}
			
			this.setUI();
			
			if (ConfigApp.isPC){
				this.boxSpeedUp.bottom = 20;
				this.boxCallCar.bottom = 20;
			}

			if (!this.boxCallCar.visible){
				this.boxSpeedUp.centerX = 0;
			}
		}


		
				
		public function onSpeedUp():void{
			var errorType:int = this.getSpeedUpErrorType();
			if (errorType){
				var errorInfo:String = this.getSpeedUpErrorInfo(errorType);
				this.clientBattle.fightMain.ui.showTipsTxt(errorInfo, 2);
				
				//FightSocket.sendFightSpeedUp(this.clientBattle.city, this.speedUpIndex);
				return;
			}
			
			var data:Object = {};
			data.title = Tools.getMsgById('countrySpeedUp');
			data.info = Tools.getMsgById('countrySpeedUpInfo',[ConfigServer.world.countryFightSpeedUpNum]);
			data.btn = Tools.getMsgById('countrySpeedUpBtn');
			data.item = this.speedUpItem;

			data.call = this;
			data.fun = this.sendSpeedUp;
			//data.args = this.sendSpeedUp;
			data.repeatKey = 'repeat_key_fightSpeedUp';
			
			this.popConfirmPanel(data);
			//view.setData(data);
			//FightMain.instance.ui.popView(view, 100);
		}
		/**
		 * 弹出战斗内确认面板，考虑有确认不再弹出
		 */
		private function popConfirmPanel(data:Object):void{
			if (data && data.repeatKey){
				if (Tools.checkAlertIsDel(data.repeatKey)){
					if (data.fun){
						data.fun.apply(data.call, data.args);
					}				
					return;
				}
			}
			var view:ViewFightCountryConfirmPanel = new ViewFightCountryConfirmPanel(data);
			FightMain.instance.ui.popView(view, 100);	
		}
				
		
		private function getSpeedUpErrorType():int
		{
			if (this.clientBattle.readyTime > 0){
				return 1;
			}
			else if (!this.clientBattle.findTroop(-1,null,FightMain.getCurrUid())){
				return 2;
			}
			else if (this.clientBattle.speedUp){
				return 3;
			}
			var cityCfg:Object = ConfigServer.city[this.clientBattle.city];
			var num:int = ConfigServer.world.cityType[cityCfg.cityType].speedUp;
			var numType:int = 4;
			if (!ConfigApp.testFightType && ConfigServer.world.countryTaskSpeedUp >= 0){
				var countryTaskArr:Array = ModelFightTask.instance.cids_map;
				var len:int = countryTaskArr.length;
				for (var i:int = 0; i < len; i++) 
				{
					var cid:String = countryTaskArr[i]+'';
					if (this.clientBattle.city == cid){
						//国战本国相关的任务城，可以特殊缩减敲战鼓的限制
						num = ConfigServer.world.countryTaskSpeedUp;
						numType = 6;
						break;
					}
				}
			}
			
			if (this.clientBattle.getTeamLength(0) < num || this.clientBattle.getTeamLength(1) < num){
				return numType;
			}
			else if (this.speedUpItem.mLabel.color == ConfigColor.TXT_STATUS_NO){
				return 5;
			}
			return 0;
		}
		private function getSpeedUpErrorInfo(type:int):String
		{
			var msgId:String = 'countrySpeedUpError' + type;
			if (type == 4){
				var cityCfg:Object = ConfigServer.city[this.clientBattle.city];
				var cityName:String = Tools.getMsgById('cityNameAndType', [Tools.getMsgById(cityCfg.name), Tools.getMsgById('cityType'+cityCfg.cityType)]);
				var num:int = ConfigServer.world.cityType[cityCfg.cityType].speedUp;
				return Tools.getMsgById(msgId, [cityName,num]);
			}
			else if (type == 6){
				return Tools.getMsgById(msgId, [ConfigServer.world.countryTaskSpeedUp]);
			}
			return Tools.getMsgById(msgId);
		}

		
		private function updateItem(ui:payTypeUI,needArr:Array):void
		{
			var len:int = needArr.length;
			var arr:Array;
			var id:String;
			var num:int;
			var enoughNum:Boolean = false;
			var txt:String;
			var maxTxt:String;
			for (var i:int = 0; i < len; i++) 
			{
				arr = needArr[i];
				id = arr[0];
				num = arr[1];
				this.speedUpIndex = i;
				var hNum:int = ModelItem.getMyItemNum(id);
				if(ConfigApp.testFightType){
					hNum = Math.floor(Math.random()*55);
				}
				else{
					hNum = ModelItem.getMyItemNum(id);
				}
				maxTxt = num + '/' + hNum;
				txt = id.indexOf('item') !=-1?maxTxt:num.toString();
				if (hNum >= num)
				{
					enoughNum = true;
					break;
				}
			}
			ui.setData(ModelItem.getItemIconAssetUI(id), txt);
			ui['maxTxt'] = maxTxt;
			ui.width = ui.getTextFieldWidth();
			ui.centerX = 0;
			ui.changeTxtColor(enoughNum?ConfigColor.TXT_STATUS_OK:ConfigColor.TXT_STATUS_NO);
		}
		
		private function sendSpeedUp():void
		{
			var errorType:int = this.getSpeedUpErrorType();
			if (errorType){
				var errorInfo:String = this.getSpeedUpErrorInfo(errorType);
				this.clientBattle.fightMain.ui.showTipsTxt(errorInfo,2);
				//FightSocket.sendFightSpeedUp(this.clientBattle.city, this.speedUpIndex);
			}
			else{
				FightSocket.sendFightSpeedUp(this.clientBattle.city, this.speedUpIndex);
			}
			//NetSocket.instance.send(EventConstant.TROOP_ADD_NUM, {hid:hero,is_pay:isPay}, Handler.create(this, this.onTroopHandler));
		}
		override public function onChange(data:* = null):void{
			//检查国战是否加速的厉害，如果已经超出极速，不再显示工具
			if (this.clientBattle.isXYZ){
				if (this.clientBattle.readyTime > 0){
					this.visible = false;
				}
				else{
					this.visible = this.clientBattle.timeScale <= ConfigFight.maxPoint;
				}
			}
		}
		
		private function setUI(isRe:Boolean=false,data:*=null):void
		{
			this.removeUpdateEvent();
			FightEvent.ED.on(EventConstant.SPEED_UP_FIGHT, this, this.setUI, [true]);
			FightEvent.ED.on(EventConstant.FIGHT_NEXT, this, this.setUI, [false]);
			
			//if (this.clientBattle.speedUp > 0){
				////立即开始下场战斗，并加速时间
				//if (data){
					//if (data.type == 'speedUp'){
						//this.clientBattle
					//}
				//}
			//}
			if (isRe){
				//立即开始下场战斗，并加速时间
				if (data){
					if (data.type == 'speedUp'){
						FightTime.playSound('speedUp', 1, 0);
						this.clientBattle.fightMain.ui.showTipsTxt(Tools.getMsgById('countrySpeedUpTips', [data.uname]), 2);
						FightTime.setTimeScale(ConfigServer.world.countryFightSpeedUpTimeScale);
						this.clientBattle.skip();
						this.clientBattle.speedUp = ConfigServer.world.countryFightSpeedUpNum;		
					}
				}
			}
			 
			//var canSpeedUp:Boolean = this.getSpeedUpErrorType() == 0;
			this.updateItem(this.speedUpItem, ConfigServer.world.countryFightSpeedUpNeed);
			var speedUpErrorType:int = this.getSpeedUpErrorType();
			if (speedUpErrorType == 3 ){
				this.boxSpeedUp.gray = true;
			}
			else{
				this.boxSpeedUp.gray = false;
			}
		}
		
		
		private function removeUpdateEvent():void{
            FightEvent.ED.off(EventConstant.SPEED_UP_FIGHT, this, this.setUI);
			FightEvent.ED.off(EventConstant.FIGHT_NEXT, this, this.setUI);
        }
		
		private function onRemoved():void{
			this.removeUpdateEvent();
        }
	}

}