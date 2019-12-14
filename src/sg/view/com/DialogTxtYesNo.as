package sg.view.com
{
    import ui.com.dialog_txt_yes_noUI;
    import laya.utils.Handler;
    import laya.events.Event;

    public class DialogTxtYesNo extends dialog_txt_yes_noUI{
        private var mTxt:String;
        private var mHandlerYes:Handler;
        private var mHandlerNo:Handler;
        public function DialogTxtYesNo(){
            this.btn_yes.on(Event.CLICK,this,this.click,[1]);
            this.btn_no.on(Event.CLICK,this,this.click,[-1]);
        }
        override public function initData():void{
            this.mTxt = this.currArg[0];
            //
            this.mHandlerYes = this.currArg[1];
            this.mHandlerNo = this.currArg[2];
            //
            this.label.text = this.mTxt;
        }
        private function click(type:int):void{
            if(type>0){
                if(this.mHandlerYes){
                    this.mHandlerYes.run();
                }
            }
            else{
                if(this.mHandlerNo){
                    this.mHandlerNo.run();
                }
            }
            this.closeSelf();
        }
    }   
}