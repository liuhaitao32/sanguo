package sg.activities
{
    import laya.ui.List;
    import sg.view.com.comIcon;
    import laya.utils.Handler;
    import sg.manager.ModelManager;

    public class ComIconList extends List
    {
        public function ComIconList() {
            this.itemRender = comIcon;
            this.renderHandler = new Handler(this, this._onRenderItem)
        }

        public function set data(obj:Object):void {
            this.array = ModelManager.instance.modelProp.getRewardProp(obj);
        }

        private function _onRenderItem(item:comIcon, index:int):void {
            var arr:Array = item.dataSource;
            item.setData(arr[0], arr[1], -1);
        }
    }
}