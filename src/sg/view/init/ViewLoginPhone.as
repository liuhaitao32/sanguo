package sg.view.init
{
    import ui.init.viewLoginPhoneUI;
    import laya.events.Event;
    import sg.model.ModelPlayer;
    import sg.manager.ViewManager;
    import sg.net.NetHttp;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;

    public class ViewLoginPhone extends viewLoginPhoneUI
    {
        private var mCodeTime:Number = 0;
        public function ViewLoginPhone()
        {
            this.text0.text=Tools.getMsgById("_login_text1");
            this.text1.text=Tools.getMsgById("_login_text5");
            this.text2.text=Tools.getMsgById("_phone02");
            this.text3.text=Tools.getMsgById("_phone03");
            this.txtNumber.prompt=Tools.getMsgById("_phone10");
            this.txtCode.prompt=Tools.getMsgById("_phone11");
            this.btn_login.label=Tools.getMsgById("_public183");

            this.mCodeTime = 0;
            this.txtNumber.restrict = "0-9";
            this.txtNumber.maxChars = 11;
            this.txtCode.restrict = "0-9";
            this.txtCode.maxChars = 8;
            this.btn_code.on(Event.CLICK,this,this.click_code);    
            this.btn_login.on(Event.CLICK,this,this.click_login);
        }
        override public function initData():void{
            this.checkCodeTime(); 
            //
        }
        private function checkCodeTime():void{
            var now:Number = new Date().getTime();
            var dis:Number = ConfigServer.system_simple.phone_code_time*1000;
            var num:Number = (now - this.mCodeTime);
            if(num > dis){
                this.btn_code.gray = false;
                this.btn_code.label = Tools.getMsgById("_phone06"); 
            }
            else{
                this.btn_code.gray = true;
                this.btn_code.label = Tools.getMsgById("_phone_tips09",[Math.floor((dis-num)*0.001)]);//"("+Math.floor((dis-num)*0.001)+"秒后)失效";
            }
            this.timer.once(1000,this,this.checkCodeTime);
        }
        private function click_code():void
        {
            // trace("获取验证码");
            var phoneNumber:String = this.txtNumber.text;
            phoneNumber = phoneNumber.replace(/\s/g,"");
            //
            if(!phoneNumber || (phoneNumber && phoneNumber.length!=11)){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_phone_tips07"));  
                return;
            }
            if(this.btn_code.gray){
                return;
            }
            // this.mCodeTime = new Date().getTime();
            NetHttp.instance.send(NetMethodCfg.HTTP_USER_SEND_SIGN_LOGIN,{tel:phoneNumber},Handler.create(this,this.recode));
        }
        private function recode(re):void
        {
            // trace(re);   
            if(NetHttp.checkReIsError(re)){
                ViewManager.instance.showTipsTxt(re.msg);
            }
            else{
                this.mCodeTime = new Date().getTime()+1000;
            }
        }
        private function click_login():void
        {
            var phoneNumber:String = this.txtNumber.text;
            phoneNumber = phoneNumber.replace(/\s/g,"");
            //
            var phoneCode:String = this.txtCode.text;
            phoneCode = phoneCode.replace(/\s/g,""); 
            //
            if(!phoneNumber || (phoneNumber && phoneNumber.length!=11)){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_phone_tips07"));  
                return;
            }
            if(phoneCode && phoneCode.length>=6){
                //
                ModelPlayer.instance.setUID("ready");
                ModelPlayer.instance.setPhone(phoneNumber);
                ModelPlayer.instance.setPhoneCode(phoneCode);
                ModelPlayer.instance.setPlayerList();                                  
                // //
                // this.closeSelf(false);
                ViewManager.instance.closePanel();
                // //
                ModelPlayer.instance.event(ModelPlayer.EVENT_LOGIN_OK,2);
            }
            else{
               ViewManager.instance.showTipsTxt(Tools.getMsgById("_phone_tips08"));  
            }
        }
    }
}