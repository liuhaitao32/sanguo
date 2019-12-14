package sg.view.more
{
    import ui.more.fight_logUI;
    import ui.more.item_fight_logUI;
    import laya.utils.Handler;
    import sg.model.ModelOfficial;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.utils.Tools;
    import sg.manager.AssetsManager;
    import sg.model.ModelItem;

    public class ViewFightLog extends fight_logUI
    {
        private var mLog:Array;
        public function ViewFightLog()
        {
            this.list.itemRender = item_fight_logUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
        }
        override public function initData():void{
            this.mLog = this.currArg;
            //
            //this.tTitle.text = Tools.getMsgById("_npc_info11");//战斗情报
            this.comTitle.setViewTitle(Tools.getMsgById("_npc_info11"));
            this.list.dataSource = this.mLog;  
            this.text0.text=(this.list.array.length==0)?Tools.getMsgById("_public199"):"";
        }
        private function list_render(item:item_fight_logUI,index:int):void
        {
            var data:Array = this.list.array[index];
            item.tTime.text = Tools.dateFormat(data[0]*Tools.oneMillis,1);
            item.tName.text = ModelOfficial.getCityName(data[1]);
            item.award.setData(AssetsManager.getAssetsICON(ModelItem.getItemIcon("item041")),data[5]);
            //
            item.btn.off(Event.CLICK,this,this.click);
            item.btn.on(Event.CLICK,this,this.click,[data]);
            // [时间,cid,守方,攻方,谁赢了,奖励,我是否输赢,兵力,杀部队,杀敌,阵亡,团队奖励];

            item.icon.skin = AssetsManager.getAssetsUI(data[6]?"icon_win06.png":"icon_win07.png");
        }
        private function click(data:Array):void
        {
            ViewManager.instance.showView(ConfigClass.VIEW_FIGHT_LOG_INFO,data);
        }
    }
}