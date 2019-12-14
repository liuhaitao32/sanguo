package sg.view.hero
{
    import ui.hero.starUpgradeUI;
    import sg.model.ModelHero;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.manager.AssetsManager;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.model.ModelPrepare;
    import sg.cfg.ConfigServer;
    import sg.model.ModelOffice;
    import sg.model.ModelBuiding;
    import sg.model.ModelItem;
    import sg.boundFor.GotoManager;
    import sg.model.ModelOfficeRight;

    public class ViewStarUpgrade extends starUpgradeUI{
        private var mModel:ModelHero;
        private var mPrepareNextStar:ModelPrepare;
        private var checkRightStr:String = "";
        public function ViewStarUpgrade():void{
            this.btn_coin.on(Event.CLICK,this,this.click,[1]);
            this.btn_gold.on(Event.CLICK,this,this.click,[0]);
            //
            this.btn_go.on(Event.CLICK,this,this.click_go);
            this.btnGoto.on(Event.CLICK,this,this.click_right_go);
        }
        override public function initData():void{
            this.mModel = this.currArg as ModelHero;
            this.mModel.getPrepare(true);
            //
            this.mPrepareNextStar = null;
            this.mPrepareNextStar = new ModelPrepare(this.mModel.getPrepareObjBy(-1,this.mModel.getStar()+1));
            //
            var m:Number = this.mModel.getMyItemNum();
            var n:Number = this.mModel.getStarUpItemNum();
            //
            this.heroStar.setHeroStar(this.mModel.getStar());
            this.tStarPro.text = Tools.getMsgById("_public21",[m+"/"+n]);//碎片
            this.barStar.value = m/n;
            //
            var coin:Number = this.mModel.getStarUpCoin();
            this.btn_coin.visible =false;
            if(coin>0 && ModelHero.checkHeroStartUpByCoin(this.mModel.id)){
                this.btn_coin.visible = true;
                this.btn_coin.centerX = -150;
                this.btn_gold.centerX = 150;
            }
            else{
                this.btn_gold.centerX = 0;
            }
            //this.mItem.setData(ModelItem.getItemIcon(ModelItem.getItemIDByHero(this.mModel.id)));
            this.mItem.setData(this.mModel.itemID);
            this.mItem.setName("");
            //
            this.btn_gold.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_GOLD),this.mModel.getStarUpGold()+"");
            this.btn_coin.setData("", coin + "");
			//this.tTitle.text = Tools.getMsgById('_hero25');
            this.comTitle.setViewTitle(Tools.getMsgById('_hero25'));
            //
            var armyLvF:int = this.mModel.getMyArmyLv()[0];
            var armyLvB:int = this.mModel.getMyArmyLv()[1];
            //
            var nextData:Object = this.mPrepareNextStar.getData();
            this.boxPropF.tName.text = Tools.getMsgById('_hero26',[ModelHero.army_seat_name[0],ModelHero.army_type_name[this.mModel.army[0]],armyLvF]);
            this.boxPropF.icon.setArmyIcon(this.mModel.army[0],ModelBuiding.getArmyCurrGradeByType(this.mModel.army[0]));
            this.boxPropF.heroArmyAtk.setHeroArmyProp4(ModelHero.army_prop_name[0]+":"+this.mModel.getArmyAtk(0,this.mModel.getPrepare()),nextData.army[0].atk);
            this.boxPropF.heroArmyDef.setHeroArmyProp4(ModelHero.army_prop_name[1]+":"+this.mModel.getArmyDef(0,this.mModel.getPrepare()),nextData.army[0].def);
            this.boxPropF.heroArmySpd.setHeroArmyProp4(ModelHero.army_prop_name[2]+":"+this.mModel.getArmySpd(0,this.mModel.getPrepare()),nextData.army[0].spd);
            this.boxPropF.heroArmyHpm.setHeroArmyProp4(ModelHero.army_prop_name[3]+":"+this.mModel.getArmyHpm(0,this.mModel.getPrepare()),nextData.army[0].hpm);
            this.boxPropF.mShard.visible = false;
            //
           
            this.boxPropB.tName.text = Tools.getMsgById('_hero26',[ModelHero.army_seat_name[1],ModelHero.army_type_name[this.mModel.army[1]],armyLvB]);
            this.boxPropB.icon.setArmyIcon(this.mModel.army[1],ModelBuiding.getArmyCurrGradeByType(this.mModel.army[1]));
            this.boxPropB.heroArmyAtk.setHeroArmyProp4(ModelHero.army_prop_name[0]+":"+this.mModel.getArmyAtk(1,this.mModel.getPrepare()),nextData.army[1].atk);
            this.boxPropB.heroArmyDef.setHeroArmyProp4(ModelHero.army_prop_name[1]+":"+this.mModel.getArmyDef(1,this.mModel.getPrepare()),nextData.army[1].def);
            this.boxPropB.heroArmySpd.setHeroArmyProp4(ModelHero.army_prop_name[2]+":"+this.mModel.getArmySpd(1,this.mModel.getPrepare()),nextData.army[1].spd);
            this.boxPropB.heroArmyHpm.setHeroArmyProp4(ModelHero.army_prop_name[3]+":"+this.mModel.getArmyHpm(1,this.mModel.getPrepare()),nextData.army[1].hpm);
            this.boxPropB.mShard.visible = false;
            //
            
            this.btn_gold.gray = (m<n);
            //
            this.tRight.visible = this.mModel.getStar()>=ModelHero.hero_star_lv_max();
            this.btnGoto.visible = this.tRight.visible;
            this.gTxt.visible = (!this.btnGoto.visible && this.btn_coin.visible);
            this.gTxt.text = Tools.getMsgById("_office10");
            if(this.tRight.visible){
                this.checkRightStr = ModelOffice.getAddstarCheck();
                this.tRight.text = Tools.getMsgById("_office2",[this.checkRightStr]);//"需要"+this.checkRightStr+"特权";
                this.btn_gold.bottom = 76;
                this.btn_coin.bottom = 76;
            }
            else{
                this.btn_gold.bottom = 46;
                this.btn_coin.bottom = 46;
            }
        }
        private function click(type:int):void{
            if(type==0){
                if(!Tools.isCanBuy("gold",this.mModel.getStarUpGold())){
                    return;
                }
                if(!Tools.isCanBuy(this.mModel.itemID,this.mModel.getStarUpItemNum())){
                    return;
                }                
            }else if(type==1){                
                if(!Tools.isCanBuy("coin",this.mModel.getStarUpCoin())){
                    return;
                }
            }
            if(this.mModel.getStar()<ModelHero.hero_star_lv_max()){
                NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_STAR_UP,{hid:this.mModel.id,if_cost:type},Handler.create(this,this.ws_sr_hero_star_up));
            }else{

                ViewManager.instance.showTipsTxt(Tools.getMsgById("_office2",[this.checkRightStr]));//需要特权
            }
        }
        private function click_right_go():void
        {
            GotoManager.boundForPanel(GotoManager.VIEW_OFFICE_MAIN,ModelOffice.getAddstarID(),null,{child:true});
        }
        private function click_go():void{
            //GotoManager.boundForPanel(GotoManager.VIEW_PUB,"",null,{child:true});
            ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,this.mModel.itemID);
        }
        private function ws_sr_hero_star_up(re:NetPackage):void{
            // Trace.log("ws_sr_hero_star_up",re.receiveData);
            ModelManager.instance.modelUser.updateData(re.receiveData);
            this.mModel.event(ModelHero.EVENT_HERO_STAR_CHANGE,true);
            //
            this.initData();
            this.closeSelf();
        }
    }
}