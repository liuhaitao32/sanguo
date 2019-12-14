package sg.view.map
{
    import sg.model.ModelClimb;
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.fight.FightMain;
    import sg.model.ModelGame;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;

	/**
	* 名将来袭
	*/
    public class ViewCaptainMain extends ViewAlienMain
    {
        public function ViewCaptainMain()
        {
            super();
        }
        override public function initData():void{
            ModelManager.instance.modelGame.off(ModelGame.EVENT_CAPTAIN_FIGHT_START,this,this.start_fight);
            ModelManager.instance.modelGame.off(ModelGame.EVENT_CAPTAIN_FIGHT_END,this,this.closeSelf);
            //            
            ModelManager.instance.modelGame.on(ModelGame.EVENT_CAPTAIN_FIGHT_START,this,this.start_fight);
            ModelManager.instance.modelGame.on(ModelGame.EVENT_CAPTAIN_FIGHT_END,this,this.closeSelf);
            //            
            this.setUI();
        }
        override public function setUI():void{
            //            
            this.mCid = this.currArg[0];
            this.mTroopV = this.currArg[1];
            //this.tTitle.text = Tools.getMsgById("_public85");//"名将来袭";
            this.comTitle.setViewTitle(Tools.getMsgById("_public85"));
			this.tRewardInfo.text = Tools.getMsgById("alien_ui_hint");
            //            
            var curr:Array  = ModelClimb.captain_curr();
            this.tName.text = Tools.getMsgById(ConfigServer.pk_npc.captain_nameandrew[curr[5]][0]);
            this.tType.text = Tools.getMsgById("alien_trouble");//"困难";
            this.tLv.text = ""+ ConfigServer.pk_npc.captain_strike_open[curr[3]][0];    
            this.hpArr = ModelClimb.getPKnpcModel("captain").pk_npc_check_hp();
            this.tArmy.text = this.hpArr[0] + "/" + this.hpArr[1];//""+curr[2]+"/"+ConfigServer.pk_npc.captain_armyopnum; 
			this.comPower.setNum(ModelClimb.getCaptainPower());
            //this.tPower.text = "" + ModelClimb.getCaptainPower();
            this.heroIcon.setHeroIcon(curr[5]);
            //
            var listData:Array = ModelClimb.captain_award(curr[3],ConfigServer.pk_npc.captain_nameandrew[curr[5]])
            list.repeatX = listData.length > 5 ? 5 : listData.length;
            this.list.dataSource = listData;
            //
            this.checkUI(2);             
        }
        override public function click():void
        {
            this.isFighting = ModelClimb.captain_check_fight_ing();
            //
            if(this.isFighting){

                this.start_fight(ModelClimb.captain_check_fight_ing_data(),true,true);
            }
            else{
                // var reward:Object = ModelClimb.captain_curr_reward();
                if(this.hpArr && this.hpArr[0]<=0){
                    this.closeSelf();
                }else{
                    ModelManager.instance.modelGame.checkTroopToAction(parseInt(this.mCid),ConfigClass.VIEW_ALIEN_HERO_SEND,1,false,0,ModelClimb.getCaptainPower());
                }
            }            
        }
        override public function outFight(receiveData:*,fighting:Boolean = false):void{
            ModelManager.instance.modelGame.event(ModelGame.EVENT_CAPTAIN_FIGHT_END);
        }
    }
}