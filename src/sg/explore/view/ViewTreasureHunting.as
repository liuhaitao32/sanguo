package sg.explore.view
{
    import laya.display.Sprite;
    import laya.events.Event;
    import sg.boundFor.GotoManager;
    import sg.explore.model.ModelTreasureHunting;
    import sg.manager.ModelManager;
    import sg.model.ModelUser;
    import laya.ui.Image;
    import sg.manager.AssetsManager;
    import laya.ui.Box;
    import sg.manager.EffectManager;
    import sg.cfg.ConfigColor;
    import sg.model.ModelItem;
    import ui.explore.treasure_huntingUI;
    import sg.utils.Tools;
    import sg.manager.LoadeManager;
    import sg.cfg.ConfigClass;
    import laya.display.Node;
    import laya.display.Animation;
    import sg.explore.model.ModelExplore;
    import sg.net.NetMethodCfg;
    import sg.net.NetSocket;
    import sg.net.NetPackage;
    import laya.utils.Handler;
    import sg.manager.ViewManager;
    import sg.utils.ObjectUtil;
    import sg.cfg.ConfigServer;
    import laya.particle.Particle2D;
    import ui.com.hero_icon7UI;
    import sg.view.com.ComPayType;
    import sg.model.ModelHero;
    import sg.model.ModelGame;
    import sg.utils.MusicManager;
    import laya.ui.Label;
    import sg.guide.model.ModelGuide;
    import sg.cfg.HelpConfig;
    import sg.fight.FightMain;

    public class ViewTreasureHunting extends treasure_huntingUI
    {
        private var model:ModelTreasureHunting = ModelTreasureHunting.instance;
        private var treasureData:Object = null;
        private var _enemy:Boolean = false;
        private var cfg:Object = model.cfg;
        private var _enemyData:Object = null;
        private var ani_clould:Animation;
		private var mParticle:Particle2D;
		private var mParticle1:Particle2D;
		public static var sView:ViewTreasureHunting = null;
        public var lock:Boolean = false;
        public function ViewTreasureHunting()
        {
            sView = this;
            btn_msg.on(Event.CLICK, this, this.onClick, [btn_msg]);
            btn_shop.on(Event.CLICK, this, this.onClick, [btn_shop]);
            btn_fight.on(Event.CLICK, this, this.onClick, [btn_fight]);
            btn_pray.on(Event.CLICK, this, this.onClick, [btn_pray]);
            btn_help.on(Event.CLICK, this, this.onClick, [btn_help]);
            btn_search.on(Event.CLICK, this, this.onClick, [btn_search]);
            btn_back.on(Event.CLICK, this, this.onClick, [btn_back]);
            icon_Resource.on(Event.CLICK, this, this._onClickResourceIcon, [ModelTreasureHunting.RESOURCE_ID]);
            (btn_shop.getChildByName('label') as Label).text = Tools.getMsgById('_explore019');
            (btn_fight.getChildByName('label') as Label).text = Tools.getMsgById('_explore016');
            (btn_pray.getChildByName('label') as Label).text = Tools.getMsgById('_explore017');
            (btn_search.getChildByName('label') as Label).text = Tools.getMsgById('_explore060');
        }

        override public function initData():void {
            this._initUI();
        }

        override public function onAdded():void {
			this.setTitle(Tools.getMsgById("_explore010")); // 蓬莱寻宝
            LoadeManager.loadTemp(bg, AssetsManager.getAssetsAD('actPay1_8.jpg'));
            if (this['bg2']) {
                LoadeManager.loadTemp(this['bg2'], AssetsManager.getAssetsAD('actPay1_8.png'));
            }
            var modelUser:ModelUser = ModelManager.instance.modelUser;

            // 添加粒子动画
			this.mParticle = EffectManager.loadParticle("p010", 10, 30, (groupPanel0 as Node), true, 0,  540);
			this.mParticle1 = EffectManager.loadParticle("p011", 30, 30, (groupPanel1 as Node), true, 0,  420);
			this.mParticle.play();
			this.mParticle1.play();

            this.mParticle.visible = this.mParticle1.visible = true;
			this.mParticle.scale(1.5, 1.5);
            
            this._createClouldAnimation();
            this._createPlace();
            this._refreshUI(false, ModelTreasureHunting.instance, false);
			MusicManager.playMusic(MusicManager.BG_HUNT);

            // 检测新战报
            model.checkNewReport(Handler.create(this, function(red:Boolean):void {
                ModelGame.redCheckOnce(btn_msg, red);
            }));

            this._checkGuide();
        }

        private function _checkGuide():void {
            var user:ModelUser = ModelManager.instance.modelUser;
            var mining:Object = user.mining;
            // 没卜过卦，可以免费卜卦，没寻宝, 大于15级
            var openLevel:int = ConfigServer.system_simple.func_open['mining'][3];
            mining.magic_id || mining.free_magic_num || mining.res.some(function(item:Object):Boolean { return item !== null; }) || user.getLv() > (openLevel + 5) || ModelGuide.executeGuide('mining_guide');
        }
        
        private function _initUI():void {
            model.on(ModelTreasureHunting.FIGHT_END, this, this._fightEnd);
            model.on(ModelTreasureHunting.REFRESH_PLACE, this, this._initUI);
            box_resource.visible = name_box_enemy.visible = btn_help.visible = btn_msg.visible = btn_shop.visible = box_fight.visible = box_search.visible = btn_back.visible = false;
            icon_cost.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_GOLD), cfg.grab_change);
            if (!_enemy) {
                box_resource.visible = btn_help.visible = btn_msg.visible = btn_shop.visible = box_fight.visible = true;
                txt_fight.text = Tools.getMsgById('_public31', [(cfg.grab_num - model.grab_num) + '/' + cfg.grab_num]);
            }
            else {
                name_box_enemy.visible = btn_back.visible = true;
                icon_country.setCountryFlag(_enemyData.country);
                txt_name_enemy.text = _enemyData.uname;
                if (_enemyData.logId) { // 复仇
                    box_search.visible = false;
                    btn_back.x = box_fight.x + (box_fight.width - btn_back.width) * 0.5;
                }
                else {
                    box_search.visible = true;
                    btn_back.x = btn_shop.x;
                    
                    // 检查对手是否过期
                    if (_enemyData.timeout) {
                        var remainTime:int =  model.checkOverdue(_enemyData.timeout);
                        remainTime && Laya.timer.once(remainTime, this, this.enemyExpired);
                    }
                }
            }

            this._setTreasureData();
            ani_clould && (ani_clould.zOrder = 999);
            this._checkUI();
        }

        /**
         * 对手过期
         */
        public function enemyExpired():void {
            var scene:ViewTreasureHunting = ViewManager.instance.getCurrentScene() as ViewTreasureHunting;
            if (!FightMain.inFight && scene === this && _enemy) {
                ViewManager.instance.closePanel();
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_explore015'));
                this.backToHome();
            }
        }

        private function _checkUI():void {
            txt_pray.text = Tools.getMsgById('_explore039', [Tools.getMsgById(model.magic_id ? cfg.magic_date[model.magic_id].name : '_explore053')]);
            icon_Resource.setData(AssetsManager.getAssetsICON(ModelTreasureHunting.RESOURCE_ID + '.png'), ModelItem.getMyItemNum(ModelTreasureHunting.RESOURCE_ID));

            // 卜卦红点
            if (!model.isPray) {
                ModelGame.redCheckOnce(btn_pray, true);
            } else {
                ModelGame.redCheckOnce(btn_pray, false);
                ModelGame.redCheckOnce(btn_fight, model.canGarb);
            }
        }

        private function _setTreasureData():void {
            treasureData = model.treasureData;
            if (_enemy) {
                var res:Array = _enemyData.mining.res;
                treasureData = ObjectUtil.clone(treasureData, true) as Array;
                for(var i:int = 0, len:int = treasureData.length; i < len; i++) {
                    var resData:Array = res[i];
                    var sData:Object = treasureData[i];
                    sData.enemy = true;
                    sData.enemyHero = _enemyData.hero;
                    sData.country = _enemyData.country;
                    sData.uname = _enemyData.uname;
                    sData.logId = _enemyData.logId;
                    sData.heros = [];
                    sData.magic = '';
                    sData.grabbed_num = 0;
                    sData.endTime = 0;
                    sData.loseTime = 0;
                    if (resData) {
                        sData.endTime = Tools.getTimeStamp(resData[0]) + cfg.work_time * Tools.oneMinuteMilli;
                        sData.heros = resData[1];
                        sData.magic = resData[2];
                        sData.grabbed_num = resData[3];
                        sData.loseTime = Tools.getTimeStamp(resData[4]);
                    }
                    sData.state = model.getState(treasureData[i], _enemyData.country);
                }
            }

            // 更新UI
            treasureData.forEach(function(data, index):void {
                var place:ItemHuntPlace = box.getChildByName('place_' + index) as ItemHuntPlace;
                place && place.setData(data);
            }, this);
        }

        private function onClick(btn:Sprite):void {
            if (lock)  return;
            switch(btn)
            {
                case btn_msg:
                    model.checkNewReport(Handler.create(this, this._getGarbLogCB));
                    break;
                case btn_shop:
                    GotoManager.boundForPanel(GotoManager.VIEW_SHOP, 'mining_shop');
                    break;
                case btn_fight:
                    if (model.canGarb)  this._getGarbUserData();
                    else ViewManager.instance.showTipsTxt(Tools.getMsgById('_explore042'));
                    break;
                case btn_search:
                    if (model.cfg.grab_change <= ModelManager.instance.modelUser.gold)  this._getGarbUserData(true);
                    else ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0110'));
                    break;
                case btn_pray:
                    GotoManager.showView(ConfigClass.VIEW_HUNT_PRAY_PANEL);
                    break;
                case btn_help:
                    ViewManager.instance.showTipsPanel(Tools.getMsgById("_explore043"));
                    break;
                case btn_back:
                    this.backToHome();
                    break;
                default:
                    console.warn('ViewTreasureHunting onClick');
                    break;
            }
        }

        public function backToHome():void {
            this._playAnimation();
            _enemy = false;
            Laya.timer.once(800, this, this._initUI);
        }

        private function _getGarbLogCB():void {
            var normalReportArr:Array = model.reportArr[0];
            var garbedReportArr:Array = model.reportArr[1];
            ModelGame.redCheckOnce(btn_msg, false);
            ViewManager.instance.showView(ConfigClass.VIEW_FIGHT_REPORT_PANEL, [normalReportArr.slice(0, cfg.report_victory), garbedReportArr.slice(0, cfg.report_grab)]);
		}

        private function _getGarbUserData(refresh:Boolean = false):void {
            model.getGarbUserData(refresh);
        }

        /**
         * 添加云雾动画
         */
        private function _createClouldAnimation():void {
			ani_clould = EffectManager.loadAnimation("glow_clould", '', 3);
            ani_clould.visible = false;
            ani_clould.x = box.width* 0.5;
            ani_clould.y = box.height * 0.5;
            box.addChild(ani_clould as Node);
        }

        /**
         * 添加寻宝位置
         */
        private function _createPlace():void {
            var localNames:Array = ['_explore012', '_explore013', '_explore014'];
            var posArr:Array = [{x:16, y:530}, {x:322, y:322}, {x:16, y:112}];
            if (HelpConfig.type_app === HelpConfig.TYPE_WW) {
                posArr = [{x:16, y:530}, {x:360, y:300}, {x:20, y:100}];
            }
            var bgArr:Array = ['actPay1_11.png', 'actPay1_10.png', 'actPay1_9.png'];
            bgArr.forEach(function(imgId:String, index:int):void {
                var img_bg:Image = this['pic_' + index] as Image;
                var bgURL:String = AssetsManager.getAssetsAD(imgId);
                LoadeManager.loadTemp(img_bg, bgURL);
                var pos:Object = posArr[index];
                var name:String = Tools.getMsgById(localNames[index]);
                var place:Node = new ItemHuntPlace(pos, name, img_bg) as Node;
                place.name = 'place_' + index;
                this['place_' + index] = place; // 引导用的
                box.addChild(place);
            }, this);
        }

        /**
         * 播放云雾动画
         */
        private function _playAnimation():void {
			ani_clould.visible = true;
            ani_clould.clearEvents();
            ani_clould.gotoAndStop(0);
            ani_clould.play(ani_clould.index, false);
            ani_clould.once(Event.COMPLETE, this, this._onAnimationComplete);
            MusicManager.playSoundUI('mining_cloud');
            lock = true;
        }

        /**
         * 动画播放结束
         */
        private function _onAnimationComplete():void {
			ani_clould.visible = false;
            lock = false;
            Laya.timer.clear(this, this._initUI);
        }

        private function _fightEnd():void {
            this._refreshUI(false, ModelTreasureHunting.instance, true);
        }

        public static function checkHeroId(hid:String):Boolean {
            return (hid is String) && (/hero\d{3}/.test(hid));
        }

        public static function renderHeroIcon(box:Box):void {
            var data:Object = box.dataSource;
            var hid:String = data.hid;
            var sData:Object = data.sData;

            var item:hero_icon7UI = box.getChildByName('mc_icon') as hero_icon7UI;
            var comPower:ComPayType = box.getChildByName('comPower') as ComPayType;
            if (comPower) {
                comPower.visible = false;
                comPower.setNum(0);
            }
            var imgPanel:Box = item.heroIcon.getChildByName("imgPanel") as Box;
            var img:Image = item.heroIcon.getNodeByName(imgPanel,"img") as Image;
            var heroBg:Image = item.heroIcon.getNodeByName(imgPanel,"heroBg") as Image;
            var bgf:Image = item.heroIcon.getNodeByName(imgPanel,"bgf") as Image;
            var imgAwaken:Image = item.heroIcon.getNodeByName(imgPanel,"imgAwaken") as Image;
            item.imgAdd.visible = img.visible = heroBg.visible = bgf.visible = imgAwaken.visible = false;
            item.heroIcon.clearEvents();
            item.imgAdd.clearEvents();
            if (checkHeroId(hid)) {
                img.visible = heroBg.visible = bgf.visible = true;
                var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
                if (sData.enemy) {
                    md  = new ModelHero(true);
                    md.setData(sData.enemyHero[hid]);
                    md.getPrepare(true, sData.enemyHero[hid]);
                }
                item.heroIcon.setHeroIcon(md.getHeadId(), true, md.getStarGradeColor());
                item.heroIcon.on(Event.CLICK, null, function(hid:Object):void {
                    sData.enemy && ViewManager.instance.showView(ConfigClass.VIEW_HERO_INFO, [sData.enemyHero[hid]]);
                    sData.enemy || ViewManager.instance.showView(ConfigClass.VIEW_HERO_INFO, hid);
                }, [hid]);
                if (comPower) {
                    comPower.visible = true;
                    comPower.setNum(md.getPower());
                }
            }
            else if (sData.state === ModelTreasureHunting.STATE_BEFORE && !sData.enemy) {
                item.imgAdd.visible = true;
                item.imgAdd.on(Event.CLICK, ModelTreasureHunting.instance, ModelTreasureHunting.instance.createTroop, [sData.index]);
            }
        }
        private function _onClickResourceIcon(itemId:String):void
        {
            var num:int = ModelItem.getMyItemNum(itemId);
            ViewManager.instance.showItemTips(itemId, num);
        }

        override public function onRemoved():void {
            this._enemy = false;
            box.removeChild(ani_clould as Node);
            model.offAll(ModelTreasureHunting.FIGHT_END);
            model.offAll(ModelTreasureHunting.REFRESH_PLACE);

            // 移除粒子动画
			if(this.mParticle){
				this.mParticle.visible = false;
				this.mParticle.stop();
				this.mParticle.removeSelf();
				this.mParticle = null;
			}
			if(this.mParticle1){
				this.mParticle1.visible = false;
				this.mParticle1.stop();
				this.mParticle1.removeSelf();
				this.mParticle1 = null;
			}
            
            treasureData.forEach(function(data, index):void {
                var place:ItemHuntPlace = box.getChildByName('place_' + index) as ItemHuntPlace;
                place && place.removeSelf();
            }, this);
            
            Laya.timer.clear(this, this.enemyExpired);
            this._onAnimationComplete();
			MusicManager.playMusic(ModelManager.instance.modelGame.isInside ? MusicManager.BG_HOME : MusicManager.BG_MAP);
            super.onRemoved();
        }

        private function _refreshUI(enemy:Boolean, enemyData:Object, playAni:Boolean = true, logId:int = null):void {
            _enemy = enemy;
            _enemyData = enemyData;
            _enemyData.logId = logId;
            if (!playAni) {
                this._initUI();
                return;
            }
            this._playAnimation();            
            Laya.timer.once(800, this, this._initUI);
        }

        public static function refreshUI(enemy:Boolean = false, enemyData:Object = null, logId:int = null):void {
            ViewManager.instance.getCurrentScene() is ViewTreasureHunting && sView._refreshUI(enemy, enemyData, true, logId);
        }
    }
}