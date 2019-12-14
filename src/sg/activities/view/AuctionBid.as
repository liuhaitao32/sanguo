package sg.activities.view
{
    import ui.activities.auction.auctionBidUI;
    import sg.activities.model.ModelAuction;
    import sg.manager.ViewManager;
    import sg.utils.Tools;
    import laya.utils.Handler;
    import laya.events.Event;
    import sg.manager.AssetsManager;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;

    public class AuctionBid extends auctionBidUI
    {
        private var model:ModelAuction = ModelAuction.instance;
        private var currentPrice:int;
        private var myPrice:int;
        private var unit:int;
        private var lowestPrice:int;
        private var highestPrice:int;
        private var noSlide:Boolean = false;
        public function AuctionBid()
        {
            comTitle.setViewTitle(Tools.getMsgById("_public203"));
            btn_bid.label = Tools.getMsgById('550024');
            txt_hint1.text = Tools.getMsgById('550021');
            txt_hint2.text = Tools.getMsgById('550022');
            btn_bid.on(Event.CLICK, this, this._onClickBid);
			btn_add.on(Event.CLICK,this,this._onClickAdd);
			btn_sub.on(Event.CLICK,this,this._onClickSub);
			slider.on(Event.CHANGE,this,this._onSliderChange);
			slider.showLabel=false;
        }

        override public function set currArg(v:*):void {
			this.mCurrArg = v;
		}

        override public function initData():void {
            this._refreshPrice();
        }

        private function _refreshPrice():void {
            currentPrice = model.sData[currArg.index][0] || currArg.currentPrice;
            unit = model.cfg.unit;
            myPrice = lowestPrice = currentPrice + unit; // 最低出价
            icon_cost0.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), currentPrice);
            icon_cost1.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), myPrice);

            // 根据最高价格设置出价
            var coin:int = ModelManager.instance.modelUser.coin; // 当前拥有的元宝
            if (coin < lowestPrice) {
                this.closeSelf();
                return;
            }
            highestPrice = coin - coin % unit; // 设定最高出价
            if (currArg.topPrice !== -1 && currArg.topPrice < highestPrice) {
                highestPrice = currArg.topPrice; // 修正最高出价
            }
            this._revisePrice();
        }

        override public function onAdded():void {
            var md:ModelHero = ModelManager.instance.modelGame.getModelHero(currArg.hid);
            txt_gift_name.text = Tools.getMsgById('550025', [Tools.getMsgById('550029', [Tools.getMsgById(md.name)])]);
        }

        override public function onRemoved():void {
        }

        private function _onClickBid():void {
            var warning:Array = model.cfg.warning;
            if ((myPrice - currentPrice) > warning[0]) {
                ViewManager.instance.showAlert(Tools.getMsgById(warning[1], [myPrice]), Handler.create(this,this._onBid), ["coin", myPrice]);
            }
            else {
                this._onBid();
            }
        }

        private function _onClickAdd():void {
            myPrice += unit;
            this._revisePrice();
        }

        private function _onClickSub():void {
            myPrice -= unit;
            this._revisePrice();
        }

        /**
         * 修正出价
         */
        private function _revisePrice():void {
            myPrice = myPrice < lowestPrice ? lowestPrice : myPrice;
            myPrice = myPrice > highestPrice ? highestPrice : myPrice;
            noSlide = true;
            var value:int = Math.floor((myPrice - currentPrice) / (highestPrice - currentPrice) * 100);
            slider.value = value < 1 ? 1 : value;
            icon_cost1.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), myPrice);
        }

        private function _onSliderChange():void {
            if (!noSlide) {
                var price:int = lowestPrice + (slider.value - 1) / 99 * (highestPrice - lowestPrice);
                myPrice = price - price % unit;
                myPrice = myPrice < lowestPrice ? lowestPrice : myPrice;
            }
            icon_cost1.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), myPrice);
            noSlide = false;
        }

        private function _onBid(type:int = 0):void { // 0是从提示界面传入的
            if (type !== 0) return;
            var index:int = currArg.index;
            var newPrice:int = model.sData[index][0];
            var vm:ViewManager = ViewManager.instance;
            if (model.getState(index) === ModelAuction.STATE_ENDED) {
                vm.showTipsTxt(Tools.getMsgById(model.cfg.end_text));
                this.closeSelf();
            }
            if (myPrice <= newPrice) {
                vm.showTipsTxt(Tools.getMsgById(model.cfg.anew));
                this._refreshPrice();
                return;
            }
            if (myPrice === currArg.topPrice) {
                vm.showAlert(Tools.getMsgById('550046', [myPrice]), Handler.create(this, this._realBid, [myPrice, index]), null, '', true);
            }
            else {
                this._realBid(myPrice, index);
            }
        }

        private function _realBid(myPrice:int, index:int):void {
            model.bid(myPrice, index);
            this.closeSelf();
        }
    }
}