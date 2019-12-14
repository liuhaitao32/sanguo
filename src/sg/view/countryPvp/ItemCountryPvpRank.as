package sg.view.countryPvp
{
	import ui.countryPvp.item_country_pvp_rankUI;
	import sg.utils.Tools;
	import laya.utils.Handler;
	import ui.bag.bagItemUI;

	/**
	 * ...
	 * @author
	 */
	public class ItemCountryPvpRank extends item_country_pvp_rankUI{
		public function ItemCountryPvpRank(){
			
		}

		public function setData(obj:Object,index:int):void{
			this.cRank.setRankIndex(index+1,Tools.getMsgById("_public101"),true);
			this.tName.text=obj.data[1];
			this.cFlag.setCountryFlag(obj.data[3]);
			this.tNum.text=obj.num;
			var arr:Array=obj.reward?obj.reward:[];
			this.list.renderHandler=new Handler(this,rListRender);
			this.list.array=arr;
		}

		private function rListRender(cell:bagItemUI,index:int):void{
			cell.setData(this.list.array[index][0],this.list.array[index][1],-1);
		}
	}

}