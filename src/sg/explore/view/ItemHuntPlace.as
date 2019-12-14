package sg.explore.view
{
    import laya.events.Event;
    import sg.utils.Tools;
    import sg.model.ModelOfficial;
    import laya.utils.Handler;
    import sg.view.com.ComPayType;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import sg.manager.LoadeManager;
    import sg.cfg.ConfigServer;
    import ui.com.hero_icon7UI;
    import sg.boundFor.GotoManager;
    import sg.cfg.ConfigClass;
    import sg.utils.ArrayUtil;
    import sg.manager.ViewManager;
    import sg.activities.model.ModelActivities;
    import sg.utils.StringUtil;
    import sg.utils.TimeHelper;
    import ui.explore.item_huntPlaceUI;
    import sg.explore.model.ModelExplore;
    import sg.net.NetMethodCfg;
    import sg.explore.model.ModelTreasureHunting;
    import laya.ui.Image;
    import laya.utils.HitArea;
    import sg.manager.EffectManager;
    import laya.display.Sprite;
    import laya.particle.Particle2D;
    import laya.display.Node;
    import sg.model.ModelUser;

    public class ItemHuntPlace extends item_huntPlaceUI
    {
        private var cfg:Object;
        private var _data:Object;
        private var img_bg:Image;
		private var mParticle:Particle2D;
        public function ItemHuntPlace(pos:Object, name:String, bg:Image) {
            img_bg = bg;
            cfg = ModelTreasureHunting.instance.cfg;
            this.pos(pos.x, pos.y);
            txt_title.text = name;
            list.renderHandler = new Handler(this, ViewTreasureHunting.renderHeroIcon);
            this.on(Event.CLICK, this, this._onClickBg);
            this.hitArea = new HitArea();
            hitArea.hit.drawRect(-50, -50, this.width + 30, this.height + 100);
            txt_lose.text = Tools.getMsgById('_explore056');

			// 添加流光特效
            mParticle = EffectManager.loadParticle("p007", 30, 50, this, false, 150,  120);
            mParticle.play();
            mParticle.zOrder = 0;
            box.zOrder = 1;
            
            this.txt_hint.text = Tools.getMsgById("_public245");
        }

        public function setData(data:Object):void {
            _data = data;
            this._removeCount();
            var user:ModelUser = ModelManager.instance.modelUser;
            var grab_city:Array = cfg.grab_city[_data.enemy ? _data.country : user.country];
            var cityNames:Array = grab_city.map(function(cId:String):String { return ModelOfficial.getCityName(cId) }, this);
            txt_lock.text = '';
            _data.index === 1 && (txt_lock.text = Tools.getMsgById('_explore071', cityNames));
            _data.index === 2 && (txt_lock.text = Tools.getMsgById('_explore072', cityNames));

            // 点击展示详情
            mParticle.visible = box_lose.visible = mc_time.visible = mc_heros.visible = img_bg.gray = mc_lock.visible = btn_reward.visible = false;
            txt_time.color = '#ffe65c'; // 黄色
            var magicData:Object = cfg.magic_date[_data.magic];
            var increase_num:Number = (magicData && magicData.increase_num) ? magicData.increase_num : 1;
            var baseNum:int = Math.floor(_data.totalNum * increase_num - _data.grabbed_num);
            baseNum = baseNum < 1 ? 1 : baseNum;
            this.setProgressBar(0);
            switch(_data.state) {
                case ModelTreasureHunting.STATE_LOCK:
                    img_bg.gray = mc_lock.visible = true;
                    break;
                case ModelTreasureHunting.STATE_BEFORE:
                    mc_time.visible = true;
                    txt_time.text = Tools.getMsgById(_data.enemy ? '_explore047' : '_explore034');
                    txt_percent.text = StringUtil.numberToPercent(0);
                    break;
                case ModelTreasureHunting.STATE_MINING:
        			mParticle.visible = mc_time.visible = true;
                    this._showHeros();
                    this._startCount();
                    break;
                case ModelTreasureHunting.STATE_REWARD:
                    mParticle.visible = mc_time.visible = btn_reward.visible = true;
                    if (_data.enemy)    this.setEnemyResourceNum(baseNum);
                    else {
                        txt_time.color = '#b9ff78'; // 绿色
                        txt_time.text = Tools.getMsgById('_explore036', [baseNum]);
                    }
                    txt_percent.text = StringUtil.numberToPercent(1);
                    this.setProgressBar(1);
                    break;
                case ModelTreasureHunting.STATE_LOSE:
                    mc_time.visible = box_lose.visible = true;
                    var percent:Number = 1 - (_data.endTime - _data.loseTime) / (cfg.work_time * Tools.oneMinuteMilli);
                    percent = percent < 0 ? 0 : (percent > 1 ? 1 : percent);
                    var tempNum:int = Math.floor(baseNum * 0.5 * percent);
                    if (_data.enemy)    this.setEnemyResourceNum(baseNum);
                    else {
                        txt_time.color = '#b9ff78'; // 绿色
                        txt_time.text = Tools.getMsgById('_explore036', [tempNum]);
                    }
                    txt_percent.text = StringUtil.numberToPercent(percent);
                    this.setProgressBar(percent);
                    break;
                default:
                    console.warn('ItemHuntPlace _init');
                    break;
            }
        }

        private function setEnemyResourceNum(baseNum:int):void {
            mc_time.visible = true;
            box_lose.visible = btn_reward.visible = false;
            var remainNum:int = Math.floor(cfg.grab_resource[0] * (baseNum - cfg.grab_safe[_data.index]));
            txt_time.text = Tools.getMsgById('_explore059', [remainNum >= 1 ? remainNum : 1]);
            this._showHeros();
        }

        /**
         * 显示英雄
         */
        private function _showHeros():void {
            mc_heros.visible =true;

            var heros:Array = _data.heros;
            list.array = ArrayUtil.padding(heros, 3, '').map(function (hid:String):Object { return {hid:hid, sData:_data} });

            // 计算战力
            var power:int = this._calculatePower();
            this.comPower.setNum(power);
            comPower.visible = power !== 0;
        }
        
        /**
         * 开始倒计时
         */
        private function _startCount():void {
            this._removeCount();

            // 设置进度
            this.refreshTime();
            Laya.timer.loop(1000, this, this.refreshTime);
        }
        
        /**
         * 移除倒计时
         */
        private function _removeCount():void {
            // trace('----------------移除---------------' + _data.index);
            Laya.timer.clear(this, this.refreshTime);
        }
        
        private function _remove():void {
            if (mParticle is Particle2D) {
                mParticle.visible = false;
                mParticle.stop();
                mParticle.removeSelf();
                mParticle = null;
            }
            this._removeCount();
        }

        private function _calculatePower():int {
            var totalPower:int = 0;
            _data.heros.forEach(function(hid:String):void {
                if (ViewTreasureHunting.checkHeroId(hid)) {
                    var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
                    if (_data.enemy) {
                        md  = new ModelHero(true);
                        md.setData(_data.enemyHero[hid]);
                        md.getPrepare(true, _data.enemyHero[hid]);
                    }
                    totalPower += md.getPower();
                }
            }, this);
            return totalPower;
        }

        private function setProgressBar(percent:Number):void {
            if (percent === 1)    bar_radial.graphics.drawCircle(mc_radial.width * 0.5, mc_radial.height * 0.5, mc_radial.width * 0.6, '#ff0000');
            else if (percent === 0)    bar_radial.graphics.clear();
            else bar_radial.graphics.drawPie(mc_radial.width * 0.5, mc_radial.height * 0.5, mc_radial.width * 0.6, -90, percent * 360 - 90, '#ff0000');
        }

        /**
         * 刷新时间
         */
        private function refreshTime():void {
            var remainTime:int = this.getRemainTime();
            var percent:Number = (cfg.work_time * Tools.oneMinuteMilli - remainTime) / (cfg.work_time * Tools.oneMinuteMilli);
            txt_percent.text = StringUtil.numberToPercent(percent);
            this.setProgressBar(percent);
            if (_data.enemy) {
                var magicData:Object = cfg.magic_date[_data.magic];
                var increase_num:Number = (magicData && magicData.increase_num) ? magicData.increase_num : 1;
                var baseNum:int = Math.floor(_data.totalNum * increase_num - _data.grabbed_num);
                var remainNum:int = Math.floor(cfg.grab_resource[0] * (baseNum - cfg.grab_safe[_data.index]));
                txt_time.text = Tools.getMsgById('_explore059', [remainNum < 1 ? 1 : remainNum]);
            }
            else {
                txt_time.text = TimeHelper.formatTime(remainTime) + Tools.getMsgById('_explore024');
            }

            if (_data.state === ModelTreasureHunting.STATE_LOCK) {
                this._removeCount();
            }

            // 可以收获
            if (remainTime === 0 && _data.state === ModelTreasureHunting.STATE_MINING) {
                this._removeCount();
                _data.state = ModelTreasureHunting.STATE_REWARD;
                this.setData(_data);
            }
        }
        
        private function getRemainTime():int {
            var remainTime:int = _data.endTime - ConfigServer.getServerTimer();
            remainTime = remainTime > 0 ? remainTime: 0;
            return remainTime;
        }

        private function _onClickBg(event:Event):void {
            if ((event.target as ItemHuntPlace) !== this && event.target.hasListener(Event.CLICK)) {
                return;
            }
            if (ViewTreasureHunting.sView.lock) return;

            // 检测战报是否过期
            if (_data.logId && Tools.isNewDay(_data.logId)) {
                ViewManager.instance.showTipsPanel(Tools.getMsgById("_explore067"));
                ViewTreasureHunting.sView.backToHome();
                return;
            }
            switch(_data.state) {
                case ModelTreasureHunting.STATE_LOCK:
                    if (_data.enemy) ViewManager.instance.showTipsTxt(Tools.getMsgById('_explore047'));
                    else ViewManager.instance.showTipsTxt(txt_lock.text);
                    break;
                case ModelTreasureHunting.STATE_BEFORE:
                    if (_data.enemy) ViewManager.instance.showTipsTxt(Tools.getMsgById('_explore047'));
                    else ViewManager.instance.showView(ConfigClass.VIEW_HUNT_DETAIL, {data:_data});
                    break;
                case ModelTreasureHunting.STATE_MINING:
                    ViewManager.instance.showView(ConfigClass.VIEW_HUNT_DETAIL, {data:_data});
                    break;
                case ModelTreasureHunting.STATE_REWARD:
                case ModelTreasureHunting.STATE_LOSE:
                    if (!_data.enemy) ModelTreasureHunting.instance.harvMining(_data.index);
                    else    ViewManager.instance.showView(ConfigClass.VIEW_HUNT_DETAIL, {data:_data});
                    break;
            }
        }
    }
}