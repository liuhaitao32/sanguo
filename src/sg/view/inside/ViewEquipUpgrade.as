package sg.view.inside
{
    import ui.inside.equipUpgradeUI;
    import laya.events.Event;
    import laya.utils.Handler;
    import laya.ui.Box;
    import sg.manager.ModelManager;
    import sg.cfg.ConfigServer;
    import sg.model.ModelEquip;
    import ui.com.payTypeUI;
    import sg.cfg.ConfigColor;
    import sg.model.ModelBuiding;
    import sg.model.ModelItem;
    import sg.utils.Tools;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.manager.ViewManager;
    import laya.ui.Label;
    import sg.model.ModelHero;
    import sg.manager.AssetsManager;
    import sg.model.ModelInside;
    import sg.model.ModelScience;
    import sg.utils.StringUtil;
    import sg.view.com.EquipInfoAttr;
    import sg.manager.LoadeManager;
    import sg.model.ModelGame;
    import laya.maths.MathUtil;

    public class ViewEquipUpgrade extends equipUpgradeUI{
        private var mBoxMakeItems:Box;
        private var mTabIndex:Object = {};
        private var mInfoAttr:EquipInfoAttr;
        private var needCoin:Number=0;
        private var payArr:Array;
        private var lastIndex:int;
        private var mEid:String;
        public function ViewEquipUpgrade():void{
            this.comTitle.setViewTitle(Tools.getMsgById("_equip30"));
            this.tab.selectHandler = new Handler(this,this.tab_select);
            this.list.itemRender = ItemEquip;
            this.list.scrollBar.hide = true;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.selectEnable = true;
            this.list.selectHandler = new Handler(this,this.list_select);
            //
            this.btn_coin.on(Event.CLICK,this,this.click,[1]);
            this.btn_cd.on(Event.CLICK,this,this.click,[0]);
            this.mBoxMakeItems = new Box();
            this.mInfo.addChild(this.mBoxMakeItems);
            //
            this.btn_change.on(Event.CLICK,this,this.click_change);
            this.text0.text = Tools.getMsgById("_equip33");
			this.btn_coin["textlabel"].text = Tools.getMsgById("_lht3");
        }
        private function click_change():void
        {
            this.mBoxInfo.visible = this.mBoxPro.visible;
            this.mBoxPro.visible = !this.mBoxInfo.visible;
        }
        override public function onRemoved():void{
            this.tab.selectedIndex = -1;
            this.list.selectedIndex = -1;
        }
        override public function initData():void{
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_19.png"));
            this.btn_change.visible = false;
            //
            var emb:ModelEquip;
            var all:Object = ModelManager.instance.modelUser.equip;
            var arr:Array = [];
            for(var key:String in all)
            {
                emb = ModelManager.instance.modelGame.getModelEquip(key);
                // this.mTabIndex[emb.type] = Number(emb.type);
                var n:Number=Number(emb.type)==3 ? 2 : Number(emb.type)==2 ? 3 : Number(emb.type);
                if(emb && arr.indexOf(n)<0){
                    arr.push(n);
                }
            }
            arr.sort();           
            // var arr:Array = ModelEquip.getHaveEquipTypes();
            var str:String = "";
            var len:int = arr.length;
            for(var i:int = 0; i < len; i++)
            {
                this.mTabIndex[i+""] = Number(arr[i]);
                str += ModelEquip.equip_type_name_tab[arr[i]]+",";
            }
            str = str.substr(0,str.length-1);
            //

            mEid=this.currArg?this.currArg:"";
            var outsideIndex:Number = mEid==""?-1:ModelManager.instance.modelGame.getModelEquip(mEid).type;
            if(outsideIndex>-1){
                outsideIndex = (outsideIndex==2)?3:(outsideIndex==3?2:outsideIndex);
            }

            for(var j:int=0;j<len;j++){
                if(this.mTabIndex[j]==outsideIndex){
                    outsideIndex=j;
                    break;
                }
            }
            
            //
            this.tab.labels = str;
            this.tab.selectedIndex = (outsideIndex==-1)?(this.tab.selectedIndex<0?0:this.tab.selectedIndex):outsideIndex;
            //
            this.mBoxInfo.visible = !this.mBoxPro.visible;

            for(var k:int = 0; k < len; k++)
            {
               if(this.mTabIndex[k]==5){
                   this.tab.items[k].visible = ModelGame.unlock(null,"equip_special").visible;
                   this.tab.items[k].gray = ModelGame.unlock(null,"equip_special").gray;
                   break;
               }
            }
            
        }
        private function formateData(index:int):void{
            var type:int = this.mTabIndex[index+""];
            type = (type==2)?3:(type==3?2:type);
            // var cfg:Object = ConfigServer.system_simple.equip_make_list;
            // var obj:Object = type<5?cfg[type]:ConfigServer.equip_make_special;
            // //
            // var eArr:Array = obj[1]?obj[1]:[];
            //
            var myEquips:Object = ModelManager.instance.modelUser.equip;
            var item:ModelEquip;
            var arr:Array = [];
            var num:int = 0;
            
            for(var key:String in myEquips)
            {
                // if(eArr.indexOf(key)>-1){
                    item = ModelManager.instance.modelGame.getModelEquip(key);
                    if(item.type == type){
                        num+=1;
                        arr.push(item);
                    }
                // }
            }
            arr.sort(MathUtil.sortByKey("index",true));
            var select:Number=0;
            if(mEid!=""){
                for(var i:int=0;i<arr.length;i++){
                    if(arr[i].id==mEid){
                        select=i;
                        break;
                    }
                }
            }
            
            
            this.tReady2.text = ModelEquip.equip_type_name[type];
            this.tList.text = num+"";//+"/"+eArr.length;
            if(arr.length>0){
                //
                this.list.array = arr;
                //
                this.list.selectedIndex = select;
                mEid="";
                //
                this.list.visible = true;

                if(select>3){
					this.list.scrollTo(select);
				}
            }
            else{
                this.list.visible = false;
            }
            //
        }        
        private function list_render(item:ItemEquip,index:int):void{
            var emd:ModelEquip = this.list.array[index];
            item.scale(0.9,0.9);
            item.setData(emd);
            item.showSelect((this.list.selectedIndex == index));
            item.off(Event.CLICK,this,this.click_item);
            item.on(Event.CLICK,this,this.click_item,[index]);
        }
        private function click_item(index:int):void{
            if(index==this.list.selectedIndex){
                return;
            }
            if(this.list.selection){
                var item2:ItemEquip = this.list.selection as ItemEquip;
                item2.showSelect(false);
            }
            this.list.selectedIndex = index;
        }        
        private function list_select(index:int):void{
            if(index>=0){
                var emd:ModelEquip = this.list.array[index];
                if(this.list.selection){
                    
                    var item:ItemEquip = this.list.selection as ItemEquip;
                    item.showSelect(true);
                    
                }
                this.setItems(emd);
            }
        }
        private function setItems(emd:ModelEquip):void{
            this.mBoxMakeItems.removeChildren();
            this.tEquipInfo.text = emd.getInfo();
            this.priceRuler.visible = true;
            this.priceBg.visible = true;
            if(emd.upgrade){
                var obj:Object = emd.getUpgradeCfgByLv(emd.getLv()+1);
                this.btn_coin.visible = true;
                this.btn_cd.visible = true;
                //
                var hmd:ModelHero = emd.getMyHero();
                this.tName.text = emd.getName();
                this.tName.color = ConfigColor.FONT_COLORS[emd.getLv()];
                if(hmd){
                    this.tHero.text = hmd.getName();
                }
                else{
                    this.tHero.text = Tools.getMsgById("_equip11");//"未装备";//未装备
                }
                //
                if(obj){
                    var cost:Object = obj.cost;
                    var ui:payTypeUI;
                    var i:int = 0;
                    payArr = Tools.getPayItemArr(cost);
                    var len:int = payArr.length;
                    var payItem:Object;
                    //
                    var costNum:Number = 0;
                    var _posX:Number = 0;
                    //
                    for(i = 0; i < len; i++)
                    {
                        payItem = payArr[i];
                        ui = new payTypeUI();
                        costNum = Math.floor(payItem.data * (1-ModelScience.func_sum_type(ModelScience.equip_up_consume,payItem.id)));//+science
                        if(payItem.id.indexOf("item")>-1){
                            ui.setData(AssetsManager.getAssetsICON(ModelItem.getItemIcon(payItem.id)),ModelItem.getMyItemNum(payItem.id)+"/"+costNum);
                            ui.changeTxtColor(ModelItem.getMyItemNum(payItem.id)>=costNum?ConfigColor.TXT_STATUS_OK:ConfigColor.TXT_STATUS_NO);
                        }
                        else{
                            ui.setData(ModelBuiding.getMaterialTypeUI(payItem.id),costNum);
                            ui.changeTxtColor(ModelBuiding.getMaterialEnough(payItem.id,costNum)?ConfigColor.TXT_STATUS_OK:ConfigColor.TXT_STATUS_NO);
                        }
                        ui.width = ui.getTextFieldWidth() + 15;                
                        ui.x = i==0 ? 0 : _posX;
                        _posX = _posX + ui.width;

                        ui.off(Event.CLICK,this,clickPay);
                        ui.on(Event.CLICK,this,clickPay,[payItem.id]);
                        this.mBoxMakeItems.addChild(ui);
                    }
                    this.mBoxMakeItems.y = this.priceRuler.y-5;
                    this.mBoxMakeItems.x = this.mBoxMakeItems.numChildren>=4 ? this.priceRuler.x+this.priceRuler.width : this.priceRuler.x+((this.mInfo.width-this.priceRuler.x)-this.mBoxMakeItems.width)*0.5;
                    //
                    var mm:Number = Math.ceil(obj.upgrade_time/(1+ModelScience.func_sum_type(ModelScience.equip_up_time)));//+science
                    var ms:Number = mm*Tools.oneMinuteMilli;
                    this.btn_cd.setData(AssetsManager.getAssetsUI("img_icon_02.png"),Tools.getTimeStyle(ms));
                    //
                    var okP:Number = (obj.chance+ModelScience.func_sum_type(ModelScience.equip_up_chance,emd.type+""));

                    this.text0.text = (okP>=1)?Tools.getMsgById("_equip24",[StringUtil.numberToPercent(okP)]):Tools.getMsgById("_equip12",[StringUtil.numberToPercent(okP),
                        StringUtil.numberToPercent(ConfigServer.system_simple.equip_upgrade_fail)
                    ]);//突破成功率{}失败后返回{}资源
                    //
                    this.btn_coin.setData("",ModelBuiding.getCostByCD(mm,1));
                    needCoin=ModelBuiding.getCostByCD(mm,1);
                    //
                    this.mItem.setHeroEquipType(emd,-1);
                }
                else{
                    this.priceRuler.visible = false;
                    this.priceBg.visible = false;
                    this.btn_coin.visible = false;
                    this.btn_cd.visible = false;
                    this.mItem.setHeroEquipType(emd,-1);
                    //
                    this.tInfo.text = Tools.getMsgById("_public192");//"已经是最高等级";
                }
                this.setInfoUI(emd);
            }
            else{
                var type:int = this.tab.selectedIndex;
                this.mItem.setHeroEquipType(null,((type>=5)?4:type));
            }
        }
        private function clickPay(id:String):void{
            ViewManager.instance.showItemTips(id);
        }

        private function setInfoUI(emd:ModelEquip):void
        {
            if(this.mInfoAttr){
                this.mInfoAttr.removeSelf();
                this.mInfoAttr.destroy(true);
            }
            this.mInfoAttr = null;
            this.mInfoAttr = new EquipInfoAttr(this.mBoxPro,this.mBoxPro.width-10,this.mBoxPro.height-5);
            this.mInfoAttr.initData(emd);
            this.mBoxPro.addChild(this.mInfoAttr);
        }
        private function tab_select(index:int):void{
            if(index>=0){
                if(this.tab.items[index].gray){
                    ViewManager.instance.showTipsTxt(ModelGame.unlock(null,"equip_special").text);                    
                    this.tab.selectedIndex=lastIndex;
                    return;
                }
                this.list.selectedIndex = -1;
                this.formateData(index);
                this.lastIndex=index;
            }
        }
        private function click(type:int):void{
            if(payArr){
                var payItem:Object;
                var costNum:Number = 0;
                for(var i:int=0;i<payArr.length;i++){
                    payItem = payArr[i];
                    costNum = Math.floor(payItem.data * (1-ModelScience.func_sum_type(ModelScience.equip_up_consume,payItem.id)));
                    if(!Tools.isCanBuy(payArr[i].id,costNum)){
                        return;
                    }    
                }
            }
            if(type==1){
                if(!Tools.isCanBuy("coin",needCoin)){
                    return;
                }
            }
            var emd:ModelEquip = this.list.array[this.list.selectedIndex];
            NetSocket.instance.send(NetMethodCfg.WS_SR_EQUIP_UPGRADE,{equip_id:emd.id,if_cost:type},Handler.create(this,this.ws_sr_equip_upgrade));
        }
        private function ws_sr_equip_upgrade(re:NetPackage):void{
            // Trace.log("ws_sr_equip_upgrade",re.receiveData);
            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            ModelManager.instance.modelInside.upgradeEquipCDByArr();
            //
            this.closeSelf();
        }
    }
}