package sg.view.init
{
    import ui.init.viewRegistFastUI;
    import sg.model.ModelPlayer;
    import sg.utils.Tools;

    public class ViewRegistFast extends viewRegistFastUI
    {
        private var uname:String;
        private var upwd:String;
        public function ViewRegistFast()
        {
            this.onlyCloseByBtn(true);
        }
        override public function initData():void{
            this.uname = this.currArg.username;
            this.upwd = this.currArg.pwd;
            this.tName.text = this.uname;
            this.tPass.text = this.upwd;
            this.tInfo.text = Tools.getMsgById("_public218");
            this.t1.text = Tools.getMsgById("_public217");
            this.t2.text = Tools.getMsgById("_public216"); 
            // this.tBtn.text = Tools.getMsgById("_public114");
            this.comTitle.setViewTitle(Tools.getMsgById("_jia0082"));
        }
        override public function onRemoved():void{
            // ModelPlayer.instance.setUID("ready");
            // ModelPlayer.instance.setName(this.uname);
            // ModelPlayer.instance.setPWD(this.upwd);
            // ModelPlayer.instance.setPlayerList(); 
            ModelPlayer.instance.loginName = this.uname;                                
            ModelPlayer.instance.loginPwd = this.upwd;                                   
            ModelPlayer.instance.event(ModelPlayer.EVENT_LOGIN_OK,-1);
        }
        override public function btnClickClose():void{
            this.closeSelf();
        }
    }
}