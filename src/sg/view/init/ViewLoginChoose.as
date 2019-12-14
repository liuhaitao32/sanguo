package sg.view.init
{
	import ui.init.viewLoginChooseUI;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.utils.ThirdRecording;
	import sg.net.NetHttp;
	import sg.net.NetMethodCfg;
	import sg.cfg.ConfigApp;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewLoginChoose extends viewLoginChooseUI{

		private var mRegistTime:Number = 1000;
		public function ViewLoginChoose(){
			//this.btn_reg.label="";
			//this.btn_fast.label="";
			//this.btn_login.label="";
			this.mRegistTime = 0;
			this.btn_reg.on(Event.CLICK,this,click,[2]);
			this.btn_fast.on(Event.CLICK,this,click,[3]);
			this.btn_login.on(Event.CLICK,this,click,[1]);
		}


		override public function initData():void{
			this.isAutoClose=false;
		}

		private function click(type:int):void{
			
			
			if(type==3){
				if(this.registCheck()){
                    return;
                }
                Trace.log("2准备注册的channel--:"+ConfigApp.pf_channel);
                NetHttp.instance.send(NetMethodCfg.HTTP_USER_REGISTER_FAST,{pf:ConfigApp.pf_channel},Handler.create(this,this.registFast));
			}else{
				ViewManager.instance.showView(ConfigClass.VIEW_LOGIN,[type]);
			}
		}

		private function registCheck():Boolean{
            var b:Boolean = false;
            var nowS:Number = new Date().getTime();
            var des:Number = nowS - this.mRegistTime;
            var ruler:Number = ConfigServer.system_simple.regist_gap_time*1000;
            if(des>=ruler){
                this.mRegistTime = nowS;
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht72")+Tools.getTimeStyle(ruler-des));
                b = true;
            }
            return b;
        }



		private function registFast(re:Object):void
        {
            Platform.checkGameStatus(501);
			Trackingio.postReport(3,re);
            ThirdRecording.setRegister();
            ViewManager.instance.closePanel();
            //username: "21b48dcc7", pwd: "253604
           ViewManager.instance.showView(["ViewRegistFast",ViewRegistFast],re); 
        }
		

		override public function onRemoved():void{

		}
	}

}
