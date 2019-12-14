package sg.activities.view
{
	import sg.fight.logic.utils.FightUtils;
    import ui.activities.auction.auctionBaseUI;
    import sg.manager.AssetsManager;
    import laya.ui.Label;
    import laya.ui.Image;
    import sg.model.ModelHero;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.model.ModelItem;
    import sg.activities.model.ModelAuction;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.cfg.ConfigServer;
    import sg.utils.TimeHelper;
    import sg.activities.model.ModelActivities;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.model.ModelUser;
    import sg.manager.EffectManager;
    import laya.utils.Tween;
    import sg.manager.LoadeManager;

    public class AuctionBase extends auctionBaseUI
    {
        private var model:ModelAuction = ModelAuction.instance;
        private var c_price:int = 0;
        public function AuctionBase()
        {
            this._recordColor();
            this._changeColor(true);
            txt_owner_hint.strokeColor = txt_owner.strokeColor = txt_hint1.strokeColor = '#ce8300';
            txt_owner_hint.stroke = txt_owner.stroke = 1;
            txt_hint2.text = Tools.getMsgById('550020');
            txt_hint3.text = Tools.getMsgById('550019');
            txt_owner_hint.text = Tools.getMsgById('550035');
            btn.on(Event.CLICK, this, this._onClick);
            this.on(Event.UNDISPLAY, this, this._onRemove)
			
			this.icon_hero.on(Event.CLICK, this, this._onClickAwaken);
        }

        private function _onRemove():void {
            Laya.timer.clearAll(this);
        }

        private function _refreshTime():void {
            txt_time.text =  TimeHelper.formatTime(this._getRemainTime());
        }

        private function _getRemainTime():int {
            return model.getTimeByIndex(_dataSource.index);
        }

        private function set dataSource(source:Object):void {
            if (!source) return;
            _dataSource = source;
            var hid:String = source.hid;
            var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
            var imd:ModelItem = ModelManager.instance.modelProp.getItemProp(md.itemID);
            var heroName:String = Tools.getMsgById(md.name);
            var awakeName:String = md.getAwakenName();
            character.setHeroIcon(hid);
            icon_hero.setHeroIcon(hid);
            txt_hero_name.text = awakeName;
            icon_chip.setData(md.itemID, source.chipNum, -1);
            txt_chip_name.text = imd.name;
            txt_gift_name.text = Tools.getMsgById('550029', [heroName]);

            var state:String = model.getState(source.index);
            this._refreshTime();
            Laya.timer.clearAll(this);
            Laya.timer.loop(1000, this, this._refreshTime);
            if (state !== ModelAuction.STATE_BEFORE) {
                Laya.timer.once(this._getRemainTime(), this, function():void {model.refreshEvent();});
            }
            var endTime:int = Tools.getTimeStamp(source.endTime);
            box_owner.visible = false;

            if (c_price && c_price < source.currentPrice) {
                var offset:int = source.currentPrice - c_price;
                this.labelTween(offset);
            }
            c_price = source.currentPrice;

            icon_cost.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), source.currentPrice);
            btn.gray = state === ModelAuction.STATE_BEFORE;
            txt_hint1.stroke = 0;
            btn.skin = AssetsManager.getAssetsUI('btn_ok.png');
            switch(state) {
                case ModelAuction.STATE_BEFORE:
                    txt_hint0.text = Tools.getMsgById('_jia0056');
                    txt_hint1.text = Tools.getMsgById('550021');
                    btn.label = Tools.getMsgById('550023');
                    icon_cost.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), '?');
                    this._changeColor(true);
                    break;
                case ModelAuction.STATE_AUCTION:
                    txt_hint0.text = Tools.getMsgById('550026');
                    txt_hint1.text = Tools.getMsgById('550021');
                    btn.label = Tools.getMsgById('550023');
                    this._changeColor(true);
                    if (source.uid === ModelManager.instance.modelUser.mUID) {
                        txt_hint1.text = Tools.getMsgById('550033');
                        btn.skin = AssetsManager.getAssetsUI('btn_yes.png');
                        txt_hint1.stroke = 1;
                        btn.label = Tools.getMsgById('550041');
                        // _setLabelColor(txt_hint1, false);
                    }
                    break;
                case ModelAuction.STATE_BUY:
                    txt_hint0.text = Tools.getMsgById('550027');
                    txt_hint1.text = Tools.getMsgById('550020');
                    btn.label = Tools.getMsgById('_public44');
                    icon_cost.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), source.topPrice);
                    this._showOwner();
                    this._changeColor(false);
                    if (this._getRemainTime() === 0) {
                        model.event(ModelActivities.UPDATE_DATA);
                    }
                    break;
                case ModelAuction.STATE_SHOW:
                case ModelAuction.STATE_ENDED:
                    icon_cost2.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), source.currentPrice);
                    Laya.timer.clearAll(this);
                    this._showOwner();
                    this._changeColor(false);
                    break;
            }

            box_end.visible = state === ModelAuction.STATE_ENDED || state === ModelAuction.STATE_SHOW;
            box_time.visible = box_price.visible = btn.visible = !box_end.visible;

            Tools.textFitFontSize(txt_hero_name);
            Tools.textFitFontSize(txt_chip_name);
        }

        private function _showOwner():void {
            var uid:int = Number(_dataSource.uid);
            if (model.bidUnames[uid]) {
                box_owner.visible = true;
                txt_owner.text = model.bidUnames[uid];
                icon_flag.setCountryFlag(model.bidCountrys[uid]);
            }
        }

		public function labelTween(num:Number):void{
			var l:Label=new Label();

            var label_re:Label =  icon_cost.getChildByName('label') as Label;
			label_re.addChild(l);
            
			l.y = -30;
			l.fontSize=18;

            l.text = "+" + num;
            l.color = "#3dff00";
			Tween.to(l,{y:l.y-20},1200,null, Handler.create(l, l.destroy));
		}

        private function _onClick():void {
            // 检测英雄是否已经觉醒
            if (ModelManager.instance.modelGame.getModelHero(_dataSource.hid).getAwaken() === 1) {
                ViewManager.instance.showTipsTxt(Tools.getMsgById(model.cfg.repeat));
                return;
            }
            var user:ModelUser = ModelManager.instance.modelUser;
            var state:String = model.getState(_dataSource.index);
            switch(state) {
                case ModelAuction.STATE_BEFORE:
                    ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0057'));
                    break;
                case ModelAuction.STATE_AUCTION:
                    if (user.mUID == _dataSource.uid) {
                        ViewManager.instance.showTipsTxt(Tools.getMsgById('550037'));
                    }
                    else if (user.coin < (_dataSource.currentPrice + model.cfg.unit)) {
                        ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0060'));
                    }
                    else {
                        ViewManager.instance.showView(ConfigClass.AUCTION_BID, _dataSource);
                    }
                    break;
                case ModelAuction.STATE_BUY:
                    var topPrice:int = _dataSource.topPrice;
                    if (user.mUID == _dataSource.uid) {
                        ViewManager.instance.showTipsTxt(Tools.getMsgById(model.cfg.repeat));
                    }
                    else if (user.coin < topPrice) {
                        ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0060'));
                    }
                    else {
                        var repeat_key:String = ModelManager.instance.modelUser.mUID + 'auction_buy';
                        ViewManager.instance.showAlert(Tools.getMsgById('550046', [topPrice]), Handler.create(model, model.buy, [_dataSource.index]), null, '', false, false, repeat_key);
                    }
                    break;
            }
        }
        
		/**
         * 弹出已觉醒英雄的天赋
         */
		private function _onClickAwaken():void {
            var hid:String = this._dataSource.hid;
			var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
			var data:Object = FightUtils.clone(md.getMyData());
			if (!data) data = {};
			data.id = hid;
			data.name = md.name;
			data.awaken = 1;
			
			var hmd:ModelHero = new ModelHero(true);
            hmd.setData(data);
            ViewManager.instance.showView(ConfigClass.VIEW_HERO_TALENT_INFO,hmd);
        }

        /**
         * 记录颜色
         */
        private function _recordColor():void {
            (txt_hint0 as Object).oriColor = txt_hint0.color;
            (txt_hint1 as Object).oriColor = txt_hint1.color;
            (txt_gift_name as Object).oriColor = txt_gift_name.color;
            (txt_time as Object).oriColor = txt_time.color;
            (img_frame0 as Object).oriSkin = img_frame0.skin;
            (img_frame0 as Object).otherSkin = AssetsManager.getAssetsUI('bar_31.png');
            (img_frame1 as Object).oriSkin = img_frame1.skin;
            (img_frame1 as Object).otherSkin = AssetsManager.getAssetsUI('bar_16.png');
            (img_bg as Object).oriSkin = img_bg.skin;
            (img_bg as Object).otherSkin = AssetsManager.getAssetsUI('icon_war007_1.png');
            (img_hint0 as Object).oriSkin = img_hint0.skin;
            (img_hint0 as Object).otherSkin = AssetsManager.getAssetsUI('bar_23_1.png');
            (img_hint1 as Object).oriSkin = img_hint1.skin;
            (img_hint1 as Object).otherSkin = AssetsManager.getAssetsUI('bar_30.png');
            (btn as Object).oriSkin = btn.skin;
            (btn as Object).otherSkin = AssetsManager.getAssetsUI('btn_no.png');
        }

        /**
         * 改变颜色
         */
        private function _changeColor(notEnd:Boolean):void {
            _setLabelColor(txt_hint0, notEnd);
            _setLabelColor(txt_hint1, notEnd);
            _setLabelColor(txt_gift_name, notEnd);
            _setLabelColor(txt_time, notEnd);

            _setImageSkin(img_frame0, notEnd);
            _setImageSkin(img_frame1, notEnd);
            _setImageSkin(img_hint0, notEnd);
            _setImageSkin(img_hint1, notEnd);
            _setImageSkin(img_bg, notEnd);
            _setImageSkin(btn as Image, notEnd);

            if (!_dataSource) {
                return;
            }
            
            var hid:String = _dataSource.hid;
            var md:ModelHero = new ModelHero(true);
            md.initData(hid, ConfigServer.hero[hid]);
            if( md.rarity === 4) {
                LoadeManager.loadTemp(imgAwaken, AssetsManager.getAssetsAD(ModelHero.img_awaken_super));
            } else {
                LoadeManager.loadTemp(imgAwaken, AssetsManager.getAssetsAD(ModelHero.img_awaken_normal));
                EffectManager.changeSprColor(imgAwaken, notEnd ? 2 : 4);
            }
        }

        private function _setLabelColor(label:Label, notEnd:Boolean):void {
            label.color  = notEnd ? '#ffffff' : (label as Object).oriColor;
        }

        private function _setImageSkin(img:Image, notEnd:Boolean):void {
            img.skin  = notEnd ? (img as Object).otherSkin : (img as Object).oriSkin;
        }
    }
}