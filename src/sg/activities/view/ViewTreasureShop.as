package sg.activities.view
{
	
	import sg.activities.model.ModelActivities;
	import sg.activities.model.ModelTreasure;
	import sg.utils.Tools;

	import ui.activities.treasure.treasureShopUI;
	import sg.activities.model.ModelEquipBox;
	import sg.manager.AssetsManager;
	import sg.model.ModelItem;

	/**
	 * ...
	 * @author
	 */
	public class ViewTreasureShop extends treasureShopUI{

		private var mModel:*;
		public function ViewTreasureShop(){
						
		}

		public override function onAdded():void{
			mModel = currArg[0];
			box1.visible = mModel is ModelEquipBox;
			box0.visible = !box1.visible;
			
			this.comTitle.setViewTitle(Tools.getMsgById(currArg[1]), true);
			this.list.scrollBar.hide = true;
			this.list.itemRender = SaleShopBase;
			mModel.on(ModelActivities.UPDATE_DATA,this,refreshPanel);
			refreshPanel();
		}

		private function refreshPanel():void {
			if(mModel.active==false){
				trace("活动已结束  关闭商店");
				this.closeSelf();
				return;
			}
			if(mModel is ModelEquipBox){
				var item_id:String=mModel.cfg.item_id;
				this.tItemName.text=ModelItem.getItemName(item_id);
				this.cCom.setData(AssetsManager.getAssetItemOrPayByID(item_id),ModelItem.getMyItemNum(item_id));
			}else{
				this.numLabel.text=mModel.mScore+"";
			}
            this.list.array = mModel.getShopData();
        }


		public override function onRemoved():void{
			mModel.off(ModelActivities.UPDATE_DATA,this,refreshPanel);
		}

		
	}

}