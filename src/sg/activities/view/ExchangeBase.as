package sg.activities.view
{
    import laya.events.Event;
    import laya.maths.Point;
    import sg.activities.model.ModelExchange;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import sg.model.ModelItem;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;
    import ui.activities.exchange.exchangeBaseUI;
    import sg.manager.ViewManager;
    import sg.model.ModelEquip;

    public class ExchangeBase extends exchangeBaseUI
    {
        private var rewardItemArr:Array = [];
        private var itemId:String;
        public function ExchangeBase()
        {
            this.btn_price.on(Event.CLICK, this, this._onClickBuy);
        }

        private function set dataSource(source:Object):void
        {
            if (!source) return;
			this._dataSource = source;
            this.text0.text = Tools.getMsgById("_public244");
			var arr:Array=ModelManager.instance.modelProp.getRewardProp(source.reward);
            itemId = arr[0][0];
            this.rewardItem.setData(itemId, arr[0][1], -1);
            box_limit.visible = this.btn_price.visible = source.state < 2;
            sellOut.visible = source.state === 2;

            
            box_own.visible = false;
            var equipModel:ModelEquip = ModelManager.instance.modelGame.getModelEquip(itemId);
            if (equipModel && equipModel.isMine()) {
                box_limit.visible = this.btn_price.visible = sellOut.visible = false;
                box_own.visible = true;
            }

            this.nameTxt.text = ModelItem.getItemName(itemId);
            var type:int = ModelItem.getItemType(itemId);
            if (type === 7) { // 英雄碎片
                this.img_type.visible = true;
                var heroId:String = itemId.replace('item', 'hero');
                var heroModel:ModelHero=ModelManager.instance.modelGame.getModelHero(heroId);
                this.img_type.skin = heroModel.getRaritySkin(true);
            }
            else {
                this.img_type.visible = false;
            }

            this.htmlLabel.style.color="#dee3ff";
            this.htmlLabel.style.fontSize=17;
            this.htmlLabel.style.align="center";
            this.htmlLabel.style.valign="bottom";
            this.htmlLabel.innerHTML=this.sellOut.visible ? "" : Tools.getMsgById("treasure_text01",[(source.limit - source.buyTimes),source.limit]);
            this.btn_price.setData(source.imgSrc, source.price);
        }
         
		private function setReward(reward:Object):void
		{
			var props:Object = ModelManager.instance.modelProp.getRewardProp(reward);
			var len:int = props.length;
            this._removeRewardItems();
            var oriX:Number = 200;
            var oriY:Number = 12;
			for(var i:int = 0; i < len; i++)
			{
				var source:Array=props[i];
				var rewardItem:RewardItem = RewardItemPool.borrowItem();
				rewardItemArr.push(rewardItem);
				rewardItem.setReward(source);
                rewardItemArr.push(rewardItem);
			    rewardItem.scale(0.85, 0.85);
				this.addChild(rewardItem);
                rewardItem.pos(oriX + (rewardItem.width + 2) * i, oriY);
			}
		}

        private function _removeRewardItems():void {
            for(var index:int = 0, len:int = rewardItemArr.length; index < len; index++)
            {
                var item:RewardItem = rewardItemArr[index];
                item.destroy();
            }
            rewardItemArr = [];
        }

        private function _onClickBuy():void {
            if (_dataSource.state === 0) {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('502067', [ModelManager.instance.modelProp.getItemProp(_dataSource.itemId).getName(true)]));
                return;
            }
            var pos:Point = Point.TEMP.setTo(rewardItem.x + rewardItem.width * 0.5, rewardItem.y + rewardItem.height * 0.5);
            pos = rewardItem['parent'].localToGlobal(pos, true);
            if (ModelEquip.canBuyEquipItem(rewardItem.item_id, true)) {
                ModelExchange.instance.buyGoods(_dataSource.shopIndex, _dataSource.goodsIndex, pos);
            }
        }
    }
}