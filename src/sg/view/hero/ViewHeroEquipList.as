package sg.view.hero
{
	import sg.cfg.ConfigColor;
    import ui.hero.heroEquipListUI;
    import sg.manager.ModelManager;
    import sg.model.ModelEquip;
    import ui.com.hero_icon_equipUI;
    import laya.utils.Handler;
    import sg.model.ModelHero;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import laya.ui.Image;
    import sg.view.inside.ItemEquip;
    import sg.cfg.ConfigClass;
    import sg.model.ModelGame;
    import sg.scene.view.MapCamera;
    import sg.view.com.EquipInfoAttr;
    import laya.maths.MathUtil;
    import sg.map.utils.ArrayUtils;
    import sg.manager.AssetsManager;
    import sg.boundFor.GotoManager;
    import sg.model.ModelBuiding;

    public class ViewHeroEquipList extends heroEquipListUI{

        private var mType:int = -1;
        private var mHeroCurr:ModelHero;
        private var mEquipInstall:String;
        private var mSelectEquip:Array;
        private var mHandler:Handler;
        private var mInfoAttr:EquipInfoAttr;
        private var mEquipModel:ModelEquip;
        public function ViewHeroEquipList():void{
            this.list.itemRender = ItemEquip;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.selectEnable = true;
            this.list.selectHandler = new Handler(this,this.list_select);
            this.list.scrollBar.hide = true;
            //
            this.btn_ok.on(Event.CLICK,this,this.click_set);
            this.btn_wash.on(Event.CLICK,this,this.click_wash,[1]);
            this.btn_up.on(Event.CLICK, this, this.click_wash, [2]);
            this.btn_en.on(Event.CLICK, this, this.click_wash, [3]);

            this.text0.text=Tools.getMsgById("_public223");
            this.text1.text=Tools.getMsgById("_equip25");
            this.text2.text=Tools.getMsgById("_enhance11");

            this.btn_up.label=Tools.getMsgById("_equip30");
            this.btn_wash.label=Tools.getMsgById("_equip31");
            this.btn_en.label=Tools.getMsgById("_equip42");
        }
        override public function initData():void{
            this.mType = this.currArg[0];
            this.mHeroCurr = this.currArg[1] as ModelHero;
            this.mEquipInstall = this.currArg[2];
            this.mHandler = this.currArg[3] as Handler;
            //
            var myEquipAll:Object = ModelManager.instance.modelUser.equip;
            var emd:ModelEquip;
            var arr:Array = [];
            var selectIndex:int = -1;
            var i:int = 0;
            for(var key:String in myEquipAll)
            {
                emd = ModelManager.instance.modelGame.getModelEquip(key);
                selectIndex = -1;
                //
                if(emd.type == this.mType){
                    if(!Tools.isNullString(this.mEquipInstall)){
                        if(this.mEquipInstall == emd.id){
                            selectIndex = i;
                        }
                    }
                    emd["sortIndex"] = ((selectIndex>-1)?(selectIndex+1)*100000:0)+emd.index;
                    arr.push(emd);
                    i++;
                }
            }
            this.btn_wash.disabled = arr.length<=0;
            this.btn_up.disabled = arr.length<=0;
            this.btn_en.disabled = arr.length<=0;

            this.btn_wash.visible = ModelGame.unlock(null,"equip_wash").visible;
            this.btn_wash.gray    = ModelGame.unlock(null,"equip_wash").gray;

            this.btn_up.visible   = ModelGame.unlock(null,"equip_up").visible;
            this.btn_up.gray      = ModelGame.unlock(null,"equip_up").gray;

            this.btn_en.visible   = ModelGame.unlock(null,"equip_enhance").visible;
            this.btn_en.gray      = ModelGame.unlock(null,"equip_enhance").gray;



            if(arr.length<=0){
                this.list.dataSource = [];
                //
                this.setUI(true); 
                //
                return;
            }
            arr.sort(MathUtil.sortByKey("sortIndex",true));
            //
            
            //
            this.list.dataSource = arr;
            this.list.selectedIndex = 0;//(selectIndex<0)?0:selectIndex;
            this.list.scrollTo(0);
        }
        private function list_render(item:ItemEquip,index:int):void{
            var emd:ModelEquip = this.list.array[index] as ModelEquip;
            item.setDataChange(emd);
            //
            item.off(Event.CLICK,this,this.click);
            item.on(Event.CLICK,this,this.click,[emd,index]);
            //
            item.showSelect((this.list.selectedIndex == index));
        }
        private function list_select(index:int):void{
            if(index>-1){
                mEquipModel = this.list.array[index];
                var hmd:ModelHero = mEquipModel.getMyHero();
                if(hmd){
                    if(hmd.id == this.mHeroCurr.id){
                        this.btn_ok.skin = AssetsManager.getAssetsUI("btn_no_s2.png");
                        this.btn_ok.label = Tools.getMsgById("_equip2");//卸载
                    }
                    else{
                        if(this.mHeroCurr.getEquip().length<=0){
                            this.btn_ok.skin = AssetsManager.getAssetsUI("btn_ok.png");
                            this.btn_ok.label = Tools.getMsgById("_equip3");//安装
                        }
                        else{
                            this.btn_ok.skin = AssetsManager.getAssetsUI("btn_ok.png");
                            this.btn_ok.label = Tools.getMsgById("_equip4");//更换
                        }
                    }
                }
                else{
                    if(this.checkEquipsIsMe(mEquipModel)!=""){
                        this.btn_ok.skin = AssetsManager.getAssetsUI("btn_ok.png");
                        this.btn_ok.label = Tools.getMsgById("_equip4");//更换
                    }
                    else{
                        this.btn_ok.skin = AssetsManager.getAssetsUI("btn_ok.png");
                        this.btn_ok.label = Tools.getMsgById("_equip3");//安装
                    }
                }   
                this.setUI();             
            }
        }
        override public function onRemoved():void
        {
            this.mSelectEquip = null;
            this.mHandler = null;
            this.list.selectedIndex = -1;
        }
        private function click(emd:ModelEquip,index:int):void
        {
            if(index!=this.list.selectedIndex){
                this.list.selectedIndex = index;
            }
        }
        private function click_wash(type:Number):void
        {
            var md:ModelBuiding=ModelManager.instance.modelInside.getBuilding002();
            if(md.lv==0)  ViewManager.instance.showTipsTxt(Tools.getMsgById("_public232",[Tools.getMsgById(md.name)]));
            if(md.lv==0)  return;
            
            var s:String = "";
            if(type == 1){
                //GotoManager.boundFor({type:2,buildingID:"building002",panelID:GotoManager.VIEW_EQUIP_WASH,viewParam:mEquipModel.id});
                s = ModelGame.unlock(null,"equip_wash").text;
                if(s!="") ViewManager.instance.showTipsTxt(s);
                if(s!="") return;
                GotoManager.boundFor({type:2,buildingID:"building002",panelID:GotoManager.VIEW_EQUIP_MAIN,viewParam:[2,mEquipModel.id]});
            }
            else if(type == 2){
                //GotoManager.boundFor({type:2,buildingID:"building002",panelID:GotoManager.VIEW_EQUIP_UPGRADE,viewParam:mEquipModel.id});
                s = ModelGame.unlock(null,"equip_up").text;
                if(s!="") ViewManager.instance.showTipsTxt(s);
                if(s!="") return;
                GotoManager.boundFor({type:2,buildingID:"building002",panelID:GotoManager.VIEW_EQUIP_MAIN,viewParam:[1,mEquipModel.id]});
            }else if(type == 3){
                s = ModelGame.unlock(null,"equip_enhance").text;
                if(s!="") ViewManager.instance.showTipsTxt(s);
                if(s!="") return;
                GotoManager.boundFor({type:2,buildingID:"building002",panelID:GotoManager.VIEW_EQUIP_MAIN,viewParam:[3,mEquipModel.id]});
            }
        }
        //
        private function click_set():void{
            if(this.list.array.length<=0){
                var emdIng:ModelEquip = ModelEquip.getCDingModel();
                if(emdIng){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_equip5"));//已有宝物在锻造中
                }
                else{
                    GotoManager.boundFor({type:2,buildingID:"building002",panelID:GotoManager.VIEW_EQUIP_MAKE,viewParam:this.mType});
                }
                return;
            }
            // if(this.mSelectEquip){
            if(this.list.selectedIndex>-1){
                var type:int = 1;
                var emd:ModelEquip =  this.list.array[this.list.selectedIndex];//this.mSelectEquip[0];
                var hmd:ModelHero = emd.getMyHero();
                var eid:String = "";
                var hid:String = "";
                if(hmd){
                    hid = hmd.id;
                    if(hid == this.mHeroCurr.id){
                        type = 0;
                    }
                    else{
                        eid = this.checkEquipsIsMe(emd);
                        type = 2;
                    }
                }
                else{
                    eid = this.checkEquipsIsMe(emd);
                    if(eid!=""){
                        type = 3;
                    }
                }
                if(this.mHandler){
                    this.mHandler.runWith([type,emd,hid,eid]);
                    this.closeSelf();
                }
            }
        }
        private function checkEquipsIsMe(ruler:ModelEquip):String
        {
            var arr:Array = this.mHeroCurr.getEquip();
            var len:int = arr.length;
            var emd:ModelEquip;
            var str:String = ""
            for(var i:int = 0;i < len;i++){
                emd = ModelManager.instance.modelGame.getModelEquip(arr[i]);
                if(emd.type == ruler.type){
                    str = emd.id;
                    break;
                }
            }
            return str;
        }
        private function setUI(isNull:Boolean = false):void{
            
            this.attrInfo.visible = !isNull;
            this.washInfo.visible = !isNull;
            this.enhanceInfo.visible = !isNull;
            this.box1.visible = false;
            this.box2.visible = false;
            if(isNull){
                this.btn_ok.skin = AssetsManager.getAssetsUI("btn_ok.png");
                this.btn_ok.label = Tools.getMsgById("_equip6");//打造
                this.tName.text = Tools.getMsgById("_equip7", [ModelEquip.equip_type_name[this.mType]]);//没有可用的{}
                return;
            }
            if(this.list.selectedIndex>-1){
                mEquipModel =  this.list.array[this.list.selectedIndex];
                // var emd:ModelEquip =  this.mSelectEquip[0];
                this.tName.text = mEquipModel.getName(true);
				this.tName.color = ConfigColor.FONT_COLORS[mEquipModel.getLv()];
                //
                this.setInfoUI(mEquipModel);
            }
        }
        private function setInfoUI(emd:ModelEquip):void
        {
            if(this.mInfoAttr){
                this.mInfoAttr.initData(emd);    
            }else{
                this.mInfoAttr = null;
                this.mInfoAttr = new EquipInfoAttr(this.attrInfo,this.attrInfo.width,this.attrInfo.height);
                this.mInfoAttr.initData(emd);
                this.attrInfo.addChild(this.mInfoAttr);
            }
            
            //
            this.washInfo.style.align = "left";
            this.washInfo.style.fontSize = 18;
            this.washInfo.style.leading = 10;
            if(!ModelGame.unlock(null,"equip_wash").stop){
                this.box1.visible=true;        
                this.washInfo.innerHTML = emd.getWashInfoHtml(true);
            }else{
                this.washInfo.innerHTML = "";
            }

            this.enhanceInfo.style.align = "left";
            this.enhanceInfo.style.fontSize = 18;
            this.enhanceInfo.style.leading = 10;
            if(!ModelGame.unlock(null,"equip_enhance").stop){
                this.box2.visible=true;        
                this.enhanceInfo.innerHTML = emd.getEnhanceInfoHtml(true);
            }else{
                this.enhanceInfo.innerHTML = "";
            }



            
        }        

    }
}