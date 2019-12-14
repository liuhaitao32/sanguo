package sg.view.effect
{
    import laya.events.Event;
    import sg.model.ModelEquip;
    import laya.utils.Handler;
    import laya.utils.Tween;
    import ui.com.effect_equip_upgradeUI;
    import sg.utils.Tools;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import laya.utils.Ease;
    import sg.view.com.EquipInfoAttr;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.cfg.ConfigColor;

    public class EquipUpgrade extends effect_equip_upgradeUI{
        private var mTween:Tween;
        private var mGlow:Animation;
        private var mLv:int;
        private var mSy:Number;
        private var mModel:ModelEquip;
        private var mInfoAttr:EquipInfoAttr;
        public function EquipUpgrade(emd:ModelEquip){
            
            // this.once(Event.REMOVED,this,this.onRemove);
            // this.alpha = 0;
            this.mModel = emd;
            LoadeManager.loadTemp(this.bgImg,AssetsManager.getAssetsUI("icon_war007.png"));
            if(emd){ 
                this.mLv = emd.getLv();
                this.mSy = this.mIcon.y;
                var olv:int = this.mLv-1;
                this.mIcon.setHeroEquipType(emd,0,false,olv);
                //
                this.tName.text = emd.getName();
                this.tName.color = ConfigColor.FONT_COLORS[emd.getLv()];
                this.tType.text =  ModelEquip.equip_type_name[emd.type];
                //
                this.tInfo.visible = false;
                //
                this.mIcon.x = this.bgImg.x+this.bgImg.width/2;
                this.mIcon.y = this.bgImg.y+this.bgImg.height/2;
                //
                this.timer.once(200,this,this.clip1);
                //
                this.setInfoUI(emd);
            }
            this.test_clip_effict_panel(this.tTitle.x,this.tTitle.y);
        }
        private function setInfoUI(emd:ModelEquip):void
        {
            if(this.mInfoAttr){
                this.mInfoAttr.removeSelf();
                this.mInfoAttr.destroy(true);
            }
            this.mInfoAttr = null;
            this.mInfoAttr = new EquipInfoAttr(this.tInfo,this.tInfo.width-10,this.tInfo.height-5);
            this.mInfoAttr.initData(emd);
            this.tInfo.addChild(this.mInfoAttr);
            this.mInfoAttr.height = this.mInfoAttr.getPanelHeight();
            this.tInfo.height = this.mInfoAttr.height;
            this.bgImg.height = this.mInfoAttr.height + 200;
        }         
        private function clip1():void
        {
            this.mGlow = EffectManager.loadAnimation("glow000");
            this.mGlow.alpha = 0;
            this.mGlow.x = this.mIcon.x;
            this.mGlow.y = this.mIcon.y;
            this.addChild(this.mGlow); 

            this.mTween = Tween.to(this.mGlow,{alpha:1},200,null,null,0,false,false);       
			
            this.timer.once(200,this,this.clip2);
        }
        private function clip2():void{

            this.mIcon.setHeroEquipType(this.mModel,0,false,this.mLv);
            //
            this.mTween = Tween.to(this.mGlow,{alpha:0},300,null,Handler.create(this,this.clip3),100,false,false);
        }
        private function clip3():void
        {
            if(this.mGlow){
                Tween.clearAll(this.mGlow);
                this.mGlow.destroy(true);
            }            
            this.mTween = Tween.to(this.mIcon,{y:this.mSy},300,null,Handler.create(this,this.onTweenEnd),0,false,false);
        }
        private function onTweenEnd():void{
            this.tInfo.visible = true;
        }
        private function onRemove():void{
            if(this.mInfoAttr){
                this.mInfoAttr.destroy(true);
            }
            if(this.mTween){
                this.mTween.clear();
                //this.mTween.recover();
            }
            this.mTween = null;
            //
            if(this.mGlow){
                Tween.clearTween(this.mGlow);
                this.mGlow.destroy(true);
            }
            this.timer.clear(this,this.clip1);
            this.timer.clear(this,this.clip2);
        }        
        public static function getEffect(emd:ModelEquip):EquipUpgrade{
            var eff:EquipUpgrade = new EquipUpgrade(emd);
            return eff;
        }
    }
}