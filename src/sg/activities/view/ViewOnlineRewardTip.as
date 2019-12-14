package sg.activities.view
{
    import laya.display.Animation;
    import laya.display.Graphics;
    import laya.events.Event;
    import laya.ui.Box;
    import laya.ui.Label;
    import laya.utils.HitArea;
    import laya.utils.Tween;

    import sg.activities.model.ModelOnlineReward;
    import sg.boundFor.GotoManager;
    import sg.cfg.ConfigServer;
    import sg.home.model.HomeModel;
    import sg.manager.EffectManager;
    import sg.map.utils.ArrayUtils;
    import sg.scene.SceneMain;
    import sg.scene.view.ui.Bubble;
    import sg.utils.Tools;

    import ui.onlineReward.onlineRewardTiipUI;
    import sg.manager.ViewManager;
    import sg.manager.ModelManager;
    import sg.utils.TimeHelper;

    public class ViewOnlineRewardTip extends Bubble
    {
        private var model:ModelOnlineReward = ModelOnlineReward.instance;
		private var box:onlineRewardTiipUI;
		private var timeTxt:Label;
		private var aniExp:Animation;
        public static var instance:ViewOnlineRewardTip;
        public function ViewOnlineRewardTip(scene:SceneMain)
        {
            super();
            super.initScene(scene);
            this.on(Event.DISPLAY, this, this._onAdded);
            this.on(Event.UNDISPLAY, this, this._onRemoved);
            ArrayUtils.push(this, this.sceneMain.bubbles);
            this.sceneMain.mapLayer.bubbleLayer.addChild(this);
            this.initTip();
            this.resize();
            Tween.clearAll(this);
            ViewOnlineRewardTip.instance = this;
        }

        public function initTip():void
        {
            this.box = new onlineRewardTiipUI();
            this.timeTxt = box.timeTxt;
            box.pos(box.width * -0.5, box.height * -1);
            this.addChild(box);
			var posArr:Array = ConfigServer.effect.homeRewardPos;
            this.pos(posArr[0] - HomeModel.instance.mapGrid.gridHalfW , posArr[1] - HomeModel.instance.mapGrid.gridHalfH);  
            
			// 添加流光特效
			this.aniExp = EffectManager.loadAnimation("glow041");
            this.aniExp.pos(box.giftIcon.x, box.giftIcon.y);
            box.addChild(this.aniExp);
        }

        private function _onAdded():void
        {
            this.visible = ModelOnlineReward.instance.active && this.model.getRewardIndex() < 4;
            if (this.visible) {
                box.giftIcon.on(Event.CLICK, this, this._onClickReward);
            }
            this.refreshTime();
            Laya.timer.loop(1000, this, this.refreshTime);
        }

        private function _onRemoved():void {
            box.giftIcon.clearEvents();
            Laya.timer.clear(this, this.refreshTime);
        }

        private function _onClickReward(event:Event):void
        {
            GotoManager.boundForPanel(GotoManager.VIEW_ONLINE_REWARD_PANEL);
        }
 
        private function refreshTime():void {
            if (this.model.getRewardIndex() >=4 ) {
                this.visible = false;
                return;
            }
            if (ModelOnlineReward.haveReward()) {
                this.timeTxt.text = Tools.getMsgById('_jia0006');
                this.aniExp.visible = true;
            }
            else {
                this.timeTxt.text = TimeHelper.formatTime(model.getTime());
                this.aniExp.visible = false;
            }
        }        
    }
}