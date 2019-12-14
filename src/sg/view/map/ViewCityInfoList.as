package sg.view.map
{
    import ui.map.cityInfoListUI;
    import laya.utils.Handler;

    public class ViewCityInfoList extends cityInfoListUI{
        public function ViewCityInfoList(){
            this.list.itemRender = ItemCityInfo;
            this.list.renderHandler = new Handler(this,this.list_render);
        }
        override public function initData():void{
            this.list.array = [1,2,3,4,5,6];
        }
        private function list_render(item:ItemCityInfo,index:int):void{
            
        }
    }
}