package sg.explore.view
{
    import ui.explore.item_reportUI;
    import sg.manager.AssetsManager;
    import ui.explore.item_report_armyUI;
    import laya.utils.Handler;
    import ui.com.hero_icon1UI;
    import sg.model.ModelHero;
    import sg.manager.ModelManager;
    import laya.events.Event;
    import sg.utils.ArrayUtil;
    import laya.ui.Image;
    import laya.ui.Box;
    import sg.utils.Tools;
    import sg.explore.model.ModelTreasureHunting;
    import sg.fight.FightMain;
    import sg.explore.model.ModelExplore;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.manager.ViewManager;
    import sg.utils.StringUtil;
    import sg.cfg.ConfigServer;

    public class ItemFightReport extends item_reportUI
    {
        private var teamData:Array;
        private var revanche_uid:int;
        private var logId:int;
        public function ItemFightReport()
        {
            box_0.list.renderHandler = box_1.list.renderHandler = new Handler(this, this._renderHeroIcon);
            btn_watch.on(Event.CLICK, this, this._onClickWatchReport);
            btn_revanche.on(Event.CLICK, this, this._onClickRevanche);
            btn_watch.label = Tools.getMsgById('_explore029');
            btn_revanche.label = Tools.getMsgById('_explore026');
            this.txt_win.text = Tools.getMsgById('_explore028');
        }

        override public function set dataSource(source:*):void {
            if (!source) return;
            _dataSource = source;
            var date:Date = new Date(source.id);
            teamData = source.pk_data.team;
            txt_place.text = Tools.getMsgById(['_explore012', '_explore013', '_explore014'][source.resId]);
            txt_time.text = (date.getMonth()+1)+"-"+date.getDate()+" "+date.getHours()+":"+ StringUtil.padding(String(date.getMinutes()), 2, '0', false);

            img_revanche.visible = source.is_revenge;
            img_bg.visible = btn_watch.visible = btn_revanche.visible = txt_win.visible = false;
            box_garbed.visible = true;
            icon_garbed.setData(AssetsManager.getAssetsICON(ModelTreasureHunting.RESOURCE_ID + '.png'), source.grab_num);
            var passive:Boolean = teamData[0].uid !== ModelManager.instance.modelUser.mUID;
            logId = source.id;
            switch(source.state) {
                case ViewFightReportPanel.NORMAL:
                    img_bg.visible = true;
                    img_result.skin = AssetsManager.getAssetsUI('icon_win06.png');
                    txt_win.visible = passive;
                    if (passive) {
                        txt_win.visible = true;
                        box_garbed.visible = false;
                    }
                    else {
                        txt_num_hint.text = Tools.getMsgById('_explore016');
                    }
                    break;
                case ViewFightReportPanel.GARBED:
                    revanche_uid = teamData[0].uid;
                    txt_num_hint.text = Tools.getMsgById('_explore032');
                    btn_watch.visible = btn_revanche.visible = true;
                    img_result.skin = AssetsManager.getAssetsUI('icon_win07.png');
                    break;
                default:
                    break;
            }
            var teamWin:Array = source.teamWin;
            var heroWin:Array = source.hero_win;
            heroWin = heroWin || [0, 0, 0]; // 数据结构容错
            txt_score.text = teamWin.join(':');
            this.setPlayer(box_0, teamData[0], heroWin);
            this.setPlayer(box_1, teamData[1], heroWin.map(function (num:int):int { return 1 - num; }));
        }

        private function setPlayer(report_army:item_report_armyUI, data:Object, heroWin:Array):void {
            report_army.icon_country.setCountryFlag(data.country);
            report_army.txt_name.text = data.uname;
            var mdArr:Array = data.troop.map(function(data:*):ModelHero { 
                var md:ModelHero = new ModelHero(true);
                md.setData(data);
                md.getPrepare(true, data);
                return md;
            });

            var armyArr:Array = ArrayUtil.padding(mdArr, 3, null);
            armyArr.forEach(function (item:Object, index:int):void { item && (item.lose = Boolean(heroWin[index] === 0)); });
            report_army.list.array = armyArr;
        }

        private function _renderHeroIcon(item:hero_icon1UI):void {
            var md:ModelHero = item.dataSource;

            var imgPanel:Box = item.getChildByName("imgPanel") as Box;
            var img:Image = item.getNodeByName(imgPanel,"img") as Image;
            var heroBg:Image = item.getNodeByName(imgPanel,"heroBg") as Image;
            var bgf:Image = item.getNodeByName(imgPanel,"bgf") as Image;
            img.visible = heroBg.visible = bgf.visible = Boolean(md);
            item.setReportTag(false);
            if (md) {
                item.setReportTag(!md['lose']);
                item.setHeroIcon(md.id, true);
            }
        }

        private function _onClickWatchReport():void {
			//trace(Tools.getTimeStamp({$datetime: "2019-12-04 11:32:50"}))
			
			var fightData:Object = this._dataSource;
			
			if (FightMain.checkPlayback(fightData.time)){
				ViewManager.instance.closePanel();
				FightMain.startBattle(fightData);
			}
			else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_explore073"));
			}
        }

        private function _onClickRevanche():void {
            if (Tools.isNewDay(logId)) {
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_explore067"));
            }
            else if (!ModelTreasureHunting.instance.canGarb) {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_explore042'));
            }
            else {
                ViewManager.instance.closePanel();
                ModelExplore.instance.sendMethod('user_mining', {uid: revanche_uid}, Handler.create(this, this._onClickRevancheCB));
            }
        }

        private function _onClickRevancheCB(re:NetPackage):void {
            ViewTreasureHunting.refreshUI(true, re.receiveData, logId);
        }

    }
}