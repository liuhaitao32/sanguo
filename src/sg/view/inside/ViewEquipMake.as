package sg.view.inside
{
    import ui.inside.equipMakeUI;
    import laya.utils.Handler;
    import sg.cfg.ConfigServer;
    import sg.model.ModelEquip;
    import sg.manager.ModelManager;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.utils.Tools;
    import laya.ui.Box;
    import ui.com.payTypeUI;
    import sg.model.ModelBuiding;
    import sg.cfg.ConfigColor;
    import sg.model.ModelItem;
    import sg.manager.ViewManager;
    import sg.manager.AssetsManager;
    import laya.maths.MathUtil;
    import sg.cfg.ConfigClass;
    import sg.utils.StringUtil;
    import sg.view.com.EquipInfoAttr;
    import sg.manager.LoadeManager;
    import sg.model.ModelGame;
    import sg.utils.MusicManager;
    import sg.map.utils.ArrayUtils;

    public class ViewEquipMake extends equipMakeUI{
        private var mBoxMakeItems:Box;
        private var mType:int = -1;
        private var mInfoAttr:EquipInfoAttr;
        private var payArr:Array;
        private var lastIndex:int;
        public function ViewEquipMake():void{
            this.comTitle.setViewTitle(Tools.getMsgById("_equip29"));
            this.tab.labels = ModelEquip.equip_type_name_tab.join(",");
            this.tab.selectHandler = new Handler(this,this.tab_select);
            this.list.itemRender = ItemEquip;
            this.list.scrollBar.hide = true;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.selectEnable = true;
            this.list.selectHandler = new Handler(this,this.list_select);
            //
            this.btn_make.on(Event.CLICK,this,this.click_make);
            this.mBoxMakeItems = new Box();
            this.mInfo.addChild(this.mBoxMakeItems);
			
			this.tNoMake.style.fontSize = 20;
            this.tNoMake.style.align = "center";     
            //
            this.btn_change.on(Event.CLICK,this,this.click_change);
            this.text0.text = Tools.getMsgById("_equip33");
			this.tInfo.text = Tools.getMsgById("ViewEquipMake_1");
        }
        override public function initData():void{
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_19.png"));
            this.mBoxInfo.visible = false;
            this.mBoxPro.visible = false;
            this.btn_change.visible = false;
            this.mType = this.currArg?this.currArg:-1;
            if(this.mType>=0){
                this.tab.selectedIndex = (this.mType == 2)?3:(this.mType == 3?2:this.mType);
            }
            else{
                this.tab.selectedIndex = this.tab.selectedIndex<0?0:this.tab.selectedIndex;
            }
            
            //强制检查屏蔽特殊类型
            var lock:Object = ModelGame.unlock(this.tab.items[this.tab.items.length-1],"equip_special");
            //
            if(ConfigServer.equip_make_special.length==0 || getSpecialArr().length==0){
                this.tab.items[this.tab.items.length-1].visible = false;
            }
        }
        override public function onRemoved():void{
            this.mType = this.currArg = -1;
            this.tab.selectedIndex = -1;
            this.list.selectedIndex = -1;
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
        private function formateData(type:int):void{
            var cfg:Object = ConfigServer.system_simple.equip_make_list;
            var obj:Object = type<5?cfg[type]:ConfigServer.equip_make_special;
            var emd:ModelEquip;
            // var em:Object;
            var arr:Array = [];
            var num:int = 0;
            //
            var eArr:Array = obj[1];
            var len:int = eArr.length;
            var key:String = "";
            //
            for(var i:int = 0; i < len; i++)
            {
                key = eArr[i];
                // em = ConfigServer.equip[key];
                emd = ModelManager.instance.modelGame.getModelEquip(key);
                // emd["sortMine"] = 
                emd["sortIndex"] = (emd.isMine()?200000:100000)+emd.index;
                emd["sortMake"] = type>=5 && isCanMake(emd.id) ? 1 : 0;
                if(emd.isMine()){
                    num+=1;
                }
                if(type>=5){
                    if(emd.isMine() || emd.hasSpecialMaterial()){
                        arr.push(emd);
                    }
                }else{
                    arr.push(emd);
                }
            }
            ArrayUtils.sortOn(["sortMake","sortIndex"],arr,true,true);
            //arr.sort(MathUtil.sortByKey("sortIndex",true));
            //
            var blv:int = ModelEquip.checkBuildLvCanUp(type);
            if(num>=arr.length){
                this.btn_make.visible = false;
                //全部{0}制作完毕，正在为您寻找新的{0}
                if(type<5)
                    this.tNoMake.innerHTML = StringUtil.substituteWithColor(Tools.getMsgById("_equip8",[ModelEquip.equip_type_name[type]]),"#e2f2ff","#e2f2ff");
                else
                    this.tNoMake.innerHTML = StringUtil.substituteWithColor(Tools.getMsgById("_equip38"),"#e2f2ff","#e2f2ff");
            }
            else{
                this.btn_make.visible = (ModelManager.instance.modelInside.getBuilding002().lv>=blv);
                this.tNoMake.innerHTML = StringUtil.substituteWithColor(Tools.getMsgById("_equip9",[blv]),"#FF0000","#e2f2ff");
            }
            this.tNoMake.visible = !this.btn_make.visible;            
            //
            this.tList.text = num+"/"+arr.length;
            //
            // this.list.selectedIndex = -1;
            //
            this.list.array = arr;
            //
            if(type>=5 && this.list.selectedIndex<0){
                this.list.selectedIndex = 0;
            }
            else{
                this.list.selectedIndex = -1;
            }
            this.list.scrollTo(0);
            //
            if(type<5){
                this.setItems(type,null);
            }
        }

        private function getSpecialArr():Array{
            var arr:Array=[];
            var obj:Object = ConfigServer.equip_make_special;
            if(obj[1]){
                for(var i:int = 0; i <obj[1].length; i++)
                {
                    var emd:ModelEquip = ModelManager.instance.modelGame.getModelEquip(obj[1][i]);
                    if(emd.isMine() || emd.hasSpecialMaterial()){
                        arr.push(emd);
                    }
                }
            }
            return arr;
        }

        public function isCanMake(eid:String):Boolean{
            var b:Boolean = true;
            var emd:ModelEquip=ModelManager.instance.modelGame.getModelEquip(eid);
            if(emd && !emd.isMine() && emd.make_item){
                var pay:Object = emd.make_item;
                var payArr:Array = Tools.getPayItemArr(pay);
                var len:int = payArr.length;
                var payItem:Object;
                var itemNo:Number = 0;
                for(var i:Number = 0; i < len; i++){
                    payItem = payArr[i];
                    if(payItem.id.indexOf("item")>-1){
                        if(ModelItem.getMyItemNum(payItem.id)<payItem.data){
                            b = false;
                            break;
                        }
                    }else{
                        if(!ModelBuiding.getMaterialEnough(payItem.id,payItem.data)){
                            b = false;
                            break;
                        }
                    }
                }
            }
            if(emd && emd.isMine()){
                b = false;
            }
            return b;
        }

        private function click_change():void
        {
            this.mBoxInfo.visible = this.mBoxPro.visible;
            this.mBoxPro.visible = !this.mBoxInfo.visible;
        }
        private function setItems(type:int,emd:ModelEquip):void{
            this.mBoxMakeItems.removeChildren();
            //
            var cfg:Object;
            var pay:Object;
            var ui:payTypeUI;
            var i:int = 0;
            var grayB:Boolean = true;
                        //
            this.makeReady.setHeroEquipType(emd?emd:null,type);
            if(emd){
                if(emd.isMine()){
                    grayB = false;
                }
                this.setInfoUI(emd);
				
				this.tName.visible = this.imgName.visible = true;
				this.tName.text = emd.getName();
                this.tName.color = ConfigColor.FONT_COLORS[emd.getLv()];
            }
			else{
				this.tName.visible = this.imgName.visible = false;
			}
            this.makeReady.gray = grayB;
            //
            this.tReady.text = ModelEquip.equip_type_name[type];
            this.tReady2.text = ModelEquip.equip_type_name[type];
            //
            this.mBoxMakeItems.visible = true;
            this.priceRuler.visible = true;
            this.mBoxInfo.visible = false;
            this.mBoxPro.visible = false;
            this.btn_change.visible = false;
            //
            this.mBoxView.x = 150;
            this.mBoxView.y = 50;
            //
            if(type<5){
                cfg = ConfigServer.system_simple.equip_make_list[type];
                pay = cfg[2];
            }
            else{
                // this.btn_change.visible = true;
                this.mBoxPro.visible = !this.mBoxInfo.visible;
                //
                this.mBoxView.x = 0;
                this.mBoxView.y = 50;
                //
                this.tEquipInfo.text = emd.getInfo();
                //
                if(emd.make_item){
                    pay = emd.make_item;
                }
                this.btn_make.visible = (!this.tNoMake.visible && !emd.isMine());
                if(emd.isMine()){
                    this.mBoxMakeItems.visible = false;
                    this.priceRuler.visible = false;
                    return;
                }
            }
            payArr = Tools.getPayItemArr(pay);
            //trace(payArr);
            var len:int = payArr.length;
            var payItem:Object;
            var itemNo:Number = 0;
            var _posX:Number=0;
            for(i = 0; i < len; i++)
            {
                payItem = payArr[i];
                ui = new payTypeUI();
                if(payItem.id.indexOf("item")>-1){
                    ui.setData(AssetsManager.getAssetsICON(ModelItem.getItemIcon(payItem.id)),ModelItem.getMyItemNum(payItem.id)+"/"+payItem.data);
                    ui.changeTxtColor(ModelItem.getMyItemNum(payItem.id)>=payItem.data?ConfigColor.TXT_STATUS_OK:ConfigColor.TXT_STATUS_NO);
                    if(ModelItem.getMyItemNum(payItem.id)<payItem.data){
                        itemNo+=1;
                    }
                }
                else{
                    ui.setData(ModelBuiding.getMaterialTypeUI(payItem.id),payItem.data);
                    ui.changeTxtColor(ModelBuiding.getMaterialEnough(payItem.id,payItem.data)?ConfigColor.TXT_STATUS_OK:ConfigColor.TXT_STATUS_NO);
                    if(!ModelBuiding.getMaterialEnough(payItem.id,payItem.data)){
                        itemNo+=1;
                    }
                }

                ui.width = ui.getTextFieldWidth() + 15;                
                ui.x = i==0 ? 0 : _posX;
                _posX = _posX + ui.width;

                ui.off(Event.CLICK,this,clickPay);
                ui.on(Event.CLICK,this,clickPay,[payItem.id]);
                this.mBoxMakeItems.addChild(ui);
            }
            if(this.btn_make.visible){
                this.btn_make.gray = itemNo>0;
            }
            this.mBoxMakeItems.y = this.priceRuler.y - 5;
            this.mBoxMakeItems.x = this.mBoxMakeItems.numChildren>=4 ? this.priceRuler.x+this.priceRuler.width : this.priceRuler.x+((this.mInfo.width-this.priceRuler.x)-this.mBoxMakeItems.width)*0.5;
        }
        private function clickPay(id:String):void{
            ViewManager.instance.showItemTips(id);
        }

        private function list_render(item:ItemEquip,index:int):void{
            var emd:ModelEquip = this.list.array[index];
            item.scale(0.9,0.9);
            item.setData(emd,this.tab.selectedIndex);
            item.imgSuc.visible = false;
            if(this.tab.selectedIndex<5){
                item.showSelect(false);
            }
            else{
                item.showSelect((this.list.selectedIndex == index));
            }
            item.off(Event.CLICK,this,this.click_item);
            item.on(Event.CLICK,this,this.click_item,[index]);
            if(this.tab.selectedIndex>=5){
                item.checkCanMake();
            }
        }
        private function click_item(index:int):void{
            var emd:ModelEquip = this.list.array[index];
            if(this.tab.selectedIndex>=5 && index!=this.list.selectedIndex){
                if(this.list.selection){
                    var item2:ItemEquip = this.list.selection as ItemEquip;
                    item2.showSelect(false);
                }
                this.list.selectedIndex = index;
            }
            else{
                if(this.tab.selectedIndex<5){
                    //显示宝物信息,和属性
                    
                    if(emd.isMine()){
                        ViewManager.instance.showView(ConfigClass.VIEW_EQUIP_MAKE_INFO,emd);
                    }
                }
            }
            this.tReady.text = ModelEquip.equip_type_name[emd.type];
        }
        private function list_select(index:int):void{
            // Trace.log("list_select",index,this.tab.selectedIndex,this.list.selection);
            if(this.tab.selectedIndex>=5 && index>=0){
                if(this.list.selection){
                    var emd:ModelEquip = this.list.array[index];
                    var item:ItemEquip = this.list.selection as ItemEquip;
                    this.setItems(5,emd);
                    item.showSelect(true);
                }
            }
        }
        private function tab_select(index:int):void{
            if(index>-1){
                var type:int = (index==2)?3:(index==3?2:index);
                if(this.tab.items[type].gray){
                    ViewManager.instance.showTipsTxt(ModelGame.unlock(null,"equip_special").text);                    
                    this.tab.selectedIndex=lastIndex;
                    return;
                }
                this.formateData(type);
                lastIndex=index;
            }
        }
        private function click_make():void{
            for(var i:int=0;i<payArr.length;i++){
                if(!Tools.isCanBuy(payArr[i].id,payArr[i].data)){
                    return;
                }
            }
            //if(this.btn_make.gray){
            //    ViewManager.instance.showTipsTxt(Tools.getMsgById("_public19"));
            //    return;
            //}
            var sd:Object;
            if(this.tab.selectedIndex<5){
                sd = {equip_type:this.checkType(this.tab.selectedIndex)};
            }
            else{
                var emd:ModelEquip = this.list.array[this.list.selectedIndex];
                sd = {equip_type:-1,equip_id:emd.id};
            }
            NetSocket.instance.send(NetMethodCfg.WS_SR_EQUIP_MAKE,sd,Handler.create(this,this.ws_sr_equip_make));
        }
        private function checkType(index:Number):Number
        {
            return (index==2)?3:((index==3)?2:index);
        }
        private function ws_sr_equip_make(re:NetPackage):void{
            // Trace.log("ws_sr_equip_make",re.receiveData);
            ModelManager.instance.modelUser.updateData(re.receiveData);
            this.formateData(this.checkType(this.tab.selectedIndex));
            //
            ModelManager.instance.modelInside.upgradeEquipCDByArr();
            //
            MusicManager.playSoundUI(MusicManager.SOUND_EQUIP_MAKE);
            this.closeSelf();
        }
    }
}