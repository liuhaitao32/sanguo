package sg.view.task
{
	import sg.cfg.ConfigAssets;
	import sg.guide.model.ModelGuide;
	import sg.view.map.ViewHeroSend;
	import sg.net.NetSocket;
	import sg.manager.ModelManager;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.fight.logic.utils.FightUtils;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.manager.ViewManager;
	import sg.manager.EffectManager;
	import sg.model.ModelFTask;
	import sg.map.view.TroopAnimation;
	import laya.ui.List;

	/**
	 * 民情攻打叛军
	 * @author
	 */
	public class ViewFtaskHeroSend extends ViewHeroSend{
		public function ViewFtaskHeroSend(){
			super();
			
		}

		override public function click_send_func(arr:Array):void{
            // trace("---派兵前往--民情 攻打叛军---",arr);
			var sendData:Object={};
			sendData["city_id"]=this.mCityId+"";
			sendData["hid"]=arr[0].model.hero;
			sendData["fight"]=1;
            NetSocket.instance.send("do_ftask",sendData,Handler.create(this,this.do_ftask_call_back));
        }
		
        private function do_ftask_call_back(re:NetPackage):void{
			var receiveData:* = re.receiveData;
            // trace("do_ftask_call_back",receiveData);
			//叛军战斗
			var hids:Array = [re.sendData.hid];
			TroopAnimation.moveTroop(hids, this.mOtherPa["v"], new Handler(this, function():void{
				FightMain.startBattle(receiveData, this, outFight, [receiveData, hids], true);
			}));
            //
			ViewManager.instance.closePanel();
            

        }


		private function outFight(receiveData:*,a:Array):void{
			if(receiveData.pk_result.winner==0){//赢了		
				ViewManager.instance.showRewardPanel(receiveData.gift_dict);
			}else{
				
			}
			ModelManager.instance.modelUser.updateData(receiveData);
			ModelManager.instance.modelUser.soloFightUpdateTroop(receiveData);
			ModelManager.instance.modelGame.getModelFtask(this.mCityId+"").event(ModelFTask.EVENT_UPDATE_FTASK);
			TroopAnimation.backTroop(a);
		}
		
		public override function showLoss():void{
			super.showLoss();
			if(this.mHeroSendPanel.mSelectArr.length) this.selectLoss("do_ftask",this.mOtherPa);
		}

		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		override public function getSpriteByName(name:String):*
		{
			var result:Array = name.split('_');
			if (this.mHeroSendPanel[result[0]]) {
				return (this.mHeroSendPanel[result[0]] as List).getCell(parseInt(result[1]));
			}
            else return super.getSpriteByName(name);
		}

	}

}