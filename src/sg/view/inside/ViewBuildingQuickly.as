package sg.view.inside
{
    import ui.inside.buildingQuicklyUI;
    import sg.model.ModelBuiding;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.model.ModelInside;
    import laya.events.Event;
    import sg.cfg.ConfigServer;
    import laya.ui.Box;
    import sg.model.ModelItem;
    import ui.bag.bagItemUI;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ViewManager;
    import sg.view.com.ProgressCDfree;
    import sg.model.ModelOffice;

    public class ViewBuildingQuickly extends buildingQuicklyUI{
        private var mMode:ModelBuiding;//当前封地建筑
        public var mTimerAll:Number = 0;
        public var mTimerLast:Number = 0;
        public var reUIbyCD:Number = -1;
        //
        public var mBox_cd:Box;
        public var autoNum:Number = 0;
        public var autoID:String = "";
        public var mProgress:ProgressCDfree;
        public var mFreeTimer:Number = 0;
        public var mFreeM:Number = 0;
        public var mTypeCD:int = 0;
        public var needCoin:Number=0;
        public function ViewBuildingQuickly(){
            this.mBox_cd = new Box();
            this.mBox.addChild(this.mBox_cd);
            //
            this.btn_coin.on(Event.CLICK,this,this.click,[1]);
			this.btn_cd.on(Event.CLICK,this,this.click,[0]);
			this.btn_free.on(Event.CLICK,this,this.click,[-1]);
            //
            this.btnAdd.on(Event.CLICK,this,this.click_slider,[1]);
            this.btnLess.on(Event.CLICK,this,this.click_slider,[-1]);
            //
            this.slider.changeHandler = new Handler(this,this.slider_change);
            //
            this.mProgress = new ProgressCDfree();
            this.mBox.addChild(this.mProgress);
            this.mProgress.left = 10;
            this.mProgress.y = 100;
            this.mProgress.height=12;
            this.bar_time.visible = false;
            this.btn_free.visible = false;
            this.btn_cd.visible = false;
            this.btn_coin.visible = false;
            //
            this.mTypeCD = 0;
            btn_cd.label = Tools.getMsgById('_bag_text04');
            btn_free.label = Tools.getMsgById('_public34') + Tools.getMsgById('_building21');
            txt_hint0.text = Tools.getMsgById('_jia0103') + Tools.getMsgById('_jia0104');
            txt_hint1.text = Tools.getMsgById('_building21') + Tools.getMsgById('_jia0104');
            txt_hint2.text = Tools.getMsgById('_public34') + Tools.getMsgById('_jia0104');
        }
        override public function initData():void{
            this.mMode = this.currArg as ModelBuiding;
            //
        }
        override public function onAdded():void{
            ModelManager.instance.modelInside.on(ModelInside.BUILDING_UPDATE_CD,this,this.building_update_cd);
            //
            this.checkUI();
            this.checkBoxProps();
        }
        override public function onRemoved():void{
            ModelManager.instance.modelInside.off(ModelInside.BUILDING_UPDATE_CD,this,this.building_update_cd);
        }
        public function checkUI():void{
            this.mTimerAll = this.mMode.getLvCD(this.mMode.lv)*Tools.oneMillis;
            this.mTimerLast = this.mMode.getLastCDtimer();

            if(this.mTimerLast<=1000){
                this.closeSelf();
                return;
            }
            //
            var m:Number = (this.mTimerLast*0.001)/60;
            var passTimer:Number = this.mTimerAll - this.mTimerLast;
            this.mFreeM = this.mMode.getCDfree();
            this.mFreeTimer = 0;
            if(this.reUIbyCD!=m){
                this.reUIbyCD = m;
                //
                //this.tname.text = this.mMode.getName();
                this.comTitle.setViewTitle(this.mMode.getName());
                this.mFreeTimer = this.mFreeM*Tools.oneMinuteMilli;
                this.mProgress.initData(580,this.mTimerAll,passTimer,this.mFreeTimer);
                this.ttime.text = this.mMode.getLastCDtimerStyle();
                if(this.mProgress.isFree()){  
                    this.tStatus.text = Tools.getMsgById("_public34")+Tools.getTimeStyle(this.mFreeTimer);
                    this.btn_free.visible = true;
                    this.btn_cd.visible = false;
                    this.btn_coin.visible = false;
                }
                else{
                    this.tStatus.text = Tools.getMsgById("_building21")+this.mMode.getLastCDtimerStyle(this.mFreeTimer)+((this.mFreeTimer>0)?","+Tools.getMsgById("_public34")+Tools.getTimeStyle(this.mFreeTimer):"");
                    this.btn_free.visible = false;
                    this.btn_cd.visible = true;
                    this.btn_coin.visible = true;
                }
                //
                
                // this.bar_time.value = passTimer/this.mTimerAll;
                //
                var coin:Number = m-this.mFreeM;
                coin = coin<0?0:coin;
                this.btn_coin.setData("",ModelBuiding.getCostByCD(coin));
                needCoin=ModelBuiding.getCostByCD(coin);
                //
            }
        }
        public function checkBoxProps(selectIndex:int = -1):void{
            this.mBox_cd.destroyChildren();
            this.autoID = "";
            this.autoNum = 0;
            //
            var arr:Array = ModelItem.getBuildingUpdateItems(this.mTypeCD);
            var len:int = arr.length;
            var element:Object;
            var icon:bagItemUI;
            var cdIndex:int = -1;
            var m:Number = Math.ceil(((this.mTimerLast - this.mFreeTimer)*0.001/60 +1)*10)*0.1;
            var max:int = 0;

            // trace("加速时间",m);
            //
            var minIndex:int = -1;
            var isOK:Boolean = false;
            var minCD:Number = 0;
            //
            for(var index:int = 0; index < len; index++)
            {
                isOK = false;
                element = arr[index];
                if(element.num>0){
                    if(minIndex<0){
                        minCD = element.cd;
                        minIndex = index;
                    }
                    else{
                        if(element.cd<=minCD){
                            minIndex = index;
                        }
                    }
                    if(index == selectIndex){
                        isOK = true;
                    }
                    else{
                        if(m>=element.cd && selectIndex<0){
                            isOK = true;
                        }
                    }
                    if(isOK){
                        cdIndex = index;
                        this.autoID = element.id;
                        max = Math.floor(m/element.cd);
                        max = max>element.num?element.num:max;
                        max = max<=0?1:max;
                        // if((m - element.cd * max) <= element.cd && index == 0){
                        //     if((element.num - max)>0){
                        //         max = max+1;
                        //     }
                        // }
                    }
                }
                icon = new bagItemUI();
                this.mBox_cd.addChild(icon);
                //icon.setData(ModelItem.getItemIcon(element.id),ModelItem.getItemQuality(element.id),ModelItem.getItemName(element.id),element.num+"");
                icon.setData(element.id,element.num);
                icon.off(Event.CLICK,this,this.click_prop);
                icon.on(Event.CLICK,this,this.click_prop,[element,index]);
                //icon.alpha = 0.3;
                icon.setSelection(false);
                icon.x = index*(icon.width+10);
                icon.scaleX=0.9;
                icon.scaleY=0.9;
                
            }
            //
            this.mBox_cd.top = 115;
            this.mBox_cd.centerX = 0;
            //
            isOK = false;
            if(!Tools.isNullString(this.autoID)){
                this.autoNum = max;
            }
            else{
                //最小量也要推荐
                if(selectIndex>=0){
                    element = arr[selectIndex];
                    if(element.num>0){
                        cdIndex = selectIndex;
                        this.autoID = element.id;
                        this.autoNum = 1;
                    }
                }
                else{
                    if(minIndex>=0){
                        element = arr[minIndex];
                        if(element.num>0){
                            cdIndex = minIndex;
                            this.autoID = element.id;
                            this.autoNum = 1;
                        }
                    }
                }
            }
            //
            this.checkSelectCD(cdIndex);
            //
        }
        private function click_prop(element:Object,index:int):void{
            //if((this.mBox_cd.getChildAt(index) as bagItemUI).alpha<1){
                if(!(this.mBox_cd.getChildAt(index) as bagItemUI).selected){
                    if(element.num>0){
                        this.checkBoxProps(index);
                    }
                }
                
            //}
        }
        private function checkSelectCD(id:int):void{
            var len:int = this.mBox_cd.numChildren;
            for(var index:int = 0; index < len; index++)
            {
                if(index==id){
                    //(this.mBox_cd.getChildAt(index) as bagItemUI).alpha = 1;
                    (this.mBox_cd.getChildAt(index) as bagItemUI).setSelection(true);
                }
                else{
                    //(this.mBox_cd.getChildAt(index) as bagItemUI).alpha = 0.3;
                    (this.mBox_cd.getChildAt(index) as bagItemUI).setSelection(false);
                }
            }
            this.click_slider(0);
        }
        private function building_update_cd(md:ModelBuiding):void{
            if(md.id == this.mMode.id){
                this.checkUI();
            }
        }
        private function click_slider(type:int):void{
            if(type<0){
                if(this.slider.value>this.slider.min){
                    this.slider.value -=1;
                }
            }
            else if(type==0){
                this.slider.max = this.autoNum;
                this.slider.min = this.autoNum<=1?0:1;
                this.slider.value = this.slider.max;
            }
            else{
                if(this.slider.value<this.slider.max){
                    this.slider.value +=1;
                }
            }
            this.slider_change(0);
        }
        private function slider_change(v:Number):void{
            this.autoNum = this.slider.value;
            this.tCdNum.text = this.autoNum+"";
            //
            var num:int = parseInt(this.tCdNum.text);
            if(!Tools.isNullString(this.autoID)){
                // trace(this.autoID,this.autoNum);
                this.mProgress.recommendNum(ModelItem.getCDitemNum(this.autoID,this.mTypeCD)*this.autoNum);
            }
            this.btn_cd.disabled = (this.autoNum==0);
        }
        public function click(type:int):void{
            var s:Object;
            var num:int = parseInt(this.tCdNum.text);
            if(type == 1){
                s = {item_id:-1,item_num:1,bid:this.mMode.id};
                 if(!Tools.isCanBuy("coin",needCoin)){
                    return;
                }
            }
            else if(type < 0){
                s = {item_id:-2,item_num:1,bid:this.mMode.id};
            }
            else{
                if(Tools.isNullString(this.autoID)){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_building2"));
                    return ;
                }
                else{
                    s = {item_id:this.autoID,item_num:num,bid:this.mMode.id};
                }
                //
            var status:Array = ModelItem.checkCDitemStatus(s.item_id,num,this.mTimerLast);
                if(status[0]<0){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_public19"));
                    return;
                }
                if(status[1]>0){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_building3",[status[1]]));
                    return;
                }
            }
            this.mMode.netUpgrade(s,Handler.create(this,this.ws_sr_kill_building_cd));
        }
        private function ws_sr_kill_building_cd():void{
            this.checkUI();
            //
            this.checkBoxProps();
        }
    }   
}