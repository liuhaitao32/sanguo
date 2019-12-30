package sg.view.honour
{
	import ui.honour.honourHistoryUI;	
	import sg.model.ModelHonour;
	import ui.honour.itemHonourHisUI;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewHonourHistroy extends honourHistoryUI{
		public function ViewHonourHistroy(){
			this.tips.text = "赛季总等级越高,结算时获得的奖励越好";
		}

		override public function onAdded():void{

		}

		private function setData():void{
			this.list.array = ModelHonour.instance.getLogList();
		}

		private function listRender(cell:itemHonourHisUI,index:int):void{
			var o:Object = this.list.array[index];
			cell.tTitle.text = "第" + o["index"] + "赛季";
			cell.tTime.text = Tools.dateFormat(o["data"].start_time)  + " ~ " + Tools.dateFormat(o["data"].end_time);
			cell.tLv.text = o["data"]["exp_max_hero"][1]+"级";
		}

		override public function onRemoved():void{
			
		}
	}

}