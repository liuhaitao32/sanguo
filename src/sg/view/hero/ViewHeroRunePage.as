package sg.view.hero
{
    import sg.view.com.ItemBase;
    import sg.model.ModelHero;
    import ui.hero.heroRunePage1UI;
    import ui.hero.heroRunePage2UI;
    import ui.hero.heroRunePage3UI;
    import ui.hero.heroRunePage4UI;
    import laya.events.Event;
    import laya.display.Node;
    import ui.com.hero_icon_rune_txtUI;
    import laya.ui.Image;
    import sg.utils.Tools;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.model.ModelRune;
    import laya.ui.Label;
    import sg.manager.ModelManager;
    import laya.utils.Handler;
    import sg.manager.AssetsManager;
    import sg.model.ModelItem;
    import sg.manager.EffectManager;
    import sg.cfg.ConfigColor;
    import sg.manager.LoadeManager;
    import sg.model.ModelGame;
    import sg.boundFor.GotoManager;
    public class ViewHeroRunePage extends ItemBase{
        private var mModel:ModelHero;
        private var mCurrUItype:int = -1;
        private var mPanel:ItemBase;
        private var mSelectName:String = "";
        private var mSelectRuneModel:ModelRune;
        public var mStatusHandler:Handler;
        public function ViewHeroRunePage(md:ModelHero):void{
            this.mModel = md as ModelHero;
            
        }
        public function setUI(uiType:int):void{
            this.clear();
            ModelManager.instance.modelGame.on(ModelRune.EVENT_SET_IN_OUT,this,this.event_set_in_out);
            //
            this.mCurrUItype = uiType;
            //
            if(uiType==0){
                this.mPanel = new heroRunePage1UI();
            }
            else if(uiType==1){
                this.mPanel = new heroRunePage2UI();
            }
            else if(uiType==2){
                this.mPanel = new heroRunePage3UI();
            }                
            else{
                this.mPanel = new heroRunePage4UI();
            }
            LoadeManager.loadTemp(this.mPanel["adImg"],AssetsManager.getAssetsUI("bg_19.png"));
            this.addChild(this.mPanel);
            //
            this.setOnOrOffClick(true);
            //
            this.click("rune0",this.getModelByName("rune0"));
            //
            this.mPanel["btn_go"].label = Tools.getMsgById("60005");
            this.mPanel["btn_go"].on(Event.CLICK,this,this.clickGo);
        }
		private function clickGo():void{
			GotoManager.instance.boundForHome("building006",1);
		}        
        private function click(str:String,rmd:ModelRune):void{
            var b:Boolean = true;
            //
            this.mSelectRuneModel = rmd;
            if(this.mSelectRuneModel){
                b = false;
            }
            this.checkRuneUI(str);
            //
            var selectType:int = parseInt(str.charAt(str.length-1));
            var fixtype:int = ModelRune.pageAndTypeToPosValue(this.mCurrUItype,selectType);
            var dtype:int = ModelRune.pageAndTypeToPosIndex(this.mCurrUItype,selectType);            
            var runes:Array = ModelRune.getMyRunesByType(fixtype,this.mModel,dtype);
            if(this.mStatusHandler){
                var rune:hero_icon_rune_txtUI = this.mPanel.getChildByName(str) as hero_icon_rune_txtUI;
                if(fixtype == 0 && !rune.bgName.visible){
                    runes = ModelRune.getFixType0(runes,this.mModel.getRune());
                }
                this.mStatusHandler.runWith([b,runes.length,rune.bgName.visible]);
            }
        }
        public function openUpgrade():void{
            if(this.mSelectRuneModel){
                ViewManager.instance.showView(ConfigClass.VIEW_HERO_RUNE_UPGRADE,[this.mModel,this.mSelectRuneModel]);
            }
        }
        private function checkRuneUI(str:String):void{
            if(!Tools.isNullString(this.mSelectName)){
                this.setRuneUIselect(this.mSelectName,false);
            }
            this.mSelectName = str;
            this.setRuneUIselect(this.mSelectName,true);
        }
        private function setRuneUIselect(str:String,b:Boolean):void{
            var rune:hero_icon_rune_txtUI;
            var imgSelect:Image;
            rune = this.mPanel.getChildByName(str) as hero_icon_rune_txtUI;
            imgSelect = rune.imgSelect;
            imgSelect.visible = b;
        }
        private function setOnOrOffClick(set:Boolean):void{
            if(this.mPanel){
                var rune:hero_icon_rune_txtUI;
                var rmd:ModelRune;
                var inID:int = -1;
                for(var i:int = 0;i<this.mPanel.numChildren;i++){
                    if(this.mPanel.getChildAt(i).name.indexOf("rune")>-1){
                        rune = this.mPanel.getChildAt(i) as hero_icon_rune_txtUI;
                        rune.addImg.visible = false;
                        rune.img.visible = false;
                        //fix_position_diff
                        var selectType:int = parseInt(rune.name.charAt(rune.name.length-1));
                        var ft:int = ModelRune.pageAndTypeToPosValue(this.mCurrUItype,selectType);
                        rune.diff.visible = ModelRune.fix_position_diff.indexOf(ft)>-1;
                        rune.boxLv.visible = false;
                        rune.imgColor.visible = false;
                        if(ft<4){
                            rune.imgColor.visible = true;
                            EffectManager.changeSprColor(rune.imgColor,ft,false,ConfigColor.COLOR_RUNE_FTYPE);
                        }
                        if(set){
                            rmd = this.getModelByName(rune.name);
                            rune.off(Event.CLICK,this,this.click);
                            rune.on(Event.CLICK,this,this.click,[rune.name,rmd]);
                            rune.bgName.visible = false;
                            if(rmd){
                                rune.tName.text = rmd.getName(true);
                                rune.img.skin = rmd.getIcon();
                                rune.bgName.visible = true;
                                rune.boxLv.visible = true;
                                rune.tLv.text = rmd.getLv()+"";
                                ModelGame.redCheckOnce(rune,false);
                            }
                            else{
                                
                                var posIndex:Number = ModelRune.pageAndTypeToPosIndex(this.mCurrUItype,selectType);
                                var runes:Array = ModelRune.getMyRunesByType(ft,this.mModel,posIndex);
                                //
                                rune.addImg.visible = true;
                                rune.addImg.skin = AssetsManager.getAssetsUI((runes.length<=0)?"icon_plusy.png":"icon_plusg.png");//
                                rune.tName.text = "";
                                //
                                var red:Boolean = this.mModel.checkRuneWill(posIndex);
                                // trace("星辰类型---",posIndex,red);
                                if(ft==0){
                                    red = red && (ModelRune.getFixType0(runes,this.mModel.getRune()).length>0);
                                    
                                }
                                //
                                ModelGame.redCheckOnce(rune,red);
                                
                            }
                            rune.img.visible = !rune.addImg.visible;
                        }
                        else{
                            rune.off(Event.CLICK,this,this.click);
                        }
                    }
                }
            }
        }
        private function getModelByName(na:String):ModelRune{
            var sType:int = parseInt(na.charAt(na.length-1));
            var inID:int = ModelRune.pageAndTypeToPosIndex(this.mCurrUItype,sType);
            return this.mModel.getRuneByIndex(inID);
        }
        public function click_set(type:int):void{
            ViewManager.instance.showView(ConfigClass.VIEW_HERO_RUNE_SET,[this.mModel,this.mSelectName,type]);
        }
        private function event_set_in_out():void{
            this.setOnOrOffClick(true);
            this.click(this.mSelectName,this.getModelByName(this.mSelectName));
        }
        override public function clear():void{
            //
            ModelManager.instance.modelGame.off(ModelRune.EVENT_SET_IN_OUT,this,this.event_set_in_out);
            this.setOnOrOffClick(false);
            if(this.mPanel){
                this.mPanel.destroy(true);
                this.mPanel.removeSelf();
            }
            this.mPanel = null;
        }
    }
}