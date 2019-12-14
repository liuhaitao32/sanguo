package sg.altar.legend.view
{
    import sg.altar.legend.model.ModelLegend;
    import laya.events.Event;
    import sg.utils.Tools;
    import ui.fight.legendExperienceUI;
    import sg.model.ModelHero;
    import sg.activities.view.RewardItem;
    import sg.utils.ArrayUtil;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import laya.utils.Handler;
    import sg.cfg.ConfigServer;
    import sg.utils.StringUtil;
    import sg.boundFor.GotoManager;
    import sg.manager.ModelManager;

    public class ViewLegendExperience extends legendExperienceUI
    {
        public var model:ModelLegend = ModelLegend.instance;
        private var mModelHero:ModelHero = new ModelHero(true);
        private var hid:String = '';
        private var cfgData:Object;
        public function ViewLegendExperience() {
            comTitle.setViewTitle(Tools.getMsgById('_jia0128'), true);
            comHint2.setNum(Tools.getMsgById('_jia0126'));
            txt_tips.text = Tools.getMsgById('_jia0124');
            txt_limit.text = Tools.getMsgById('_jia0123');
            btn_challenge.label = Tools.getMsgById('_climb15');
            btn_help.on(Event.CLICK, this, this._onClickHelp);
            btn_challenge.on(Event.CLICK, this, this._onClickChallenge);
            reward_list.itemRender = RewardItem;
        }

        override public function initData():void {
            hid = currArg;
            cfgData = model.cfg_heros[hid].experience;
            mModelHero.initData(hid, ConfigServer.hero[hid]);
            model.on(ModelLegend.UPDATE_DATA, this, this.refreshPanel);
        }

        override public function onAdded():void {
            (hero_info as LegendBaseHero).setData(mModelHero);
            this._setLimitType();
            icon_reward.setData(mModelHero.itemID, -1, -1);
            
            reward_list.array = this._getListData();
            this.refreshPanel();
        }

        private function refreshPanel():void {
            btn_challenge.gray = model.remainTimes <= 0;
        }

        private function _setLimitType():void {
            var limit_type:Array = cfgData.limit_thero_type;
            var heroType:String = ModelHero.type_name_all[limit_type[0]];
            icon_limit_0.visible = Boolean(heroType);
            icon_limit_0.setHeroType(heroType);

            heroType = ModelHero.type_name_all[limit_type[1]];
            icon_limit_1.visible = Boolean(heroType);
            icon_limit_1.setHeroType(heroType);
            box_limit.visible = Boolean(limit_type.length);
        }

        private function _getListData():Array {
            var idPool :Array = [];
            var rewardPool :Array = [];
            var award:Object = ConfigServer.award;
            var ids:Array = ArrayUtil.flat(cfgData.fixed_reward, 99).filter(function(str:String):Boolean { return str is String; } );
            ids.forEach(function (awardId:String):void {
                var range:Array = award[awardId].range;
                range.forEach(function (arr2:Array):void {
                    var itemId:String = arr2[0][0];
                    if (idPool.indexOf(itemId) === -1) {
                        idPool.push(itemId);
                        rewardPool.push([itemId, -1]);
                    }
                });
            });
            return rewardPool;
        }

        override public function onRemoved():void {
            model.off(ModelLegend.UPDATE_DATA, this, this.refreshPanel);
        }

        private function _onClickChallenge():void {
            if (btn_challenge.gray && !price) {
                var price:int = model.buyPrice;
                if (price){
                    ViewManager.instance.showAlert(Tools.getMsgById("legend3", [1, Tools.getMsgById('_public146')]), Handler.create(model, model.buyChallengeTimes), ['coin', model.buyPrice]); // 购买次数
                }
                else {
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_pve_tips08"));
                }
                return;
            }
            ViewManager.instance.showView(ConfigClass.VIEW_LEGEND_TROOP, {
                title: Tools.getMsgById('_jia0128'),
                mMaxTroop: cfgData.max_battle,
                limitTypes: cfgData.limit_thero_type,
                handler: Handler.create(this, function(hids:Array):void {
                    model.challenge(mModelHero.id, hids, Handler.create(this, this._outFight));
                })
            });
        }

        private function _outFight(data:Object):void {
            GotoManager.boundForPanel(GotoManager.VIEW_LEGEND_EXPERIENCE, '', hid);
            ViewManager.instance.showView(['ViewLegendKillRate', ViewLegendKillRate], [StringUtil.numberToPercent(1 - data.pk_result.teamHpPer[1]), data.gift_dict]);
        }

        private function _onClickHelp():void {
            ViewManager.instance.showTipsPanel(Tools.getMsgById(model.cfg.help_tips, [cfgData.max_battle]));
        }
    }
}