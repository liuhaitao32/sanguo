package sg.view.task
{
	import sg.cfg.ConfigServer;
	import sg.guide.model.ModelGuide;
	import sg.manager.EffectManager;
	import sg.model.ModelPrepare;
    import ui.task.work_conquestUI;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import laya.utils.Handler;
    import sg.model.ModelTask;
    import sg.model.ModelHero;
    import sg.utils.Tools;
    import sg.cfg.ConfigClass;
    import sg.model.ModelGame;
    import sg.view.com.HeroSendPanel;
    import sg.manager.ViewManager;
    import sg.fight.FightMain;
    import sg.map.utils.Vector2D;
    import sg.map.view.TroopAnimation;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;
	import sg.utils.StringUtil;
	import sg.model.ModelOffice;

	/**
	 * 政务山贼面板
	 * @author
	 */
    public class ViewWorkConquest extends work_conquestUI
    {
        private var mTask:Object;
        public var mTroops:Array;
        public var mTroopV:Vector2D;
        public var mHeroSendPanel:HeroSendPanel;
        private static const talk_info:Object = {gtask003:"gtask_talk04",gtask004:"gtask_talk05",gtask005:"gtask_talk06"};
        private static const talk_info2:Object = {gtask003:"gtask_talk07",gtask004:"gtask_talk08",gtask005:"gtask_talk09"};
        public function ViewWorkConquest()
        {
            this.btn_sendTroop.on(Event.CLICK,this,this.click);
            //
            this.mHeroSendPanel = new HeroSendPanel();
            this.boxMain.addChild(this.mHeroSendPanel);
            this.mHeroSendPanel.width = 594;
            this.mHeroSendPanel.height = 384;
            this.mHeroSendPanel.y = 344;
            //
            //this.iTitle.text = Tools.getMsgById("_lht8");
            this.comTitle.setViewTitle(Tools.getMsgById("_lht8"));
            
            this.btn_sendTroop.label = Tools.getMsgById("_lht9");
        }
        override public function initData():void{
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_17.png"));
            this.mTask = this.currArg[0];
            this.mTroopV = this.currArg[1];
            //
            this.tFoeLv.text = ""+this.mTask.bot_hero.lv;
            var hmd:ModelHero = new ModelHero(true);
            hmd.setData(this.mTask.bot_hero);
			
			this.tLvName.text = Tools.getMsgById('_public188');
			this.tPowerName.text = Tools.getMsgById('_public187');
			//推荐战力
			var powerValue:int = hmd.getPower(hmd.getPrepare(true, this.mTask.bot_hero));
			powerValue = ModelPrepare.getFormatPower(powerValue, ConfigServer.ftask.thief_enemy_power);
			this.comPower.setNum(powerValue);
            //this.tFoePower.text = "" + powerValue;
			this.mHeroSendPanel.mPowerRefer = powerValue;
            //
            this.tName.text = Tools.getMsgById(ModelTask.gTask_npc_name(this.mTask.id));
            this.tInfo.text = Tools.getMsgById(talk_info[this.mTask.id]);
            this.tTips.text = Tools.getMsgById(talk_info2[this.mTask.id],[this.mTask.rate]);
            this.heroIcon.setHeroIcon(hmd.id);
            //
            var cid:int = parseInt(this.mTask.city_id);
            var b:Boolean=!ModelOffice.func_flygtask();
            var troops:Array = ModelManager.instance.modelTroopManager.getMoveCityTroop(cid,b?0:-2);

            this.mHeroSendPanel.clear();
            this.mHeroSendPanel.initData([cid,troops,true,b,new Handler(this,this.hspChange),new Handler(this,this.hspTroopNull)]);
            //
            this.mHeroSendPanel.setList(false);
        }
        private function hspTroopNull(isNull:Boolean):void
        {
            this.btn_sendTroop.disabled = isNull;
        }        
        private function hspChange():void
        {
        }
        private function click():void
        {
            if(this.mHeroSendPanel.mSelectArr.length<1){
                ModelManager.instance.modelGame.checkTroopToAction(this.mTask.city_id,ConfigClass.VIEW_HERO_SEND,null,false,1,-1,3);
                this.closeSelf();
            }
            else{
                NetSocket.instance.send(NetMethodCfg.WS_SR_DO_GTASK,{task_id:this.mTask.id,donate_num:0,hid:this.mHeroSendPanel.mSelectArr[0].ct.model.hero},Handler.create(this,this.ws_sr_do_gtask),this.mTask.rate);
            }
        }
        private function ws_sr_do_gtask(re:NetPackage):void
        {
            var receiveData:* = re.receiveData;
            var rate:Number = re.otherData;
            //
            ModelManager.instance.modelUser.updateData(receiveData);
            //
            var rateAdd:Number = (ModelTask.gTask_self_take()[re.sendData.task_id].rate - rate);
            var gift:Object = null;
            if(rateAdd>0){
                gift={};
                gift[ModelTask.gTask_need_cfg(re.sendData.task_id)[0]] = rateAdd;
            }
            //

            var hids:Array = [re.sendData.hid];
            TroopAnimation.moveTroop(hids,this.mTroopV,Handler.create(this,this.inFight,[re.receiveData,gift,hids]));
            //
            this.closeSelf(); 
        }
        private function inFight(receiveData:*,gift:*,hids:Array):void
        {
			//政务山贼
            FightMain.startBattle(receiveData,this,this.outFight,[receiveData,gift,hids],true);
        }
        private function outFight(receiveData:*,re:Object,hids:Array):void
        {
            ModelManager.instance.modelUser.soloFightUpdateTroop(receiveData);
            if(re){
                ViewManager.instance.showRewardPanel(re);
                TroopAnimation.backTroop(hids);
            }                       
        }
    }
}