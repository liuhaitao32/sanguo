package sg.view.effect
{
    import ui.com.effect_hero_normalUI;
    import sg.model.ModelHero;
    import ui.com.hero_icon2UI;
    import laya.maths.Point;
    import laya.utils.Tween;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import laya.events.Event;
    import laya.utils.Handler;
    import sg.utils.MusicManager;

    public class HeroStarUpgrade extends effect_hero_normalUI
    {
        private var heroIcon:hero_icon2UI;
        private var tween:Tween;
        public function HeroStarUpgrade(hmd:ModelHero,ui:hero_icon2UI)
        {
            this.once(Event.REMOVED,this,this.onRemove);
            this.width = Laya.stage.width;
            this.height = Laya.stage.height;
            //
            this.addChild(EffectManager.loadHeroStarUp(hmd.id,hmd.getStarGradeColor(),this,this.overClip));
            //
            MusicManager.playSoundUI(MusicManager.SOUND_HERO_STAR_UP);
        }
        private function endClip():void{
            //
            if(this.tween){
                this.tween.clear();
            }
            this.tween = Tween.to(this,{alpha:0},200,null,Handler.create(this,this.overClip),0,false,false);
        }
        private function overClip():void{
            if(this.parent){
                (this.parent as EffectUIBase).onRemovedBase();
            }
        }
        private function onRemove():void{
            if (this.tween){
				this.tween.clear();
                //this.tween.recover();
            }
            this.tween = null;
            this.destroyChildren();
            this.heroIcon = null;
        }
        public static function getEffect(hmd:ModelHero,ui:hero_icon2UI):HeroStarUpgrade{
            var eff:HeroStarUpgrade = new HeroStarUpgrade(hmd,ui);
            return eff;
        }
    }   
}