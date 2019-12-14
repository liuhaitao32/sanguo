package sg.view.map
{
	import sg.cfg.ConfigAssets;
	import sg.guide.model.ModelGuide;
	import sg.manager.ViewManager;
	import sg.manager.ModelManager;
	import sg.manager.EffectManager;
	import sg.fight.FightMain;
	import sg.cfg.ConfigServer;
	import sg.fight.logic.utils.FightUtils;
	import sg.net.NetPackage;
	import laya.utils.Handler;
	import sg.net.NetSocket;
	import sg.map.view.TroopAnimation;

	/**
	 * ...
	 * @author
	 */
	public class ViewEstateHeroSend extends ViewHeroSend{

		public function ViewEstateHeroSend(){
			
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
			sendData["city_id"]=this.mCityId+"";
			sendData["estate_index"]=this.mOtherPa["estate_index"];
			sendData["fight"]=1;			
			sendData["hid"]=arr[0].model.hero;
            NetSocket.instance.send("occupy_estate",sendData,Handler.create(this,this.occupy_estate_call_back));
        }
		
        private function occupy_estate_call_back(re:NetPackage):void{
            //trace("occupy_estate_call_back",re.receiveData);
			var receiveData:* = re.receiveData;
			var hids:Array = [re.sendData.hid];
			TroopAnimation.moveTroop(hids,this.mOtherPa["v"],new Handler(this,function():void{
				FightMain.startBattle(receiveData, this, outFight, [receiveData,hids], true);
			}));

            //
			ViewManager.instance.closePanel();
        }


		private function outFight(receiveData:*,a:Array):void{
			ModelManager.instance.modelUser.updateData(receiveData);
			ModelManager.instance.modelUser.soloFightUpdateTroop(receiveData);
			TroopAnimation.backTroop(a);
			if(receiveData.pk_result.winner==0){//赢了			    
				ModelManager.instance.modelGame.addEstate(this.mCityId+"",this.mOtherPa["estate_index"]);
			}
		}

		public override function showLoss():void{
			super.showLoss();
			if(this.mHeroSendPanel.mSelectArr.length) this.selectLoss("occupy_estate",this.mOtherPa);
		}
	}

}