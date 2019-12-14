package sg.utils
{
    import sg.cfg.ConfigApp;
    import laya.utils.Browser;

    public class ThirdRecording
    {
        public function ThirdRecording()
        {
            
        }
        public static function setUid(uid:String):void{
            if(ThirdRecording.isAnd()){
                // if(ConfigApp.pf == ConfigApp.PF_juedi_ios){
                //     ToIOS.callFunc("ta_setUserUniqueID",function(re:*):void{
                //     },{"uid":uid});
                // }
                // else{
                    ToJava.callMethod("ta_setUserUniqueID",uid,null);
                // }
            }
        }
        public static function setPay(arr:Array):void{
            if(ThirdRecording.isAnd()){
                // if(ConfigApp.pf == ConfigApp.PF_juedi_ios){
                //     ToIOS.callFunc("ta_setPurchase",function(re:*):void{
                //     },{orderId:arr[0],iapId:arr[1],currencyAmount:arr[2],currencyType:arr[3],virtualCurrencyAmount:arr[4],paymentType:arr[5]});
                // }
                // else{
                    // trace("000000000==>setPay==>>"+JSON.stringify(arr));
                    if(arr && arr.length==7){
                        arr.push(true);
                        ToJava.callMethod("ta_setPurchase",arr,null);
                    }
                // }
            }            
        } 
        public static function setRegister():void{
            if(ThirdRecording.isAnd()){
                // if(ConfigApp.pf == ConfigApp.PF_juedi_ios){
                // }
                // else{
                    // trace("000000000==>setRegister==>>");
                    ToJava.callMethod("ta_setRegister",["mobile",true],null);
                // }
            }            
        }            
        public static function isAnd():Boolean{
            var b:Boolean = false;
            if(Browser.onAndroid && (ConfigApp.pf == ConfigApp.PF_and_1 || ConfigApp.pf == ConfigApp.PF_and_jj_meng52)){
                b = true;
            }
            // else if(ConfigApp.pf == ConfigApp.PF_juedi_ios){
            //     b = true;
            // }
            return b;
        }   
    }
}