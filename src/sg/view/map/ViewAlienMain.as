package sg.view.map
{
	import laya.ui.Box;
    import ui.map.alien_mainUI;
    import sg.model.ModelClimb;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import ui.bag.bagItemUI;
    import laya.utils.Handler;
    import sg.model.ModelItem;
    import laya.events.Event;
    import sg.cfg.ConfigClass;
    import sg.manager.ViewManager;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.model.ModelGame;
    import sg.fight.FightMain;
    import sg.manager.AssetsManager;
    import sg.model.ModelUser;
    import sg.map.utils.Vector2D;
    import sg.cfg.ConfigServer;
    import sg.map.view.TroopAnimation;
    import sg.manager.LoadeManager;
    import sg.festival.model.ModelFestival;

	/**
	 * 异族入侵
	 * @author
	 */
    public class ViewAlienMain extends alien_mainUI
    {
        public var mCid:String;
        public var isFighting:Boolean = false;
        public var mTroopV:Vector2D;
        public var hpArr:Array;
        public function ViewAlienMain()
        {
            //this.list.itemRender = bagItemUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            //this.list.spaceX = -30;
            this.list.scrollBar.hide = true;
            //
            this.btn.on(Event.CLICK,this,this.click);

            this.tLvName.text = Tools.getMsgById("_public188");
			this.tArmyName.text = Tools.getMsgById("_public189");
			this.tPowerName.text = Tools.getMsgById("_public187");
			this.tRewardTitle.text = Tools.getMsgById("_public190");
			this.tRewardInfo.text = Tools.getMsgById("alien_ui_hint");
        }
        override public function initData():void{
            //
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_166.png"));
            //
            ModelManager.instance.modelGame.off(ModelGame.EVENT_ALIEN_FIGHT_START,this,this.start_fight);
            ModelManager.instance.modelGame.off(ModelGame.EVENT_ALIEN_FIGHT_END,this,this.closeSelf); 
            //          
            ModelManager.instance.modelGame.on(ModelGame.EVENT_ALIEN_FIGHT_START,this,this.start_fight);
            ModelManager.instance.modelGame.on(ModelGame.EVENT_ALIEN_FIGHT_END,this,this.closeSelf);
            //
            this.setUI();
        }
        public function setUI():void
        {
            //            
            this.mCid = this.currArg[0];
            this.mTroopV = this.currArg[1];
            //            
            var cityData:Array = ModelClimb.alien_city(this.mCid);
            // cityData["cid"] = this.mCid;
            //
            var cfg_txt_ui:Array = ModelClimb.alien_country_diff(this.mCid);
			this.tLvName.text = Tools.getMsgById("_public188");
			this.tArmyName.text = Tools.getMsgById("_public189");
			this.tPowerName.text = Tools.getMsgById("_public187");
			this.tRewardTitle.text = Tools.getMsgById("_public190");
			this.tRewardInfo.text = Tools.getMsgById("alien_ui_hint");
            //            
            //this.tTitle.text = Tools.getMsgById("battle_mode_5");//"异族入侵";
            this.comTitle.setViewTitle(Tools.getMsgById("battle_mode_5"));
            
            this.tType.text = Tools.getMsgById(ModelClimb.pk_npc_diff_name[cityData[0]]);
            this.tLv.text = ""+cityData[1];
            if(cfg_txt_ui.length>0){
                this.tName.text = Tools.getMsgById(cfg_txt_ui[0]);
            }
            this.heroIcon.setHeroIcon(ModelClimb.pk_npc_get_hero_icon(ModelUser.getCountryID(),cityData[0]));
            //
            this.hpArr = ModelClimb.getPKnpcModel(this.mCid).pk_npc_check_hp();
            this.tArmy.text = this.hpArr[0] + "/" + this.hpArr[1];//""+cityData[3]+"/"+ModelClimb.alien_army_max(this.mCid);
			this.comPower.setNum(ModelClimb.getAlienPower(this.mCid));
            //this.tPower.text = "" + ModelClimb.getAlienPower(this.mCid);
            //
            var arr:Array = ModelClimb.alien_award(this.mCid).concat();
            var fest:Array=ModelFestival.getRewardInterfaceByKey("pk_npc");
            if(fest.length!=0) arr.unshift(fest);
            
            this.list.repeatX = arr.length > 5 ? 5 : arr.length;
            this.list.dataSource = arr;
            this.list.centerX = 0;
            //
            this.isFighting = ModelClimb.alien_check_fight_ing(this.mCid);
            //
            this.checkUI(cityData[0]);
        }
        public function checkUI(diff:int):void{
            this.btn.label = this.isFighting?Tools.getMsgById("_country7"):Tools.getMsgById("_country8");//"查看":"进攻";  
            //
            var colors:Array = ["#83afff","#d583ff","#ff8a50"];
            this.tType.color = colors[diff];
            this.tName.color = colors[diff];
            this.diffBg.skin = AssetsManager.getAssetsUI("icon_chenghao"+diff+".png");
        }
        public function list_render(box:Box,index:int):void
        {
			var item:bagItemUI = box.getChildByName('item') as bagItemUI;
            var data:Array = this.list.array[index];
            //
            //item.scale(0.7,0.7);
            //item.setData(ModelItem.getItemIcon(data[0],true),0,"",data[1]);
            var it:ModelItem = ModelManager.instance.modelProp.getItemProp(data[0]);
            //item.setData(it.icon,it.ratity,"",data[1]+"",it.type);
            item.setData(it.id,data[1],-1);
        }
        public function click():void
        {
            this.isFighting = ModelClimb.alien_check_fight_ing(this.mCid);
            //
            if(this.isFighting){
                this.start_fight(ModelClimb.alien_check_fight_ing_data(this.mCid),true,false);
            }
            else{
                // var reward:Object = ModelClimb.alien_city_reward(this.mCid);
                if(this.hpArr && this.hpArr[0]<=0){
                    this.closeSelf();
                }
                else{
                    ModelManager.instance.modelGame.checkTroopToAction(parseInt(this.mCid), ConfigClass.VIEW_ALIEN_HERO_SEND, 0, false, 0, ModelClimb.getAlienPower(this.mCid));
                }
            }
        }
        public function start_fight(receiveData:*,fighting:Boolean,isCaptain:Boolean):void{
            var fd:Object = fighting?receiveData:receiveData.user;
            var climbMd:ModelClimb;
            climbMd = isCaptain?ModelClimb.getPKnpcModel("captain"):ModelClimb.getPKnpcModel(this.mCid);
            if(climbMd){
                climbMd.pk_npc_fight_start(fd.pk_data,fd.pk_result);
            } 
            var fightArr:Array = isCaptain?ModelClimb.captain_check_fight_data():ModelClimb.alien_check_fight_data(this.mCid);           
            //
            fd.pk_data["reward"] = isCaptain?ModelClimb.captain_curr_reward():ModelClimb.alien_city_reward(this.mCid);
            fd.pk_data["skipTime"] = ModelClimb.pk_npc_fight_ing_pass(fightArr);
            fd.pk_data["lastKillWave"] = isCaptain?(ConfigServer.pk_npc.captain_armyopnum - (ModelClimb.captain_curr()[2]+fd.pk_result.killWave)):(ModelClimb.alien_army_max(this.mCid) - (ModelClimb.alien_city(this.mCid)[3]+fd.pk_result.killWave));
            //
            this.closeSelf();
            //异族入侵跑过去再打
            if(fighting){
                this.inFight(fd,fighting,receiveData,fightArr,climbMd.pk_npc_hids);
            }
            else{
                TroopAnimation.moveTroop(climbMd.pk_npc_hids,this.mTroopV,Handler.create(this,this.inFight,[fd,fighting,receiveData,fightArr,climbMd.pk_npc_hids]));
            }
			
        }
        private function inFight(fd:Object,fighting:Boolean,receiveData:*,fightArr:Array,hids:Array):void
        {
            // trace(fd,this.mTroopV,receiveData);
            ModelClimb.pk_npc_check_end(fightArr,hids,fighting);
            FightMain.startBattle(fd,this,this.outFight,[receiveData,fighting]);            
        }
        public function outFight(receiveData:*,fighting:Boolean = false):void{
            ModelManager.instance.modelGame.event(ModelGame.EVENT_ALIEN_FIGHT_END);
        }
    }
}