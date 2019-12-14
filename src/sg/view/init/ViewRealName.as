package sg.view.init
{
	
import sg.utils.Tools

    import ui.init.view_real_nameUI;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.model.ModelPlayer;
    import sg.net.NetHttp;

    public class ViewRealName extends view_real_nameUI
    {
        private var m:RegExp = /^\d{6}(18|19|20)?\d{2}(0[1-9]|1[012])(0[1-9]|[12]\d|3[01])\d{3}(\d|[xX])$/;
        public function ViewRealName()
        {
            this.btn.on(Event.CLICK,this,this.click);
            //
            // this.tName.restrict = "0-9\a-z\A-Z";
            this.tName.maxChars = 16;
            this.tName.mouseThrough = false;
            this.tName.mouseEnabled = false;
            //
            this.tNum.restrict = "0-9\a-z\A-Z";
            this.tNum.maxChars = 18;    
            //
            this.tReal.restrict = "\u4E00-\u9FA5";
            this.tReal.maxChars = 4;        
        }
        override public function initData():void{
            this.tName.text = ModelPlayer.instance.getName();
            this.tNum.text = "";
            this.tReal.text = "";
        }
        private function click():void
        {
            var b1:Boolean = false;
            var b2:Boolean = false;    
            var b3:Boolean = false;    
            if(this.tName.text.length>=3){
                b1 = true;
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public141"));
                return;
            }            
            if(this.tNum.text.length==18){
                b2 = true;
            }  
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("msg_ViewRealName_0"));
                return;                
            }
            if(this.tReal.text.length>1){
                b3 = true;
            }  
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("msg_ViewRealName_1"));
                return;                
            }            
            if(b1 && b2 && b3){
                //验证
                NetHttp.instance.send(NetMethodCfg.HTTP_USER_VALIDATE_USER_CODE,{username:this.tName.text,user_code:this.tNum.text},Handler.create(this,this.http_user_validate_user_code));
            }             
        }
        private function http_user_validate_user_code(re:Object):void
        {
            var player:Object;
            for(var key:String in ModelPlayer.instance.mPlayerList)
            {
                player = ModelPlayer.instance.mPlayerList[key];
                //
                if(player.hasOwnProperty("username")){
                    if(player["username"] == this.tName.text){
                        player["ucid"] = this.tNum.text;
                        ModelPlayer.instance.mPlayerList[key] = player;
                        break;
                    }
                }
            }
            ModelPlayer.instance.savePlayerAll();
            ModelPlayer.instance.updateAll();
            //
            ViewManager.instance.showTipsTxt(Tools.getMsgById("msg_ViewRealName_2"));
            this.closeSelf();
        }
    }
}