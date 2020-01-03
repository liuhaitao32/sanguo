package sg.view.honour
{
	import ui.honour.honourRewardUI;
	import ui.bag.bagItemUI;
	import laya.utils.Handler;
	import sg.model.ModelHonour;

	/**
	 * ...
	 * @author
	 */
	public class ViewHonourReward extends honourRewardUI{
		public function ViewHonourReward(){
			this.list.renderHandler = new Handler(this,listRender);
			this.list.scrollBar.visible = false;
			this.tTips.text = '可随机获得以上奖励';
		}

		override public function onAdded():void{
			var arr:Array = ModelHonour.instance.getReardList();
			this.list.array = arr;
		}

		private function listRender(cell:bagItemUI,index:int):void{
			var a:Array = this.list.array[index];
			cell.setData(a[0],a[1],-1);
		}

		override public function onRemoved():void{
			
		}
	}

}