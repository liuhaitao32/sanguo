package sg.view.menu
{
    import ui.menu.payTest2UI;
    import laya.utils.Handler;
    import sg.model.ModelGame;
    import sg.manager.ModelManager;
    import sg.cfg.ConfigServer;
    import laya.ui.Box;
    import laya.ui.Label;
    import sg.utils.Tools;
    import sg.cfg.ConfigApp;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.net.NetPackage;
    import sg.cfg.ConfigClass;

    public class ViewCZ1 extends payTest2UI
    {
        public var configData:Object={};
		public var listData:Array=[];
		public var pay_pid_log:Array;
        public function ViewCZ1()
        {
            this.list.scrollBar.visible=false;
			this.list.renderHandler=new Handler(this,this.listRender);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_PAY_END,this,function():void{
				pay_pid_log=ModelManager.instance.modelUser.records.pay_pid_log;
				list.refresh();	
			});
        }
        override public function onAdded():void{		
			configData=ConfigServer.pay_config_pf;
			pay_pid_log=ModelManager.instance.modelUser.records.pay_pid_log;
			getListData();
		}
        public function getListData():void{
			listData=ModelManager.instance.modelUser.getPayList();
			// if(listData.length<=6){
			// 	this.list.repeatY=3;
			// }else if(listData.length>6){
			// 	this.list.repeatY=4;
			// }
			this.list.array = listData;
			// this.all.height = this.list.top + this.list.height + 8;
		}
        public function listRender(cell:Box,index:int):void{
            var text1:Label=cell.getChildByName("text1") as Label;
			var text2:Label=cell.getChildByName("text2") as Label;
            // 
            var o:Object=listData[index];
            text1.text=Tools.getMsgById((ConfigApp.pf==ConfigApp.PF_and_google || ConfigApp.pf==ConfigApp.PF_ios_meng52_tw)?"_lht76":"193004",[o["cost"]]);// "¥ "+o["cost"];
			text2.text=""+o["get"];
            // 
            cell.offAll(Event.CLICK);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
        }
        public function itemClick(index):void{
			//
			if(ConfigServer.system_simple.pay_warning_pf && ConfigServer.system_simple.pay_warning_pf.indexOf(ConfigApp.pf)>-1){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public234"));//"目前不能充值"
				return;
			}
			//
			ModelGame.toPay(this.listData[index].id);
		}
        public function clickCallBack(np:NetPackage):void{
			ViewManager.instance.showTipsTxt(Tools.getMsgById("_public115"));//"充值成功！"
			ViewManager.instance.showIcon(np.receiveData.gift_dict,np.otherData.x,np.otherData.y);
			ModelManager.instance.modelUser.updateData(np.receiveData);
			Platform.payClose();
		}
    }
}