package sg.view.fight
{
    import ui.fight.championHeroEditUI;
    import ui.fight.itemChampionHeroUI;
    import laya.utils.Handler;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.net.NetPackage;
    import sg.model.ModelClimb;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.utils.Tools;

    public class ViewChampionHeroEdit extends championHeroEditUI{
        private var mOpenNum:Number = 0;
        private var mArr:Array;
        private var mArrServer:Array;
        private var isSignUp:Boolean = false;
        public function ViewChampionHeroEdit(){
            this.comTitle.setViewTitle(Tools.getMsgById("_climb25"));
            this.list.itemRender = itemChampionHeroUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            //
            this.btn.on(Event.CLICK,this,this.click_ok);
            this.text0.text=Tools.getMsgById("_public245");
        }
        override public function initData():void{
            //
            this.mArrServer = this.currArg;
            //
            this.mOpenNum = ModelClimb.getChampionHeroNum();
            //
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_17.png"));
            //
            var hadArr:Array = this.mArrServer?this.mArrServer:[];
            //
            var max:Number = 8;
            var arr:Array = [];
            var obj:Object;
            var hmd:ModelHero;
            var i:Number = 0;
            //
            var isSign:Boolean = false;
            if(hadArr.length>0){
                for(i = 0; i < hadArr.length; i++){
                    hmd = ModelManager.instance.modelGame.getModelHero(hadArr[i]);
                    // if(ModelManager.instance.modelUser.getCommander(hmd.id)){
                    //     continue;
                    // }
                    arr.push(hmd);
                }
            }
            else{
                isSign = true;
            }           
            var lastArr:Array = [];
            var lastNum:Number = this.mOpenNum - hadArr.length;
            if(lastNum>0){//不够上阵补上
                lastArr = ModelClimb.getChampionHeroRecommend(lastNum,hadArr);
            }    
            arr = arr.concat(lastArr);  
            //      
            if(isSign){
                if(ModelClimb.isChampionStartSeason()){
                    isSign = false;
                }
            }
            this.isSignUp = isSign;
            this.btn.label = isSign?Tools.getMsgById("_climb21"):Tools.getMsgById("_public96");//"报名":"保存";
            //
            var len:Number = max - arr.length;
            //
            if(len>0){//不够8个补null
                for(i = 0; i < len; i++)
                {
                    hmd = null;
                    arr.push(hmd);
                }
            }
            this.list.dataSource = this.mArr = arr;
            //
            this.setUI();
        }        
        private function setUI():void{
            this.changePower();
            this.tName.text = ""+ModelManager.instance.modelUser.uname;
            this.heroIcon.setHeroIcon(ModelManager.instance.modelUser.getHead());
        }
        private function list_render(item:itemChampionHeroUI,index:int):void{
            var hmd:ModelHero = this.list.array[index];
            item.mHave.visible = false;
            item.mLock.visible = false;
            item.mAdd.visible = false;
            item.mNo.visible = false;
            var status:int = -1;
            if(hmd){
                item.mHave.visible = true;
                item.tIndex.text = (index+1)+"";
                item.tName.text = hmd.getName();
				item.comPower.setNum(hmd.getPower());
                //item.tPower.text = hmd.getPower()+"";
                item.heroIcon.setHeroIcon(hmd.getHeadId(),true,hmd.getStarGradeColor());
                status = 1;
            }
            else{
                item.mNo.visible = true;
                if(index<this.mOpenNum){
                    item.mAdd.visible = true;
                    status = 0;
                }
                else{
                    item.mLock.visible = true;
                    status = -1;
                }
            }
            item.offAll(Event.CLICK);
            item.on(Event.CLICK,this,this.click_edit_list,[hmd,status,index]);
        }
        private function click_edit_list(hmd:ModelHero,status:int,index:int):void{
            if(status>-1){
                ViewManager.instance.showView(ConfigClass.VIEW_CHAMPION_TROOP,[hmd,this.mArr,index,Handler.create(this,this.updateList)]);
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_climb22",[ModelManager.instance.modelClimb.getChampionUnlockLv(index)]));//"无法上阵,第"++"届开启"
            }
        }
        private function updateList():void{
            this.list.dataSource = this.mArr;   
            this.changePower();       
        }
        private function changePower():void
        {
            //
            var len:int = this.mArr.length;
            var power:Number = 0;
            for(var i:int = 0; i < len; i++)
            {
                if(this.mArr[i]){
                    power+=(this.mArr[i] as ModelHero).getPower();
                }
                
            }
			this.comPower.setNum(power);
            //this.tPower.text = ""+power;              
        }
        private function click_ok():void{
            var hidArr:Array = [];
            var len:int = this.mArr.length;
            for(var i:int = 0; i < len; i++)
            {
                if(this.mArr[i]){
                    hidArr.push((this.mArr[i] as ModelHero).id);
                }
            }
            //
            ModelManager.instance.modelClimb.send_WS_SR_JOIN_PK_YARD(hidArr,Handler.create(this,this.ws_sr_join_pk_yard));
        }
        private function ws_sr_join_pk_yard(re:NetPackage):void{
            ViewManager.instance.showTipsTxt(Tools.getMsgById("_public97"));//保存成功
            ModelManager.instance.modelClimb.event(ModelClimb.EVENT_CHAMPION_SIGN_OK);
            this.closeSelf();
        }
    }   
}