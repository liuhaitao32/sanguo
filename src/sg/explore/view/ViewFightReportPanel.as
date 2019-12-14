package sg.explore.view
{
    import ui.explore.fight_reportUI;
    import sg.utils.Tools;
    import laya.utils.Handler;
    import sg.explore.model.ModelTreasureHunting;

    public class ViewFightReportPanel extends fight_reportUI
    {
        public static const NORMAL:String = 'normal';
        public static const GARBED:String = 'garbed';
        public function ViewFightReportPanel()
        {
            comTitle.setViewTitle(Tools.getMsgById('_explore025'));
            tab.labels = [Tools.getMsgById('_explore030'), Tools.getMsgById('_explore027')].join();
            tab.selectHandler = new Handler(this,this.tab_select);
            txt_hint.text = Tools.getMsgById('_explore031', [Math.floor(ModelTreasureHunting.instance.cfg.report_time / 60)]);
            txt_msg.text = Tools.getMsgById('_explore061');
			this.list.itemRender = ItemFightReport;
			this.list.scrollBar.hide = true;
        }

        override public function onAddedBase():void {
            super.onAddedBase();
            this.tab.selectedIndex = 0;
        }

        private function tab_select(index:int):void {
            var dataArr:Array = this.currArg[index];
            dataArr = dataArr || [];
            dataArr.forEach(function (item):void { item.state = index === 0 ? NORMAL : GARBED }, this);       
            box_hint.visible = Boolean(dataArr.length === 0);
            list.array = dataArr;
        }
    }
}