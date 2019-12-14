package sg.activities.view
{
    import laya.events.Event;
    import laya.ui.ISelect;
    import laya.utils.Handler;
    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelExchange;
    import sg.manager.AssetsManager;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import ui.activities.exchange.exchangeShopUI;
    import laya.ui.Button;
    import sg.manager.ViewManager;
    import sg.view.com.ComPayType;
    import sg.model.ModelGame;
    import sg.model.ModelItem;
    import sg.model.ModelEquip;
    import sg.utils.ArrayUtil;

    public class ExchangeShop extends exchangeShopUI
    {
        private var model:ModelExchange = ModelExchange.instance;
        private var consume_items:Array;
        private var tabListData:Array;
        private var shopIndex:int;
        public function ExchangeShop()
        {
            list.left = this.list.spaceX = this.list.spaceY = 8;
			list.itemRender = ExchangeBase;
			list_tab.itemRender = ExchangeTabBase;
            list.scrollBar.hide = list_tab.scrollBar.hide = true;
            model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            this.on(Event.DISPLAY, this, this._onDisplay);
            hintTxt.text = Tools.getMsgById('_jia0052');
            consume_items = model.cfg['consume_items'];
            var sort_by:Array = model.cfg['sort_by'];
            var oriData:Array = model.goodsData.map(function(item:Array, index):Object {
                var goodsId:String = item[0];
                var itemId:String = consume_items[index]
                var name:String = ModelManager.instance.modelProp.getItemProp(itemId).getName(true);
                return {
                    shop_index: index, 
                    itemId: itemId, 
                    name: name, 
                    num: 0, 
                    locked: !goodsId, 
                    selected: false, 
                    red: false, 
                    handler: null
                }; 
            }, this);
            // 重新排序 并过滤掉未开启的商店
            tabListData = [];
            for(var i:int = 0, len:int = sort_by.length; i < len; i++) {
                var itemId:String = sort_by[i];
                var obj:Object = ArrayUtil.find(oriData, function(item:Object):Boolean { return item.itemId === itemId }, this);
                if (obj && !obj.locked) {
                    obj.handler = new Handler(this, this.tab_select, [tabListData.length])
                    tabListData.push(obj);
                }
            }

            Tools.textLayout(this.hintTxt,this.timeTxt,this.timeImg);
        }

        private function _onDisplay():void {
            Laya.timer.loop(1000, this, this.refreshtime);
            this.refreshtime();
            list_tab.selectedIndex = 0;
            this.tab_select(0); // 这行有用  不能删
            this.refreshPanel();
        }

        private function tab_select(index:int):void {
            tabListData.forEach(function (item:Object):void {
                item.selected = false;
                if (tabListData.indexOf(item) === index) {
                    item.selected = true;
                    shopIndex = item.shop_index;
                }
            }, this);
            this.refreshPanel();
        }

        private function _onClickShopCoin(itemId:String):void
        {
            var num:int = ModelItem.getMyItemNum(itemId);
            ViewManager.instance.showItemTips(itemId, num);
        }

        private function itemClick(index:int):void {
            ViewManager.instance.showTipsTxt(Tools.getMsgById('502066'));
        }

		public function removeCostumeEvent():void {
            Laya.timer.clear(this, this.refreshtime);
			this.model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
		}

        private function refreshPanel():void {
            if (list_tab.selectedIndex < 0) return;
            tabListData.forEach(function (item:Object):void {
                item.num = ModelItem.getMyItemNum(item.itemId);
                item.red = model.checkRedByShopIndex(item.shop_index);
            }, this);
            var goodsId:String = model.goodsData[shopIndex][0];
            var goodsList:Array = model.cfg.shoplists[shopIndex][goodsId] || [];
            this.buildGoosData(goodsList);
            list.array = goodsList;
            list_tab.array = tabListData.filter(function(item:*):Boolean {return !item.locked});
        }

        private function buildGoosData(goodsList:Array):void {          
            var itemId:String = consume_items[shopIndex];
            var buyTimesData:Object = model.goodsData[shopIndex][1];
            var num:int = ModelItem.getMyItemNum(itemId);
            for(var i:int = 0, len:int = goodsList.length; i < len; i++) {
                var obj:Object = goodsList[i];
                obj.shopIndex = shopIndex;
                obj.itemId = itemId;
                obj.imgSrc = AssetsManager.getAssetsICON(itemId+ '.png');
                obj.goodsIndex = i;
                obj.buyTimes = 0;
                if (buyTimesData[obj.goodsIndex] is Number) obj.buyTimes = buyTimesData[obj.goodsIndex];
                obj.state = obj.buyTimes >= obj.limit ? 2: (num < obj.price ? 0 : 1);
            }
        }

        private function refreshtime():void {
            this.timeTxt.text = model.getTimeString();
        }
    }
}