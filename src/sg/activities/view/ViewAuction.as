package sg.activities.view
{
    import ui.activities.auction.auctionPanelUI;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.activities.model.ModelAuction;
    import sg.cfg.ConfigServer;
    import sg.utils.TimeHelper;
    import sg.activities.model.ModelActivities;
    import laya.utils.Handler;
    import ui.activities.auction.auctionIconUI;
    import sg.model.ModelHero;
    import sg.manager.ModelManager;
    import sg.utils.ObjectUtil;
    import sg.utils.ArrayUtil;

    public class ViewAuction extends auctionPanelUI
    {
        private var model:ModelAuction = ModelAuction.instance;
        public function ViewAuction()
        {
            comTitle.setViewTitle(Tools.getMsgById('auction_name'), true);
            txt_hint.text = Tools.getMsgById(model.cfg.info);
            list.itemRender = AuctionBase;
            list_hero.itemRender = auctionIconUI;
            list_hero.renderHandler = new Handler(this, this._renderIcon);
            list_hero.scrollBar.hide = true;
            btn_help.on(Event.CLICK, this, this._onClickHelp);
        }

        private function _onClickHelp():void {
            ViewManager.instance.showTipsPanel(Tools.getMsgById(model.cfg.tips));
        }

        override public function set currArg(v:*):void {
			this.mCurrArg = v;
		}

        override public function initData():void {
            model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
        }

        override public function onAdded():void {
            var list_section:Array = model.cfg.list_section;
            var hideList:Boolean = !list_section || list_section.indexOf(model.actId) === -1;
            if (hideList) {
                box_hero.visible = false;
                mBox.width = 504;
            }
            else {
                box_hero.visible = true;
                mBox.width = 610;
            }
            this.refreshPanel();
        }

        /**
         * 刷新界面
         */
        private function refreshPanel():void {
            if (!model.active){
                this.closeSelf();
                return;
            }
            list.array = model.listData;
            list_hero.array = this._getHeroData();
            var index:int = ArrayUtil.findIndex(list_hero.array, function(item:Object):Boolean { return item.state === 1; }, this);
            if (index === -1) {
                index = ArrayUtil.findIndex(list_hero.array, function(item:Object):Boolean { return item.state === 2; }, this);
            }
            list_hero.scrollTo(index >= 1 ? index - 1 : 0);
        }

        private function _getHeroData():Array {
            var data:Array = ObjectUtil.entries(model.cfg.library);
            data.sort(function(a:Array, b:Array):Boolean { return parseInt(a[0]) - parseInt(b[0]); });
            var idArr:Array = data.map(function(arr:Array):Array { 
                return arr[1].map(function(arr2:Array, index: int):Object {  
                    var state:int = parseInt(arr[0]) - model.actId;
                    state = state ? state / Math.abs(state) : 0;
                    state += 1; // 0 已结束 1 进行中 2 未开始
                    if (state === 1) {
                        switch(model.getState(index)) {
                            case ModelAuction.STATE_BEFORE:
                                state = 2;
                                break;
                            case ModelAuction.STATE_BUY:
                                state = 3;
                                break;
                            case ModelAuction.STATE_ENDED:
                            case ModelAuction.STATE_SHOW:
                                state = 0;
                                break;
                        }
                    }
                    return {hid: arr2[2].awaken[0], state: state};
                }, this);
             }, this);
            return ArrayUtil.flat(idArr);
        }

        private function _renderIcon(item:auctionIconUI, index:int):void {
            var source:Object = item.dataSource;
            var hid:String = source.hid;
            var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
            item.icon.setHeroIcon(hid);
            item.txt_name.text = md.getAwakenName();
            item.txt_state.text = Tools.getMsgById(['550047', '550048', '550049', '550050'][source.state]);
            item.txt_state.color = ['#fff', '#a4fe6e', '#fff', '#a4fe6e'][source.state];
            switch(source.state) {
                case 0:
                    item.gray = true;
                    item.alpha = 0.5;
                    break;
                case 1:
                    item.gray = false;
                    item.alpha = 1;
                    break;
                case 2:
                    item.gray = false;
                    item.alpha = 0.5;
                    break;
            }
        }

        override public function onRemoved():void {
            model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
        }
    }
}