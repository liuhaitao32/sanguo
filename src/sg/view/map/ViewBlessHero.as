package sg.view.map
{
    import ui.map.bless_heroUI;
    import sg.model.ModelBlessHero;
    import sg.utils.Tools;
    import sg.model.ModelHero;
    import sg.manager.ModelManager;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import laya.utils.Handler;
    import sg.utils.StringUtil;
    import sg.manager.AssetsManager;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.utils.ArrayUtil;
    import sg.model.ModelUser;
    import sg.utils.TimeHelper;
    import sg.manager.LoadeManager;
    import sg.fight.logic.utils.FightUtils;
    import sg.cfg.ConfigServer;

    public class ViewBlessHero extends bless_heroUI {
        private var model:ModelBlessHero = ModelBlessHero.instance;
        private var rewardIndex:int;
        private var type:String;
        private var data:Object;
        private var showAni:Boolean;
        private var rankData:Array;
        private var myData:Array;
        private var secondary_lv:Array; // 额外等级
        public function ViewBlessHero() {
            btn_rank.label = Tools.getMsgById('bless_hero_01');
            txt_hurt_hint.text = Tools.getMsgById('bless_hero_09');
            txt_rank_hint.text = Tools.getMsgById('bless_hero_10');
            txt_times_hint.text = Tools.getMsgById('bless_hero_11');
            txt_tips.text = Tools.getMsgById('500056');
            btn_help.on(Event.CLICK, this, this._onClickHelp);
            btn_rank.on(Event.CLICK, this, this._onClickRank);
            btn.on(Event.CLICK, this, this._onClickButton);
            btn_left.on(Event.CLICK, this, this._onClickArrow, [-1]);
            btn_right.on(Event.CLICK, this, this._onClickArrow, [1]);
            heroIcon.on(Event.CLICK, this, this._onClickHeroIcon);
            list_reward.itemRender = BlessRewardBase;
        }

        override public function onAdded():void {
            type = currArg[0];
            showAni = currArg[1];
            data = model.teamData[type];
            mc_star.setStar(showAni ? data.reward_num : data.star_num, data.star_num);
            var hid:String = data.hid;
            txt_hero_name.text = ModelHero.getHeroName(hid, data.awaken);
            heroIcon.setHeroIcon(hid, false);
			this.imgAwaken.visible = data.awaken;
            var md:ModelHero = new ModelHero(true);
            md.initData(hid, ConfigServer.hero[hid]);
            if( md.rarity === 4) {
                LoadeManager.loadTemp(imgAwaken, AssetsManager.getAssetsAD(ModelHero.img_awaken_super));
            } else {
                LoadeManager.loadTemp(imgAwaken, AssetsManager.getAssetsAD(ModelHero.img_awaken_normal));
            }
            if (data.star_num === data.reward.length || data.star_num > data.reward_num) {
                rewardIndex = data.star_num;
            } else {
                rewardIndex = data.star_num + 1;
            }
            box_star.visible = data.star_num > 0;
            this.refreshReward();
            model.on(ModelBlessHero.UPDATE_DATA, this, this.refreshReward);

            // 获取排行榜数据
            this.getRank(type, model.show_num);

            this._refreshTime();
            this.timer.loop(Tools.oneMillis, this, this._refreshTime);
        }

        private function _refreshTime():void {
            txt_time.text = TimeHelper.formatTime(model.getTime(type)) + Tools.getMsgById('_public107');
        }

        private function refreshReward():void {
            txt_times.text = [data.remain_times, model.cfg.num].join('/')
            txt_reward.text = Tools.getMsgById('bless_hero_02', [StringUtil.numberToChinese(rewardIndex)]);
            var reward:Array = data.reward[rewardIndex - 1];
            var received:Boolean = data.reward_num >= rewardIndex;
            reward.forEach(function(arr:Array, index:int):void {
                arr[2] = received; // 是否已领取
            }, this);
            list_reward.array = reward;
            btn_left.visible = rewardIndex > 1;
            btn_right.visible = rewardIndex < data.reward.length;
            if (data.reward_num < data.star_num) {
                btn.label = Tools.getMsgById('bless_hero_08');
                btn.skin = AssetsManager.getAssetsUI('btn_no.png');
            } else {
                btn.label = Tools.getMsgById('bless_hero_07');
                btn.skin = AssetsManager.getAssetsUI('btn_ok.png');
            }
            this.refreshEntrance();
        }

        /**
         * 检查关闭面板
         */
        private function refreshEntrance():void {
            if (!model.checkActive(type)) {
                this.closeSelf();
            }
        }

        /**
         * 获取排行榜数据
         */
        private function getRank(type:String, size:int):void {
            model.sendMethod(NetMethodCfg.WS_SR_GET_BLESS_RANK, {type: type, size: size}, Handler.create(this, this.getRankCB));
        }

        private function getRankCB(re:NetPackage):void {
            var receiveData:Object = re.receiveData;
            rankData = receiveData.rank_list || [];
            myData = receiveData.myself || [0, 0];
            secondary_lv = receiveData.secondary_lv;
            secondary_lv = secondary_lv is Array ? secondary_lv : [];
            var user:ModelUser = ModelManager.instance.modelUser;
            // 服务器已经排序了
            // rankData.sort(function(a:Array, b:Array):Boolean {
            //     if (a[1][0] === b[1][0]) {
            //         return a[1][1] - b[1][1]; // 按照伤害排序（从大到小）
            //     } else {
            //         return b[1][0] - a[1][0]; // 按照时间排序（从小到大）
            //     }
            // });
            var uids:Array = rankData.map(function(arr:Array):int{return arr[0]}, this);
            model.sendMethod('w.get_user_list', {uids: uids}, Handler.create(this, this.reveive_user_list));

            // 检查自己排名
            var myRank:int = ArrayUtil.findIndex(rankData, function(arr:Array):Boolean {return user.mUID == arr[0]}, this);
            if (myRank !== -1) {
                txt_hurt.text = rankData[myRank][1][0];
                myData.push(myRank + 1);
                txt_rank.text = String(myRank + 1);
            } else {
                myData.push(0);
                txt_hurt.text = myData[0] || '0';
                txt_rank.text = Tools.getMsgById('_public101');
            }
        }
        
		public function reveive_user_list(np:NetPackage):void {
            np.receiveData.forEach(function(arr:Array, index:int):void {
                rankData[index][2] = arr;
                rankData[index][3] = index;
            }, this);
        }

        override public function onRemoved():void {
            mc_star.clear();
            this.timer.clear(this, this._refreshTime);
            model.off(ModelBlessHero.UPDATE_DATA, this, this.refreshReward);
        }

        private function _onClickArrow(num:int):void {
            rewardIndex += num;
            this.refreshReward();
        }

        private function _onClickRank():void {
            ViewManager.instance.showView(ConfigClass.VIEW_BLESS_HERO_RANK, [rankData, myData]);
        }

        private function _onClickButton():void {
            if (data.reward_num < data.star_num) {
                model.getReward(type, data.team_id);
                return;
            }
            
            if (data.remain_times === 0) {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('bless_hero_16'));
                return;
            }
            var arr:Array = model.getEnemyDataByType(type, secondary_lv);
            ViewManager.instance.showView(ConfigClass.VIEW_PVE_TROOP, {
                title: Tools.getMsgById('bless_hero_06'),
                saveKey: ModelManager.instance.modelUser.mUID + '_bless_hero_',
                mMaxTroop: 5,
                enemyData: {troop: arr},
                handler: Handler.create(this, function(hids:Array):void {
                    model.fight(type, data.team_id, hids);
                })
            });
        }

        private function _onClickHeroIcon():void {
            var hid:String = data.hid;
			var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
			var hmddata:Object = FightUtils.clone(md.getMyData());
			if (!hmddata) hmddata = {};
			hmddata.id = hid;
			hmddata.name = md.name;
			hmddata.awaken = data.awaken;
			var hmd:ModelHero = new ModelHero(true);
            hmd.setData(hmddata);
            ViewManager.instance.showView(ConfigClass.VIEW_HERO_TALENT_INFO, hmd);            
        }

        private function _onClickHelp():void {
            ViewManager.instance.showTipsPanel(Tools.getMsgById('bless_hero_03'));
        }
    }
}