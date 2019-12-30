package sg.view.honour
{
	import ui.honour.honourRankUI;
	import ui.honour.itemHonourRankUI;

	/**
	 * ...
	 * @author
	 */
	public class ViewHonourRank extends honourRankUI{

		private var mData:Array;
		public function ViewHonourRank(){
			
		}

		override public function onAdded():void{
			if(this.currArg == null) return;
			mData = this.currArg;

		}

		private function listRender(cell:itemHonourRankUI,index:int):void{
			
			cell.cRank.setRankIndex(index);
		}

		override public function onRemoved():void{
			
		}
	}

}