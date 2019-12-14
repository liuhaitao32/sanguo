package sg.view.task
{
    import ui.task.work_donationUI;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.model.ModelTask;
    import sg.model.ModelItem;
    import sg.model.ModelBuiding;
    import sg.manager.ViewManager;
    import sg.utils.Tools;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;

    public class ViewWorkDonation extends work_donationUI
    {
        private var mTask:Object;
        private var mNum:Number = 0;
        private var mItemId:String = "";
        private var mRe:Array;
        public function ViewWorkDonation()
        {
            this.btn.on(Event.CLICK,this,this.click);
            this.btn_add.on(Event.CLICK,this,this.click_num,[1]);
            this.btn_less.on(Event.CLICK,this,this.click_num,[-1]);
            //
            this.btn.label = Tools.getMsgById("_ftask_text01");
            //this.tTilte.text = Tools.getMsgById("_lht5");
            this.comTitle.setViewTitle(Tools.getMsgById("_lht5"));
            
            this.tAdd.text = Tools.getMsgById("_lht6");
            this.iLess.text = Tools.getMsgById("_lht7");
        }
        override public function initData():void{
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_17.png"));
            //
            this.mTask = this.currArg;
            //
            this.mRe = ModelTask.gTask_need(this.mTask.id);
            //
            this.mNum = this.mRe[0];
            if(ModelTask.gTask_self_take()[this.mTask.id].rate>=this.mRe[1]){
                this.mNum = 0;
            }
            this.btn.gray = this.mNum==0;
            this.btn_add.disabled = this.mNum==0;
            this.btn_less.disabled = this.mNum==0;
            //
            this.setUI();
        }
        private function setUI():void{
            this.tNum.text = this.mNum+"";
            this.tLess.text = this.mRe[0]+"";
            //
            var cfg:Array = ModelTask.gTask_need_cfg(this.mTask.id);
            mItemId=cfg[0];
            //
            this.award.setData(ModelBuiding.getMaterialTypeUI(mItemId),ModelTask.gTask_self_take()[this.mTask.id].rate+"");
            //
            this.btn_add.label = "+"+this.mRe[0];
            this.btn_less.label = "-"+this.mRe[0];
            this.tTalk.text = Tools.getMsgById("gtask_talk10");
            //
            //this.tInfo.text = Tools.getMsgById("_gtask7",[ModelBuiding.material_type_name[cfg[0]]+this.mRe[0],this.mRe[1]]);//"需要上缴"++" 到 "++"之间数量获得不同评价奖励";
            this.tInfo.text = Tools.getMsgById("_gtask7",[Tools.getNameByID(mItemId)+this.mRe[0],this.mRe[1]]);//"需要上缴"++" 到 "++"之间数量获得不同评价奖励";
            this.heroIcon.setHeroIcon("hero747");
        }
        private function click_num(type:int):void
        {
            var all:Number = this.mNum+this.mRe[0]*type;
            var max:Number = this.mRe[1]- ModelTask.gTask_self_take()[this.mTask.id].rate;
            max = max<1?0:max;
            //
            if(ModelBuiding.getMaterialEnough(ModelTask.gTask_need_cfg(this.mTask.id)[0],all)){
                if(type>0){
                    this.mNum = all>=max?max:all;
                }
                else{
                    this.mNum = all<=this.mRe[0]?this.mRe[0]:all;
                }
                //
                this.setUI();
            }
        }
        private function click():void
        {
            if(this.btn.gray){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht66"));
                return;
            }
            if(!Tools.isCanBuy(mItemId,mNum)){
                return;
            }
            NetSocket.instance.send(NetMethodCfg.WS_SR_DO_GTASK,{task_id:this.mTask.id,donate_num:this.mNum},Handler.create(this,this.ws_sr_do_gtask));
        }
        private function ws_sr_do_gtask(re:NetPackage):void
        {
            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            ViewManager.instance.showTipsTxt(Tools.getMsgById("_gtask8"));//捐献成功
            //
            this.closeSelf();
        }
    }
}