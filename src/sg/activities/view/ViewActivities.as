package sg.activities.view
{
    import laya.display.Sprite;
    import laya.ui.Box;
    import laya.utils.Handler;
    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelConsumeTotal;
    import sg.activities.model.ModelDial;
    import sg.activities.model.ModelFund;
    import sg.activities.model.ModelPayOnce;
    import sg.activities.model.ModelPayTotal;
    import sg.activities.model.ModelSaleShop;
    import sg.activities.model.ModelTreasure;
    import sg.activities.model.ModelWish;
    import sg.activities.view.PromoteMain;
    import sg.activities.view.WishMain;
    import sg.model.ModelGame;
    import sg.utils.SaveLocal;
    import sg.utils.Tools;
    import sg.view.com.ItemBase;
    import ui.activities.activitiesSceneUI;
    import laya.events.Event;
    import sg.utils.ArrayUtil;
    import sg.activities.ActivityHelper;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigServer;

    public class ViewActivities extends activitiesSceneUI
    {
        public static var instace:ViewActivities = null;
        private var model:ModelActivities = ModelActivities.instance;
        private var actType:String;
        private var tabType:String;
        private var mBox:Box;
        private var mFuncPanel:ItemBase;
        private var data:Array;
        private var tempData:Array = []; // 调试
        public function ViewActivities()
        {
            instace = this;
			this.tabList.itemRender = IconBase;
            this.tabList.scrollBar.hide = true;
            this.tabList.renderHandler = new Handler(this, this._updateTab);
            this.tabList.selectEnable = true;
            this.tabList.selectHandler = new Handler(this, this.tab_select);
            this.mBox = new Box();
            this.box.addChild(this.mBox);
            arrow_l.visible = arrow_r.visible = true;
            var offset:int = 20;
            tabList.width -= offset * 2;
            tabList.x = offset;
            tabList.scrollBar.changeHandler = new Handler(this, this._onTabScroll);
            tabList.on(Event.MOUSE_UP, this, this._checkArrowRed);
            tabList.on(Event.MOUSE_OUT, this, this._checkArrowRed);
        }

        /**
         * 设置箭头是否显示
         */
        private function _onTabScroll():void
        {
            var v:Number = tabList.scrollBar.value;
            var max:Number = tabList.scrollBar.max;
            arrow_l.visible = arrow_r.visible = true;
            if (v === 0) arrow_l.visible = false;
            if (v === max) arrow_r.visible = false;
        }

        /**
         * 红点检测
         */
        private function _checkArrowRed():void
        {
            var v:Number = tabList.scrollBar.value;
            var w:Number = tabList.cells[0].width;
            var spaceX:Number = tabList.spaceX;

            // 左侧未显示的个数
            var num_l:int = Math.floor((v + spaceX) / (w + spaceX));
            var start_r:int = Math.floor((v + tabList.width + spaceX) / (w + spaceX));
            // var num_l:int = Math.floor((v + spaceX + arrow_l.width) / (w + spaceX));
            // var start_r:int = Math.floor((v + tabList.width - arrow_l.width + spaceX) / (w + spaceX));
            var flag_l:Boolean = false;
            var flag_r:Boolean = false;

            for(var i:int = 0, len:int = this.data.length; i < len; i++)
            {
                var element:Object = this.data[i];
                if (i < num_l) {
                    flag_l = flag_l || this.redCheckByType(element.type, element.timeType);
                }
                else if (i >= start_r) {
                    flag_r = flag_r || this.redCheckByType(element.type, element.timeType);
                }
            }
            ModelGame.redCheckOnce(arrow_l, flag_l);
            ModelGame.redCheckOnce(arrow_r, flag_r);
        }

        override public function initData():void {
            actType = this.currArg['actType'];
            var type:String = this.currArg['type'];
            var act_left:Array = ConfigServer.system_simple.act_left;
            var wonder_act:Array = ConfigServer.system_simple.wonder_act;
            var limittime_act:Array = ConfigServer.system_simple.limittime_act;
            if (type) {
                actType = ArrayUtil.find(limittime_act, function(obj:Object):Boolean{return obj.type === type}, this) ? ModelActivities.TYPE_LIMIT_ACT : ModelActivities.TYPE_WONDER_ACT;
            }

			this.setTitle(Tools.getMsgById(ArrayUtil.find(act_left, function(obj:Object):Boolean{return obj.type === actType}, this).name));
            this.data = this.model.getActDataBytype(actType);
            this.tabList.array = this.data;
            this.tabList.selectedIndex = type ? ArrayUtil.findIndex(this.data, function(obj:Object):Boolean{return obj.type === type}, this): 0;
        }

        override public function onAdded():void {
            this.model.on(ModelActivities.REFRESH_TAB, this, this.refreshScne);
            this.refreshScne();
            Laya.timer.once(50, this, function ():void {
                this._onTabScroll();
                this._checkArrowRed();
            });
        }

        override public function onRemoved():void {
            Laya.timer.clearAll(this);
            this.model.off(ModelActivities.REFRESH_TAB, this, this.refreshScne);
            this.tabList.selectedIndex = -1;
            ModelActivities.instance.event(ModelActivities.REFRESH_LIST);
        }

        private function refreshScne():void
        {            
            this.data = this.model.getActDataBytype(this.actType);
            if (this.data.length === 0){
                Laya.timer.callLater(this,this.click_closeScenes);
                return;
                //this.click_closeScenes();
            }
            this.tabList.array=this.data;//.refresh();//更新红点
            var currentIndex:int = ArrayUtil.findIndex(this.data, function(item:Object):Boolean{return item.type === tabType;});
            if (currentIndex is Number) {
                //currentIndex = currentIndex <= 0 ? 0 : currentIndex;
                //this.tabList.selectedIndex != currentIndex && (this.tabList.selectedIndex = currentIndex);
                if(currentIndex==-1){//当前活动没了  页面重置为第一个
                    this.tabList.selectedIndex = -1;
                    this.tabList.selectedIndex = 0;
                }else{
                    this.tabList.selectedIndex != currentIndex && (this.tabList.selectedIndex = currentIndex);
                }

                
            }
            this.tabList.scrollBar.value=(this.tabList.selectedIndex==0)?0:this.tabList.scrollBar.value;
            this._onTabScroll();
            this._checkArrowRed();
        }

        private function _updateTab(item:IconBase, index:int):void
        {
            var source:* = item.dataSource;
            item.setData({id: source.icon, type:source.type, name: Tools.getMsgById(source.name)});
			item.setSelcetion(this.tabType === source.type);
            ModelGame.redCheckOnce(item, this.redCheckByType(source.type, source.timeType));
        }

        private function redCheckByType(type:String, timeType:String = null):Boolean
        {
            var notClicked:Boolean = !Boolean(SaveLocal.getValue(SaveLocal.KEY_ACT + type, true));
            switch(type)
            {
                case ActivityHelper.TYPE_ONCE:
                    return notClicked || ModelPayOnce.instance.checkRewardByType(timeType);
                case ActivityHelper.TYPE_ADD_UP:
                    return notClicked || ModelPayTotal.instance.checkRewardByType(timeType);
                default:
                    return notClicked || ActivityHelper.instance.getModelByType(type).redPoint;
            }
        }

        override public function set currArg(v:*):void {
			this.mCurrArg = v;
		}

        private function tab_select(index:int):void {
            if (index === -1 || this.tabList.length === 0)   return;
            var startIndex:int = tabList.startIndex;
            if (index <= startIndex) {
                index = startIndex;
                tabList.scrollTo(startIndex);
            }
            else if (index >= startIndex + tabList.repeatX) {
                index = startIndex + tabList.repeatX;
                tabList.scrollTo(startIndex + 1);
            }
            
            var cell:IconBase = this.tabList.getCell(index) as IconBase;
            cell.setSelcetion(true);
            tabType = this.data[index]['type'];
            this.clearFuncPanel();
            this.mBox.x = 0;
            this.mBox.y = this.tabList.y + this.tabList.height;
            var type:String = this.data[index].type;
            switch(type)
            {
                case ActivityHelper.TYPE_ONCE:
                    this.mFuncPanel = new PayOnceMain(data[index].timeType);
                    break;
                case ActivityHelper.TYPE_ADD_UP:
                    this.mFuncPanel = new PayTotalMain(data[index].timeType);
                    break;
                default:
                    this.mFuncPanel = ActivityHelper.instance.getItemBaseByType(type);
                    break;
            }
            if(this.mFuncPanel){
                this.mBox.addChild(this.mFuncPanel);
            }
        }

        private function clearFuncPanel():void{
            if (this.mFuncPanel is Sprite) {
                this.mFuncPanel['removeCostumeEvent'] && this.mFuncPanel['removeCostumeEvent']();
                this.mFuncPanel.removeSelf();
            }
            this.click_closeScenes
        }

        public static function resetScene():void
        {
            if (!instace) return;
            if (ModelActivities.instance.getActDataBytype(instace.actType).length) {
                instace.initData();
            }
            else {
                ViewManager.instance.closeScenes();
            }
        }
    }
}

import sg.manager.AssetsManager;
import sg.utils.SaveLocal;

import ui.shop.shop_icon_textUI;

class IconBase extends shop_icon_textUI{
    private var type:String;
	public function IconBase(){
		this.box1.visible=false;
	}

	public function setData(obj:*):void{
        type = obj.type;
		this.img0.skin=AssetsManager.getAssetsUI(obj.id+".png");
		this.label0.text=this.label1.text= obj.name;
	}	

	public function setSelcetion(b:Boolean):void{
		this.box1.visible=b;
		this.label0.visible=!b;
        
        var notClicked:Boolean = !Boolean(SaveLocal.getValue(SaveLocal.KEY_ACT + type, true));
        if (notClicked && type && b) {
            SaveLocal.save(SaveLocal.KEY_ACT + type, true, true);
        }
	}
}