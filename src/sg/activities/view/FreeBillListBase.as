package sg.activities.view
{
    import laya.events.Event;

    import sg.activities.model.ModelFreeBill;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import sg.model.ModelItem;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;

    import ui.activities.freeBill.freeBillBaseUI;
    import laya.maths.Point;
    import sg.manager.AssetsManager;

    public class FreeBillListBase extends freeBillBaseUI
    {
        private var rewardItemArr:Array = [];
        private var _goods_id:String;
        public function FreeBillListBase()
        {
            this.btn_price.on(Event.CLICK, this, this._onClickBuy);
        }

        override public function set dataSource(source:*):void {
            if (!source) return;
			this._dataSource = source;
            var reward:Object = source.reward;
            var iid:String = ObjectUtil.keys(reward)[0];
            this.rewardItem.setData(iid, reward[iid], -1);
            this.btn_price.visible = source.state !== 2;
            this.sellOut.visible = source.state === 2;
            this.btn_price.gray = ModelFreeBill.instance.actState !== 1;
            this.nameTxt.text = ModelItem.getItemName(iid);
            var type:int = ModelItem.getItemType(iid);
            if (type === 7) { // 英雄碎片
                this.img_type.visible = true;
                var heroId:String = iid.replace('item', 'hero');
                var heroModel:ModelHero=ModelManager.instance.modelGame.getModelHero(heroId);
                this.img_type.skin = heroModel.getRaritySkin(true);
                nameTxt.x = img_type.x + img_type.width + 10;
            }
            else {
                nameTxt.x = nameTxtPanel.x + (nameTxtPanel.width - nameTxt.width) * 0.5;
                this.img_type.visible = false;
            }

            this.htmlLabel.style.color="#dee3ff";
            this.htmlLabel.style.fontSize=16;
            this.htmlLabel.style.align="center";
            this.htmlLabel.style.valign="bottom";
            this.htmlLabel.innerHTML=this.sellOut.visible ? "" : Tools.getMsgById("treasure_text01",[(source.limit - source.buyTimes), source.limit]);
            btn_price.setData(AssetsManager.getAssetItemOrPayByID("coin"), source.price);
            this._goods_id = source.goods_id + "";
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
            var pos:Point = Point.TEMP.setTo(rewardItem.x + rewardItem.width * 0.5, rewardItem.y + rewardItem.height * 0.5);
            pos = rewardItem['parent'].localToGlobal(pos, true);
            ModelFreeBill.instance.buyGoods(this._goods_id, pos);
        }
    }
}