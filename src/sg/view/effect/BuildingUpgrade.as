package sg.view.effect
{
    import ui.com.effect_building_upgradeUI;
    import sg.model.ModelBuiding;
    import sg.model.ModelHero;
    import laya.events.Event;
    import sg.manager.ModelManager;
    import laya.utils.Tween;
    import laya.utils.Ease;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.utils.Tools;
    import sg.utils.MusicManager;

    public class BuildingUpgrade extends effect_building_upgradeUI
    {
        public function BuildingUpgrade(bmd:ModelBuiding)
        {
            this.on(Event.REMOVED,this,this.onRemove,[bmd,0]);
            LoadeManager.loadTemp(this.adImg, AssetsManager.getAssetsUI("icon_war007.png"));
			bBox.txt_hint_lv.text = Tools.getMsgById('_hero14');
            //
            var isBase:Boolean = bmd.isBase();
            this.tBase.visible = isBase;
            this.tName.visible = !isBase;
            this.baseBox.visible = isBase;
            this.bBox.visible = !isBase;
            this.bBoxInfo.visible = !isBase;
            //
            if(isBase){
                this.tBaseLv.text = bmd.lv+"";
                this.tBaseTips1.text = Tools.getMsgById("_effect1",[ModelHero.getMaxLv(bmd.lv)]);//"英雄等级上限提升到 "++"级";
                //
                this.timer.frameLoop(1,this,this.clip1);
                this.tBase.scaleX = 0.5;
                Tween.to(this.tBase,{scaleX:1},200,Ease.bounceOut);
                //
                this.test_clip_effict_panel(this.tBase.x,this.tBase.y);
            }
            else{
                var baseLv:Number = bmd.lv;
                if(baseLv>0){
                    baseLv-=1;
                }
                this.bBox.setBuildingInfoLv(bmd,true);
                this.bBoxInfo.setBuildingInfoInfo(bmd,true,true,baseLv);
                this.tName.scaleX = 0.5;
                Tween.to(this.tName,{scaleX:1},200,Ease.bounceOut);
                this.test_clip_effict_panel(this.tName.x,this.tName.y);
            }
            MusicManager.playSoundUI(MusicManager.SOUND_BUILD_LV_UP);
        }
        private function clip1():void
        {
            this.iBase.rotation+=1;
        }
        private function onRemove(bmd:ModelBuiding,index:int):void{
            this.off(Event.REMOVED,this,this.onRemove);
            this.timer.clear(this,this.clip1);
            ModelManager.instance.modelGame.checkBaseBuildUnlockFunc(bmd,index);          
        }
        public static function getEffect(bmd:ModelBuiding):BuildingUpgrade{
            var eff:BuildingUpgrade = new BuildingUpgrade(bmd);
            return eff;
        }        
    }
}