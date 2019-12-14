package sg.view.map
{
    import ui.map.country_officer_infoUI;
    import sg.model.ModelOfficial;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.net.NetPackage;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetSocket;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import sg.cfg.ConfigServer;
    import sg.utils.StringUtil;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.manager.EffectManager;
    import sg.model.ModelUser;

    public class ViewCountryOfficerInfo extends country_officer_infoUI
    {
        private var mId:int;
        private var mData:Array;
        private var isOpen:Boolean;
        private var mOnline:*;
        private var mCandidateArr:Array;//可弹劾的候选人
        private var mStatus:Number=0;
        private var cfgImpeach:Object;
        private var mStatus2:Number=0;//0 国王自己  1 候选人  2 其他
        public function ViewCountryOfficerInfo()
        {
            this.btn.on(Event.CLICK,this,this.click,[this.btn]);
            this.impBtn.on(Event.CLICK,this,this.click,[this.impBtn]);
            this.btn.label = Tools.getMsgById("_lht27");
        }

        private function eventCallBack():void{
            setImp();
        }

        override public function initData():void{
            this.tOpen.text = "";
            mStatus=0;
            cfgImpeach=ConfigServer.country.impeach;
            this.impBtn.visible=this.btn.gray=false;
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_17.png"));
            this.mId = this.currArg[0];
            this.mData = this.currArg[1];
            this.isOpen = this.currArg[2];
            this.mOnline = this.currArg[3];
            this.mCandidateArr = this.currArg[4]?this.currArg[4]:null;
            //
            this.tOfficer.text = ModelOfficial.getOfficerName(this.mId);
            //EffectManager.changeSprColor(this.img, ModelOfficial.getOfficerColorLevel(mId, ModelOfficial.getInvade(mId)));
            
            //
            //txt_title.text = Tools.getMsgById("countryTeamBestInfo_official") + Tools.getMsgById("_chat_text06");
            var s:String = Tools.getMsgById("countryTeamBestInfo_official") + Tools.getMsgById("_chat_text06");
            this.comTitle.setViewTitle(s);
            
            this.tStatus.text = ModelOfficial.getOfficerName(this.mId)+Tools.getMsgById("_public87");
            this.tInfo.style.fontSize = 18;
            this.tInfo.style.wordWrap = true;
            this.tInfo.style.leading = 6;
            this.tInfo.style.align = "left";
            this.tInfo.innerHTML = StringUtil.substituteWithColor(ModelOfficial.getOfficerInfo(this.mId),ModelOfficial.cities["-1"].country == ModelUser.getCountryID()?"#6dfe7e":"#999999","#c5dbff");
            //
            var heads:String = ConfigServer.system_simple["init_user"]["head"];
            //
            this.heroIcon.off(Event.CLICK,this,clickHero);
            if(this.mData.length>0){
                this.tName.text = this.mData[1];                
                this.heroIcon.setHeroIcon(Tools.isNullObj(this.mData[3])?heads:this.mData[3]);
                this.heroIcon.on(Event.CLICK,this,clickHero,[mData[0]]);
                this.tTips.text = "";
            }
            else{
                this.tName.text = Tools.getMsgById("_country2");// Tools.getMsgById("_public88");//"空闲";//空闲
                this.heroIcon.setHeroIcon("hero000");
                this.tTips.text = ModelOfficial.getOfficerCondition(this.mId);
            }
            this.tName.centerX=0;
            Tools.textLayout2(this.tOfficer,this.imgName,280,190);
            //this.tTips.y = this.box0.y-this.tTips.height-4;
            var b:Boolean = false;
            if(ModelOfficial.isPremier(ModelManager.instance.modelUser.mUID)>-1 && this.mId == 9){
                this.tOpen.text = Tools.getMsgById("_country18");//"无法任命此官职";//无法任命此官职
            }
            else{
                var b0:Boolean = this.mId!=0 && this.mId!=11;
                if(ModelOfficial.isKingKing(ModelManager.instance.modelUser.mUID)){
                    b0 = this.mId!=0;
                }
                var b1:Boolean = (ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)>-1 || ModelOfficial.isPremier(ModelManager.instance.modelUser.mUID)>-1);
                
            
                if(this.isOpen && b0 && b1){
                    b = true;
                
                }
                else{
                    if(!this.isOpen){
                        this.tOpen.text = Tools.getMsgById("_country19",[Tools.getMsgById(ModelOfficial.getInvadeCfg(ModelOfficial.getOfficerInvade(this.mId)).name)]);
                        // "天下大势到达"+Tools.getMsgById(ModelOfficial.getInvadeCfg(ModelOfficial.getOfficerInvade(this.mId)).name)+"解锁官职";
                    }
                    else{
                        if(ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)>-1 && this.mId == 11){
                            b = true;
                        }
                        else{
                            this.tOpen.text = b0?(b1?Tools.getMsgById("_country21"):Tools.getMsgById("_country20")):Tools.getMsgById("_country18");//"任命官员":"本官职无权限任命"):"无法任命此官职"
                        }
                    }
                }
            }
            this.btn.visible = b;
            this.tOpen.visible = !this.btn.visible;      
            if(mOnline==false){
                this.tOnline.text="";
            }else{
                this.tOnline.text=mOnline===true?Tools.getMsgById("_guild_text29"):Tools.howTimeToNow(Tools.getTimeStamp(mOnline));
                this.tOnline.color=mOnline===true?"#10F010":"#828282";
                this.tOnline.x=this.tName.x+this.tName.width+6;
            }

            setImp();
            if(mId!=0){
                this.box1.visible=false;
            }else{
                var n:Number=ModelOfficial.getInvadeAwardMax();//当前天下大势历史最高阶段
                if(n==0)
                    n=1;
                
                this.box1.visible=true;
                if(n>=3){
                    this.tMsg.text = Tools.getMsgById("_country84");    
                }else{
                    var str:String = ModelOfficial.getInvadeUnlock(n)[0];
                    this.tMsg.text = Tools.getMsgById("_country83",[str,ModelOfficial.getOfficerName(0, n)]);
                }
                
            }
            this.box0.y=box1.visible ? box1.y - 127 : box1.y - 127 + box1.height;
        }

        private function setImp():void{
            if(this.mCandidateArr){                
                this.btn.visible=false;
                this.tOpen.text="";
                mStatus=ModelOfficial.getImpeachStatus();
                var candidateUIDs:Array=[];
                for(var i:int=0;i<this.mCandidateArr.length;i++){
                    var u:String=this.mCandidateArr[i][0];
                    if(u!=mData[0]){
                        candidateUIDs.push(u);
                    }
                    if(candidateUIDs.length==cfgImpeach.start){
                        break;
                    }
                }
                this.impBtn.gray=false;
                this.impBtn.label=Tools.getMsgById("_country_impeach0");//"弹劾";
                switch(mStatus){
                    case 0://可弹劾
                        //在弹劾候选人中
                        this.impBtn.visible=true;
                        if(candidateUIDs.indexOf(ModelManager.instance.modelUser.mUID)!=-1){
                            this.impBtn.visible=true;
                            mStatus2=1;
                        }else{
                            this.impBtn.gray=true;
                            mStatus2=2;
                        }
                        break;
                    case 1://可投票
                        this.impBtn.visible=true;
                        this.impBtn.label=Tools.getMsgById("_country_impeach14");
                        break;
                    case 2://已投票
                        this.impBtn.visible=true;
                        this.impBtn.label=Tools.getMsgById("_country_impeach14");//"弹劾中";
                        break;
                    case 3://可查看
                        this.impBtn.visible=true;
                        this.impBtn.label=Tools.getMsgById("_country_impeach14");//"弹劾中";
                        break;
                    case 4://国王保护
                        this.impBtn.visible=this.impBtn.gray=true;
                        break;
                    case 5://失败cd
                        this.impBtn.visible=this.impBtn.gray=true;
                        break;
                    case 6://个人cd
                        this.impBtn.visible=this.impBtn.gray=true;
                        break;
                }

                
                
            }

            if(mId==0 && isOpen && mData[0]==ModelManager.instance.modelUser.mUID){
                var n:Number=ModelOfficial.getImpeachStatus();
                if(n==0){
                    mStatus2=0;
                    this.impBtn.visible=this.impBtn.gray=true;
                }else if(n==1||n==2||n==3){
                    this.impBtn.visible=true;
                    this.impBtn.label=Tools.getMsgById("_country_impeach14");//"弹劾中";
                }
            }
            
            //弹劾功能开关
            if(ConfigServer.country.impeach["switch"] == null || ConfigServer.country.impeach["switch"] == 0){
                this.impBtn.visible = false;
            }

            if(impBtn.visible)
                this.tOpen.visible=false;
        }


        private function clickHero(_id:*):void{
            ModelManager.instance.modelUser.selectUserInfo(_id);
        }

        override public function onAdded():void{
            ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_SET_OFFICER_IS_OK,this,this.event_set_officer_is_ok);
            ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_UPDATE_IMPEACH,this,eventCallBack);
        }
        override public function onRemoved():void{
            ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_SET_OFFICER_IS_OK,this,this.event_set_officer_is_ok);
            ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_UPDATE_IMPEACH,this,eventCallBack);
        }
        private function event_set_officer_is_ok():void
        {
            this.closeSelf();
        }
        private function click(_button:*):void
        {
            // if(ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)>-1 || (ModelOfficial.isPremier(ModelManager.instance.modelUser.mUID)>-1 && this.mId!=11)){
            // // 国王可以,分封其他官员
            //     // return;
            // }
            switch(_button){
                case this.btn:
                    ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_OFFICER_LIST,[null,this.mId]);
                    break;
                case this.impBtn:
                    impeachFun();
                    break;
            }
        }

        private function impeachFun():void{
            var s:String="";
            if(mStatus==0){
            //     NetSocket.instance.send("w.start_impeach",{},new Handler(this,function(np:NetPackage):void{
            //         ModelManager.instance.modelUser.updateData(np.receiveData);
            //         ModelOfficial.updateImpeach(np.receiveData);
            //         ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_IMPEACH);
            //     }));
                if(mStatus2==0){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("530107"));
                }else if(mStatus2==1){
                    ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_IMPEACH);
                }else if(mStatus2==2){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("530106"));
                }
                
            }else if(mStatus==1 || mStatus==2 || mStatus==3){
                ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_IMPEACH);
            }else if(mStatus==4){
                s=Tools.getTimeStyle(ModelOfficial.king_time+cfgImpeach.cd1*Tools.oneMinuteMilli-ConfigServer.getServerTimer());
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_country_impeach15",[ModelOfficial.getOfficerName(0),s]));//"国王保护期");
            }else if(mStatus==5){
                s=Tools.getTimeStyle(ModelOfficial.impeach_fail_time+cfgImpeach.cd2*Tools.oneMinuteMilli-ConfigServer.getServerTimer());
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_country_impeach16",[s]));//"失败cd中");
            }else if(mStatus==6){
                s=Tools.getTimeStyle(Tools.getSeasonTimes(ModelManager.instance.modelUser.impeach_time)+cfgImpeach.cd3*Tools.oneMinuteMilli-ConfigServer.getServerTimer());
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_country_impeach17",[s]));//"个人cd中");
            }
            
        }
    }   
}