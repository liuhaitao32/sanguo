package sg.activities.view
{
    import laya.display.Sprite;
    import laya.events.Event;
    import laya.ui.List;
    import sg.activities.model.ModelActivities;
    import sg.cfg.ConfigServer;
    import sg.guide.model.GuideChecker;
    import sg.guide.model.ModelGuide;
    import sg.utils.ArrayUtil;
    import sg.cfg.ConfigApp;

    public class ActIconList extends List
    {
        public static const SHOW_ICONS:String = 'show_icons';
        private var act_left:Array = ConfigServer.system_simple.act_left;
        private var model:ModelActivities = ModelActivities.instance;
        public function ActIconList()
        {
            this.itemRender = ActIcon;
            this.model.on(ModelActivities.REFRESH_LIST, this, this.refreshList);
            this.on(Event.DISPLAY, this, this._onAdd);
            this.on(Event.UNDISPLAY, this, this._remove);
            this.mouseThrough = true;
            this.mouseThrough = true; 
            
            if (!ConfigServer.system_simple['act_left_show'] && ModelGuide.isNewPlayerGuide()) {
                this.visible = false;
                GuideChecker.instance.on(SHOW_ICONS, this, function():void {this.visible = true;});
            }
        }

        private function _onAdd():void {
            // 刷新列表
            this.refreshList();
        }

        private function _remove():void {
            this.model.off(ModelActivities.REFRESH_LIST, this, this.refreshList);            
        }
        
        private function refreshList():void
        {
            var data:Array = this.model.getLeftIconsData();
            var len:int = data.length;
            var left_cfg:Object = ConfigServer.system_simple.left_cfg;
            var maxLen:int = 7;
            if (left_cfg) {
                maxLen = left_cfg.max_num;
            }
            if(ConfigApp.isPC) maxLen = 6;
            if (len <= maxLen) {
                this.repeatX = 1;
                this.repeatY = data.length;
                this.array = data;
            }
            else {
                var tempData:Object = {type: "whatever", name: "", icon: data[0].icon, showTime: false};
                var arr2:Array = data.splice(maxLen);
                ArrayUtil.padding(arr2, maxLen, tempData);
                var newData:Array = [];
                for(var i:int = 0; i < maxLen; ++i) {
                    newData.push(data[i]);
                    newData.push(arr2[i]);
                }
                this.repeatX = 2;
                this.repeatY = maxLen;
                this.array = newData;
            }
        }
        
		public function getSpriteByName(name:String):Sprite
		{
			return this;
		}
    }
}

import laya.display.Animation;
import laya.events.Event;

import sg.activities.model.ModelActivities;
import sg.activities.model.ModelBaseLevelUp;
import sg.activities.model.ModelFreeBill;
import sg.activities.model.ModelFreeBuy;
import sg.activities.model.ModelPayment;
import sg.activities.model.ModelWXShare;
import sg.boundFor.GotoManager;
import sg.manager.AssetsManager;
import sg.manager.EffectManager;
import sg.model.ModelAlert;
import sg.model.ModelGame;
import sg.utils.Tools;

import ui.menu.ItemActUI;
import sg.cfg.ConfigClass;
import sg.activities.model.ModelRoolPay;
import sg.festival.model.ModelFestival;
import sg.activities.model.ModelAuction;
import sg.activities.model.ModelPayRank;
import sg.manager.ViewManager;
import sg.activities.model.ModelEquipBox;
import sg.activities.model.ModelSurpriseGift;
import sg.cfg.ConfigServer;
import sg.zmPlatform.ModelFocus;
import sg.zmPlatform.ModelVerify;
import sg.activities.model.ModelPhone;
import sg.festival.model.ModelFestivalPayAgain;

class ActIcon extends ItemActUI
{
    private var _cfg:Object;
    private var _ainm:Animation;
    public function ActIcon()
    {
        this.on(Event.DISPLAY, this, this._onDisPlay);
        this.imgIcon.on(Event.CLICK, this, this._onClickIcon)
        this.on(Event.UNDISPLAY, this, this._offDisPlay);
        var left_cfg:Object = ConfigServer.system_simple.left_cfg;
        if (left_cfg) {
            this.height = 82 + 13 * (left_cfg.name_lines);
        }
    }

    private function set cfg(value:Object):void {
        this._cfg= value;      
    }

    private function get cfg():Object {
        return this._cfg;
    }

