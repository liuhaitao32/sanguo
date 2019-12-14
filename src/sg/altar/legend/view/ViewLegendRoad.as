package sg.altar.legend.view
{
    import ui.fight.legendRoadUI;
    import sg.altar.legend.model.ModelLegend;
    import sg.model.ModelHero;
    import sg.model.ModelTalent;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.boundFor.GotoManager;
    import sg.cfg.ConfigServer;
    import laya.html.dom.HTMLDivElement;
    import sg.utils.StringUtil;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import laya.utils.Handler;
    import sg.utils.ObjectUtil;
    import laya.display.Node;
    import sg.view.com.ComPayType;
    import sg.activities.view.RewardItem;
    import sg.manager.ModelManager;
    import laya.display.Animation;
    import sg.manager.EffectManager;

    public class ViewLegendRoad extends legendRoadUI
    {
        public var model:ModelLegend = ModelLegend.instance;
        private var mModelHero:ModelHero = new ModelHero(true);
		private var mModelTalent:ModelTalent;
        private var hid:String = '';
        private var cfgData:Object;
		private var aniExp:Animation;
        public function ViewLegendRoad() {
            comTitle.setViewTitle(Tools.getMsgById('_jia0127'));
            txt_hint.text = Tools.getMsgById('_jia0121');
            txt_hint2.text = Tools.getMsgById('_public113');
            txt_goal.text = Tools.getMsgById('_jia0122');
            txt_limit.text = Tools.getMsgById('_jia0123');
            btn_help.on(Event.CLICK, this, this._onClickHelp);
            btn_challenge.on(Event.CLICK, this, this._onClickChallenge);
            reward_list.itemRender = RewardItem;
			// 添加流光特效
			aniExp = EffectManager.loadAnimation("glow053");
            aniExp.x = btn_challenge.width * 0.5;
            aniExp.y = btn_challenge.height * 0.5;
            aniExp.autoSize = true;
            btn_challenge.addChild(aniExp);
        }

        override public function initData():void {
            hid = currArg;
            cfgData = model.cfg_heros[hid].road;
            mModelHero.initData(hid, ConfigServer.hero[hid]);
            mModelTalent = ModelTalent.getModel(this.mModelHero.id);
        }

        override public function onAdded():void {
            model.on(ModelLegend.UPDATE_DATA, this, this.refreshPanel);
            this._setLimitType();
            this.refreshPanel();
        }

        public function refreshPanel():void {
            (hero_info as LegendBaseHero).setData(mModelHero);
            // txt_talent.text = Tools.getMsgById("_hero32", [mModelTalent.getName()]);
			// txt_talent_info.text = Tools.getMsgById(this.mModelTalent.getLegendTalent(), [mModelTalent.getLegendValue(ModelHero.getStarMax())]);
            // this._initTalentBox();
            var killNum:int = model.getKillNum(hid);
            var need_kill:int = cfgData.need_kill;
            killNum = killNum > need_kill ? need_kill : killNum;
            txt_progress.text = killNum + '/' + need_kill;
            bar.value = killNum / need_kill;
            aniExp.visible = false;
            btn_challenge.label = Tools.getMsgById('_climb15');
            btn_challenge.gray = model.remainTimes <= 0;
            reward_list.array = ModelManager.instance.modelProp.getRewardProp(cfgData.reward);
            if (model.getRoadRewardState(mModelHero.id) === 1) {
                btn_challenge.gray = false;
                btn_challenge.label = Tools.getMsgById('_public103');
                aniExp.visible = true;
            }
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
        
        private function _initTalentBox():void {
			// boxTalent.destroyChildren();

			var color0:String = '#EEEEEE';
			var color1:String = '#EEDDAA';
			var color2:String = '#FCAA44';
			var color3:String = '#88AACC';
			var sign:String = Tools.getMsgById('_hero33');
			var info:String = this.mModelTalent.getInfoHtml();
			var infoArr:Array = info.split('；');
			var len:int = infoArr.length;
			var sumY:Number = 0;
			var tempY:Number = 0;
			
			for (var i:int = 0; i < len; i++) 
			{
				info = infoArr[i];
				if (!info)
					continue;
					
				var html:HTMLDivElement = new HTMLDivElement;
				// html.width = this.boxTalent.width;
				
				if (info.substr(0, 1) == '_'){
					//属于子项目
					info = info.substr(1);
					info = StringUtil.repeat('&nbsp;', 4) + StringUtil.substituteWithColor(info, color2, color3);
					tempY = 5;
					html.style.fontSize = 18;
				}
				else{
					info = StringUtil.substituteWithColor(sign + info, color2, (i % 2 == 0)?color0:color1);
					tempY = 6;
					html.style.fontSize = 18;
				}
				//html.style.fontSize = 20;
				html.style.leading = 8;

				html.innerHTML = info;
				html.y = sumY;
				// this.boxTalent.addChild(html as Node);
				
				sumY += html.contextHeight + tempY;
			}
			// this.boxTalent.height = sumY;
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
            if (model.getRoadRewardState(mModelHero.id) === 1) {
                model.getRoadReward(mModelHero.id);
                this.closeSelf();
                return;
            }
            ViewManager.instance.showView(ConfigClass.VIEW_LEGEND_TROOP, {
                title: Tools.getMsgById('_jia0127'),
                mMaxTroop: cfgData.max_battle,
                limitTypes: cfgData.limit_thero_type,
                handler: Handler.create(this, function(hids:Array):void {
                    model.challenge(mModelHero.id, hids, Handler.create(this, this._outFight));
                })
            });
        }

        private function _outFight(data:Object):void {
            var robot:Object = model.cfg.robot[hid];
            var armys:Array = ObjectUtil.values(robot.fixed);
            GotoManager.boundForPanel(GotoManager.VIEW_LEGEND_ROAD, '', hid);
            ViewManager.instance.showView(['ViewLegendKillNum', ViewLegendKillNum], data.pk_result.userKill);
        }

        private function _onClickHelp():void {
            ViewManager.instance.showTipsPanel(Tools.getMsgById(model.cfg.help_tips, [cfgData.max_battle]));
        }
    }
}