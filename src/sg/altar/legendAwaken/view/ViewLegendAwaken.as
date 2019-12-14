package sg.altar.legendAwaken.view
{
    import ui.legendAwaken.legendAwakenUI;
    import sg.cfg.ConfigServer;
    import laya.events.Event;
    import sg.utils.Tools;
    import sg.manager.ViewManager;
    import laya.utils.Handler;
    import sg.altar.legendAwaken.model.ModelLegendAwaken;
    import sg.manager.AssetsManager;
    import sg.boundFor.GotoManager;
    import sg.cfg.ConfigClass;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import sg.manager.LoadeManager;
    import laya.utils.Tween;
    import laya.maths.Point;
    import ui.bag.bagItemUI;
    import laya.utils.Ease;
    import sg.utils.MusicManager;
    import laya.media.SoundChannel;
    import laya.ui.Box;
    import laya.ui.Label;
    import laya.utils.Browser;

    public class ViewLegendAwaken extends legendAwakenUI
    {
        public var model:ModelLegendAwaken = ModelLegendAwaken.instance;
		private var aniExp:Animation; // 抽将动画
		private var aniExp2:Animation; // 抽将特效
        private var cfg:Object = model.cfg;
        private var reward_temp:Array = null;
        private var channel:SoundChannel = null;
        public function ViewLegendAwaken() {
            comTitle.setViewTitle(Tools.getMsgById(cfg.name[0]));
            txt_tips.visible = Boolean(cfg.quota);
            txt_hint_0.text = Tools.getMsgById('_public249');
            txt_item.text = Tools.getMsgById('500309') + ':';
            btn_drop.label = Tools.getMsgById('_star_text05');
            btn_pay.label = Tools.getMsgById('_jia0141');
            btn_shop.label = Tools.getMsgById(cfg.name[1]);
            payIcon_hint.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), cfg.limit * 10 + ' ' + Tools.getMsgById('_jia0053'));
            comBoxBg.visible = false;

            btn_shop.on(Event.CLICK, this, this._onClickShop);
            box_hint.on(Event.CLICK, this, this._onClickPay);
            btn_drop.on(Event.CLICK, this, this._onViewRate);
            btn_help.on(Event.CLICK, this, this._onClickHelp);

            var fraction:Object = cfg.fraction;
            var ratio:int = 0;
            try {
                ratio = cfg['draw_' + ModelManager.instance.modelUser.mergeNum][0][1][0][0][1];
            } catch (e) {
                console.warn('检查一下传奇抽将配置');
                ratio = 1;
            }
            txt_buy_tips0_0.text = Tools.getMsgById('500304');
            txt_buy_tips1_0.text = Tools.getMsgById('500304');
            payIcon_0.setData(AssetsManager.getAssetsICON(model.itemId + '.png'), fraction[0][2]);
            payIcon_1.setData(AssetsManager.getAssetsICON(model.itemId + '.png'), fraction[1][2]);
            txt_buy_tips0_1.text = Tools.getMsgById('500305', [fraction[0][1] * ratio]);
            txt_buy_tips1_1.text = Tools.getMsgById('500305', [fraction[1][1] * ratio]);
            btn_buy_0.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), fraction[0][0]);
            btn_buy_1.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), fraction[1][0]);
            btn_buy_0.on(Event.CLICK, this, this.onClickBuy, [0]);
            btn_buy_1.on(Event.CLICK, this, this.onClickBuy, [1]);
            mBtn.on(Event.CLICK, this, this._removeAnimation);
            itemIcon.on(Event.CLICK, this, this._onClickItem);
            payIcon_0.on(Event.CLICK, this, this._onClickItem);
            payIcon_1.on(Event.CLICK, this, this._onClickItem);
            box_heroRoll.createIcons(model.hids);
        }

        override public function initData():void {
            box_heroRoll.startRoll();
            model.on(ModelLegendAwaken.UPDATE_DATA, this, this.refreshPanel);
        }

        override public function onAdded():void {
            btn_buy_0.disabled = btn_buy_1.disabled = mBtn.visible = false;
            this.refreshPanel();
            LoadeManager.loadImg('clip/glow_lyrics/hero01.png');
            LoadeManager.loadImg('clip/glow_lyrics/hero02.png');
            LoadeManager.loadImg('clip/glow_lyrics/hero03.png');
            LoadeManager.loadImg('clip/glow_lyrics/hero04.png');
            Laya.timer.once(100, this, function():void {
                aniExp = EffectManager.loadAnimation("glow_lyrics", '', 3);
                aniExp.on(Event.COMPLETE, this, this._aniComplete);
                aniExp.x = box.width * 0.5;
                aniExp.y = box.height * 0.5;
                aniExp.visible = false;
                box.addChild(aniExp);
                comBox.zOrder = 1; // 将奖励展示在上层
            });
            this.refreshTime();
            Laya.timer.loop(1000, this, this.refreshTime);
        }

        public function refreshPanel():void {
            var fraction:Object = cfg.fraction;
            if (ModelManager.instance.modelUser.pay_money_daily < cfg.limit) {
                btn_buy_0.disabled = btn_buy_1.disabled = box_hint.visible = true;
            } else {
                btn_buy_0.disabled = btn_buy_1.disabled = box_hint.visible = false;
                btn_buy_0.gray = !Tools.isCanBuy("coin", fraction[0][0], false);
                btn_buy_1.gray = !Tools.isCanBuy("coin", fraction[1][0], false);
            }

            txt_tips.text = Tools.getMsgById('_public62') + ([cfg.quota - model.draw_times, cfg.quota].join('/'));
            itemIcon.setData(AssetsManager.getAssetsICON(model.itemId + '.png'), model.score);
        }

        private function playAnimation():void {
            this.btnCloseFun = aniExp.visible = mBtn.visible = true;
			aniExp.play(0, false);
			comBox.destroyChildren();
            channel = MusicManager.playSoundUI('legend_awaken01');
            var time:Number = Tools.oneMillis * (aniExp.frames.length / 12) * 0.55;
            Laya.timer.once(time, this, this.showReward);
        }
 
        private function _aniComplete(isDelay:Boolean = true):void {
            aniExp.gotoAndStop(0);
            aniExp.visible = false;
            
            // 非正常结束展示奖励
            isDelay || this.showReward(isDelay);
        }

		private function showReward(isDelay:Boolean = true):void {
            Laya.timer.clear(this, this.showReward);
            channel = MusicManager.playSoundUI('office_up');
            comBoxBg.visible = true;
            var oriX:Number = comBox.width * 0.5;
            var oriY:Number = comBox.height * 0.5;
            var offset:Number = 120;

            if (reward_temp.length > 1) {
                oriX -= offset * 2;
                oriY -= offset * 0.5;
            }

            reward_temp && reward_temp.length && reward_temp.forEach(function(obj:Object, index:int):void {
                var arr:Array = ModelManager.instance.modelProp.getRewardProp(obj)[0];
				var com:bagItemUI = new bagItemUI();
				com.name = 'com' + index;
				com.setData(arr[0], arr[1], -1);
				com.scaleX = com.scaleY = 0.8;
				com.anchorX = com.anchorY = 0.5;
                com.alpha = isDelay ? 0 : 1;
                var x:Number = (index % 5) * offset + oriX;
                var y:Number = Math.floor(index / 5) * offset + oriY;
                com.pos(x, y);
                comBox.addChild(com);
                isDelay && comShow(com, 50 * (index + 1));
                Laya.timer.once(isDelay ? (reward_temp.length + 1) * 50 : 30, this, showOver);
            }, this);
        }

		private function comShow(com:*,delay:Number):void{
			com.alpha=0;
			com.scaleX=com.scaleY=0;
			Tween.to(com,{scaleX:0,scaleY:0},200,null,new Handler(this, function():void{
				var a:Animation=EffectManager.loadAnimation('glow_lyrics1', '', 1);
				comBox.addChild(a);
				a.x=com.x;
				a.y=com.y;
				Tween.to(com,{alpha:1},100,null);	
				Tween.to(com,{scaleX:1,scaleY:1},250,null,new Handler(this, function():void{
					// MusicManager.playSoundUI(MusicManager.SOUND_EQUIP_BOX_SHOW);
					Tween.to(com, {scaleX:0.8, scaleY:0.8}, 250);
				}));
			}),delay);
		}

		private function showOver():void {
			for(var i:int=0;i<comBox.numChildren;i++){
				var com:*=comBox.getChildByName("com"+i);
				com && comTween(com);		
			}
        }

        private function removeReward():void {
            this.btnCloseFun = mBtn.visible = comBoxBg.visible = false;
            btn_buy_0.mouseEnabled = btn_buy_1.mouseEnabled = true;
            reward_temp && reward_temp.length && reward_temp.forEach(function(obj:Object, index:int):void {
				var com:bagItemUI = comBox.getChildByName("com" + index) as bagItemUI;
                com && comGet(com, obj);
            }, this);
            comBox.destroyChildren();
        }

		/**
		 * 上下跳动
		 */
		private function comTween(com:*,b:Boolean=true):void {
			var delay:Number = b ? Tools.getRandom(0,7) * 100 : 0;
            EffectManager.tweenLoop(com, {y: com.y + 6}, 600, Ease.linearOut, null, delay);
		}

		/**
		 * 物品收到仓库动画
		 */
		private function comGet(com:bagItemUI, o:Object):void{
			var pos:Point = Point.TEMP.setTo(com.x, com.y);
			pos = com['parent'].localToGlobal(pos, true);
			ViewManager.instance.showIcon(o, pos.x, pos.y, false,"",true);
		}
 
        private function _removeAnimation():void {
            channel && channel.stop && channel.stop();
            if (aniExp && aniExp.visible) {
                this._aniComplete(false);
            } else if (comBox.numChildren) {
                this.removeReward();
            }
        }
 
        private function refreshTime():void {
            if (model.getRemainingTime(false)) {
                txt_time.text = Tools.getMsgById('500313', [model.getTimeString(false)]);
            } else {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('500311'));
                this.closeSelf();
            }
        }

        override public function onRemoved():void {
            Laya.timer.clear(this, this.refreshTime);
            Laya.timer.clear(this, this.showOver);
            Laya.timer.clear(this, this.playAnimation);
            this.removeReward();
            aniExp.destroy();
            box_heroRoll.stopRoll();
            comBox.destroyChildren();
        }

        private function _onClickShop():void {
            if (model.active) {
                this.closeSelf();
                ViewManager.instance.showView(ConfigClass.VIEW_LEGEND_AWAKEN_SHOP);
            } else {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('500312'));
            }
        }

        private function _onClickPay():void {
            GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
        }

        private function onClickBuy(draw_type:int):void {
            var times:int = cfg.quota - model.draw_times;
            if (times < cfg.fraction[draw_type][1]) {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('500316'));
                return;
            } else if (ModelManager.instance.modelUser.coin < cfg.fraction[draw_type][0]) { // 黄金不足
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0060'));
                return;
            }
            MusicManager.playSoundUI(MusicManager.SOUND_GET_BAGGAGE);
            aniExp2 = EffectManager.loadAnimation("glow011","",1);
            var buyBox:Box = this['box_buy' + draw_type];
            aniExp2.pos(buyBox.width * 0.5, 15);
            buyBox.addChild(aniExp2);
            var l:Label=new Label();
            l.fontSize=18;
            l.color="#3dff00";
            l.text = '+' + (draw_type ? 10 : 1);
            l.pos(itemIcon.x + itemIcon.width * 0.4, itemIcon.y + itemIcon.height * 0.3);
            itemIcon.parent.addChild(l);
            Tween.to(l, {y: l.y - 30}, 450,  Ease.sineInOut, Handler.create(l, l.destroy), 0, false, false);
            btn_buy_0.mouseEnabled = btn_buy_1.mouseEnabled = false;
            model.sendMethod(NetMethodCfg.WS_SR_DRAW_LEGEND_AWAKEN, {draw_type: draw_type}, Handler.create(this, this.buyCB));
        }
        
		/**
		 * @param	re
		 */
		private function buyCB(re:NetPackage):void {
			var receiveData:* = re.receiveData;
			reward_temp = receiveData && receiveData.gift_dict_list;
			ModelManager.instance.modelUser.updateData(receiveData);
            Laya.timer.once(450, this, this.playAnimation);
		}

        private function _onViewRate():void {
            ViewManager.instance.showView(ConfigClass.VIEW_SHOW_PROBABILITY, [cfg.name[0], model.cfg_show_chance]);
        }

        private function _onClickItem():void {
            ViewManager.instance.showItemTips(model.itemId, model.score);
        }

        private function _onClickHelp():void {
            ViewManager.instance.showTipsPanel(Tools.getMsgById(cfg.info, [cfg.limit * 10]));
        }
    }
}