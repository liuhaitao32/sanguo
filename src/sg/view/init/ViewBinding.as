package sg.view.init
{
    import ui.init.ViewBindingUI;
    import sg.manager.LoadeManager;
    import sg.activities.model.ModelPhone;
    import laya.utils.Handler;
    import ui.bag.bagItemUI;
    import laya.ui.Label;
    import sg.model.ModelItem;
    import laya.ui.Box;
    import sg.manager.ModelManager;
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.cfg.ConfigApp;
    import laya.utils.Browser;
    import sg.model.ModelPlayer;
    import sg.net.NetHttp;
    import sg.net.NetMethodCfg;
    import sg.manager.ViewManager;
    import sg.utils.SaveLocal;
    import sg.activities.model.ModelActivities;

    public class ViewBinding extends ViewBindingUI
    {
        public function ViewBinding()
        {
            this.list.renderHandler=new Handler(this,listRender);
            this.list.scrollBar.hide = true;
            //
            this.btnFB.on(Event.CLICK,this,this.clickTo,["fb"]);
            this.btnGG.on(Event.CLICK,this,this.clickTo,["gg"]);
        }
        override public function onAdded():void{
            LoadeManager.loadTemp(imgTemp,"ui/bg_19.png");
            //
            this.box0.visible = false;
            this.box2.visible = false;
            // 
            var arr:Array=ModelManager.instance.modelProp.getRewardProp(ConfigServer.system_simple.phone_reward);
			this.list.repeatX=arr.length;
			this.list.centerX=0;
			this.list.array=arr;
            //
            this.input0.text = ModelManager.instance.modelUser.uname;
            //
            this.text0.text = Tools.getMsgById("_lht74");
            this.txt1.text = Tools.getMsgById("_lht75");
            this.comTitle.setViewTitle(Tools.getMsgById("_lht73"));
            //
            if(ConfigApp.pf == ConfigApp.PF_ios_meng52_tw){
                this.btnGG.visible = false;
                this.btnFB.centerX = 0;
            }
            // 
            Platform.logout(null);
        }
        public function listRender(cell:Box,index:int):void{
			var arr:Array=this.list.array[index];
			var icon:bagItemUI=cell.getChildByName("icon") as bagItemUI;
			var label:Label=cell.getChildByName("rewardName") as Label;
			icon.setData(arr[0],arr[1],-1);
			label.text=ModelItem.getItemName(arr[0]);
		}
        private function clickTo(type:String):void{
            var _this:* = this;
            // 
            Platform.login(Handler.create(this,function(status:*,data:*):void{
                //服务器绑定
                // ToIOS.log("这里是绑定触发1::"+JSON.stringify(data));
                // Browser.window.traceIOS("这里是绑定触发::"+JSON.stringify(data));
                var p:Object = data;
                p["login_name"] = ModelPlayer.instance.getName();
                p["login_pwd"] = ModelPlayer.instance.getPWD();
                p["login_uid"] = ModelManager.instance.modelUser.mUID;
                // 
                // ToIOS.log("这里是绑定触发2::"+JSON.stringify(p));
                // 
                NetHttp.instance.send(NetMethodCfg.HTTP_FB_GOOGLE_BING,p,Handler.create(null,function(re:Object):void{
                    //
                    // trace("这里是绑定成功"+JSON.stringify(re));
                    if(re.status && re.status=="error"){
                        ViewManager.instance.showTipsTxt(re.msg);
                        return;
                    }  
                    // 
                    ModelPlayer.instance.setName(re.pf_key);
            	    ModelPlayer.instance.setPWDs(re.pf_pwd);
                    // 
                    SaveLocal.deleteObj(SaveLocal.KEY_VISITOR_USER_DATA);              
                    //
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_phone_tips03"));
                    // 
                    ModelActivities.instance.refreshLeftList();
                    // 
                    _this.closeSelf()
                }))
            }),type);
        }
    }
}