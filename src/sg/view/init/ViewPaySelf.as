package sg.view.init
{
    import ui.init.viewPaySelfUI;
    import laya.events.Event;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;

    public class ViewPaySelf extends viewPaySelfUI
    {
        private var payObj:Object;
        private var selectType:Number = -1;
        public function ViewPaySelf()
        {
            // this.btn_wx.on(Event.CLICK,this,this.click,[0]);
            // this.btn_ali.on(Event.CLICK,this,this.click,[1]);
            this.btn_0.on(Event.CLICK,this,this.click,[0]);
            this.btn_1.on(Event.CLICK,this,this.click,[1]);            
            this.btnPay.on(Event.CLICK,this,this.click_pay);            
            this.btnClose.on(Event.CLICK,this,this.closeSelf);
        }
        public override function initData():void{
            this.payObj = this.currArg;
            var cfg:Array = this.payObj.cfg;
            var pid:String = payObj.pid;
            var isSale:Boolean = false;
            if(ConfigServer.system_simple.sale_pay){
                if(ConfigServer.system_simple.sale_pay[pid]){
                    pid = ConfigServer.system_simple.sale_pay[pid][0];
                    isSale = true;
                }
            }
            //
            var payCfg:Array = ConfigServer.pay_config[pid];
            this.tNum.text = payCfg[1]+payCfg[8];
            this.tPrice.text = "¥"+payCfg[0];
            this.tSalePay.text = isSale ? Tools.getMsgById("sale_pay_13",["¥"+(payCfg[0]-cfg[0])]) : Tools.getMsgById("sale_pay_12");
            this.tSalePay.color = isSale ? "#FF5040" : "#000000";

            //this.tNum.text = cfg[1]+cfg[8];
            //this.tPrice.text = "¥"+cfg[0];
            this.tTotal.text = "¥"+cfg[0];
            //
            this.click(0);
            //
            this.btnPay.label = Tools.getMsgById("_lht64",[cfg[0]]);
        }
        private function click(type:Number):void
        {
            this.selectType = type;
            //
            this.btn_0.selected = this.selectType == 0;
            this.btn_1.selected = this.selectType == 1;
        }
        private function click_pay():void{
            if(this.selectType == 0 ){
                this.payObj["wx_pay"] = true;
            }            
            Platform.pay(this.payObj,true);
            this.closeSelf();
        }
    }
}