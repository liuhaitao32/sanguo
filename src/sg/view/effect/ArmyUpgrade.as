package sg.view.effect
{
    import ui.com.effect_army_upgradeUI;
    import sg.model.ModelBuiding;
    import sg.model.ModelHero;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;
    import sg.utils.Tools;
    import sg.cfg.HelpConfig;
    import laya.ui.Box;
    import sg.manager.EffectManager;
    import laya.display.Sprite;

    public class ArmyUpgrade extends effect_army_upgradeUI{
        public function ArmyUpgrade(bmd:ModelBuiding,armyCurrObj:Object,armyNextObj:Object,grade:int){
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("icon_war007.png"));
            //
            this.atk.tTitle.text = ModelHero.army_prop_name[0];
            this.atk.tA.text = armyCurrObj.atkBase;
            this.atk.tB.text = armyNextObj.atkBase;
            this.atk.tC.text = "(+"+(armyNextObj.atkBase - armyCurrObj.atkBase)+")";
            //
            this.def.tTitle.text = ModelHero.army_prop_name[1];
            this.def.tA.text = armyCurrObj.defBase;
            this.def.tB.text = armyNextObj.defBase;
            this.def.tC.text = "(+"+(armyNextObj.defBase - armyCurrObj.defBase)+")";
            //
            this.spd.tTitle.text = ModelHero.army_prop_name[2];
            this.spd.tA.text = armyCurrObj.spdBase;
            this.spd.tB.text = armyNextObj.spdBase;
            this.spd.tC.text = "(+"+(armyNextObj.spdBase - armyCurrObj.spdBase)+")";
            //
            this.hpm.tTitle.text = ModelHero.army_prop_name[3];
            this.hpm.tA.text = armyCurrObj.hpmBase;
            this.hpm.tB.text = armyNextObj.hpmBase;
            this.hpm.tC.text = "(+"+(armyNextObj.hpmBase - armyCurrObj.hpmBase)+")";
            //
            this.tLv.text = Tools.getMsgById("100001",[grade])+ModelHero.army_type_name[ModelBuiding.army_type[bmd.id]];
            //
            this.aBox.destroyChildren();
            this.img.visible = false;
            var armyAID:String = "army"+bmd.getArmyType()+""+grade;
            if(HelpConfig.type_app == HelpConfig.TYPE_SG){
                var sp:Sprite = EffectManager.loadArmysIcon(armyAID);
                sp.scaleX = 1.4; 
                sp.scaleY = 1.4;
                aBox.addChild(sp);
            }else{
                this.img.visible = true;
                this.img.skin = AssetsManager.getAssetsArmy(armyAID);
            }
            
            //
            this.test_clip_effict_panel(this.tTitle.x,this.tTitle.y);
        }
        public static function getEffect(bmd:ModelBuiding,armyCurrObj:Object,armyNextObj:Object,grade:int):ArmyUpgrade{
            var eff:ArmyUpgrade = new ArmyUpgrade(bmd,armyCurrObj,armyNextObj,grade);
            return eff;
        }        
    }   
}