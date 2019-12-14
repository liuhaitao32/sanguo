package sg.activities.view
{
    import ui.activities.payChoose.payChooseBaseUI;
    import sg.utils.ObjectUtil;
    import sg.manager.ModelManager;

    public class PayChooseBase extends payChooseBaseUI
    {
        public function PayChooseBase()
        {
			checkBox.mouseEnabled = false;
			checkBox.selected = img_border.visible = false;
        }

        private function set dataSource(source:Object):void
        {
            if (!source) return;
			this._dataSource = source;
			var arr:Array=ModelManager.instance.modelProp.getRewardProp(source.reward);
            this.rewardItem.setData(arr[0][0], arr[0][1], -1);
            this.selected = source.selected;
        }

        public function set selected(value:Boolean):void
        {
			checkBox.selected = value;
            img_border.visible = value;
        }
    }
}