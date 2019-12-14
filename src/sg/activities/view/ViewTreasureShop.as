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
		private var mType:Number=0;
		public function ViewTreasureShop(){
						
		}

		public override function onAdded():void{
			mType=this.currArg?this.currArg:0;
			this.box0.visible=mType==0;
			this.box1.visible=mType==1;
			
			this.comTitle.setViewTitle(mType==0 ? Tools.getMsgById("treasure_text05") : Tools.getMsgById("equip_box3"),true);
			this.list.scrollBar.hide = true;
			this.list.itemRender = SaleShopBase;
			mModel=mType==0 ? ModelTreasure.instance : ModelEquipBox.instance;
			mModel.on(ModelActivities.UPDATE_DATA,this,refreshPanel);
			refreshPanel();
		}

		private function refreshPanel():void {
			if(mModel.active==false){
				trace("活动已结束  关闭商店");
				this.closeSelf();
				return;
			}
			if(mType==0){
				this.numLabel.text=mModel.mScore+"";
			}else{
				var item_id:String=mModel.cfg.item_id;
				this.tItemName.text=ModelItem.getItemName(item_id);
				this.cCom.setData(AssetsManager.getAssetItemOrPayByID(item_id),ModelItem.getMyItemNum(item_id));
			}
            this.list.array = mModel.getShopData();
        }


		public override function onRemoved():void{
			mModel.off(ModelActivities.UPDATE_DATA,this,refreshPanel);
		}

		
	}

}