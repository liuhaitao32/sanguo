package
{
    import laya.renders.Render;
    import laya.utils.Handler;
    import sg.cfg.ConfigApp;
    import laya.utils.Browser;

    public class ToJava
    {
        public function ToJava()
        {
            
        }
        public static var sRestartAPPTool:*;
        public static var sTools:*;
        public static function init():void{
            if(ConfigApp.onAndroid()){
                if(Browser.window){
                    if(Browser.window.toAndroid){
                        sTools = Browser.window.toAndroid;
                        if(sTools){
                            sTools("createClass",null,"meng52.Tools");
                        }
                    }       
                }
            }
        }
        public static function restartApp():void{
            if(sRestartAPPTool){
            }
        }
        public static function alertToApp(title:String,msg:String,func:Function):void{
            if(sTools){
            }
        }
        public static function getPhoneID(pf:String,callback:Handler):String{
            if(sTools){
                sTools("getPhoneID",function(rst:*):void{
                    if(callback){
                        callback.runWith([rst,rst]);
                    }
                },pf);
            }  
            return "";          
        }
        public static function getAppName():String{
            if(sTools){
            }  
            return "";          
        }
        public static function openAlipay(url:String):Boolean{
            if(sTools){
                sTools("pay_alipay",function(openApp:Boolean):void{
                    if(!openApp){           
                    }
                },url)
                
            }
            return false;            
        }
        public static function initSDK(pf:String,callback:Handler):void{
            if(sTools){
                sTools("initSDK",function(rst:*):void{
                    if(callback){
                        callback.runWith([rst,"initSDK"]);
                    }
                },pf);
                
            }   
            else{
                if(callback){
                    callback.runWith([0,null]);
                }                
            }     
        }  
        public static function pay(req:*,callback:Handler):Boolean{
            if(sTools){
                sTools("pay",function(rst:*):void{
                    // trace("--客户端调用ad方法,pay-- 返回1 -- "+rst);
                    if(callback){
                        callback.runWith([rst,"pay"]);
                    }
                },JSON.stringify(req));             
            }
            return false;            
        }  
        public static function pay_wx(req:*,callback:Handler):Boolean{
            if(sTools){
                sTools("pay_wx",function(rst:*):void{
                    // trace("--客户端调用ad方法,pay-- 返回1 -- "+rst);
                    if(callback){
                        callback.runWith([rst,"pay_wx"]);
                    }
                },JSON.stringify(req));             
            }
            return false;            
        }        
        public static function pay2(req:*,callback:Handler):Boolean{
            if(sTools){
                sTools("pay",function(rst:Object):void{
                    // trace("--客户端调用ad方法,pay-- 返回1 -- "+rst);
                    if(callback){
                        callback.runWith([0,rst]);
                    }
                },JSON.stringify(req));                
            }
            return false;            
        }               
        public static function login(pf:String,callback:Handler):Boolean{
            if(sTools){
                sTools("login",function(reJson:Object):void{
                    // trace("--Client调用android方法login返回在Client输出-- "+JSON.stringify(reJson));
                    if(callback){
                        callback.runWith([0,reJson]);
                    }
                },pf);                
            }
            return false;            
        } 
        public static function logout(callback:Handler):Boolean{
            if(sTools){
                // sTools.call("logout");
                sTools("logout",function(rst:Number):void{
                    if(callback){
                        callback.runWith([rst,"logout"]);
                    }
                },"");
            }
            return false;            
        }         
        public static function showfloat():Boolean{
            if(sTools){
                // sTools.call("showfloat");
                sTools("showfloat",null,"");
            }
            return false;            
        }
        public static function hidefloat():Boolean{
            if(sTools){
                // sTools.call("hidefloat");
                sTools("hidefloat",null,"");
            }
            return false;            
        } 
        public static function savePlayerInfo(info:*,callback:Handler):Boolean{
            if(sTools){
                sTools("savePlayerInfo",function(rst:Number):void{
                    if(callback){
                        callback.runWith([rst,"savePlayerInfo"]);
                    }
                },JSON.stringify(info));                
            }
            return false;            
        } 
        public static function callMethod(method:String,req:*,callback:Handler):Boolean{
            if(sTools){
                var params:String = "";
                if(req is String){
                    params = req+"";
                }
                else{
                    params = JSON.stringify(req);
                }
                sTools(method,function(rst:*):void{
                    // trace("--客户端调用ad方法,pay-- 返回1 -- "+rst);
                    if(callback){
                        callback.runWith([rst,method]);
                    }
                },params);             
            }
            return false;            
        }  
        public static function other_fun(req:*,callback:Handler):Boolean{
            if(sTools){
                sTools("other_fun",function(rst:*):void{
                    // trace("--客户端调用ad方法,pay-- 返回1 -- "+rst);
                    if(callback){
                        callback.runWith([rst,"other_fun"]);
                    }
                },req);             
            }
            return false;            
        }                                                    
    }
}