    private function _onDisPlay():void
    {
        Laya.timer.loop(500, this, this._onLoop);
        this.mouseThrough = true;
        this.parent['mouseThrough'] = true;
    }

    override public function set dataSource(source:*):void {
        if (!source) { // 凑位置用的
            this.visible = false;
            return;
        }
        this._dataSource = source;
        this.mcTime.visible = source.showTime && source.model.getTime() > 0;
        switch(source.type)
        {
            case ModelActivities.TYPE_WONDER_ACT:
            case ModelActivities.TYPE_LIMIT_ACT:
                ModelGame.redCheckOnce(this, ModelActivities.instance.checkWonderActRed(source.type));
                break; 
            case ModelActivities.TYPE_FREE_BUY:
                ModelGame.redCheckOnce(this, ModelFreeBuy.instance.red_point());
                break; 
            case ModelActivities.TYPE_PAYMENT:
                ModelGame.redCheckOnce(this, ModelPayment.instance.redPoint);
                break; 
            case ModelActivities.TYPE_BASE_UP:
                ModelGame.redCheckOnce(this, ModelBaseLevelUp.instance.redPoint);
                break;
            case ModelActivities.TYPE_SHARE_REWARD:
                ModelGame.redCheckOnce(this, ModelWXShare.instance.redPoint());
                break;
            case ModelActivities.TYPE_HAPPY_BUY:
                ModelGame.redCheckOnce(this, ModelAlert.red_happy_all());
                break;
            case ModelActivities.TYPE_LIMIT_FREE:
                ModelGame.redCheckOnce(this, ModelFreeBill.instance.redPoint);
                break;
            case ModelActivities.TYPE_PHONE:
                ModelGame.redCheckOnce(this, ModelPhone.instance.redPoint);
                break;
            case ModelActivities.TYPE_FOCUS:
                ModelGame.redCheckOnce(this, ModelFocus.instance.redPoint);
                break;
            case ModelActivities.TYPE_VERIFY:
                ModelGame.redCheckOnce(this, ModelVerify.instance.redPoint);
                break;
            case ModelActivities.TYPE_ROOL_PAY:
                ModelGame.redCheckOnce(this, ModelRoolPay.instance.redPoint);
                break;
            case ModelActivities.TYPE_FESTIVAL:
                ModelGame.redCheckOnce(this, ModelFestival.instance.redPoint);
                break;
            case ModelActivities.TYPE_AUCTION:
                ModelGame.redCheckOnce(this, ModelAuction.instance.redPoint);
                break;
            case ModelActivities.TYPE_PAY_RANK:
                ModelGame.redCheckOnce(this, ModelPayRank.instance.redPoint);
                break;
            case ModelActivities.TYPE_EQUIP_BOX:
                ModelGame.redCheckOnce(this, ModelEquipBox.instance.redPoint);
                break;
            case ModelActivities.TYPE_SURPRISE_GIFT:
                ModelGame.redCheckOnce(this, ModelSurpriseGift.instance.redPoint);
                break;
            case ModelActivities.TYPE_PAY_AGAIN:
                ModelGame.redCheckOnce(this, ModelFestivalPayAgain.instance.redPoint);
                break;
        }
        this.setIconData(source);
    }

    private function _offDisPlay():void
    {
        Laya.timer.clearAll(this);
    }

    private function _onLoop():void
    {
        if(!_dataSource) return;
        var model:Object = _dataSource.model;
        if (model && model.getTime()) {
            this.setTime(model.getTime());
        }
        else {
            this.mcTime.visible = false;
        }
    }

