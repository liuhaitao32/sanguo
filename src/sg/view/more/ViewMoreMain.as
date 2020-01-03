package sg.view.more
{
    import ui.more.more_mainUI;
    import laya.utils.Handler;
    import laya.ui.Button;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import ui.more.item_moreUI;
    import sg.manager.AssetsManager;
    import sg.view.map.ViewVisitMain;
    import sg.view.map.ViewCityBuildMain;
    import sg.view.task.ViewFTaskTest;
    import sg.model.ModelGame;
    import sg.utils.Tools;
    import sg.boundFor.GotoManager;
    import sg.model.ModelAlert;
    import sg.net.NetHttp;
    import sg.view.TestButton2;
    import sg.model.ModelUser;
    import sg.cfg.ConfigApp;
    import laya.utils.Browser;
    import sg.model.ModelHonour;

    public class ViewMoreMain extends more_mainUI{

        private var mData:Array=[{"text":Tools.getMsgById("add_office"),  "lock_key":"more_office",  "key":"office",   "skin":"icon_more01.png"},
                                 {"text":Tools.getMsgById("_country36"),  "lock_key":"more_rank",    "key":"rank",     "skin":"icon_more04.png"},
                                 {"text":Tools.getMsgById("_country37"),  "lock_key":"estate",       "key":"estate",   "skin":"icon_more05.png"},
                                 {"text":Tools.getMsgById("_country38"),  "lock_key":"",             "key":"mail",     "skin":"icon_more06.png"},
                                 {"text":Tools.getMsgById("_country39"),  "lock_key":"more_code",    "key":"code",     "skin":"icon_more07.png"},
                                 {"text":Tools.getMsgById("_country40"),  "lock_key":"servier",      "key":"servier",  "skin":"icon_more08.png"},
                                 {"text":Tools.getMsgById("_settings001"),"lock_key":"more_set",     "key":"settings", "skin":"icon_more10.png"},
                                 {"text":Tools.getMsgById("_jia0061"),    "lock_key":"more_notice",  "key":"notice",   "skin":"icon_more11.png"},
                                 {"text":Tools.getMsgById("_jia0137"),    "lock_key":"more_binding",  "key":"binding",  "skin":"icon_more12.png"},
                                 {"text":Tools.getMsgById("_jia0137"),    "lock_key":"more_unbinding","key":"unbinding","skin":"icon_more12.png"},
                                 {"text":Tools.getMsgById("_jia0138"),    "lock_key":"more_bbs",      "key":"bbs",      "skin":"icon_more13.png"},

                                 {"text":Tools.getMsgById("_country35"),    "lock_key":"",            "key":"country",  "skin":"icon_more03.png"},
                                 ];

        public function ViewMoreMain(){
            this.comTitle.setViewTitle(Tools.getMsgById("_lht21"));
            this.list.itemRender = item_moreUI;
            this.list.renderHandler = new Handler(this,this.list_render); 
        }
        override public function initData():void{
            ModelManager.instance.modelGame.on(ModelGame.EVENT_UPDAET_BUG_MSG,this,eventCallBack);//客服红点
            var arr:Array=[];
            //var a:Array=lock_key_arr;//.concat();
            for(var i:int=0;i<mData.length;i++){
                var o:Object=mData[i];
                if(o["key"] == "country"){//天下大势 开启赛季功能时增加
                    if(ModelHonour.instance.isOpen()){
                        arr.push(o);    
                    }
                    continue;
                }
                if(isShowByKey(o["lock_key"] ? o["lock_key"] : "")){
                    arr.push(o);
                }
            }
            this.list.dataSource =arr;
        }

        private function isShowByKey(key:String):Boolean{
            var b:Boolean = false;
            if(key == ""){
                b = true;
            }else{
                var o:Object=ModelGame.unlock(null,key);
                if(o.visible) b = true;
            }
            
            var b1:Boolean = false;
            if(key=="more_binding" || key == "more_unbinding" || key=="more_bbs"){
                if(ConfigApp.pf == ConfigApp.PF_r2game_kr_h5){
                    b1 = false;
                }
                else{
                    if(ConfigApp.pf_channel == ConfigApp.PF_r2game_xm){
                        var linked:Boolean = Platform.pf_login_data.linked=="1"?true:false;
                        var fborgg:Boolean = Platform.pf_login_data.isFBorGG=="1"?true:false;
                        if(key=="more_binding"){
                            if(!linked && !fborgg){
                                b1 = true;
                            }
                        }
                        else if(key == "more_unbinding"){
                            if(linked && !fborgg){
                                b1 = true;
                            }
                        }
                        else{
                            b1 = true;
                        }
                    }
                    else if(ConfigApp.pf_channel == ConfigApp.PF_r2game_kr){
                        if(key=="more_unbinding"){
                            b1 = false;
                        }else{
                            b1 = true;
                        }
                    }
                }
            }
            else{
                b1 = true;
            }
            return b && b1;
        }

        public function eventCallBack():void{
            this.list.refresh();
        }

        private function list_render(item:item_moreUI,index:int):void{
            var data:Object = this.list.array[index];
            item.tName.text = data.text;
            item.img.skin = AssetsManager.getAssetsUI(data.skin);
            var lock:Boolean = false;
            //
            if(data.lock_key!=""){
                var o:Object = ModelGame.unlock(null,data.lock_key);
                item.gray = o.gray;
                lock = o.gray;
            }
            ModelGame.redCheckOnce(item,lock?false:ModelAlert.red_more_check(data.key));
            item.off(Event.CLICK,this,this.click);
            item.on(Event.CLICK,this,this.click,[data.key,lock]);
        }

        private function click(key:String,lock:Boolean):void{
            if(lock){
                return;
            }
            switch(key)
            {
                case "office":
                    GotoManager.boundForPanel(GotoManager.VIEW_OFFICE_MAIN)
                    break;
                case "country2":
                    GotoManager.boundForPanel(GotoManager.VIEW_COUNTRY_MAIN);
                    break; 
                case "rank":                      
					ViewManager.instance.showView(ConfigClass.VIEW_MORE_RANK_MAIN);
                    break;   
                case "estate":
                    ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_MAIN);
                    break;               
                case "mail":
					NetSocket.instance.send("get_msg",{},Handler.create(this,function(np:NetPackage):void{
						ModelManager.instance.modelUser.updateData(np.receiveData);
                        ModelManager.instance.modelChat.isNewMail=false;
						ViewManager.instance.showView(ConfigClass.VIEW_MAIL_MAIN);
					}));                    
                    break;
                case "code":
                    ViewManager.instance.showView(ConfigClass.VIEW_CODE);
                    break;  
                case "servier":
                    if((ConfigApp.pf_channel == ConfigApp.PF_r2game_kr || ConfigApp.pf_channel == ConfigApp.PF_r2game_xm) && (ConfigApp.pf != ConfigApp.PF_r2game_kr_h5)){
                        Platform.helpOther();
                    } else if (ConfigApp.pf === ConfigApp.PF_muzhi_h5 || ConfigApp.pf === ConfigApp.PF_muzhi2_h5){
                        Browser.window.open('http://data.254game.com:8080/sdk/param/index/index.html');
                    }else if(ConfigApp.releaseWeiXin()){
                        Platform.helpOther();
                    } 
                    else {
                        var sendData:Object={"uid":ModelManager.instance.modelUser.mUID,
                                                                "sessionid":ModelManager.instance.modelUser.mSessionid,
                                                                "zone":ModelManager.instance.modelUser.zone};
                        NetHttp.instance.send("bug_msg.get_bug_msg",sendData,Handler.create(this,callBack));
                    }
                    break;                 
                case "settings":
                    ViewManager.instance.showView(ConfigClass.VIEW_SETTINGS);
                    break;
                case "notice":
                    ViewManager.instance.showView(ConfigClass.VIEW_AFFICHE);
                    break;
                case "binding":
                    // trace("==============绑定");
                    Platform.bindOther();
                    break;
                case "unbinding":
                    // trace("==============解除绑定");
                    Platform.unBindOther();
                    break;                    
                case "bbs":
                    // trace("==============论坛");
                    if(ConfigApp.pf_channel == ConfigApp.PF_r2game_kr){
                        Platform.bbsOther();
                    }
                    else if(ConfigApp.pf_channel == ConfigApp.PF_r2game_xm){
                        Platform.restart();
                    }
                    break;
                case "country"://天下大势
                    ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_INVADE_MAIN);
                    break; 
            }
            this.closeSelf();
        }
        public function callBack(re:Array):void{
            ViewManager.instance.showView(["ViewMoreService",ViewMoreService],re);
            
        }

        public override function onRemoved():void{
            ModelManager.instance.modelGame.off(ModelGame.EVENT_UPDAET_BUG_MSG,this,eventCallBack);
            if(ModelAlert.red_more_all()==false)
                ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,{"user":{"1":""}});
            
        }
    }   
}