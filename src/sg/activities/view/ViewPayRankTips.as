package sg.activities.view
{
    import ui.activities.payRank.payRankTipsUI;
    import sg.model.ModelHero;
    import sg.manager.ModelManager;
    import laya.events.Event;
    import sg.boundFor.GotoManager;
    import sg.activities.model.ModelPayRank;
    import sg.manager.EffectManager;
    import laya.particle.Particle2D;
    import sg.manager.ViewManager;
    import laya.maths.Point;
    import sg.manager.QueueManager;
    import sg.utils.ArrayUtil;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.utils.Tools;
    import sg.utils.TimeHelper;
    import laya.ui.Box;
    import laya.display.Sprite;
    import laya.ui.Panel;
    import sg.cfg.ConfigServer;

    public class ViewPayRankTips extends payRankTipsUI
    {
		private var model:ModelPayRank = ModelPayRank.instance;
		private var mParticle1:Particle2D;
		private var mParticle2_1:Particle2D;
		private var mParticle2_2:Particle2D;
        public function ViewPayRankTips() {
            txt_go.text = Tools.getMsgById('_jia0131');
            mParticle1 = this._createParticle(box_one, box1);
            mParticle2_1 = this._createParticle(box_two, box2_1);
            mParticle2_2 = this._createParticle(box_two, box2_2);
            box_go.on(Event.CLICK, this, this._onClick);
            box_zero.on(Event.CLICK, this, this._onClick);
            box_one.on(Event.CLICK, this, this._onClick);
            box_two.on(Event.CLICK, this, this._onClick);
        }

        private function _createParticle(boxParent:Box, panel:Panel):Particle2D {
            var pos:Point = new Point(panel.x + panel.width * 0.5, panel.y + panel.height * 1);
            pos = boxParent.localToGlobal(pos);
            var mParticle: Particle2D = EffectManager.loadParticle("p007", 15, 600, ViewManager.instance.mLayerEffect, true, pos.x, pos.y);
            mParticle.visible = false;
            return mParticle;
        }

        override public function onAdded():void {
            var actId:int = model.open_day || model.next_open_day_id;
            var actData:* = ArrayUtil.find(model.cfg.round, function(item:*):Boolean {
                return item.open_day === actId;
            }, this);
            var hids:Array = actData.heroIds || [];
            var modelHero:ModelHero = null;
            var hid:String = hids[0];
            if (hid) {
                modelHero = ModelManager.instance.modelGame.getModelHero(hid);
                heroIcon1.setHeroIcon(hid);
                heroName1.text = modelHero.getAwakenName();
                heroIcon2_1.setHeroIcon(hid);
                heroName2_1.text = modelHero.getAwakenName();
            }

            hid = hids[1];
            if (hid) {
                modelHero = ModelManager.instance.modelGame.getModelHero(hid);
                heroIcon2_2.setHeroIcon(hid);
                heroName2_2.text = modelHero.getAwakenName();
            }
            
            box_zero.visible = box_one.visible = box_two.visible = mParticle1.visible = mParticle2_1.visible = mParticle2_2.visible = false;
            switch(hids.length) {
                case 0:
                    var img_src:String = actData.bg_image is Array ? actData.bg_image[1] || '' : ''
                    LoadeManager.loadTemp(img_ad_zero, AssetsManager.getAssetsAD(img_src));
                    box_zero.visible = true;
                    break;
                case 1:
                    LoadeManager.loadTemp(img_ad_one, AssetsManager.getAssetsAD('actPay1_23.png'));
                    mParticle1.play()
                    box_one.visible = mParticle1.visible = true;
                    break;
                case 2:
                    LoadeManager.loadTemp(img_ad_two, AssetsManager.getAssetsAD('actPay1_22.png'));
                    mParticle2_1.play()
                    mParticle2_2.play()
			        box_two.visible = mParticle2_1.visible = mParticle2_2.visible = true;
                    break;
            }
            Laya.timer.loop(1000, this, this._refreshTime);
            this._refreshTime();
            box_go.visible = !model.notStart;
        }

        private function _refreshTime():void {
            if (model.notStart) {
                txt_tips.text = Tools.getMsgById('_jia0056') + TimeHelper.formatTime(model.getTime());
            }
            else if (model._endTime > ConfigServer.getServerTimer()) {
                txt_tips.text = Tools.getMsgById('_jia0052') + TimeHelper.formatTime(model.getTime());
            }
            else {
                txt_tips.text = Tools.getMsgById('happy_tips07');
            }
        }

        private function _onClick():void {
            if(ModelPayRank.instance.active && !ModelPayRank.instance.notStart){
                QueueManager.instance.mIsGoto=true;
                GotoManager.boundForPanel(GotoManager.VIEW_PAY_RANK);
            }
            this.closeSelf();
        }

		override public function onRemoved():void{
			this.mouseEnabled = true;
            Laya.timer.clear(this, this._refreshTime);
			if(this.mParticle1){
				mParticle1.visible = mParticle2_1.visible = mParticle2_2.visible = false;
				mParticle1.stop();
				mParticle2_1.stop();
				mParticle2_2.stop();
			}
		}
    }
}