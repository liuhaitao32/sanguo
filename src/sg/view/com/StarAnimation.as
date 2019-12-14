package sg.view.com
{
    import ui.com.mc_starUI;
    import laya.ui.Image;
    import laya.display.Animation;
    import sg.manager.EffectManager;

    public class StarAnimation extends mc_starUI
    {
        private const MAX_NUM:int = 5;
        public function StarAnimation() {
        }

        public function setStar(from:int = 0, to:int = MAX_NUM):void {
            box.x = (MAX_NUM - to) * (this.width / MAX_NUM) * 0.5;
            this.clear();
            var interval:int = 150;
            for(var i:int = 1; i <= MAX_NUM; i++) {
                var img:Image = box.getChildByName('star_' + i) as Image;
                img.visible = i <= from;
                if (i > from && i <= to) {
                    this.timer.once(interval * (i - from -1), this, this.addStar, [img], false);
                }
            }
            to > from && this.timer.once((to - 1) * interval + 1000, this, this.addBlow);
        }

		private function addStar(img:Image):void {
            var aniExp:Animation = EffectManager.loadAnimation("glow_star_add", '', 2);
            aniExp.pos(img.x + img.width * 0.5, img.y + img.height * 0.5);
            box.addChild(aniExp);
		}

		private function addBlow():void {
            var aniExp:Animation = EffectManager.loadAnimation("glow_surprise_blow", '', 1);
            aniExp.pos(box.width * 0.5, box.height * 0.5);
            aniExp.blendMode = 'lighter';
            box.addChild(aniExp);
		}

		public override function clear():void {
            this.timer.clearAll(this);
            var array:Array = box._childs;
            for(var len:int = array.length; len; len--) {
                var spr:* = array[len-1];
                (spr is Image )&& (spr.visible = false);
                (spr is Animation) && spr.removeSelf();
            }
		}
    }
}