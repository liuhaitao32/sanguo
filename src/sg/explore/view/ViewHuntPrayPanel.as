package sg.explore.view
{
    import ui.explore.pray_panelUI;
    import sg.utils.Tools;
    import laya.display.Animation;
    import laya.ui.Box;
    import sg.manager.EffectManager;
    import laya.events.Event;
    import laya.utils.Tween;
    import laya.utils.Handler;
    import sg.manager.AssetsManager;
    import sg.explore.model.ModelExplore;
    import sg.net.NetMethodCfg;
    import sg.explore.model.ModelTreasureHunting;
    import sg.model.ModelItem;
    import sg.net.NetSocket;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import laya.maths.Point;
    import laya.display.Sprite;
    import laya.display.Node;
    import sg.cfg.ConfigColor;
    import laya.utils.Ease;
    import sg.utils.MusicManager;
    import sg.manager.ViewManager;
    import sg.manager.LoadeManager;

    public class ViewHuntPrayPanel extends pray_panelUI
    {
		private var aniExp:Animation;
		private var aniExp2:Animation;
		private var _lock:Boolean;
		private var _playTimes:int;
		private var model:ModelTreasureHunting = ModelTreasureHunting.instance;
        public function ViewHuntPrayPanel()
        {
            comTitle.setViewTitle(Tools.getMsgById('_explore020'));
            btn_pray.on(Event.CLICK, this, this._onPray);
            this.on(Event.CLICK, this, this._removePrayAnimation);
            box_tool.on(Event.CLICK, this, this._onClickResourceIcon, [ModelTreasureHunting.PRAY_TOOL_ID]);
        }

        override public function onAddedBase():void {
            super.onAddedBase();
            _lock = false;
            this.isAutoClose = !_lock;
            LoadeManager.loadTemp(img_bg, AssetsManager.getAssetsUI('bg_17.png'));

            img_hero.setHeroIcon('hero420', false);
            this._createPrayAnimation();
            this._refreshTool();
            this._clearResult();
            
            if (model.magic_id) {
                this._showResult(false);
                var speak_change:Array = model.cfg.speak_change;
                txt_words.text = Tools.getMsgById(speak_change[Math.floor(Math.random() * speak_change.length)]);
            }
            else {
                var speak_begin:Array = model.cfg.speak_begin;
                txt_words.text = Tools.getMsgById(speak_begin[Math.floor(Math.random() * speak_begin.length)]);
            }
        }

        /**
         * 添加卜卦特效
         */
        private function _createPrayAnimation():void {
			aniExp = EffectManager.loadAnimation("glow_pray", '', 3);
			var box:Box = img_ptayTool.parent as Box;
            box.parent.addChild(aniExp as Node);
            var pos:Point = (box.parent as Sprite).globalToLocal(box.localToGlobal(Point.TEMP.setTo(box.width* 0.5, box.height * 0.4)));
            aniExp.pos(pos.x, pos.y);
			aniExp.visible = false;
            
			aniExp2 = EffectManager.loadAnimation("glow_pray_lighting", '', 3);
            this.addChild(aniExp2 as Node);
            pos = this.globalToLocal(box_result.localToGlobal(Point.TEMP.setTo(box_result.width* 0.5, txt_name.y + txt_name.height)));
            aniExp2.pos(this.width * 0.5, pos.y);
			aniExp2.visible = false;
            aniExp.zOrder = aniExp2.zOrder = 2;
        }

        private function _removePrayAnimation():void {
            if (!aniExp || !aniExp.visible)    return;

			aniExp.visible = false;
            img_ptayTool.visible = true;

            var magic_id:String = model.magic_id;
            var magicData:Object = model.cfg.magic_date[magic_id];
            this._changeColor(magicData.quality);
            _lock = false;
            this.isAutoClose = !_lock;
            
            box.zOrder = 1;
            mBg.zOrder = 0;

            var x0:Number = s0.x;
            var x1:Number = s1.x;
            s0.x -= 150;
            s1.x += 150;
            Tween.to(s0,{alpha:1,x:x0},300, Ease.circIn);
            Tween.to(s1,{alpha:1,x:x1},300, Ease.circIn);
            Tween.to(txt_name,{alpha:1}, 300, null, Handler.create(this, this._showResult), 150);
        }

        private function _onPray():void {
            var tooNum:int = ModelItem.getMyItemNum(ModelTreasureHunting.PRAY_TOOL_ID);
            var condition:Boolean = model.free_magic_num < model.cfg.magic_num || tooNum > 0;
            if (!condition || _lock || btn_pray.gray)  return;
            _lock = true;
            this.isAutoClose = !_lock;
            this._clearResult();
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_MAGIC, {}, Handler.create(this, this._prayCB));
        }

        private function _prayCB(re:NetPackage):void {
			ModelManager.instance.modelUser.updateData(re.receiveData);
            this._onPlayAnimation();
            this._refreshTool();
            _playTimes = 0;
		}

        /**
         * 清除卜卦结果
         */
        private function _clearResult():void {
            txt_name.text = '';
            txt_info.text = '';
            txt_tip.text = '';
            s0.alpha = 0;
            s1.alpha = 0;
            txt_name.alpha = 0;
        }

        /**
         * 播放卜卦动画
         */
        private function _onPlayAnimation():void {
            img_ptayTool.visible = false;
			aniExp.visible = true;
            aniExp.play(0, false);
            aniExp.clearEvents();
            aniExp.once(Event.COMPLETE, this, this._onAnimationComplete);
            MusicManager.playSoundUI('mining_pray');

            box.zOrder = 0;
            mBg.zOrder = 1;
        }

        /**
         * 动画播放结束
         */
        private function _onAnimationComplete():void {
            _playTimes += 1;
            if (_playTimes < 2) {
                aniExp.gotoAndStop(0);
                this._onPlayAnimation();
                return;
            }
            this._removePrayAnimation();
        }

        private function _showResult(playAni:Boolean = true):void {
            var data:Object = model.cfg.magic_date[model.magic_id];
            var magic_id:String = model.magic_id;
            var magicData:Object = model.cfg.magic_date[magic_id];
            var arr:Array = ['_explore049', '_explore050', '_explore051', '_explore052'];
            
            txt_name.text = Tools.getMsgById(arr[magicData.quality]) + ' - ' + Tools.getMsgById(data.name);
            txt_info.text = Tools.getMsgById(data.info);
            txt_tip.text = Tools.getMsgById(data.tip);
            txt_words.text = Tools.getMsgById(data.speak);

            this._changeColor(magicData.quality);
            if (playAni) {
                aniExp2.visible = true;
                aniExp2.gotoAndStop(0);
                aniExp2.play(0, false);
                MusicManager.playSoundUI('mining_lighting');
            }
            
            s0.alpha = s1.alpha = txt_name.alpha = 1;
        }

        private function _changeColor(quality:int):void {
            var index:int = [4, 3, 0, 0][quality];
            EffectManager.changeSprColor(s0 as Sprite, index);
            EffectManager.changeSprColor(s1 as Sprite, index);
            txt_name.color = ConfigColor.FONT_COLORS[index];
            EffectManager.changeSprColor(aniExp2 as Sprite, index);
        }

        private function _refreshTool():void {
            btn_pray.gray = false;
            if (model.free_magic_num < model.cfg.magic_num) {
                txt_hint.centerX = 0;
                txt_hint.text = Tools.getMsgById('_public34') + Tools.getMsgById('_explore017');
                box_tool.visible = false;
                btn_pray.label = Tools.getMsgById('_explore038', [model.cfg.magic_num - model.free_magic_num]); 
            }
            else {
                txt_hint.centerX = -55;
                txt_hint.text = Tools.getMsgById('_explore037');
                btn_pray.label = Tools.getMsgById('_explore017'); 
                box_tool.visible = true;
                btn_pray.gray = ModelItem.getMyItemNum(ModelTreasureHunting.PRAY_TOOL_ID) < 1;
            }
            iconTool.setData(AssetsManager.getAssetsICON(ModelTreasureHunting.PRAY_TOOL_ID + '.png'), ModelItem.getMyItemNum(ModelTreasureHunting.PRAY_TOOL_ID));
        }

        private function _onClickResourceIcon(itemId:String):void
        {
            var num:int = ModelItem.getMyItemNum(itemId);
            ViewManager.instance.showItemTips(itemId, num);
        }

        override public function onRemovedBase():void {
            aniExp.parent.removeChild(aniExp as Node);
            aniExp2.parent.removeChild(aniExp2 as Node);
            super.onRemovedBase();
        }
    }
}