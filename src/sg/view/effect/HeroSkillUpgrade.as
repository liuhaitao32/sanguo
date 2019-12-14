package sg.view.effect
{
    import ui.com.effect_hero_normalUI;
    import laya.ui.Image;
    import sg.manager.AssetsManager;

    public class HeroSkillUpgrade extends effect_hero_normalUI
    {
        public function HeroSkillUpgrade()
        {
            var img:Image = new Image(AssetsManager.getAssetLater("img_name16.png"));
            img.anchorX = 0.5;
            img.anchorY = 0.5;
            img.x = this.width*0.5;
            img.y = this.height*0.5;
            this.addChild(img);
            //
            this.test_clip_effict_panel(img.x,img.y);
            //
            this.timer.once(3000,this,this.endClip);
        }
        private function endClip():void
        {
            (this.parent as EffectUIBase).onRemovedBase();
        }        
        public static function getEffect():HeroSkillUpgrade{
            var eff:HeroSkillUpgrade = new HeroSkillUpgrade();
            return eff;
        }        
    }
}