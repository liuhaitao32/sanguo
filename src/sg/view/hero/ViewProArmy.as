package sg.view.hero
{
    import ui.hero.heroProArmyUI;
    import sg.model.ModelHero;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import ui.bag.bagItemUI;
    import sg.manager.ModelManager;
    import laya.ui.Label;
    import sg.utils.Tools;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import laya.ui.ProgressBar;
    import ui.bag.bagItemSmallUI;
    import sg.manager.AssetsManager;
    import sg.cfg.ConfigServer;
    import sg.model.ModelItem;
    import sg.model.ModelBuiding;
    import sg.manager.EffectManager;
    import laya.display.Animation;
    import sg.view.effect.HeroArmyUpgrade;
    import sg.model.ModelGame;
    import sg.cfg.HelpConfig;
    import laya.ui.Image;

    public class ViewProArmy extends heroProArmyUI{
        private var mModel:ModelHero;
        private var fb:int = 0;
        private var mArmyItems:Array;
        public function ViewProArmy(md:ModelHero,fbType:int):void{
            this.mModel = md;
            this.fb = fbType;
            //
            this.btn_gold.on(Event.CLICK,this,this.click,[0]);
            //
        }
        public function setUpdate():void{
            this.setUI();
        }
        private function setUI():void{
            //
            this.mModel.getPrepare(true);
            //
            var armyLv:int = this.mModel.getMyArmyLv()[this.fb];
            this.boxProp.tName.text =  ModelHero.army_seat_name[this.fb]+ModelHero.army_type_name[this.mModel.army[this.fb]]+" "+Tools.getMsgById("_hero16",[armyLv]);
            this.boxProp.icon.setArmyIcon(this.mModel.army[this.fb],ModelBuiding.getArmyCurrGradeByType(this.mModel.army[this.fb]));
            //
            this.boxProp.heroArmyAtk.setHeroArmyProp4(ModelHero.army_prop_name[0]+" : "+this.mModel.getArmyAtk(this.fb,this.mModel.getPrepare()),0);
            this.boxProp.heroArmyDef.setHeroArmyProp4(ModelHero.army_prop_name[1]+" : "+this.mModel.getArmyDef(this.fb,this.mModel.getPrepare()),0);
            this.boxProp.heroArmySpd.setHeroArmyProp4(ModelHero.army_prop_name[2]+" : "+this.mModel.getArmySpd(this.fb,this.mModel.getPrepare()),0);
            this.boxProp.heroArmyHpm.setHeroArmyProp4(ModelHero.army_prop_name[3]+" : "+this.mModel.getArmyHpm(this.fb,this.mModel.getPrepare()),0);
            //
            var hmd:ModelBuiding = ModelManager.instance.modelInside.getBuildingModel(ModelBuiding.army_type_building[this.mModel.army[this.fb]]);
            //
            var unlock:Object = ModelGame.unlock(null,"hero_armylv");
            var isMine:Boolean = this.mModel.isMine();
            var showB:Boolean = unlock.visible && isMine;
            this.mBoxUpgrade.visible = true;
            this.tError.visible = false;
            // if(!showB){
            //     this.tError.text = isMine?"官邸等级不足":"需要先招募英雄";
            //     return;
            // }
            //
            this.setArmyImg();
            //
            this.mArmyItems = this.mModel.getMyArmyItems(this.fb);

            var itemArr:Array = this.mArmyItems[0];
            var item:bagItemSmallUI;
            var itemTxt:Label;
            var itemNum:Number = 0;
            var itemBar:ProgressBar;
            for(var i:int = 0;i<itemArr.length;i++){
                item = this["item"+i] as bagItemSmallUI;
                itemTxt = this["tItemNum"+i] as Label;
                itemNum = ModelHero.getArmyItemNum(itemArr[i]);
                item.tName.text = "";//ModelItem.getItemName(itemArr[i]);
                item.itemIcon.setData(itemArr[i]);
                item.itemIcon.setName("");
                item.itemIcon.mCanClick = false;
                item.off(Event.CLICK,this,this.click_item);
                item.on(Event.CLICK,this,this.click_item,[itemArr[i]]);
                (this["barItem"+i] as ProgressBar).value = itemNum/this.mArmyItems[1];
                if(armyLv>=ModelHero.getArmyUpgradeLvMax()){
                    itemTxt.text = itemNum+" / -";
                }else{
                    itemTxt.text = itemNum+" / "+this.mArmyItems[1];
                }
                
            }
            this.btn_gold.setData(AssetsManager.getAssetItemOrPayByID("gold"),this.mArmyItems[2]);
            //
            var myNormalNum:Number = ModelHero.getArmyItemNum(ConfigServer.army.all_material);
            if((this.mArmyItems[3]>0 && this.mArmyItems[3]>myNormalNum) || armyLv>=ModelHero.getArmyUpgradeLvMax() || !showB) {//
                this.btn_gold.gray = true;
            }
            else{
                this.btn_gold.gray = false;
            }
            //
            this.boxProp.mShard.off(Event.CLICK,this,this.click_shard);
            this.boxProp.mShard.on(Event.CLICK,this,this.click_shard);
        }
        private function click_item(iid:String):void
        {
            ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,iid);
        }
        private function click_shard():void
        {
            ViewManager.instance.showTipsPanel(Tools.getMsgById(192000));
        }
        private function setArmyImg():void{
            this.boxProp.imgBox.destroyChildren();
            this.boxProp.imgBox.visible = true;
            //
            var len:int = 4;
            var a:int = this.mModel.army[this.fb];//this.mModel.getMyArmyLv()[this.fb];
            var b:int = ModelBuiding.getArmyCurrGradeByType(this.mModel.army[this.fb]);
            // a = 3;
            // b = 1;
            var aid:String = "army" + a +""+ b;
            if(HelpConfig.type_app == HelpConfig.TYPE_WW){
                var img:Image = new Image();
                img.skin = AssetsManager.getAssetsArmy(aid);
                img.scaleX = img.scaleY = 0.45;
                img.centerX = 10;
                img.centerY = 0;
                this.boxProp.imgBox.addChild(img);
            }else{
                this.boxProp.imgBox.addChild(EffectManager.loadArmysIcon(aid));
            }
            
        }
        override public function clear():void{
            //
            this.boxProp.imgBox.destroy(true);
            this.boxProp.destroy(true);
            this.destroy(true);
            //
            this.mModel = null;
            this.mArmyItems = null;            
        }
        private function click(type:int = 1):void{
            var isMine:Boolean = this.mModel.isMine();
            if(!isMine || !ModelGame.unlock(null,"hero_armylv").visible){
                ViewManager.instance.showTipsTxt(isMine?Tools.getMsgById("_public15"):Tools.getMsgById("_hero19"));//官邸等级不足:先招募英雄
                return;
            }
            var armyLv:int = this.mModel.getMyArmyLv()[this.fb];
            if(armyLv>=this.mModel.getLv()){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public16"));//无法升级,需要提高英雄的等级
                return;
            }
            if(armyLv>=ModelHero.getArmyUpgradeLvMax()){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public191"));//已经是最高等级
                return;
            }

            var myNormalNum:Number = ModelHero.getArmyItemNum(ConfigServer.army.all_material);
            var normalNum:Number = this.mArmyItems[3];
            if(normalNum>0 && type==0){
                if(normalNum<=myNormalNum){
                    if(Tools.checkAlertIsDel(ViewProNormalItem.hero_army_up_normal)){
                        this.click();
                    }
                    else{
                        ViewManager.instance.showView(ConfigClass.VIEW_PRO_NORMAL_ITEM,[this.mArmyItems,Handler.create(this,this.click)]);
                    }
                }
                return;
            }
            
            if(Tools.isCanBuy("gold",this.mArmyItems[2])){
            //
                NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_ARMY_LV_UP,{hid:this.mModel.id,army_index:this.fb},Handler.create(this,this.ws_sr_hero_army_lv_up));
            }
        }
        private function ws_sr_hero_army_lv_up(re:NetPackage):void{
            this.clipStart();
            ModelManager.instance.modelUser.updateData(re.receiveData);
        }
        private function clipStart():void{
            this.boxProp.imgBox.visible = false;
            //
            ViewManager.instance.showViewEffect(HeroArmyUpgrade.getEffect(this.boxProp,this.mModel,this.fb),0,Handler.create(this,this.clipEnd));
        }
        private function clipEnd():void{
            this.mModel.event(ModelHero.EVENT_HERO_ARMY_LV_CHANGE,[false,"army"]);
        }
    }   
}