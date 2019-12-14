package sg.view.hero
{
    import laya.events.Event;
    import sg.manager.ModelManager;
    import sg.model.ModelGame;
    import sg.model.ModelHero;
    import sg.model.ModelUser;
    import sg.utils.Tools;
    import ui.hero.heroAdjutantUI;
    import sg.cfg.ConfigServer;
    import sg.utils.MusicManager;

    public class ViewHeroAdjutant extends heroAdjutantUI
    {
        private var mModel:ModelHero;
        private var mArmyFront:ViewAdjutantArmy;
        private var mArmyBehind:ViewAdjutantArmy;
        private var modelGame:ModelGame;
        private var modelUser:ModelUser;
        public function ViewHeroAdjutant(md:ModelHero):void{
            this.mModel = md as ModelHero;
            this.mArmyFront = new ViewAdjutantArmy(0);
            this.mArmyBehind = new ViewAdjutantArmy(1);
            this.mArmyFront.right = 7;
            this.mArmyBehind.left = 7;
            this.mArmyFront.bottom = 7;
            this.mArmyBehind.bottom = 7;
            this.addChild(mArmyFront);
            this.addChild(mArmyBehind);
        }
        override public function init():void{
            var modelManager:ModelManager = ModelManager.instance;
            modelGame = modelManager.modelGame;
            modelUser = modelManager.modelUser;
            this.refreshUI();
            this.mModel.on(ModelHero.EVENT_HERO_ADJUTANT_CHANGE, this, this.refreshUI);
        }

        public function refreshUI():void  {
            box_open.visible = box_commander.visible = mArmyFront.visible = mArmyBehind.visible = false;
            if (ModelGame.unlock(null,"hero_adjutant").gray) { // 副将功能只显示，未正式开启
                box_open.visible = true;
                txt_title_open.text = Tools.getMsgById('_jia0089', [Tools.getMsgById('_jia0076')]);
                txt_tips1_open.text = Tools.getMsgById('_jia0065');
                txt_tips2_open.text = Tools.getMsgById('_public58', [ConfigServer.system_simple.func_open['hero_adjutant'][3]]);
                return;
            }
            // 检查自己是否是副将            
            var commander:String = modelUser.getCommander(mModel.id);            
            if (commander) { // 是副将
                box_commander.visible = true;
			    heroIcon.setHeroIcon(commander);
                var commanderModel:ModelHero = modelGame.getModelHero(commander);
                var adjutant:Array = modelUser.hero[commander]['adjutant'];
                var fb:int = adjutant.indexOf(mModel.id);
                var posStr:String = ModelHero.army_seat_name[fb];
                var armyStr:String = ModelHero.army_type_name[mModel.army[fb]];
                txt_tips.text = Tools.getMsgById('_jia0079', [commanderModel.getName(), posStr + armyStr]);
                Tools.textFitFontSize2(txt_tips);
                btn_go.label = Tools.getMsgById('_jia0135',[commanderModel.getName()]);
                btn_go.on(Event.CLICK,this,this._onClickGo, [commander]);
            }
            else {
                mArmyFront.setModel(mModel);
                mArmyBehind.setModel(mModel);
                img_bg.visible = false;
                mArmyFront.visible = mArmyBehind.visible = true;
            }
        }

        override public function clear():void{
            this.mModel.off(ModelHero.EVENT_HERO_ADJUTANT_CHANGE, this, this.refreshUI);
            this.mModel = null;
            this.btn_go.off(Event.CLICK,this,this._onClickGo);
            this.destroy(true);
        }

        private function _onClickGo(commander:String):void {
            modelGame.event(ModelHero.EVENT_HERO_LOOK_UP, commander);
        }
    }
}