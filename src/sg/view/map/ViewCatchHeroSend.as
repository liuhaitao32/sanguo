package sg.view.map
{
	import sg.cfg.ConfigAssets;
	import sg.guide.model.ModelGuide;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.fight.logic.utils.FightUtils;
	import sg.cfg.ConfigServer;
	import sg.manager.ViewManager;
	import sg.fight.FightMain;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.map.view.TroopAnimation;
	import sg.scene.constant.EventConstant;

	/**
	 * ...
	 * @author
	 */
	public class ViewCatchHeroSend extends ViewHeroSend{


		public function ViewCatchHeroSend(){
			super();
		}
		
		override public function click_send_func(arr:Array):void{
			
            // trace("---派兵前往--名将切磋---",arr);			
			var index:int=0;
			var hero_list:Array=ModelManager.instance.modelUser.hero_catch.hero_list;
			for(var i:int=0;i<hero_list.length;i++){
				var a:Array=hero_list[i];
				if(a[1]==this.mCityId){
					index=i;
					break;
				}
			}
			var sendData:Object={};
			sendData["hero_index"]=index;
			sendData["hid"]=arr[0].model.hero;
			sendData["fight"]=1;
            NetSocket.instance.send("hero_catch_pk",sendData,Handler.create(this,this.hero_catch_pk_call_back));
        }
		
        private function hero_catch_pk_call_back(re:NetPackage):void{
            //trace("hero_catch_pk_call_back",re.receiveData);
			var receiveData:* = re.receiveData;
			var hids:Array = [re.sendData.hid];
			TroopAnimation.moveTroop(hids,this.mOtherPa["v"],new Handler(this,function():void{
				FightMain.startBattle(receiveData, this, outFight, [receiveData,hids],true);
			}));
            //
			ViewManager.instance.closePanel();
			
            //ModelManager.instance.modelUser.updateData(re.receiveData);
        }




		private function outFight(receiveData:*,a:Array):void{
			
			//ViewManager.instance.closeFightScenes();
            //
			ModelManager.instance.modelUser.soloFightUpdateTroop(receiveData);
			TroopAnimation.backTroop(a);
			if(receiveData.pk_result.winner==0){//赢了			    
				ViewManager.instance.showRewardPanel(receiveData.gift_dict);
				ModelManager.instance.modelUser.event(EventConstant.HERE_CATCH_DIE,this.mCityId);
				ModelManager.instance.modelUser.updateData(receiveData);
			}else{//输了
				ModelManager.instance.modelUser.updateData(receiveData);
			}
		}


		public override function showLoss():void{
			super.showLoss();
			if(this.mHeroSendPanel.mSelectArr.length) this.selectLoss("hero_catch_pk",{"hero_index":this.mOtherPa["index"],"fight":0});
		}
	}

}