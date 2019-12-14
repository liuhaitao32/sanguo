package sg.view.fight
{
    import ui.fight.pkReportUI;
    import laya.utils.Handler;
    import sg.manager.ModelManager;
    import sg.utils.Tools;

    public class ViewPKReport extends pkReportUI{
        public function ViewPKReport(){
            this.comTitle.setViewTitle(Tools.getMsgById("_pk01"));
            this.list.itemRender = ItemPKreport;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
        }
        override public function initData():void{
            var arr:Array = ModelManager.instance.modelClimb.getPKlog();
            var newArray:Array = [];
            var myUID:Number = Number(ModelManager.instance.modelUser.mUID);
            for each(var item:Object in arr)
            {
                if(item.team[1].uid == myUID){
                    item.team.reverse();
                    item.teamWin.reverse();
                }
                newArray.push(item);
            }
            this.list.dataSource = newArray;
        }        
        private function list_render(item:ItemPKreport,index:int):void{
            item.setData(this.list.array[index]);
        }
    }
}