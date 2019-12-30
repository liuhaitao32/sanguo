package sg.festival.view
{
    import laya.events.Event;
    import sg.manager.AssetsManager;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import sg.model.ModelItem;
    import sg.utils.Tools;
    import laya.maths.Point;
    import sg.utils.ObjectUtil;
    import ui.festival.festivalSaleBaseUI;
    import sg.festival.model.ModelFestivalLuckShop;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import laya.display.Sprite;
    import sg.manager.ViewManager;
    import sg.model.ModelEquip;

    public class FestivalSaleBase extends festivalSaleBaseUI
    {
        private var rewardItemArr:Array = [];
        private var _goods_id:String;
		private var aniExp:Animation;
        public function FestivalSaleBase()
        {
            this.hintTxt1.text = Tools.getMsgById('_public104');
            this.hintTxt2.text = Tools.getMsgById('_jia0053');
            //this.btn_price.on(Event.CLICK, this, this._onClickBuy);

			// 添加特效
			aniExp = EffectManager.loadAnimation("glow_sale");
            aniExp.x = this.width * 0.5;
            aniExp.y = this.height * 0.5;
            this.addChild(aniExp);
            this.visible = false;
        }

        override public function set dataSource(source:*):void {
            if (!source) return;
			this._dataSource = source;
            var reward:Object = source.reward;
            var iid:String = ObjectUtil.keys(reward)[0];
            this.rewardItem.setData(iid, reward[iid], -1);
            sellOut.visible = source.buyTimes >= source.limit;
            this.rebateTxt.visible = this.btn_price.visible = !sellOut.visible;
            this.hintBox.visible = this.rewardBox.gray = false;
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

            aniExp.visible = source.discount === 1;
            if(source.discount === 10){
                this.rebateTxt.text = "";
            }else{
                this.rebateTxt.text = Tools.getMsgById('_jia0054', [source.discount]);
            }

            this.htmlLabel.style.color="#dee3ff";
            this.htmlLabel.style.fontSize=16;
            this.htmlLabel.style.align="center";
            this.htmlLabel.style.valign="bottom";
            this.htmlLabel.innerHTML=this.sellOut.visible ? "" : Tools.getMsgById("treasure_text01",[(source.limit - source.buyTimes),source.limit]);
            
            var costId:String = source.price[0];
            var realPrice:int = Math.floor(source.price[1] * source.discount * 0.1); 
            this.btn_price.setData(AssetsManager.getAssetItemOrPayByID(costId), realPrice);
            this._goods_id = source.goods_id;
            btn_price.off(Event.CLICK, this, this._onClickBuy);
            btn_price.on(Event.CLICK, this, this._onClickBuy,[source.goods_id]);
            btn_price.disabled = realPrice > ModelItem.getMyItemNum(costId);
        }

        private function _onClickBuy(id:String):void {
            var pos:Point = Point.TEMP.setTo(rewardItem.x + rewardItem.width * 0.5, rewardItem.y);
            pos = rewardItem['parent'].localToGlobal(pos, true);
            var price:Array = _dataSource.price;
            if(!Tools.isCanBuy(price[0], price[1] * 0.1 * _dataSource.discount)){
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0060'));
                return;
            }
            if(ModelEquip.canBuyEquipItem(rewardItem.item_id, true)) {
                ModelFestivalLuckShop.instance.buyGoods(id, pos);
            }
        }
    }
}