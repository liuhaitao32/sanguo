package sg.activities.view
{
    import laya.events.Event;

    import sg.activities.model.ModelSaleShop;
    import sg.activities.model.ModelTreasure;
    import sg.manager.AssetsManager;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import sg.model.ModelItem;
    import sg.utils.Tools;

    import ui.activities.saleShop.saleBaseUI;
    import laya.maths.Point;
    import sg.activities.model.ModelEquipBox;
    import sg.model.ModelEquip;

    public class SaleShopBase extends saleBaseUI
    {
        private var rewardItemArr:Array = [];
        private var _goods_id:String;
        public function SaleShopBase()
        {
            this.hintTxt1.text = Tools.getMsgById('_public104');
            this.hintTxt2.text = Tools.getMsgById('_jia0053');
            //this.btn_price.on(Event.CLICK, this, this._onClickBuy);
        }

        private function set dataSource(source:Object):void
        {
            if (!source) return;
			this._dataSource = source;
            var reward:Object = source.reward;
            this.rewardItem.setData(reward[0], reward[1], -1);
            this.rebateTxt.visible = this.btn_price.visible = source.state !== 2;
            this.sellOut.visible = source.state === 2;
            this.hintBox.visible = source.state === 0;
            this.rewardBox.gray = source.state === 0;
            var iid:String = reward[0];
            this.nameTxt.text = ModelItem.getItemName(iid);
            var type:int = ModelItem.getItemType(iid);
            if (type === 7) { // 英雄碎片
                this.img_type.visible = true;
                var heroId:String = iid.replace('item', 'hero');
                var heroModel:ModelHero=ModelManager.instance.modelGame.getModelHero(heroId);
                this.img_type.skin = heroModel.getRaritySkin(true);
                nameTxt.x = img_type.x + img_type.width + 5;
            }
            else {
                nameTxt.x = nameTxtPanel.x + (nameTxtPanel.width - nameTxt.width) * 0.5;
                this.img_type.visible = false;
            }
            if(source.price == source.originalPrice){
                this.rebateTxt.text="";
            }else{
                var rate:Number = Math.floor(source.price / source.originalPrice * 100) / 10;
                this.rebateTxt.text = Tools.getMsgById('_jia0054', [rate]);
            }
            this.payIcon.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), source.needMoney * 10);

            this.htmlLabel.style.color="#dee3ff";
            this.htmlLabel.style.fontSize=16;
            this.htmlLabel.style.align="center";
            this.htmlLabel.style.valign="bottom";
            this.htmlLabel.innerHTML=this.sellOut.visible ? "" : Tools.getMsgById("treasure_text01",[(source.limitTimes - source.buyTimes),source.limitTimes]);
            
            this.btn_price.setDoubleTxt(source.originalPrice,source.price,source.itemId!=null ? source.itemId : "coin");
            this._goods_id = source.goods_id;
            //this.btn_price.gray = ModelManager.instance.modelUser.coin < source.price;
            this.btn_price.gray = source.totalMoney < source.price;
            
            this.btn_price.off(Event.CLICK, this, this._onClickBuy);
            this.btn_price.on(Event.CLICK, this, this._onClickBuy,[source.key]);
        }

        private function _onClickBuy(key:String):void {
            if(ModelEquip.canBuyEquipItem(rewardItem.item_id,true)==false){
				return;
			}
            var pos:Point = Point.TEMP.setTo(rewardItem.x + rewardItem.width * 0.5, rewardItem.y);
            pos = rewardItem['parent'].localToGlobal(pos, true);
            switch(key){
                case "sale":
                    ModelSaleShop.instance.buyGoods(this._goods_id, pos);
                    break;
                case "treasure":
                    ModelTreasure.instance.buyGoods(Number(this._goods_id)-1,pos);
                    break;
                case "equip_box":
                    ModelEquipBox.instance.buyGoods(Number(this._goods_id)-1,pos);
                    break;
            }
            
        }
    }
}