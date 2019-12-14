package sg.fight.client.view {
	import laya.display.Animation;
    import laya.events.Event;
    import laya.ui.Image;
    import laya.utils.Ease;
    import laya.utils.Handler;
    import laya.utils.Tween;
    import sg.fight.FightMain;
	import sg.fight.client.utils.FightLoad;
    import sg.fight.client.utils.FightViewUtils;
    import sg.fight.logic.utils.FightUtils;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
    import sg.manager.ModelManager;
    import sg.model.ModelItem;
    import sg.model.ModelProp;
    import sg.utils.Tools;
    import ui.bag.bagItemUI;
    import ui.battle.fightFinishSandTableUI;
    
    /**
     * 沙盘演义的战斗结束
     * @author zhuda
     */
    public class ViewFightFinishSandTable extends fightFinishSandTableUI {
        private var propModel:ModelProp;
        private var canExit:Boolean = false;
		private var data:Object;
		private var gift:Object;
		private var delay:int;
        
        public function ViewFightFinishSandTable(data:Object, gift:Object, delay:int) {
            this.propModel = ModelManager.instance.modelProp;
			this.data = data;
			this.gift = gift;
			this.delay = delay;
			this.init();
            //this.initUI(data, gift, delay);
            this.rewardTxt.text = Tools.getMsgById('_public210');
            this.anyTxt.text = Tools.getMsgById('_public114');
        }
        
        override public function onAddedBase():void {
			var delay:int = this.delay;
            this.panel.centerY = 60;
            Tween.to(this.panel, {centerY: 0}, 600, Ease.sineOut, null, delay);
            delay += 300;
            
            var i:int;
            var len:int;
            
            var bArr:Array = [false, false, false];
            if (this.data.winner == 0) {
                bArr[0] = true;
                if (this.data.teamWin[1] == 0) {
                    bArr[1] = true;
                }
                if (this.data.teamHpPer[0] >= 0.3) {
                    bArr[2] = true;
                }
            }
			//bArr[0] = true;
			//bArr[1] = true;
			//bArr[2] = true;
            //评星
            this.starBox.y -= 40;
            this.starBox.alpha = 0;
            Tween.to(this.starBox, {y: this.starBox.y + 40, alpha: 1}, 400, Ease.sineOut, null, delay);
            delay += 200;
            
            var img:Image;
            for (i = 0; i < 3; i++) {
                if (bArr[i]) {
                    img = new Image(AssetsManager.getAssetsUI('icon_64.png'));
                    img.x = i * 75 + (i-1) * 150;
                    img.y = -80;
                    img.alpha = 0;
					img.anchorX = 0.5;
					img.anchorY = 0.5;
                    img.rotation = 300;
                    img.scale(2, 2, true);
                    this.starBox.addChild(img);
                    Tween.to(img, {alpha: 1, x: i * 75, y: 0, rotation: 0, scaleX: 1, scaleY: 1}, 400, Ease.backOut, null, delay);
					Laya.timer.once(delay + 100, this, function(image:Image,index:int):void{
						if(!image.destroyed && this.starBox){
							var ani:Animation = FightLoad.loadAnimation('glow011', '', 1);
							ani.x = index * 75;
							this.starBox.addChildAt(ani,0);
						}
					}, [img,i]);
                    delay += 200;
                }
            }
            
            //显示状态
            this.stateBox.y -= 20;
            this.stateBox.alpha = 0;
            Tween.to(this.stateBox, {y: this.stateBox.y + 20, alpha: 1}, 400, Ease.sineOut, null, delay);
            delay += 400;
            for (i = 0; i < 3; i++) {
                //this.stateImg0.skin = 'ui/icon_no.png';
                if (!bArr[i]) {
                    this['stateImg' + i].skin = 'ui/icon_no.png';
                    //this['stateImg' + i].disabled = true;
                    this['stateTxt' + i].color = '#AAAAAA';
                }
            }
            this.stateTxt0.text = Tools.getMsgById('193000');
            this.stateTxt1.text = Tools.getMsgById('193001');
            this.stateTxt2.text = Tools.getMsgById('193002');
            
            //获得奖励
            this.rewardBox.alpha = 0;
            Tween.to(this.rewardBox, {alpha: 1}, 400, Ease.sineOut, Handler.create(this, this.showComplete), delay);
            delay += 400;
            var giftArr:Array = this.propModel.getRewardProp(this.gift,true);
            len = giftArr.length;
            var ww:int = this.rewardBox.width * 0.5 - 40;
            for (i = 0; i < len; i++) {
                var item:bagItemUI = new bagItemUI();
                item.alpha = 0;
                item.pos((i - (len - 1) / 2) * 100 + ww, 50);
                item.scale(0.6, 0.6);
                Tween.to(item, {alpha: 1, y: 20}, 400, Ease.sineOut, null, delay);
                delay += 100;
                
                var it:Array = giftArr[i];
                item.setData(it[0],it[1]);
                this.rewardBox.addChild(item);
            }
            
            this.on(Event.CLICK, this, this.onExit);
        }
        
        private function showComplete():void {
			this.alpha = 1;
            this.canExit = true;
        }
		
		override public function set alpha(value:Number):void {
			super.alpha = value;
        }
        
        private function onExit():void {
            if (this.canExit) {
                FightViewUtils.onExit();
            }
        }
    
    }

}