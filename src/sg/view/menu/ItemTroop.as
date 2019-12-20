package sg.view.menu
{
    import ui.menu.itemTroopUI;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.model.ModelTroop;
    import sg.utils.Tools;
    import sg.model.ModelTroopManager;
    import sg.manager.ModelManager;
    import sg.map.model.entitys.EntityMarch;
    import sg.model.ModelHero;
    import sg.model.ModelGame;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import sg.model.ModelClimb;
    import sg.scene.constant.EventConstant;

    public class ItemTroop extends itemTroopUI{
        public var mModel:ModelTroop;
        private var mMarch:EntityMarch;
        private var mMarchTime:Number;
        private var mFighting:Animation;
        private var mNewClip:Animation;
        private var mPhValue:Number = 1;
        private var mData:Object;
        private var isFightingClip:Number = -1;
        private var isNewTroop:Number = -1
        public function ItemTroop():void{
            
        }
        public function setSelect(b:Boolean):void{
            this.mSelect.visible = b;
        }
        public function initData(data:Object):void{
            this.mData = data;
            this.mModel = null;
            this.mModel = data.troop;
            //
            this.checkUI();
        }
        private function checkUI():void{
            //
            this.heroNull.visible = false;
            this.heroIcon.visible = false;
            this.sLock.visible = false;
            this.sNull.visible = false;
            this.sTimer.visible = false;
            this.sStatus.visible = false;
            this.sHome.visible = false;
            this.sMove.visible = false;
            this.sFight.visible = false;
            this.sMoveQuick.visible = false;
            this.tNull.visible = false;
            this.tTimer.visible = false;
            this.tStatus.visible = false;
            this.pFight.visible = false;
            //
            this.timer.clear(this,this.troopRunning);
            if(this.mMarch){
                this.mMarch.off(EventConstant.REPEAT,this,this.repeatMarch);                
            }
            //
            this.mMarch = null;
            this.mMarchTime = 0;
            //
            var pkIng:Boolean = false;
            //
            this.pFight.value = 0;

            var clearFightClip:Boolean = true;
            var fightClip:int = 0;
            //
            if(!Tools.isNullObj(this.mModel)){
                //
                var status:int = this.mModel.state;//0;//this.mModel.status;
                //
                switch(status){
                    case ModelTroop.TROOP_STATE_IDLE:
                    
                        pkIng = this.mModel.isReadyFight;
                        // trace("是否战斗中",pkIng);
                        if(pkIng){
                            var pi:int = this.mModel.index;//<1 ,,>=100 备战排名
                            var isFight:Boolean = (pi<1);
                            //战斗中
                            //前排有多少人 n
                            this.pFight.visible = true;
                            this.sFight.visible = true;
                            this.sStatus.visible = isFight;
                            this.tStatus.visible = true;
                            this.tStatus.text = isFight?Tools.getMsgById("_public118"):((pi<100)?Tools.getMsgById("_public119")+pi:Tools.getMsgById("_public120"));
                            //"交战中":((pi<100)?"排队少于 "+pi:"排队大于100")
                            clearFightClip = false;//!isFight;
                            fightClip = 1;//isFight?1:0;
                        }
                        else{
                            this.pFight.visible = true;
                            this.sHome.visible = true;
                            // this.sStatus.visible = true;
                            this.tStatus.visible = true;
                            this.tStatus.text = Tools.getMsgById("_public88");//空闲
                        }
                        break;
                    case ModelTroop.TROOP_STATE_MOVE:
                    case ModelTroop.TROOP_STATE_RECALL:
                        this.mMarch = ModelManager.instance.modelMap.marchs[this.mModel.id];//行军
                        this.mMarch.on(EventConstant.REPEAT,this,this.repeatMarch);
                        this.mMarchTime = status == ModelTroop.TROOP_STATE_MOVE ? this.mMarch.remainTime() + 2 : this.mMarch.remainTime(0) - this.mMarch.remainTime() + 1;
                        //
                        this.pFight.visible = true;
                        this.tTimer.visible = true;
                        this.sTimer.visible = true;
                        this.sMove.visible = true;
                        this.sMoveQuick.visible = true;
                        this.troopRunning();
                        this.timer.loop(1000,this,this.troopRunning);
                        break; 
                    case ModelTroop.TROOP_STATE_MONSTER:
                        clearFightClip = false;
                        fightClip = 1;
                        this.pFight.visible = true;
                        this.sFight.visible = true;
                        this.sStatus.visible = true;
                        this.tStatus.visible = true;
                        this.tStatus.text = Tools.getMsgById("_country6");//"野战中";
                        //
                        break;                                             
                }        
                this.setHeroHpUI(status);
                //
                this.setFightingUI(clearFightClip,fightClip);
                //
                this.checkIsNewTroopClip();
                //
                // this.checkTROOP_ADD_NUMClip();
            }
            else{
                this.heroIcon.setHeroIcon("");
                this.sNull.visible = true;
                this.tNull.visible = true;
                this.tNull.text = Tools.getMsgById("_public121");//"创建";
                this.heroNull.visible = true;
                // this.sStatus.visible = true;
                this.setFightingUI(true,-1);
            }
            //
        }
        private function repeatMarch(index:int):void
        {
			if (index < 4 || !this.mMarch) return;
            this.mMarchTime = this.mMarch.remainTime()+1;
            this.troopRunning();
        }
        private function troopRunning():void{
            if(this.mMarch && this.tTimer.visible){
                this.mMarchTime-=1;
                if(this.mMarchTime >0){
                    this.tTimer.text = Tools.getTimeStyle(this.mMarchTime*Tools.oneMillis);
                }
                else{
                    this.tTimer.visible = false;
                    this.timer.clear(this,this.troopRunning);
                }
            }
        }
        private function setFightingUI(clear:Boolean,fightClip:Number):void{
            if(fightClip != this.isFightingClip){
                this.isFightingClip = fightClip;
            }
            else{
                if(!clear){
                    return;
                }
            }
            if(clear){
                if(this.mFighting){
                    this.mFighting.removeSelf();
                    this.mFighting.destroy(true);
                    this.mFighting = null;
                }
                return;
            }
			if (!this.mFighting) {
				this.mFighting = EffectManager.loadAnimation("headfight","",0);
				this.mFighting.pos(this.width*0.5,this.height*0.5);
				this.addChild(this.mFighting); 
			}
            
        }
        private function setHeroHpUI(status:int):void{
            // trace("英雄 血量",status);
            var evt:String = this.mData.evt;
            var hmd:ModelHero = ModelManager.instance.modelGame.getModelHero(this.mModel.hero);
            //
            this.heroIcon.visible = true;
            //this.heroIcon.setHeroIcon(this.mModel.hero,true,hmd.getStarGradeColor());
            this.heroIcon.setHeroIcon(hmd.getHeadId(),true,hmd.getStarGradeColor());
            //
			this.pFight.value = this.mPhValue = this.mModel.getHpPer();
        }
        public function click():void{
            if(this.isFightingClip == 1){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("fight_troop_turn_fighting"));//"正在战斗中"
                return;
            }            
            var arr:Array = ModelManager.instance.modelUser.getTroops();
            var isNull:Boolean = Tools.isNullObj(this.mModel);
            if(arr.length<1 && isNull){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public122"));//"没有英雄可编队"
                return;
            }
            if(this.mSelect.visible || isNull){
                if(isNull) ViewManager.instance.showView(ConfigClass.VIEW_TROOP_EDIT,ModelManager.instance.modelCountryPvp.isOpen);
                else ViewManager.instance.showView(ConfigClass.VIEW_TROOP_EDIT,this.mModel);
            }
        }
        private function checkIsNewTroopClip():void
        {
            if(!Tools.isNullObj(this.mModel)){
                if(this.mData.evt == EventConstant.TROOP_CREATE && ModelManager.instance.modelGame.creatNewTroopID.hasOwnProperty(this.mModel.hero)){
                    delete ModelManager.instance.modelGame.creatNewTroopID[this.mModel.hero];
                    if(this.mNewClip){
                        this.mNewClip.removeSelf();
                        this.mNewClip.destroy(true);
                    }
                    this.mFighting = EffectManager.loadAnimation("glow040","",1);
                    this.mFighting.pos(this.width*0.5,this.height*0.5);
                    this.addChild(this.mFighting);                    
                }
            }
        }
        private function checkTROOP_ADD_NUMClip():void
        {
            if(!Tools.isNullObj(this.mModel)){
                if(this.mData.evt == EventConstant.TROOP_ADD_NUM)
                {
                    if(this.mNewClip){
                        this.mNewClip.removeSelf();
                        this.mNewClip.destroy(true);
                    }
                    this.mData.evt = "";
                    this.mFighting = EffectManager.loadAnimation("glow040","",1);
                    this.mFighting.pos(this.width*0.5,this.height*0.5);
                    this.addChild(this.mFighting);                    
                }
            }
        }        
    }   
}