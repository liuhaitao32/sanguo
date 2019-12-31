package sg.explore.view
{
    import sg.utils.Tools;
    import laya.utils.Handler;
    import laya.ui.Box;
    import sg.model.ModelHero;
    import sg.cfg.ConfigClass;
    import sg.manager.ViewManager;
    import laya.events.Event;
    import sg.manager.ModelManager;
    import sg.utils.ArrayUtil;
    import sg.view.com.ComPayType;
    import ui.com.hero_icon7UI;
    import sg.boundFor.GotoManager;
    import ui.explore.hunt_detailUI;
    import sg.explore.model.ModelTreasureHunting;
    import sg.utils.TimeHelper;
    import sg.manager.AssetsManager;
    import sg.cfg.ConfigServer;
    import laya.ui.Image;
    import laya.ui.Label;
    import laya.ui.List;

    public class ViewHuntDetail extends hunt_detailUI
    {
        private var _data:Object;
        private var _mine:Boolean;
        private var cfg:Object;
        public function ViewHuntDetail()
        {
            list_hero.renderHandler = new Handler(this, ViewTreasureHunting.renderHeroIcon);
            list_enemy.renderHandler = new Handler(this, this._renderGarbHint);
            btn.on(Event.CLICK, this, this._onClickBtn);
            img_resource.skin = AssetsManager.getAssetsICON(ModelTreasureHunting.RESOURCE_ID + '.png');
        }

        override public function onAddedBase():void {
            super.onAddedBase();
            _data = currArg.data;
            _mine = !_data.enemy;
            cfg = ModelTreasureHunting.instance.cfg;
            box_mine.visible = _mine;
            list_enemy.visible = !_mine;
            comTitle.setViewTitle(Tools.getMsgById(['_explore012', '_explore013', '_explore014'][_data.index]));
            this._initUI();
        }
        
        /**
         * 开始倒计时
         */
        private function _startCount():void {
            this._removeCount();

            // 设置进度
            this.refreshTime();
            list_hero.array = ArrayUtil.padding(_data.heros, 3, '').map(function (hid:String):Object { return {hid:hid, sData:_data} }); 
            Laya.timer.loop(1000, this, this.refreshTime);
        }
        
        /**
         * 移除倒计时
         */
        private function _removeCount():void {
            // trace('----------------移除---------------' + _data.index);
            Laya.timer.clear(this, this.refreshTime);
        }

        override public function onRemovedBase():void {
            this._removeCount();
            _mine && ModelTreasureHunting.instance.off(ModelTreasureHunting.REFRESH_DETAIL, this, this._initUI);
            super.onRemovedBase();
        }

        private function _initUI():void {
            var totalNum:int = cfg.work_reward[_data.index];
            var safeNum:int = cfg.grab_safe[_data.index];
            var ratioArr:Array = cfg.grab_resource;
            var grabedNum:int = _data.grabbed_num;

            var magicData:Object = cfg.magic_date[_data.magic];
            var increase_num:Number = (magicData && magicData.increase_num) ? magicData.increase_num : 1;
            var baseNum:int = Math.floor(_data.totalNum * increase_num - _data.grabbed_num);
            baseNum = baseNum < 1 ? 1 : baseNum;
            if (_mine) {
                txt_income.text = Tools.getMsgById('_explore035', [baseNum]);
                txt_garbed.text = Tools.getMsgById('_explore057', [grabedNum]);
                txt_battle.text = Tools.getMsgById('_explore040', _data.grabbedArr);   
                txt_name.text = Tools.getMsgById(magicData ? magicData.name : '_explore053');
                img_name.width = txt_name.textField.textWidth + 15;
                txt_info.text = magicData ? Tools.getMsgById(magicData.info) : '';
            }
            else {
                list_enemy.array = ratioArr.map(function(ratio:Number, index:int):Object{ return {star: 3 - index, resourceNum: Math.floor(ratio * (baseNum - safeNum))} }).reverse();
                txt_name.text = '';
                txt_info.text = '';
            }

            list_hero.array = ArrayUtil.padding(_data.heros, 3, '').map(function (hid:String):Object { return {hid:hid, sData:_data} });    
            btn.label = Tools.getMsgById(_mine ? '_explore023' : '_explore022');

            btn.visible = !_mine;
            box_hint0.y = 5;
            box_hint1.visible = box_hint2.visible = true;
            switch(_data.state)
            {
                case ModelTreasureHunting.STATE_BEFORE:
                    txt_time.text = Tools.getMsgById('_explore055');
                    btn.visible = _mine;
                    box_hint0.y = 25;
                    box_hint1.visible = box_hint2.visible = false;
                    break;
                case ModelTreasureHunting.STATE_MINING:
                    this._startCount();
                    break;
                case ModelTreasureHunting.STATE_REWARD:
                    txt_time.text = Tools.getMsgById('_explore048');
                    break;
                case ModelTreasureHunting.STATE_LOSE:
                    txt_time.text = Tools.getMsgById('_explore062');
                    break;
                default:
                    break;
            }
            if (_mine) {
                ModelTreasureHunting.instance.off(ModelTreasureHunting.REFRESH_DETAIL, this, this._initUI);
                ModelTreasureHunting.instance.on(ModelTreasureHunting.REFRESH_DETAIL, this, this._initUI);
            }
        }

        /**
         * 刷新时间
         */
        private function refreshTime():void {
            var remainTime:int = this.getRemainTime();
            if (remainTime <= 0) {
                this._removeCount();
                txt_time.text = Tools.getMsgById('_explore048');
            }
            else txt_time.text = TimeHelper.formatTime(remainTime) + Tools.getMsgById('_explore024');
        }
        
        private function getRemainTime():int {
            var remainTime:int = _data.endTime - ConfigServer.getServerTimer();
            remainTime = remainTime > 0 ? remainTime: 0;
            return remainTime;
        }
        
        private function _renderGarbHint(box:Box):void {
            var data:Object = box.dataSource;
            
            (box.getChildByName('star_0') as Image).skin = AssetsManager.getAssetsUI('icon_64.png');
            (box.getChildByName('star_1') as Image).skin = AssetsManager.getAssetsUI(data.star >= 2 ? 'icon_64.png' : 'icon_64_0.png');
            (box.getChildByName('star_2') as Image).skin = AssetsManager.getAssetsUI(data.star >= 3 ? 'icon_64.png' : 'icon_64_0.png');
            (box.getChildByName('hint_garb') as Label).text = Tools.getMsgById('_explore041');
            (box.getChildByName('icon_garb') as ComPayType).setData(AssetsManager.getAssetsICON(ModelTreasureHunting.RESOURCE_ID + '.png'), data.resourceNum < 1 ? 1 : data.resourceNum);
        }
        
        private function _onClickBtn():void {
            if (!_mine) {
                var scene:ViewTreasureHunting = ViewManager.instance.getCurrentScene() as ViewTreasureHunting;
                if (!_data.logId) {
                    var timeout:int = ModelTreasureHunting.instance.enemyData.timeout;
                    if (scene  is ViewTreasureHunting && timeout && ModelTreasureHunting.instance.checkOverdue(timeout) === 0) {
                        scene.enemyExpired();
                        return;
                    }
                }
                if (!ModelTreasureHunting.instance.magic_id) {
                    ViewManager.instance.showHintPanel(
                        Tools.getMsgById('_explore044'), // 内容
                        null,
                        [
                            {'name': Tools.getMsgById('_explore017'), 'handler': Handler.create(ViewManager.instance, ViewManager.instance.showView, [ConfigClass.VIEW_HUNT_PRAY_PANEL])},
                            {'name': Tools.getMsgById('_explore045'), 'handler': Handler.create(this, this.fight)},
                        ]
                    );
                } else {
                    if (scene  is ViewTreasureHunting) {
                        Laya.timer.clear(scene, scene.enemyExpired);
                    }
                    this.fight();
                }
            }
            else {
                ModelTreasureHunting.instance.createTroop(_data.index);
            }
        }

        private function fight():void {
            var enemyArr:Array = _data.heros.map(function(hid:String, index:int, arr:Array):Object { return {index: index, data: _data.enemyHero[hid], mine: false} }, this);
            ViewManager.instance.showView(ConfigClass.VIEW_PK_HUNT, {
                title: Tools.getMsgById('_explore021'),
                saveKey: ModelManager.instance.modelUser.mUID + '_pk_hunt_',
                mMaxTroop: 3,
                enemyData: {uname: _data.uname, country: _data.country, troop: enemyArr},
                handler: Handler.create(this, function(hids:Array):void {
                    ModelTreasureHunting.instance.garbUser(hids, _data.index, _data.logId);
                })
            });
        }

        override public function getSpriteByName(name:String):* {
			var reg:RegExp = /(.+)_(\d+)/;
			if (reg.test(name)) {
				var result:Array = name.match(reg);
				var list:List = this[result[1]];
				if (list is List) {
					return list.getCell(parseInt(result[2])).getChildByName('mc_icon')['imgAdd'];
				}
			}
            return super.getSpriteByName(name);
        }
    }
}