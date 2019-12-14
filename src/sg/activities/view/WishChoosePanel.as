package sg.activities.view
{
    import laya.events.Event;
    import laya.utils.Handler;
    import sg.activities.model.ModelWish;
    import sg.utils.Tools;
    import ui.activities.wish.wish_chooseUI;
    import ui.bag.bagItemUI;
    import sg.utils.ArrayUtil;

    public class WishChoosePanel extends wish_chooseUI
    {
        private var model:ModelWish = ModelWish.instance;
        private var wishArr:Array;
        private var wish_rewchoo_num:int;
        public function WishChoosePanel()
        {
            this.wishArr = this.model.getWishArray();
            //this.titleTxt.text = Tools.getMsgById('_jia0012');
            this.comTitle.setViewTitle(Tools.getMsgById("_jia0012"));
            this.chooseTips.text = Tools.getMsgById('_jia0013');
			this.choosePool.itemRender = bagItemUI;
			this.rewardList.itemRender = bagItemUI;
            this.choosePool.scrollBar.hide = true;
            this.choosePool.renderHandler = new Handler(this, this._updateItem);
            this.btn_wish.label = Tools.getMsgById("_jia0039");
            this.btn_wish.on(Event.CLICK, this, this._onWish);
        }

        override public function onAdded ():void {
            this._initPanel();
        }

        private function _initPanel():void {
            var cfg:Object = this.model.getConfig();
            this.wish_rewchoo_num = cfg['wish_rewchoo_num'];
            var arr:Array = this.choosePool.array = cfg['wish_rewpond'];

            this.rewardList.array = this.model.getRewardArray();
            // this.rewardList.renderHandler = new Handler(this, this._updateItem2);

            var len:int = this.wishArr.length;
            for(var i:int = 0; i < len; i++) {
                var index:int = this.wishArr[i];
                arr[index]['imgSelected'] = true;
            }
            
            this._refreshPanel();
        }

        private function _onWish():void {
            if(this.wishArr.length === 4) {
                this.model.makeAWish();
                this.closeSelf();
            }
        }

        private function _updateItem(item:bagItemUI, index:int):void
        {
            var source:* = item.dataSource;
            item.setData(source[0], source[1], -1);
            item.setSelection(source.imgSelected);
            item.off(Event.CLICK, this, this._selectItem);
            item.on(Event.CLICK, this, this._selectItem, [index]);
        }

        private function _selectItem(index:int, event:Event):void
        {
            var item:bagItemUI = event.currentTarget as bagItemUI;
            var pos:int = this.wishArr.indexOf(index);
            item.dataSource['imgSelected'] = false;
            if (pos === -1) {
                if (this.wishArr.length < this.wish_rewchoo_num) {
                    this.wishArr.push(index);
                    item.dataSource['imgSelected'] = true;
                }
            }
            else{
                this.wishArr.splice(pos, 1);
            }
            this.choosePool.refresh();
            this._refreshPanel();
        }

        private function _refreshPanel():void {
            var index:int = 0;
            var len:int = this.choosePool.array.length;
            var cfg:Object = this.model.getConfig();
            var wish_rewpond:Array = cfg['wish_rewpond'];
            var i:int = 0;
            for(i = 0, len = this.wish_rewchoo_num; i < len; i++) {
                var rewardArr:Array = this.model.getRewardArray();
                if (i < this.wishArr.length) {
                    index = this.wishArr[i];
                    rewardArr[i] = wish_rewpond[index];
                } else {
                    rewardArr[i] = null;
                }         
            }
            var chooseArray:Array = this.wishArr.map(function(index:int):Array { 
                var arr:Array = wish_rewpond[index].slice(0, 2);
                arr.push(1);
                return arr;
             });
            this.rewardList.array = ArrayUtil.padding(chooseArray, 4, ['', 0, -1]);
            this.chooseTxt.text = this.wishArr.length + '/' + this.wish_rewchoo_num;
            this.btn_wish.gray = this.wishArr.length < this.wish_rewchoo_num;
        }
    }
}