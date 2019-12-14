package sg.view.hero
{
	import laya.display.Animation;
	import laya.particle.Particle2D;
	import sg.model.ModelBuiding;
	import sg.model.ModelTalent;
    import sg.model.ModelHero;
    import sg.model.ModelPrepare;
    import sg.manager.EffectManager;
    import laya.ui.Box;
    import sg.manager.ModelManager;
    import sg.model.ModelSkill;
    import sg.utils.Tools;
    import ui.com.skillItemUI;
    import laya.display.Animation;
    import laya.events.Event;
    import laya.utils.Ease; 
    import sg.utils.MusicManager;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import ui.hero.heroAwakenUI;
    import laya.display.Node;
    import laya.display.Sprite;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import laya.utils.Handler;
    import sg.boundFor.GotoManager;
''
    public class ViewAwakenHero extends heroAwakenUI {
		private static var recruitIds:Array = [];
		private static var awakenIds:Array = [];
        private var ani1:Animation;
        private var ani2:Animation;
        private var awakenId:String;
        public function ViewAwakenHero(){
            this._changeSprBrightness(icon_hero_w, 100);
        }

        override public function initData():void {
            awakenId = currArg || 'hero701';
            icon_hero.setHeroIcon(awakenId, false);
            icon_hero_w.setHeroIcon(awakenId, false);
        }

        override public function onAdded():void {
            this.btnCloseFun = true;
            var md:ModelHero = ModelManager.instance.modelGame.getModelHero(awakenId);
            LoadeManager.loadImg(AssetsManager.getAssetsAD(md.rarity === 4 ? ModelHero.img_awaken_super : ModelHero.img_awaken_normal), Handler.create(this, this._playAni));
            this.mBg.visible = false;
        }

        private function _playAni():void {
            var md:ModelHero = ModelManager.instance.modelGame.getModelHero(awakenId);
            ani1 = EffectManager.loadAnimation("glow_awake_01","",2);
            ani1.pos(box_f.width * 0.5, box_f.height * 0.5);
            box_f.addChild(ani1 as Node);
            ani2 = EffectManager.loadAnimation(md.rarity === 4 ? "glow_awake_03" : "glow_awake_02","",2);
            ani2.on(Event.COMPLETE,this,this._clearAni);
            ani2.pos(box_b.width * 0.5, box_b.height * 0.5);
            box_b.addChild(ani2 as Node);
            EffectManager.changeSprColor(ani2, md.getStarGradeColor(), false);
            MusicManager.playSoundHero(awakenId);
            ani_hero.play(0, false);
        }

        override public function onRemoved():void{
            ani_hero.gotoAndStop(0);
            Laya.timer.callLater(this, this._checkNext);
        }

        private function _checkNext():void {
            checkRecruitOrAwaken();
        }

        private function _clearAni():void {
            ani1 && ani1.destroy(true);
            ani2 && ani2.destroy(true);
            ani1 = ani2 = null;
            this.closeSelf();
        }
		
        /**
         * 调整显示对象亮度
		 * @param	spr	需要调整亮度的显示对象
		 * @param	brightness	亮度（-100~100）
         */
		private function _changeSprBrightness(spr:*, brightness:Number):Sprite {
            var n:Number = brightness * 2.55;
			var mat:Array = [
				1, 0, 0, 0, n,
				0, 1, 0, 0, n,
				0, 0, 1, 0, n,
				0, 0, 0, 1, 0
			];
			return EffectManager.changeSprColorFilter(spr, mat, false);
		}

        /**
         * 检查是否需要招募(需要在刷新个人数据之前调用)
         */
        public static function checkGiftDict(gift_dict:Object):void {
            if (gift_dict && gift_dict.awaken is Array) {
                var needAwakenId:String = gift_dict.awaken[0];
                var mine:Boolean = ModelManager.instance.modelGame.getModelHero(needAwakenId).isMine();
                awakenIds.push(needAwakenId);
                mine || recruitIds.push(needAwakenId);
            }
        }

        /**
         * 检查是否需要招募或觉醒
         */
        public static function checkRecruitOrAwaken():void {
            if (recruitIds && recruitIds.length) {
                recruitOrAwaken(recruitIds[0]);
            }
            else if (awakenIds && awakenIds.length) {
                recruitOrAwaken(awakenIds[0]);
            }
        }

        /**
         * 播放招募动画
         */
        public static function recruitHero(hid:String):void {
            ViewManager.instance.showView(ConfigClass.VIEW_HERO_GET_NEW, hid);
        }

        /**
         * 播放觉醒动画
         */
        public static function awakenHero(hid:String):void {
            var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
            GotoManager.boundForPanel(GotoManager.VIEW_HERO_FEATURES,"",[md,[],0],{type:2,child:false});
            ViewManager.instance.showView(ConfigClass.VIEW_AWAKEN_HERO, hid);
        }

        /**
         * 招募或觉醒(优先招募)
         */
        public static function recruitOrAwaken(hid:String):void {
            var index:int = recruitIds.indexOf(hid);
            if (index !== -1) {
                recruitIds.splice(index, 1);
                recruitHero(hid);
            }
            else {
                index = awakenIds.indexOf(hid);
                if (index !== -1) {
                    awakenIds.splice(index,1);
                    awakenHero(hid);
                }
            }
        }
    }   
}