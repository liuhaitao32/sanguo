package
{
    import sg.cfg.ConfigApp;
    import laya.renders.Render;
    import laya.utils.Browser;

    public class ToIOS
    {
        public static var sTools:*;
        public static function init():void{
            if(ConfigApp.onIOS()){
                if(Render.isConchApp){
                    sTools = Laya.PlatformClass.createClass("FuncBridge");
                }
                else{
                    if(ConfigApp.onIOSlayaWK()){
                        sTools = Browser.window.conchMarket;
                    }
                    else{
                        sTools = Browser.window.toIOS
                    }
                    
                }
            }
        }
        public static function callFunc(method:String,callback:*,params:*):void{
            if(Render.isConchApp){
                sTools.callWithBack(callback,method+":",params);
            }
            else{
                if(ConfigApp.onIOSlayaWK()){
                    if(sTools && sTools.hasOwnProperty(method)){
                        if(params && params is String){
                            sTools[method](params,callback);
                        }
                        else{
                            if(params){
                                sTools[method](JSON.stringify(params),callback);
                            }
                            else{
                                sTools[method]("",callback);
                            }
                        }
                    }
                }else{
                    sTools(method,callback,params);
                }
            }
        }
        public static function log(params:*):void{
            if(Render.isConchApp){
                // trace(params);
            }
            else{
                if(ConfigApp.onIOSlayaWK()){
                    ToIOS.callFunc("traceLog",null,params);
                }
                else{
                    Browser.window.traceIOS(params);
                }
                
            }
        }
        /**
         * Apple IAP
         */
        public static function pay(callback:*,params:*):void{
            if(ConfigApp.onIOSlayaWK()){
                var jso:Object = {product_id:params.pid,amount:1,order_id:params.ext,callback_uri:params.url};
                ToIOS.callFunc("cz",callback,JSON.stringify(jso));
            }
            else{
                ToIOS.callFunc("pay",callback,params);
            }
        }
    }
}