package sg.view.task
{
	import sg.guide.model.ModelGuide;
	import sg.model.ModelPrepare;
	import ui.task.work_conquestUI;
	import sg.view.com.HeroSendPanel;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.model.ModelHero;
	import sg.model.ModelCityBuild;
	import sg.net.NetSocket;
	import sg.net.NetMethodCfg;
	import sg.cfg.ConfigClass;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.manager.EffectManager;
	import sg.cfg.ConfigAssets;
	import sg.model.ModelUser;
	import sg.model.ModelFTask;
	import laya.utils.Handler;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.FightMain;
	import sg.map.view.TroopAnimation;

	/**
	 * 民情山贼面板
	 * @author
	 */
	public class viewFtaskConquest extends work_conquestUI{

		private var config_ftask:Object={};
		private var list_data:Array=[];
		private var mTaskId:String="";
		private var mCityId:int;
		private var user_ftask:Object={};
        public var mHeroSendPanel:HeroSendPanel;
		public var enemyTroop:*;
		private var v:*;
        public function viewFtaskConquest()
        {
            this.btn_sendTroop.on(Event.CLICK,this,this.click);
            //
            this.mHeroSendPanel = new HeroSendPanel();
            this.boxMain.addChild(this.mHeroSendPanel);
            this.mHeroSendPanel.width = 594;
            this.mHeroSendPanel.height = 384;
            this.mHeroSendPanel.y = 344;
			//
			this.btn_sendTroop.label = Tools.getMsgById("_lht9");
        }

		override public function initData():void{			
			config_ftask=ConfigServer.ftask;
			this.mCityId = this.currArg[0];
			this.enemyTroop = this.currArg[1];
			v=this.currArg[2];
			user_ftask=ModelManager.instance.modelUser.ftask;
			mTaskId = ConfigServer.city[this.mCityId].pctask_id[ModelUser.getCountryID()][user_ftask[mCityId][0]];
			setUI();
			var troops:Array = ModelManager.instance.modelTroopManager.getMoveCityTroop(mCityId,0,"",true);			
            this.mHeroSendPanel.clear();
            this.mHeroSendPanel.initData([mCityId,troops,true,true,new Handler(this,this.hspChange),new Handler(this,this.hspTroopNull)]);
            //
            this.mHeroSendPanel.setList(false);
		}
        private function hspTroopNull(isNull:Boolean):void
        {
            this.btn_sendTroop.disabled = isNull;
        } 		
		 private function hspChange():void
        {
			
        }

		public function setUI():void{
			this.tTips.text="";
			this.tName.text=Tools.getMsgById(config_ftask.people_task[mTaskId].task_npc_name);
			this.tInfo.text=Tools.getMsgById(config_ftask.people_task[mTaskId].task_npc_talk);
			//this.iTitle.text=Tools.getMsgById("pctask_ui_name",[ModelCityBuild.getCityName(this.mCityId+"")]);
			var s:String = Tools.getMsgById("pctask_ui_name",[ModelCityBuild.getCityName(this.mCityId+"")]);
			this.comTitle.setViewTitle(s);
			
			//var blv:Number=ModelManager.instance.modelInside.getBase().lv;
			//this.tFoeLv.text = "" + (blv * ConfigServer.city[mCityId].thief_lv[ModelUser.getCountryID()]);
			this.tFoeLv.text = "" + ConfigServer.city[mCityId].thief_lv[ModelUser.getCountryID()];
			var emHmd:ModelHero=new ModelHero(true);
			emHmd.setData(enemyTroop);
			
			this.tLvName.text = Tools.getMsgById('_public188');
			this.tPowerName.text = Tools.getMsgById('_public187');
			//推荐战力
			var powerValue:int = emHmd.getPower(emHmd.getPrepare());
			powerValue = ModelPrepare.getFormatPower(powerValue, ConfigServer.ftask.thief_enemy_power);
			this.comPower.setNum(powerValue);
			//this.tFoePower.text = "" + powerValue;
			this.mHeroSendPanel.mPowerRefer = powerValue;
			
			this.heroIcon.setHeroIcon(emHmd.id);

		}


		public function click():void{
			if(this.mHeroSendPanel.mSelectArr.length<1){
                ModelManager.instance.modelGame.checkTroopToAction(mCityId,ConfigClass.VIEW_HERO_SEND);
                this.closeSelf();
            }
            else{
				var sendData:Object={};
				sendData["city_id"]=this.mCityId+"";
				sendData["hid"]=this.mHeroSendPanel.mSelectArr[0].ct.model.hero;
				sendData["fight"]=1;
				NetSocket.instance.send("do_ftask",sendData,Handler.create(this,this.do_ftask_call_back));
                //NetSocket.instance.send(NetMethodCfg.WS_SR_DO_GTASK,{task_id:this.mTask.id,donate_num:0,hid:this.mHeroSendPanel.mSelectArr[0].ct.model.hero},Handler.create(this,this.ws_sr_do_gtask),this.mTask.rate);
            }
		}
		private function do_ftask_call_back(re:NetPackage):void{
			this.closeSelf();
			var receiveData:* = re.receiveData;
            //trace("do_ftask_call_back",receiveData);
			//山贼战斗

			var hids:Array = [re.sendData.hid];
			TroopAnimation.moveTroop(hids,v,new Handler(this,function():void{
				FightMain.startBattle(receiveData, this, outFight, [receiveData,hids],true);
			}));
			
        }

		public function outFight(receiveData:*,a:Array):void{
			//if(receiveData.pk_result.winner==0){//赢了		
				//ViewManager.instance.showRewardPanel(receiveData.gift_dict);
			//}else{
				//
			//}
			ModelManager.instance.modelUser.soloFightUpdateTroop(receiveData);
			ModelManager.instance.modelUser.updateData(receiveData);
			//ModelManager.instance.modelUser.event(ModelUser.EVENT_FTASK_UPDATE);
			ModelManager.instance.modelGame.getModelFtask(this.mCityId+"").event(ModelFTask.EVENT_UPDATE_FTASK);
			TroopAnimation.backTroop(a);
			//this.closeSelf();
		}



		public override function onRemoved():void{

		}
	}

}