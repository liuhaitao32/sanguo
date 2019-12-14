package sg.view.menu
{
    import ui.menu.userInfoUI;
    import laya.utils.Handler;
    import sg.model.ModelUser;
    import sg.view.com.ItemBase;
    import sg.manager.ModelManager;
    import sg.utils.Tools;

    public class ViewUserInfo extends userInfoUI{
        private var mUser:Object;
        private var mView:*;
        private var curId:String="";
        public function ViewUserInfo(){
            //
            this.comTitle.setViewTitle(Tools.getMsgById("_public198"));
            this.tab.selectHandler = new Handler(this,this.tab_select);
            ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_INFO_UPDATE,this,eventCallBack);
        }

        public function eventCallBack():void{
            if(this.tab.selectedIndex == 0){
                (this.mView as UserInfoNormal).setData(this.mUser);
            }
        }

        override public function initData():void{
            this.tab.visible=false;
            this.mUser = this.currArg;
            //
            this.tab.selectedIndex = 0;
        }
        private function tab_select(index:int):void{
            if(this.mView){
                (this.mView as ItemBase).clear();
                this.mBox.removeChild(this.mView);
            }
            //
            if(index == 0){
                this.mView = new UserInfoNormal();
                (this.mView as UserInfoNormal).setData(this.mUser);
            }
            this.mView.x = this.tab.x;
            this.mView.y = this.tab.y + this.tab.height + 10;
            this.mBox.addChild(this.mView);
        }
        override public function onRemoved():void{
            this.tab.selectedIndex=-1;
        }
    }   
}