    private function _onClickIcon():void
    {
        var type:String = this._dataSource.type;
        switch(type)
        {
            case ModelActivities.TYPE_WONDER_ACT:
            case ModelActivities.TYPE_LIMIT_ACT:
                GotoManager.boundForPanel(GotoManager.VIEW_ACTIVITIES, '', {actType:type});
                break;
            case ModelActivities.TYPE_FREE_BUY:
                GotoManager.boundForPanel(GotoManager.VIEW_FREE_BUY);               
                break;
            case ModelActivities.TYPE_PAYMENT:
                GotoManager.boundForPanel(GotoManager.VIEW_PAYMENT);               
                break;
            case ModelActivities.TYPE_BASE_UP:
                GotoManager.boundForPanel(GotoManager.VIEW_BASE_LEVEL_UP);         
                break;
            case ModelActivities.TYPE_SHARE_REWARD:
                GotoManager.boundForPanel(GotoManager.VIEW_ACTIVITIES_SHARE);         
                break;
            case ModelActivities.TYPE_HAPPY_BUY:
                GotoManager.boundForPanel(GotoManager.VIEW_HAPPY_BUY);         
                break;
            case ModelActivities.TYPE_PAY_AGAIN:
                GotoManager.showView(ConfigClass.VIEW_FESTIVAL_PAYAGAIN);
                break;
            case ModelActivities.TYPE_LIMIT_FREE:
                GotoManager.showView(ConfigClass.VIEW_FREE_BILL);
                break;
            case ModelActivities.TYPE_PHONE:
                if (ModelPhone.instance.bindSupported) {
                    ModelPhone.bindPhone();
                } else {
                    GotoManager.boundForPanel(GotoManager.VIEW_PHONE);
                }
                break;
            case ModelActivities.TYPE_FOCUS:
                ModelFocus.instance.focusOnPublicAccount();
                break;
            case ModelActivities.TYPE_VERIFY:
                ModelVerify.instance.nameVerify();
                break;
            case ModelActivities.TYPE_ROOL_PAY:
                GotoManager.boundForPanel(GotoManager.VIEW_SUPER_INFO);
                break;
            case ModelActivities.TYPE_FESTIVAL:
                GotoManager.boundForPanel(GotoManager.VIEW_FESTIVAL);
                break;
            case ModelActivities.TYPE_AUCTION:
                GotoManager.boundForPanel(GotoManager.VIEW_AUCTION);
                break;
            case ModelActivities.TYPE_PAY_RANK:
                if (ModelPayRank.instance.notStart) {
                    ViewManager.instance.showView(ConfigClass.VIEW_PAY_RANK_TIPS);
                }
                else {
                    ModelPayRank.instance.round_dict && GotoManager.boundForPanel(GotoManager.VIEW_PAY_RANK);
                }
                break;
            case ModelActivities.TYPE_EQUIP_BOX:
                GotoManager.boundForPanel(GotoManager.VIEW_EQUIP_BOX);
                break;
            case ModelActivities.TYPE_SURPRISE_GIFT:
                GotoManager.boundForPanel(GotoManager.VIEW_SURPRISE_GIFT);
                break;
        }        
    }

    public function setIconData(cfg:Object):void
    {
        this.cfg = cfg;
        this.imgIcon.skin = AssetsManager.getAssetsICON(cfg.icon + '.png', true);
        var name:String = Tools.getMsgById(cfg.name);
        // name = 'Hello\nWorld';
        this.nameLabel.text = name;
        if (Tools.isNullString(cfg.ui)) {
            this.imgPanel.visible = false;
        }
        else {
            this.imgPanel.visible = true;
            this.imgPanel.skin = AssetsManager.getAssetsUI(cfg.ui + '.png');
        }
        if (!this._ainm) {
            this._ainm = EffectManager.loadAnimation('buy_reward');;
            this.addChild(this._ainm);
            this._ainm.pos(this.imgIcon.x + this.imgIcon.width * 0.5, this.imgIcon.y + this.imgIcon.height * 0.5);
            this.setChildIndex(this._ainm, 0);
        }
    }

    public function setTime(milliseconds:int):void {
        if (milliseconds is String) {
            this.mcTime.visible = true;
            this.timeLabel.text = milliseconds as String;
            return;
        }
        if(milliseconds<=0){
            this.mcTime.visible = false;
            if (cfg.type === 'share_reward') {
                ModelWXShare.instance.event(ModelWXShare.EVENT_ChANGE_SHARE);
            //}else if(cfg.type === 'free_buy'){
            //    ModelFreeBuy.instance.event(ModelFreeBuy.EVENT_ChANGE_FREE_BUY);	
            }
            return;
        }
        this.mcTime.visible = true;
        milliseconds = milliseconds >= 0 ? milliseconds : 0;
        var seconds:int = Math.floor(milliseconds / 1000);
        var minutes:int = Math.floor(seconds / 60);
        var hours:int = Math.floor(minutes / 60);
        var days:int = Math.floor(hours / 24);
        hours %= 24;
        minutes %= 60;
        seconds %= 60;
        this.timeLabel.text = Math.floor(hours + days * 24) + ':' + formatTimeNumber(minutes) + ':' + formatTimeNumber(seconds);
    }

    private function formatTimeNumber(num:Number):String
    {
        var str:String = (num / 100).toFixed(2);
        return str.split('.')[1];
    }
}