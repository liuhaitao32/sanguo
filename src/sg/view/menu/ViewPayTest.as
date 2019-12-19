package sg.view.menu
{
	import ui.menu.payTestUI;
	import laya.ui.Box;
	import laya.ui.Label;
	import sg.cfg.ConfigServer;
	import laya.maths.MathUtil;
	import sg.net.NetPackage;
	import laya.utils.Handler;
	import laya.events.Event;
	import sg.net.NetSocket;
	import sg.manager.ViewManager;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.model.ModelGame;
	import laya.renders.Render;
	import laya.utils.Browser;
	import sg.cfg.ConfigApp;
	import laya.ui.Image;
	import sg.net.NetHttp;
	import sg.net.NetMethodCfg;
	import sg.activities.model.ModelWeekCard;
	import sg.cfg.ConfigClass;
	import sg.manager.AssetsManager;
	import sg.model.ModelSalePay;
	import laya.ui.Button;
	import laya.display.Text;
	import sg.activities.view.ViewSalePay;
	import sg.model.ModelUser;
	import sg.activities.model.ModelCostly;

	/**
	 * ...
	 * @author
	 */
	public class ViewPayTest extends payTestUI{
		public var configData:Object={};
		public var listData:Array=[];
		public var pay_pid_log:Array;
		private var mPayId:String;

		private var mTime:int;
		private var mGap:int = 2000;

		public function ViewPayTest(){
			this.list.scrollBar.visible=false;
			this.list.renderHandler=new Handler(this,this.listRender);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_PAY_END,this,function():void{
				pay_pid_log = ModelManager.instance.modelUser.records.pay_pid_log;
				listData = ModelManager.instance.modelUser.getPayList();
				list.array = listData;
			});

			ModelManager.instance.modelGame.on(ModelGame.EVENT_PAY_LIST_UPDATE,this,function():void{
				listData = ModelManager.instance.modelUser.getPayList();
				list.array = listData;
			});

			this.comTitle.setViewTitle(Tools.getMsgById("_public104"),true);

			this.askBtn.on(Event.CLICK,this,function():void{
				ViewManager.instance.showTipsPanel(ModelCostly.instance.getText());
			});
		}

		override public function onAdded():void{
			mTime = 0;
			this.askBtn.visible = ModelCostly.instance.active;
			// 
            if(!Platform.payCanShowUI()){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("msg_ViewPayTest_0"));
				this.closeSelf();
				return;
			}
			configData=ConfigServer.pay_config_pf;
			pay_pid_log=ModelManager.instance.modelUser.records.pay_pid_log;
			getListData();
		}


		override public function onRemoved():void{
			this.list.scrollBar.value = 0;
		}
		public function getListData():void{
			var listArr:Array = ModelManager.instance.modelUser.getPayList();
			var isSelfPay:Boolean = ConfigApp.payIsSelf();
			// 
			if(!isSelfPay && ConfigApp.pf == ConfigApp.PF_ios_meng52_mj1){
				var outData:Object = ConfigServer.system_simple.pay[ConfigApp.pf];
				// outData = {'pay1':'',"pay2":"","pay3":"","pay4":""};
				if(outData){
					listData = [];
					var len:int = listArr.length;
					for(var i:int = 0; i < len; i++)
					{
						var element:Object = listArr[i];
						if(outData.hasOwnProperty(element.id)){
							listData.push(element);
						}
					}
				}
				else{
					listData = listArr;
				}
			}
			else{
				listData = listArr;
			}
			// 
			if(listData.length<=6){
				this.list.repeatY=3;
			}else if(listData.length>6){
				this.list.repeatY=4;
			}
			this.list.array = listData;
			this.all.height = this.list.top + this.list.height + 8;
		}

		public function listRender(cell:Box,index:int):void{
			var text1:Label=cell.getChildByName("text1") as Label;
			var text2:Label=cell.getChildByName("text2") as Label;
			var box:Box=(cell.getChildByName("box") as Box);
			var text3:Label=box.getChildByName("text3") as Label;
			var text4:Label=box.getChildByName("text4") as Label;
			var img:Image=cell.getChildByName("img") as Image;
			var bigImg:Image=cell.getChildByName("bigImg") as Image;
			var imgZhou:Image=cell.getChildByName("imgZhou") as Image;
			var imgText:Image=cell.getChildByName("imgText") as Image;

			var imgLine:Image=cell.getChildByName("imgLine") as Image;
			var text5:Label=cell.getChildByName("text5") as Label;
			
			var o:Object=this.list.array[index];
			imgZhou.visible=o["cost"]==30 && ModelWeekCard.instance.active;
			text1.text=ModelUser.getPayMoneyStr(o["cost"]);
			text2.text=""+o["get"];
			if(Platform.pay_list_info){
				var payCfg:Object = ConfigServer.system_simple.pay[ConfigApp.pf];
				var oid:String = payCfg[o.id];
				var info:Object = Platform.pay_list_info[oid];
				var tts:String = info["price"];
				text1.text = tts;//tts.replace(info["currency"],"");
			}
			var bag_arr:Array=o["redbag"];
			if(bag_arr[0]==0 && bag_arr[1]==0){
				box.visible=false;
			}else{
				box.visible=true;
				//text3.text=""+ModelManager.instance.modelProp.getItemProp(o["item"]).name+" x"+o["num"];
				text3.text=Tools.getMsgById("_country51",bag_arr);
				text4.text=Tools.getMsgById("_public43");
				box.width=text3.x+text3.width+text4.width;
			}
			//首充双倍  删掉了
			//img.visible=(o["get"]!=o["first"])&&(pay_pid_log && pay_pid_log.indexOf(listData[index].id)==-1);
			bigImg.skin=AssetsManager.getAssetLater(o["icon"]+".png");

			var saleID:String = o.salePayID;
			text5.text = "";
			if(saleID!="" && o.salePayNum > 0){
				var md:ModelSalePay = ModelSalePay.getModel(saleID);
				text5.text = ModelUser.getPayMoneyStr(o["cost"]);
				text1.text = ModelUser.getPayMoneyStr(ModelManager.instance.modelUser.getPayMoney(md.payId2,ConfigServer.pay_config[md.payId2][0]));
				text5.x = text1.x - text5.textField.textWidth;
				imgLine.width = text5.width;
				imgLine.x = text5.x;
				text5.visible = true;

			}
			var n:Number = text1.textField.textWidth + 37;
			if(text5.text!="") n+=text5.textField.textWidth;
			imgLine.visible = text5.text != "";

			imgText.width = n;

			var btn:Button = cell.getChildByName("btn") as Button;	
			btn.off(Event.CLICK,this,this.itemClick);
			btn.on(Event.CLICK,this,this.itemClick,[index]);

			var btnSalePay:Button = cell.getChildByName("btnSalePay") as Button;	
			btnSalePay.visible = o.salePayNum > 0;

			if(btnSalePay.visible){
				var dueBox:Box = btnSalePay.getChildByName("dueBox") as Box;
				var sale01:Label = btnSalePay.getChildByName("sale01") as Label;
				var saleImg:Image = btnSalePay.getChildByName("saleImg") as Image;
				var imgGlow:Image = (btnSalePay.getChildByName("box1") as Box).getChildByName("imgGlow") as Image;

				var sale02:Label = dueBox.getChildByName("sale02") as Label;
				var sale03:Label = dueBox.getChildByName("sale03") as Label;
				sale01.text = Tools.getMsgById("sale_pay_03",[o.salePayNum]);
				sale02.text = Tools.getMsgById("sale_pay_01");
				sale03.text = Tools.getMsgById("sale_pay_02");
				if(ModelSalePay.getModel(saleID)){
					saleImg.skin = ModelSalePay.getModel(saleID).getIcon();
				}
				imgGlow.visible = saleID!="";
				dueBox.visible = ModelSalePay.getNearlyOverSID(o.id)!="";
			}		
			btnSalePay.off(Event.CLICK,this,this.salePayClick);
			btnSalePay.on(Event.CLICK,this,this.salePayClick,[index]);

			btn.top = btn.bottom = btn.left = 0;
			btn.right = btnSalePay.visible ? btnSalePay.width : 0;
		}

		private function salePayClick(index:int):void{
			ViewManager.instance.showView(["ViewSalePay",ViewSalePay],this.listData[index].id);
		}



		public function itemClick(index:int):void{
			// Browser.window.openFrame("   ","pay_test.html");
			// return;
			//
			var n:Number = ConfigServer.getServerTimer();
			if(mTime>0 && n - mTime < mGap){
				ViewManager.instance.showTipsTxt(Tools.getMsgById('_public248'));
				return;
			}
			
			if(ConfigServer.system_simple.pay_warning_pf && ConfigServer.system_simple.pay_warning_pf.indexOf(ConfigApp.pf)>-1){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public234"));//"目前不能充值"
				return;
			}
			mPayId = this.listData[index].id;
			if(this.listData[index].salePayID!=""){	
				var sid:String = this.listData[index].salePayID;
				if(ModelSalePay.isActive()){
					mPayId = ModelSalePay.getModel(sid).payId2;
				}
				var arr:Array = ModelManager.instance.modelUser.sale_pay;
				var b:Boolean = false;
				var now:Number = ConfigServer.getServerTimer();
				for(var i:int=0;i<arr.length;i++){
					if(arr[i][0] == sid){
						var n2:Number = Tools.getTimeStamp(arr[i][2]);
						if(n2>now){
							b = true;
						}
					}
				}			
				if(!b){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("sale_pay_19"));//"已过期"
					listData = ModelManager.instance.modelUser.getPayList();
					this.list.array = listData;
					return;
				}
				ModelGame.tryToPay(mPayId);
			}else{
				ModelGame.toPay(mPayId);
			}
			
			mTime = ConfigServer.getServerTimer();
			
			//
			// var payObj:Object;
			// var payCfg:Object = ConfigServer.pay_config_pf[this.listData[index].id];
			// var envN:Number = ConfigServer.system_simple.wx_pay_test?ConfigServer.system_simple.wx_pay_test:0;
			// var ios_url:String = "";//http://192.168.1.116:8888/gateway/
			// payObj = {
			// 			pid:this.listData[index].id,
			// 			zone:ModelManager.instance.modelUser.zone,
			// 			uid:ModelManager.instance.modelUser.mUID,
			// 			pf:ConfigApp.pf,
			// 			buyQuantity:payCfg[0]*10,
			// 			env:envN,
			// 			cfg:payCfg,
			// 			url:ios_url,
			// 			channel:ConfigApp.pf_channel
			// 		};	
			// //	
			// var isSelfPay:Boolean = ConfigApp.payIsSelf();
			// //
			// if(isSelfPay){
			// 	ViewManager.instance.showView(ConfigClass.VIEW_PAY_SELF,payObj);
			// }
			// else{
			// 	Platform.pay(payObj,false);
			// }
		}
		public function clickCallBack(np:NetPackage):void{
			ViewManager.instance.showTipsTxt(Tools.getMsgById("_public115"));//"充值成功！"
			ViewManager.instance.showIcon(np.receiveData.gift_dict,np.otherData.x,np.otherData.y);
			ModelManager.instance.modelUser.updateData(np.receiveData);
			Platform.payClose();
		}
	}

}