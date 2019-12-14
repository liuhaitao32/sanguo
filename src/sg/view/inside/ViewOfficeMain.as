package sg.view.inside
{
    import ui.inside.officeMainUI;
    import laya.events.Event;
    import ui.inside.itemOfficeUI;
    import laya.utils.Handler;
    import laya.ui.Box;
    import ui.inside.officePrivilegeUI;
    import laya.display.Sprite;
    import laya.maths.Rectangle;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.model.ModelOffice;
    import sg.model.ModelOfficeRight;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.model.ModelGame;
    import laya.maths.Point;
    import sg.model.ModelUser;
    import sg.manager.AssetsManager;
    import sg.model.ModelInside;
    import sg.manager.EffectManager;
    import laya.display.Animation;
    import sg.manager.LoadeManager;
    import laya.net.LoaderManager;
    import laya.net.Loader;
    import laya.net.URL;
    import sg.utils.MusicManager;
    import sg.cfg.ConfigServer;
    import sg.utils.SaveLocal;

    public class ViewOfficeMain extends officeMainUI{
        private var mArr:Array;
        private var mCurrIndex:int;
        private var mUpgradeId:String;
        private var mRightKey:String;
        private var mLocal:Object;
        private var mLocalNum:int;
        public function ViewOfficeMain(){
            this.btn_next.on(Event.CLICK,this,this.click,[1]);
            this.btn_pre.on(Event.CLICK,this,this.click,[-1]);
            //
            this.btn.on(Event.CLICK,this,this.click_up);
            //
            this.list.itemRender = itemOfficeUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            //
            this.listRight.itemRender = officePrivilegeUI;
            this.listRight.renderHandler = new Handler(this,this.listRight_render);
            this.listRight.scrollBar.hide = true;
            txt_title.text = Tools.getMsgById('_jia0093', [Tools.getMsgById('lvup03_1_name')]);
            txt_reward0.text = Tools.getMsgById('_public206');
            txt_reward1.text = Tools.getMsgById('_public206');
            txt_baseLimit.text = Tools.getMsgById('_jia0094', [Tools.getMsgById('502018')]);
            //
            ModelManager.instance.modelGame.on(ModelGame.EVENT_OFFICE_RIGHT_CHANGE,this,this.setUI);
        }
        override public function initData():void{
            mLocal=SaveLocal.getValue(SaveLocal.KEY_SEE_OFFICE_MAIN+ModelManager.instance.modelUser.mUID,true);
            mLocalNum=0;
            if(mLocal==null) mLocal={};
            for(var s:String in mLocal){
                if(mLocal[s]==false){
                    mLocalNum++;
                }
            }
            //字符串就是特权id  数字就是爵位等级
            mRightKey=this.currArg && !(this.currArg is Number)?this.currArg:"";
            this.mArr = ModelOffice.getOfficeAll();
            LoadeManager.loadTemp(this.adImg1,AssetsManager.getAssetLater("bg_003.png"));
            LoadeManager.loadTemp(this.adImg2,AssetsManager.getAssetLater("bg_003.png"));            
            this.setTitle(Tools.getMsgById("lvup03_1_name"));
            var n:Number= ModelManager.instance.modelUser.office>0?(ModelManager.instance.modelUser.office-1):0;
            if(mRightKey!=""){
                var o:Object=ConfigServer.office.right[mRightKey];
                if(o){
                    n=o.office_lv-1;
                }
            }

            this.mCurrIndex = (this.currArg && (this.currArg is Number)) ? this.currArg-1 : n;//(n-1 < 0 ? 0 : n-1);
            this.click(0);
        }
        private function list_render(item:itemOfficeUI,index:int):void{
            var data:Object = this.list.array[index];
            //trace("==========",data);
            item.tName.text = data.info;//data.id+"   "+
            item.tStatus.text = "("+(data.n1>data.n2?data.n2:data.n1)+"/"+data.n2+")";//data.ok;
            item.tStatus.color = data.pre>=1 ? "#99ff97" : "#cce0ff"; 
            item.cb.selected = data.ok;
            item.bar.value = data.pre;
        }
        private function setUI(right_id:String = ""):void{
            
            var len:int = this.mArr.length;
            var maxLv:Number = -1;
            for(var i:int = 0; i < len; i++)
            {
               if(!this.mArr[i].condition){
                   maxLv = i;
                   break;
               }
            }
            //
            this.mUpgradeId = right_id;
            //
            var omd:ModelOffice = this.mArr[this.mCurrIndex];

            this.tName.text = omd.getName();
            //
            var isCanLvUp:Boolean=omd.isCanLvUp();
            this.conditionNo.visible = !isCanLvUp;
            
            //
            this.setPrivilege();
            //
            var oidNum:Number = Number(omd.id);
            var nn:Number = ModelManager.instance.modelUser.office - oidNum;
            var isHad:Boolean = ModelManager.instance.modelUser.office >= oidNum;
            // this.mBoxAward.visible = !isHad;
            this.btn.visible = nn==-1;//!isHad;
            this.isGet.visible = isHad;
            this.award.visible = !isHad;
            
            //升级之后有数据重置成0  所以传参isHad
            this.list.array = isCanLvUp ? omd.getConditionArr(this.mCurrIndex,false) : [];
            this.mBoxPre.visible = this.list.array.length>0;

            this.btn.label = omd.condition?Tools.getMsgById("_office6"):Tools.getMsgById("_office7");
            if(!isCanLvUp){
                this.btn.disabled = true;
            }
            else{
                this.btn.disabled = false;
            }
            //
            var conditionB:Boolean = Tools.getDictLength(omd.condition,true)>0;
            this.tCoin.text = "+"+omd.upaward["coin"];
            //
            var clv:Number =  Number(omd.id);
            //
            var minLv:Number = ModelOffice.getBuildingMaxLv(clv-1);
            minLv = (minLv<=0)?1:minLv;
            minLv = omd.condition ? minLv : (maxLv>-1) ? ModelOffice.getBuildingMaxLv(maxLv) : 1;
            this.tMin.text = minLv+"";
            this.tMax.text = (omd.condition ? ModelOffice.getBuildingMaxLv(clv) : minLv)+"";
            //
            this.officeIcon.skin = AssetsManager.getAssetLater("office"+omd.id+".png");
            
            if(mLocal.hasOwnProperty(omd.id)){
                mLocal[omd.id]=true;
            }
            var local0:Boolean=mLocal[mCurrIndex+2]==null ? false : !mLocal[mCurrIndex+2];
            var local1:Boolean=mLocal[mCurrIndex-2]==null ? false : !mLocal[mCurrIndex-2];
            var b:Boolean=false;
            if(this.btn_next.visible){
                b=ModelOffice.checkOfficeOpenWill(this.mArr[this.mCurrIndex+1],mCurrIndex+1);
                ModelGame.redCheckOnce(this.btn_next,!this.btn.visible && (b || local0));
            }
            if(this.btn_pre.visible){
                b=ModelOffice.checkOfficeOpenWill(this.mArr[this.mCurrIndex-1],mCurrIndex-1);
                ModelGame.redCheckOnce(this.btn_pre,b || local1);
            }
        }
        private function listRight_render(item:officePrivilegeUI,index:int):void{
            var ormd:ModelOfficeRight = this.listRight.array[index];
            item.mLock.visible = !ormd.isMine();
            item.btn.label = ormd.getName();
            item.btn.mouseEnabled = false;
            item.btn.toggle = true;
            item.btn.selected = !item.mLock.visible;
            var b:Boolean=ModelOffice.checkOfficeWillRight(ModelOfficeRight.getCfgRightById(ormd.id),ormd.id);
            ModelGame.redCheckOnce(item,item.mLock.visible?b:false);
            //
            item.off(Event.CLICK,this,this.click_privilege);
            item.on(Event.CLICK,this,this.click_privilege,[ormd]);
            //
            item.clipBox.destroyChildren();
            if(!Tools.isNullString(this.mUpgradeId)){
                if(this.mUpgradeId == ormd.id){
                    var clipAni:Animation = EffectManager.loadAnimation("glow031","",1);
                    clipAni.x = item.btn.x;
                    clipAni.y = item.btn.y;
                    item.clipBox.addChild(clipAni);
                    this.mUpgradeId = "";
                }
            }
        }
        private function setPrivilege():void{
            var id:String = (this.mCurrIndex+1)+"";
            this.listRight.dataSource = ModelOffice.getRightByLv(id);
        }
        private function click_privilege(right:ModelOfficeRight):void{
            // if(!right.isMine()){
                ViewManager.instance.showView(ConfigClass.VIEW_OFFICE_ACTIVATION,right);
            // }
        }
        private function click(type:int):void{
            this.btn_next.visible = true;
            this.btn_pre.visible = true;
            //
            this.mCurrIndex+=type;
            //
            if(this.mCurrIndex>=this.mArr.length-1){
                this.btn_next.visible = false;
               
            }
            if(this.mCurrIndex<=0){
                this.btn_pre.visible = false;
            }
            
            this.setUI();
        }
        private function click_up():void{
            NetSocket.instance.send(NetMethodCfg.WS_SR_OFFICE_LV_UP,{},Handler.create(this,this.ws_sr_office_lv_up));
        }
        private function ws_sr_office_lv_up(re:NetPackage):void{
            MusicManager.playSoundUI(MusicManager.SOUND_OFFICE_UP);
            ModelManager.instance.modelUser.updateData(re.receiveData);
            var omd:ModelOffice = this.mArr[this.mCurrIndex];
            var pt:Point = this.tCoin.localToGlobal(new Point(-10,0));
            ViewManager.instance.showIcon(omd.upaward,pt.x,pt.y);
            ModelManager.instance.modelGame.event(ModelUser.EVENT_USER_UPDATE);
            ModelManager.instance.modelInside.updateBaseBuilding();
            this.initData();
        }

        override public function onRemoved():void{
            var n:Number=0;
            for(var s:String in mLocal){
                if(mLocal[s]==false){
                    n++;
                }
            }
            if(n!=mLocalNum){
                SaveLocal.save(SaveLocal.KEY_SEE_OFFICE_MAIN+ModelManager.instance.modelUser.mUID,mLocal,true);
            }
        }
    }   
}