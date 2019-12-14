package sg.view.map
{
    import ui.map.troop_quicklyUI;
    import sg.map.model.MapModel;
    import sg.model.ModelTroop;
    import sg.map.model.entitys.EntityMarch;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import sg.scene.constant.EventConstant;
    import sg.cfg.ConfigServer;
    import sg.view.com.ComPayType;
    import laya.ui.Image;
    import sg.model.ModelItem;
    import sg.manager.AssetsManager;
    import sg.utils.StringUtil;
    import laya.events.Event;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.model.ModelGame;
    import laya.ui.Button;
    import sg.manager.ViewManager;

    public class ViewTroopQuickly extends troop_quicklyUI
    {
        private var mTroop:ModelTroop;
        private var mMarch:EntityMarch;
        private var mLastTime:Number = 0;
        private var mAllTime:Number = 0;
        public function ViewTroopQuickly()
        {
            this.comTitle.setViewTitle(Tools.getMsgById("_lht23"));
            this.tText1.text = Tools.getMsgById("_public246");
            this.tText2.text = Tools.getMsgById("_public247");
            this.img1.x = this.tText2.x - this.img1.width - 1;
        }
        override public function initData():void{
            this.mTroop = this.currArg;
            this.mMarch = MapModel.instance.marchs[this.mTroop.id];
            this.mLastTime = this.mMarch.remainTime();
            this.mAllTime = this.mMarch.remainTime(0);
            //item_army_go
            //
            this.timer.clear(this,this.timerClip);
            this.timer.loop(1000,this,this.timerClip,[true]);
            this.timerClip(false);
            //
            ModelManager.instance.modelGame.off(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE, this,this.updateData);
            ModelManager.instance.modelGame.on(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE, this,this.updateData);
            // ModelManager.instance.modelTroopManager.sendSpeedUpTroops(this.mModel.hero, 2);
            //
            this.setUI();
        }
        private function updateData():void
        {
            this.mMarch = MapModel.instance.marchs[this.mTroop.id];
            if(this.mMarch){
                this.mLastTime = this.mMarch.remainTime();
            }
            else{
                this.closeSelf();
            }
            //
        }
        override public function onRemoved():void{
            ModelManager.instance.modelGame.off(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE, this,this.updateData);
            this.timer.clear(this,this.timerClip);
        }
        private function timerClip(clip:Boolean):void
        {
            if(clip){
                this.mLastTime -=1;
            }
            if(this.mLastTime >1){
                this.ttime.text = Tools.getTimeStyle(this.mLastTime*Tools.oneMillis);
                this.imgText.width=this.ttime.width+12;
                this.checkBar();
            }
            else{
                this.timer.clear(this,this.timerClip);
                this.closeSelf();
            }
        }
        private function checkBar():void
        {
            this.bar_time.value = 1-this.mLastTime/this.mAllTime;
        }
        private function setUI():void
        {
            this.setItemUI(this.num1 as ComPayType,this.btn1,this.icon1,0);
            this.setItemUI(this.num2 as ComPayType,this.btn2,this.icon2,1);
        }
        private function setItemUI(num:ComPayType,btn:Button,icon:Image,type:Number):void
        {
            var itemCfg:Array = ConfigServer.system_simple.item_army_go[type];
            var myItemNum:Number = ModelItem.getMyItemNum(itemCfg[0]);
            var coinNum:Number = itemCfg[2];
            var addNum:Number = itemCfg[1];

            if(myItemNum>0){
                num.setData(AssetsManager.getAssetsICON(ModelItem.getItemIcon(itemCfg[0])),myItemNum+"/1");
            }
            else{
                num.setData(AssetsManager.getAssetsUI(ModelItem.getItemIcon("coin")),coinNum);
            }
            icon.skin = AssetsManager.getAssetsICON(ModelItem.getItemIcon(itemCfg[0]));
            // btn.setData("",Tools.getMsgById("_country32",[StringUtil.numberToPercent(addNum)]),-1,-1);//移动时间减少
            //
            btn.label = Tools.getMsgById("_country32",[StringUtil.numberToPercent(addNum)]);
            btn.off(Event.CLICK,this,this.click);
            btn.on(Event.CLICK,this,this.click,[type]);
        }
        private function click(n:Number):void
        {
            if(this.mLastTime<ConfigServer.world.troop_move_speedup_limit_time){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht43"));//距离抵达不足10秒
                return;
            }
            var itemCfg:Array = ConfigServer.system_simple.item_army_go[n];
            var myItemNum:Number = ModelItem.getMyItemNum(itemCfg[0]);
            var coinNum:Number = itemCfg[2];
            if(myItemNum<=0){
                if(!Tools.isCanBuy("coin",coinNum)){
                    return;
                }
            }
            ModelManager.instance.modelTroopManager.sendSpeedUpTroops(this.mTroop.hero, n,Handler.create(this,this.sendBack));
        }
        private function sendBack(re:NetPackage):void
        {
            ModelManager.instance.modelUser.updateData(re.receiveData);
            ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht39"));
            // this.initData();
            this.setUI();
        }
    }
}