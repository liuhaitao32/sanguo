package sg.view.menu
{
    import laya.ui.VBox;
    import ui.menu.rightButton_userUI;
    import sg.manager.AssetsManager;
    import sg.model.ViewModelBase;
    import sg.manager.ModelManager;
    import sg.model.ModelCountryPvp;
    import laya.events.Event;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import sg.activities.model.ModelAfficheMerge;
    import sg.model.ModelFightTask;
    import sg.model.ModelArena;
    import sg.cfg.ConfigServer;
    import sg.model.ModelGame;

    public class RightButtonBox extends VBox
    {
        private var cfg:Array = RightButtonHelper.cfg;
        private var btns:Array = [];
        public function RightButtonBox() {
			ModelManager.instance.modelCountryPvp.on(ModelCountryPvp.EVENT_XYZ_START, this, this.refreshBox);
			ModelManager.instance.modelCountryPvp.on(ModelCountryPvp.EVENT_XYZ_TIME_OUT, this, this.refreshBox);
			ModelAfficheMerge.instance.on(ModelAfficheMerge.SHOW_MERGE_BTN, this, this.refreshBox);
			ModelFightTask.instance.on(ModelFightTask.SHOW_FIGHT_TASK_BTN, this, this.refreshBox);
            ModelArena.instance.on(ModelArena.EVENT_UPDATE_BTN_STATUS, this, this.refreshBox);
            
            this.timer.once(500, this, this.refreshBox);
        }

        public function refreshBox():void {
            this._createButton();
            this.refreshTxt();
            Laya.timer.clear(this, this.refreshTxt);
            btns.length && Laya.timer.loop(1000, this, this.refreshTxt);
        }

        /**
         * 创建按钮
         */
        private function _createButton():void {
            this.destroyChildren();
            btns.splice(0, btns.length);
            var item:rightButton_userUI = null;
            var len:int = cfg.length;
            for(var i:int = 0; i < len; i++) {
                var data:Object = cfg[i];
                var name:String = data.name;
                var glow:String = data.glow;
                var model:ViewModelBase = RightButtonHelper.getModelByName(name);
                if (model.active) {
                    if(name == "arena"){
                        var now:Number = ConfigServer.getServerTimer();
                        if(now<ModelArena.instance.mTime0){//还没到预告时间
                            break;
                        }
                        if(now>=ModelArena.instance.mTime4){//超过最后查看时间
                            break;
                        }
                        if(ModelGame.unlock(null,"arena").stop){
                            break;
                        }
                    }
                    item = new rightButton_userUI();
                    item.name = name;
                    item.btn.skin = AssetsManager.getAssetsUI(data.skin);
                    item.on(Event.CLICK, this, this._onClick);
                    btns.push(item);
                    this.addChild(item);
                    if (glow) {
				        var ani:Animation = EffectManager.loadAnimation("glow047");
                        ani.x = item.btn.x;
                        ani.y = item.btn.y;
                        ani.scale(item.btn.scaleX, item.btn.scaleY);
                        item.btn.zOrder = ani.zOrder = -1;
                        item.addChild(ani);
                    }
                }
            }
            this.changeItems();
        }

        /**
         * 刷新文本，同时检查是否需要隐藏
         */
        public function refreshTxt():void {
            var len:int = btns.length
            for(var i:int = 0; i < len; i++) {
                var item:rightButton_userUI = btns[i];
                var model:Object = RightButtonHelper.getModelByName(item.name);
                item.txt.text = model.getTxt();
                if (!model.active) {
                    this.refreshBox();
                    return;
                }
            }
        }

        private function _onClick(evt:Event):void {
            var item:rightButton_userUI = evt.currentTarget as rightButton_userUI;
            RightButtonHelper.onClick(item.name);
        }
    }
}