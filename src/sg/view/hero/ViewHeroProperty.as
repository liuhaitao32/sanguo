package sg.view.hero
{
    import ui.hero.heroPropertyUI;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.model.ModelHero;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import sg.cfg.ConfigServer;
    import sg.model.ModelItem;
    import sg.model.ModelUser;

    public class ViewHeroProperty extends heroPropertyUI{
        private var mModel:ModelHero;
        private var mArmyFront:ViewProArmy;
        private var mArmyBehind:ViewProArmy;
        //
        public function ViewHeroProperty(md:ModelHero):void{
            this.mModel = md as ModelHero;
        }
        override public function init():void{
            this.btn_star.on(Event.CLICK,this,this.click,[1]);
            this.btn_lv.on(Event.CLICK,this,this.click,[0]);
            this.btn_pub.on(Event.CLICK,this,this.click_pub);
            btn_lv.label = Tools.getMsgById('_building23');
            btn_star.label = Tools.getMsgById('_public176');
            //
            this.mArmyFront = new ViewProArmy(this.mModel,0);
            this.mArmyBehind = new ViewProArmy(this.mModel,1);
            // this.mArmyFront.width = 300;
            // this.mArmyFront.height = 320;
            // this.mArmyBehind.width = 300;
            // this.mArmyBehind.height = 320;
            this.mArmyFront.right = 14;
            this.mArmyBehind.left = 14;
            this.mArmyFront.bottom = 14;
            this.mArmyBehind.bottom = 14;
            //
            this.addChild(this.mArmyFront);
            this.addChild(this.mArmyBehind);
            //
            this.setUI();
            //
            this.mModel.on(ModelHero.EVENT_HERO_STAR_CHANGE,this,this.setUI);
            this.mModel.on(ModelHero.EVENT_HERO_EXP_CHANGE,this,this.setUI);
            this.mModel.on(ModelHero.EVENT_HERO_ARMY_LV_CHANGE,this,this.setUI);
            this.mModel.on(ModelHero.EVENT_HERO_TITLE_CHANGE, this, this.setUI);
			this.mModel.on(ModelHero.EVENT_HERO_FORMATION_CHANGE, this, this.setUI);//
			this.mModel.on(ModelHero.EVENT_HERO_BEAST_CHANGE,this,this.setUI);//
            ModelManager.instance.modelUser.on(ModelUser.EVENT_UPDATE_ARMY_ITEM,this,this.setUI);//
		}
        private function click_pub():void{
			// ViewManager.instance.showView(ConfigClass.VIEW_PUB_MAIN,null,1,true);
            ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,this.mModel.itemID);
		}
        private function setUI(update:Boolean = false,type:String = ""):void{
            //
            if(type == ""){
                this.btn_star.disabled = !this.mModel.isMine();
                this.btn_lv.disabled = !this.mModel.isMine();
                //
                this.heroStar.setHeroStar(this.mModel.getStar());
                this.barStar.value = this.mModel.getMyItemNum()/this.mModel.getStarUpItemNum();
                if(this.mModel.getStar()>=ConfigServer.system_simple.hero_star.length){
                    this.tStarPro.text = Tools.getMsgById(90006,[this.mModel.getMyItemNum(),"-"]);
                }else{
                    this.tStarPro.text = Tools.getMsgById(90006,[this.mModel.getMyItemNum(),this.mModel.getStarUpItemNum()]);
                }
                
                //
                var lv:Number = this.mModel.isMine()?this.mModel.getLv():1;
                var cexp:Number = this.mModel.getExp();
                var nexp:Number = this.mModel.getLvExp(lv+1);
                this.barExp.value = cexp/nexp;
                this.tLv.text = Tools.getMsgById(90007,[lv,ModelHero.getMaxLv()]);
                this.tExp.text = Tools.getMsgById(90008,[cexp,nexp]);
            }
            //
            this.checkClip(false,type);
            //
            this.mArmyFront.setUpdate();
            this.mArmyBehind.setUpdate();            
        }
        private function checkClip(clear:Boolean = false,type:String = ""):void{
            if(type=="army"){
                return;
            }
            this.clipBox.destroyChildren();
            if(clear){
                return;
            }
            if(!this.mModel.isMine()){
                return;
            }
            // if(this.mModel.getLv()>=ModelHero.getMaxLv()){
            //     return;
            // }
            //星级别
            var m:Number = this.mModel.getMyItemNum();
            var n:Number = this.mModel.getStarUpItemNum();
            // var coin:Number = this.mModel.getStarUpCoin();
            if(m>=n && this.mModel.getStar()<ModelHero.hero_star_lv_max()){//|| (coin>0 && ModelManager.instance.modelUser.coin>=coin)
                var aniStar:Animation = EffectManager.loadAnimation("glow006");
                aniStar.x = this.btn_star.x;
                aniStar.y = this.btn_star.y;
                aniStar.scaleX = 1.1;
                this.clipBox.addChild(aniStar);
            }
        }
        private function click(type:int):void{
            if(type==0){
                ViewManager.instance.showView(ConfigClass.VIEW_LV_UPGRADE,this.mModel);
            }
            else{
                if(this.mModel.getStar()>=ConfigServer.system_simple.hero_star.length){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero21"));//已经突破到最高星级
                    return;
                }
                ViewManager.instance.showView(ConfigClass.VIEW_STAR_UPGRADE,this.mModel);
            }
        }
        override public function clear():void{
            this.checkClip(true);
            //
            this.btn_star.off(Event.CLICK,this,this.click);
            this.btn_lv.off(Event.CLICK,this,this.click);
            this.btn_pub.off(Event.CLICK,this,this.click_pub);
            //
            this.mArmyFront.clear();
            this.mArmyBehind.clear();
            //
            this.mModel.off(ModelHero.EVENT_HERO_STAR_CHANGE,this,this.setUI);
            this.mModel.off(ModelHero.EVENT_HERO_EXP_CHANGE,this,this.setUI);
            this.mModel.off(ModelHero.EVENT_HERO_ARMY_LV_CHANGE,this,this.setUI);
            this.mModel.off(ModelHero.EVENT_HERO_TITLE_CHANGE, this, this.setUI);
			this.mModel.off(ModelHero.EVENT_HERO_FORMATION_CHANGE, this, this.setUI);//
			this.mModel.off(ModelHero.EVENT_HERO_BEAST_CHANGE,this,this.setUI);//
            ModelManager.instance.modelUser.off(ModelUser.EVENT_UPDATE_ARMY_ITEM,this,this.setUI);//
            //
            this.destroyChildren();
            this.destroy(true);
            this.mModel = null;
            this.mArmyFront = null;
            this.mArmyBehind = null;            
        }
    }
}