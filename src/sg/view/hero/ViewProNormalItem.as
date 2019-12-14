package sg.view.hero
{
    import ui.hero.heroProNormalItemUI;
    import laya.events.Event;
    import sg.model.ModelHero;
    import laya.utils.Handler;
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;

    public class  ViewProNormalItem extends heroProNormalItemUI{
        private var mArmyItems:Array;
        private var mHandler:Handler;
        public static var hero_army_up_normal:String = "hero_army_up_normal";
        public function ViewProNormalItem():void{
            this.btn_no.on(Event.CLICK,this,this.click,[0]);
            this.btn_ok.on(Event.CLICK,this,this.click,[1]);
            this.setMust.on(Event.CLICK,this,this.click_must);
            this.btn_ok.label = Tools.getMsgById("_public183");
            this.btn_no.label = Tools.getMsgById("_shogun_text03");
            this.comTitle.setViewTitle(Tools.getMsgById("200034"));
        }
        override public function initData():void{
            this.mArmyItems = this.currArg[0];
            this.mHandler = this.currArg[1];
            //
            this.tPay.text = Tools.getMsgById("_public17");//本次将消耗通用道具
            this.tPayNum.text = ""+this.mArmyItems[3];
            this.tHave.text = Tools.getMsgById("_public18",[""])//拥有
            this.tHaveNum.text = ""+ ModelHero.getArmyItemNum(ConfigServer.army.all_material);
            //
            this.tMust.text = Tools.getMsgById("193006");
            this.setMust.selected = false;
            //
        }
        private function click_must():void
        {
            this.setMust.selected = !this.setMust.selected;
            //
        }
        private function click(type:int):void{
            if(type==1){
                this.mHandler.run();
                if(this.setMust.selected){
                    Tools.setAlertIsDel(ViewProNormalItem.hero_army_up_normal);
                }
            }
            this.closeSelf();
        }
    }
}