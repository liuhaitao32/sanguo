package sg.view.honour
{
	import ui.honour.honourHistoryUI;	
	import sg.model.ModelHonour;
	import ui.honour.itemHonourHisUI;
	import sg.utils.Tools;
	import laya.ui.Box;
	import laya.events.Event;
	import sg.net.NetSocket;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.cfg.ConfigServer;

	/**
	 * ...
	 * @author
	 */
	public class ViewHonourHistroy extends honourHistoryUI{
		public function ViewHonourHistroy(){
			this.tips.text = "赛季总等级越高,结算时获得的奖励越好";
			this.comHero.setHeroIcon(ConfigServer.honour.show_hero,false);
			this.list.scrollBar.visible = false;
			this.list.renderHandler = new Handler(this,listRender);
		}

		override public function onAdded():void{
			this.comTitle.setViewTitle("战绩历史");
			setData();
		}

		private function setData():void{
			this.list.array = ModelHonour.instance.getLogList();
		}

		private function listRender(cell:itemHonourHisUI,index:int):void{
			var o:Object = this.list.array[index];
			var data:Object = o.data;
			cell.tTitle.text = "第" + (o["index"]+1) + "赛季";
			cell.tTime.text = Tools.dateFormat(o["data"].start_time,3)  + " ~ " + Tools.dateFormat(o["data"].end_time,3);
			cell.tLv.text = o["data"]["exp_max_hero"][1]+"级";
			cell.tRank.text = '排名：'+ (data.rank > ModelHonour.instance.rankNum ? '大于'+ModelHonour.instance.rankNum : data.rank);
			cell.tStatus.text = '';
			cell.boxReward.setRewardBox2(data.status);

			cell.boxReward.off(Event.CLICK,this,rewardClick);
			if(data.status == 0)
				cell.boxReward.on(Event.CLICK,this,rewardClick,[o["index"]]);
		}

		private function rewardClick(index:int):void{
			NetSocket.instance.send("get_honour_history_reward",{"history_index":index},new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				setData();
			}));
		}

		override public function onRemoved():void{
			
		}
	}

}