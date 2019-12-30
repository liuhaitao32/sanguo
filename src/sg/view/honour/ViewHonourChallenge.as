package sg.view.honour
{
	import ui.honour.honourChallengeUI;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.model.ModelHonour;
	import laya.utils.Handler;
	import ui.honour.itemHonourClgUI;
	import laya.events.Event;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import ui.bag.bagItemUI;

	/**
	 * ...
	 * @author
	 */
	public class ViewHonourChallenge extends honourChallengeUI{
		public function ViewHonourChallenge(){
			this.comTitle.setViewTitle("赛季挑战");
			this.list.renderHandler = new Handler(this,listRender);
			this.list.scrollBar.visible = false;
		}

		override public function onAdded():void{
			this.comHero.setHeroIcon(ConfigServer.honour.show_hero,false);
			setData();
		}

		private function setData():void{
			var arr:Array = ModelHonour.instance.getHonourTaskData();
			this.list.array = arr;
		}

		private function listRender(cell:itemHonourClgUI,index:int):void{
			var o:Object = this.list.array[index];
			cell.tName.text = o.name;
			cell.tInfo.text = o.info;

			cell.btn.mouseEnabled = !o.isGet;
			cell.btn.label = o.isGet ? "已领取" : "领取";
			cell.btn.visible = o.isFinish;			

			cell.btn.off(Event.CLICK,this,btnClick);
			cell.btn.on(Event.CLICK,this,btnClick,[index]);

			var reward:Array = o.reward;
			if(reward.length > 0){
				if(reward.length == 1){
					cell.reward0.visible = false;
					cell.reward1.setData(reward[0][0],reward[0][1],-1);
				}else{
					cell.reward0.visible = true;
					cell.reward0.setData(reward[0][0],reward[0][1],-1);
					cell.reward1.setData(reward[1][0],reward[1][1],-1);
				}
			}else{
				cell.reward0.visible = cell.reward1.visible = false;
			}
		}


		private function btnClick(index:int):void{
			var o:Object = this.list.array[index];
			NetSocket.instance.send("get_honour_task_reward",{"task_kind":o.task_kind,"task_index":o.index},new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				setData();
			}));
		}

		override public function onRemoved():void{
			
		}
	}

}