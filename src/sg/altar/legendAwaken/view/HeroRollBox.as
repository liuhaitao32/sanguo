package sg.altar.legendAwaken.view
{
import laya.ui.Box;
import ui.legendAwaken.heroRollBaseUI;
import laya.events.Event;
import laya.utils.Tween;
import laya.utils.Handler;
    public class HeroRollBox extends Box
    {
        private static const speed:Number = 0.1; // 像素每毫秒
        private static const offsetX:int = 3;
        private static const maxNum:int = 5; // 同时显示的最大个数
        private var tweens:Array = [];
        private var inited:Boolean = false;
        private var hids:Array;
        private var idIndex:int;
        private var offset:int; // 每两个icon之间的X坐标差
        private var maxX:int;
        public var playing:Boolean = false; // 是否正在滚动
        public function HeroRollBox() {
        }

        public function createIcons(arr:Array):void {
            if (arr is Array && arr.length > maxNum) {
                hids = arr;
                for (; idIndex < maxNum; ++idIndex) {
                    var sp:heroRollBaseUI = new heroRollBaseUI();
                    this.initVariable(sp.width);
                    sp.name = 'hero' + idIndex;
                    this.addChild(sp);
                }
            }
        }

        private function initVariable(width:Number):void {
            if (inited) return;
            offset = width + offsetX;
            maxX = offset * (maxNum - 1);
            inited = true;
        }

        private function resetHeroIcons():void {
            idIndex = 0;
            tweens.splice(0, tweens.length);
            for (; idIndex < maxNum; ++idIndex) {
                var sp:heroRollBaseUI = this.getChildByName('hero' + idIndex) as heroRollBaseUI;
                sp.x = offset * idIndex;
                sp.character.setHeroIcon(hids[idIndex], false);

                var tween:Tween = Tween.to(sp, {x: offset * -1}, (sp.x + offset) / speed, null, Handler.create(this, this.onComplete, [sp]));
                tweens.push(tween);
            }
        }

        public function startRoll():void {
            if (!inited) return;
            this.resetHeroIcons();
			Laya.stage.on(Event.VISIBILITY_CHANGE,this,this.visibility_change);
            playing = true;
        }

        public function stopRoll():void {
            playing = false;
			Laya.stage.off(Event.VISIBILITY_CHANGE,this,this.visibility_change);
            tweens.forEach(function(tween:Tween):void {
                tween.clear();
            }, this);
        }
		
		private function visibility_change(e:Event):void {
            if (Laya.stage.isVisibility) {
                this.stopRoll();
                this.startRoll();
            } 
        }

        private function onComplete(sp:heroRollBaseUI):void {
            var index:int = sp.name.match(/\d/)[0];
            index = index > 0 ? index - 1 : 4;
            sp.x = (this.getChildByName('hero' + index) as heroRollBaseUI).x + offset;
            idIndex++;
            idIndex === hids.length && (idIndex = 0);
            sp.character.setHeroIcon(hids[idIndex], false);
            var tween:Tween = tweens.shift();
            tween.clear();
            tween = Tween.to(sp, {x: offset * -1}, (sp.x + offset) / speed, null, Handler.create(this, this.onComplete, [sp]));
            tweens.push(tween);
        }
    }
}