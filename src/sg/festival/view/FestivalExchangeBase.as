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
    import sg.festival.model.ModelFestivalLuckShop;
    import ui.festival.festival_exchange_baseUI;
    import sg.activities.view.RewardItem;
    import sg.festival.model.ModelFestivalExchange;
    import sg.manager.ViewManager;
    import sg.model.ModelEquip;

    public class FestivalExchangeBase extends festival_exchange_baseUI
    {
        private var rewardItemArr:Array = [];
        private var _goods_id:String;
        public function FestivalExchangeBase()
        {
            txt_hint1.text = Tools.getMsgById('_festival007');
            Tools.textFitFontSize(txt_hint1);
            txt_hint2.text = Tools.getMsgById('_festival001');
            Tools.textFitFontSize(txt_hint2);
            btn_get.label = Tools.getMsgById('_festival008');
            Tools.textFitFontSize(btn_get);
			list.itemRender = NeedItem;
            btn_get.on(Event.CLICK, this, this._onClickBuy);
        }

        override public function set dataSource(source:*):void {
            if (!source) return;
			this._dataSource = source;
            _goods_id = source.goods_id;
            var reward:Object = source.reward;
            var iid:String = ObjectUtil.keys(reward)[0];
            this.rewardItem.setData(iid, reward[iid], -1);
            var noLimit:Boolean = source.limit === -1;
            txt_hint2.visible = img_num_panel.visible = txt_num.visible = !noLimit;
            btn_get.visible = noLimit || source.buyTimes < source.limit;
            sellOut.visible = !btn_get.visible;
            txt_num.text = String(source.limit - source.buyTimes);
            list.array = source.need;
            var notEnough:Boolean = source.need.some(function(need:Array):Boolean { return ModelItem.getMyItemNum(need[0]) < need[1] }, this);
            btn_get.disabled = btn_get.visible && notEnough; 
        }

        private function _onClickBuy(id:String):void {
            // var pos:Point = Point.TEMP.setTo(rewardItem.x + rewardItem.width * 0.5, rewardItem.y);
            // pos = rewardItem['parent'].localToGlobal(pos, true);
            if(ModelEquip.canBuyEquipItem(rewardItem.item_id, true)) {
                ModelFestivalExchange.instance.exchangeGood(_goods_id);
            }
        }
    }
}