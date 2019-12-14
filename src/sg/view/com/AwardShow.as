package sg.view.com
{
    import ui.com.award_showUI;
    import ui.bag.bagItemUI;
    import laya.utils.Handler;
    import sg.model.ModelItem;

    public class AwardShow extends award_showUI{
        public function AwardShow(){
            this.list.itemRender = bagItemUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
        }
        override public function initData():void{
            var award:Object = this.currArg;
            var arr:Array = [];
            for(var key:String in award)
            {
                arr.push([key,award[key]]);   
            }
            this.list.dataSource = arr;
        }
        private function list_render(item:bagItemUI,index:int):void{
            var d:Array = this.list.array[index];
            //item.setIcon(ModelItem.getItemIcon(d[0]));
            item.setData(d[0]);
            item.setName("");
        }
    }   
}