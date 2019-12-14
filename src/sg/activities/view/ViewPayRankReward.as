package sg.activities.view
{
    import sg.utils.Tools;
    import sg.manager.ViewManager;
    import avmplus.finish;
    import laya.events.Event;
    import ui.activities.payRank.payRankRewardUI;
    import sg.activities.model.ModelPayRank;
    import laya.utils.Handler;

    public class ViewPayRankReward extends payRankRewardUI
    {
        public var model:ModelPayRank = ModelPayRank.instance;
        private var splitArr:Array = model.cfg.split_arr;
        public function ViewPayRankReward() {
            com_title.setViewTitle(Tools.getMsgById('pay_rank0'));
            list.itemRender = PayRankRewardBase;
            list.scrollBar.hide = true;
            tab.selectHandler = new Handler(this, this._tabSelect);

            var endStr:String = model.cfg.end_time.join(Tools.getMsgById('_public108')) + Tools.getMsgById('_public109');
            txt_hint.text = Tools.getMsgById('pay_rank4', [endStr]);
            txt_none.text = Tools.getMsgById('pay_rank8');

            // 设置标签文字
            tab.labels = splitArr.slice(0, 3).map(function(start:int, index:int):String {
                return Tools.getMsgById('pay_rank7', [(start+1) + '-' + splitArr[index + 1]]);
            }, this).join();
        }

        override public function initData():void {
        }

        override public function onAdded():void {
            tab.selectedIndex = 0;
        }

        private function _tabSelect(index:int):void {
            list.array = model.rankDataArr.slice(splitArr[index], splitArr[index + 1]);
            box_hint.visible = !Boolean(list.array.length);
        }

        override public function onRemoved():void {
            tab.selectedIndex = -1;
        }
    }
}
