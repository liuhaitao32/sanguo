package sg.view.effect
{
    import ui.com.effect_hero_normalUI;
    import sg.manager.AssetsManager;
    import sg.manager.EffectManager;
    import laya.display.Animation;
    import ui.com.SoldiersinformationUI;
    import laya.maths.Point;
    import ui.com.t_img_tUI;
    import sg.model.ModelPrepare;
    import sg.model.ModelHero;
    import ui.com.effect_txt1UI;
    import laya.events.Event;
    import laya.utils.Handler;
    import sg.manager.LoadeManager;

    public class HeroArmyUpgrade extends effect_hero_normalUI
    {
        private var atkA:Animation;
        private var defA:Animation;
        private var spdA:Animation;
        private var hpmA:Animation;
        //
        private var mPrepareNextArmyLv:ModelPrepare;
        private var mModel:ModelHero;
        //
        public function HeroArmyUpgrade(ui:SoldiersinformationUI,hmd:ModelHero,fb:int)
        {
            this.width = Laya.stage.width;
            this.height = Laya.stage.height;
            this.mModel = hmd;
            //
            var armyLv:Array = [this.mModel.getMyArmyLv()[0]+1,this.mModel.getMyArmyLv()[1]+1];
            this.mPrepareNextArmyLv = new ModelPrepare(this.mModel.getPrepareObjBy(-1,-1,armyLv));
            //
            this.timerOnce(30,this,function():void{
                atkA = EffectManager.loadAnimation("glow009","",2);
                this.addChild(atkA);
                this.setAniXY(atkA,ui.heroArmyAtk,this.mPrepareNextArmyLv.getData().army[fb].atk);
            });
            this.timerOnce(130,this,function():void{
                defA = EffectManager.loadAnimation("glow009","",2);
                this.addChild(defA);
                this.setAniXY(defA,ui.heroArmyDef,this.mPrepareNextArmyLv.getData().army[fb].def);
            });
            this.timerOnce(230,this,function():void{
                spdA = EffectManager.loadAnimation("glow009","",2);
                this.addChild(spdA);
                this.setAniXY(spdA,ui.heroArmySpd,this.mPrepareNextArmyLv.getData().army[fb].spd);
            });
            this.timerOnce(330,this,function():void{
                hpmA = EffectManager.loadAnimation("glow009","",2);
                this.addChild(hpmA);
                this.setAniXY(hpmA,ui.heroArmyHpm,this.mPrepareNextArmyLv.getData().army[fb].hpm,true);
            });            
        }
        private function setAniXY(ani:Animation,sp:t_img_tUI,v:Number,end:Boolean = false):void{
            var p1:Point = new Point(0,0);
            p1 = sp.localToGlobal(p1);
            p1 = this.globalToLocal(p1);
            //
            if(end){
                ani.once(Event.COMPLETE,this,this.endClip);
            }
            //
            ani.x = p1.x + 120;
            ani.y = p1.y + 10;//-5;
            ani.scaleY = 0.5;
            //
            this.timerOnce(300,this,function():void{
                var txt:effect_txt1UI = new effect_txt1UI();
                txt.label.text = v+"";
                txt.x = p1.x + sp.width-40;
                txt.y = p1.y;
                this.addChild(txt);
                //
            });
        }
        private function endClip():void
        {
            this.mPrepareNextArmyLv = null;
            this.mModel = null;
            (this.parent as EffectUIBase).onRemovedBase();
        }
        public static function getEffect(ui:SoldiersinformationUI,hmd:ModelHero,fb:int):HeroArmyUpgrade{
            var eff:HeroArmyUpgrade = new HeroArmyUpgrade(ui,hmd,fb);
            return eff;
        }
    }   
}