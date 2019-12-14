package sg.view.hero
{
    import ui.hero.heroRuneUI;
    import sg.model.ModelHero;
    import laya.utils.Handler;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.manager.EffectManager;
    import laya.display.Animation;
    import sg.utils.Tools;
    import sg.model.ModelGame;
    import sg.model.ModelAlert;

    public class ViewHeroRune extends heroRuneUI{
        private var mModel:ModelHero;
        private var mViewHeroRunePage:ViewHeroRunePage;
        public function ViewHeroRune(md:ModelHero):void{
            this.mModel = md as ModelHero;
            this.mViewHeroRunePage = new ViewHeroRunePage(this.mModel);
            this.mViewHeroRunePage.mStatusHandler = new Handler(this,this.checkStatus);
            //
            this.mViewHeroRunePage.x = 105;
            this.mViewHeroRunePage.y = 0;
            this.addChild(this.mViewHeroRunePage);
            //
            this.btn_set.on(Event.CLICK,this,this.click,[0]);
            this.btn_up.on(Event.CLICK,this,this.click,[1]);
            btn_up.label = Tools.getMsgById('_building23');
            this.tab.dataSource = [Tools.getMsgById('_public69'), Tools.getMsgById('_public70'), Tools.getMsgById('_public71'), Tools.getMsgById('_public72')];
            //
        }
        override public function init():void{
            this.tab.selectHandler = new Handler(this,this.tab_select);
            this.tab.selectedIndex = this.tab.selectedIndex==-1?0:this.tab.selectedIndex;
            //
            this.mModel.on(ModelHero.EVENT_HERO_RUNE_CHANGE,this,this.checkRed);//
            this.checkRed();
            
        }
        private function checkRed():void{
            for(var i:int = 0;i < 4;i++){
                // this.tab.items[i].name = "tab_"+i;
                ModelGame.redCheckOnce(this.tab.items[i],!ModelGame.unlock(null,"hero_star").stop && this.mModel.checkRuneWillByType(i));
            }
        }
        override public function clear():void{
            this.mModel.off(ModelHero.EVENT_HERO_RUNE_CHANGE,this,this.checkRed);//
            this.checkClip(false);
            this.mViewHeroRunePage.clear();
            this.mViewHeroRunePage.destroy(true);
            this.mViewHeroRunePage = null;
            //
            this.mModel = null;
            //
            this.tab.destroy(true);
            //
            this.btn_set.off(Event.CLICK,this,this.click);
            this.btn_up.off(Event.CLICK,this,this.click);
            //
            this.destroy(true);
        }
        private function tab_select(index:int):void{
            this.setUI();
        }
        private function setUI():void{
            this.mViewHeroRunePage.setUI(this.tab.selectedIndex);
        }
        private function checkStatus(b:Boolean,len:Number,isSetOn:Boolean):void{
            this.btn_up.gray = b;
            //
            var setB:Boolean = len>0;
            this.btn_set.gray = !setB;
            this.btn_set.mouseEnabled = setB;
            this.btn_set.label = isSetOn?Tools.getMsgById("_equip4"):Tools.getMsgById("_equip3");//更换:安装
            this.checkClip(setB && !isSetOn);
        }
        private function checkClip(glow:Boolean = false):void{
            this.clipBox.destroyChildren();
            if(!glow){
                return;
            }
            var aniStar:Animation = EffectManager.loadAnimation("glow006");
            aniStar.scaleX = 1.5;
            aniStar.scaleY = 1;            
            aniStar.x = this.btn_set.x;
            aniStar.y = this.btn_set.y;

            this.clipBox.addChild(aniStar);

        }        
        private function click(type:int):void{
            if(!this.mModel.isMine()){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero19"));//先招募英雄
                return
            }
            if(type==0){
                this.mViewHeroRunePage.click_set(this.tab.selectedIndex);
            }
            else{
                this.mViewHeroRunePage.openUpgrade();
            }
        }
    }
}