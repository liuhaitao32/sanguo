package sg.view.shop
{
	import ui.shop.shopEquipTipsUI;
	import sg.utils.Tools;
	import sg.model.ModelItem;
	import sg.model.ModelEquip;
	import sg.manager.ModelManager;
	import sg.view.com.EquipInfoAttr;
	import sg.cfg.ConfigColor;
	import sg.cfg.ConfigApp;

	/**
	 * ...
	 * @author
	 */
	public class ViewShopEquipTips extends shopEquipTipsUI{

		public var mItemID:String;
	    private var mInfoAttr:EquipInfoAttr;
		private var emd:ModelEquip;
		public function ViewShopEquipTips(){
			
		}


		public override function onAdded():void{
			mItemID=this.currArg;
			var imd:ModelItem=ModelManager.instance.modelProp.getItemProp(mItemID);
			var emd:ModelEquip=ModelManager.instance.modelGame.getModelEquip(imd.equip_info[0]);

			this.icon.setData(mItemID,-1,-1);
			this.nameLabel.text = imd.getName(true);
			this.nameLabel.color = imd.getColor();
			var n:Number = emd.nextLvNeedItemNum(imd.id);
			this.numLabel.text=Tools.getMsgById("_public18",[imd.num+"/"+(n==0 ? '-' : n)]);
			this.infoLabel.text=imd.info;
			this.eBox.y=this.infoLabel.y+this.infoLabel.height+2;

			this.equipIcon.setData(emd.id,-1,-1);
			this.eNameLabel.text=emd.getName();
			this.eNameLabel.color=ConfigColor.FONT_COLORS[emd.getLv()];
			this.eInfoLabel.text=Tools.getMsgById("_shop_text11",[emd.useHid()]);
			this.imgBG.y=eBox.y+eBox.height+2;
			setInfoUI(emd);
			this.text0.text = Tools.getMsgById("_bag_text20");
			
			this.tType.x = this.eNameLabel.x + this.eNameLabel.textField.textWidth + 5;
			var groupName:String = emd.getGroupName();
			if (groupName){
				this.tType.text = Tools.getMsgById('_equip28', [emd.getTypeName(), groupName]);
				this.tType.bold = true;
			}
			else{
				this.tType.text = Tools.getMsgById('_equip27', [emd.getTypeName()]);
				this.tType.bold = false;
			}
			this.tType.color = ConfigColor.FONT_COLORS[emd.getMaxLv()];
		}

		private function setInfoUI(emd:ModelEquip):void{
            if(this.mInfoAttr){
                this.mInfoAttr.removeSelf();
                this.mInfoAttr.destroy(true);
            }
            this.mInfoAttr = null;
            this.mInfoAttr = new EquipInfoAttr(this.imgBG,this.imgBG.width-10,this.imgBG.height-5);
            this.mInfoAttr.initData(emd);
			this.imgBG.height=this.mInfoAttr.getPanelHeight();
            this.imgBG.addChild(this.mInfoAttr);
			this.box.height=this.imgBG.y+this.imgBG.height+16;
        }


		public override function onRemoved():void{

		}
	}

}