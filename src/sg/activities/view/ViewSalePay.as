package sg.activities.view
{
	import ui.activities.salePay.salePayUI;
	import ui.activities.salePay.salePayItemUI;
	import laya.utils.Handler;
	import sg.model.ModelSalePay;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.map.utils.ArrayUtils;
	import sg.model.ModelUser;
	import laya.events.Event;
	import sg.model.ModelGame;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigApp;

	/**
	 * ...
	 * @author
	 */
	public class ViewSalePay extends salePayUI{

		private var mId:String;
		//private var mSid:String;
		private var mMoney:String;//原价
		public function ViewSalePay(){
			this.list.itemRender = salePayItemUI;
			this.list.renderHandler = new Handler(this,listRender);
			this.list.scrollBar.visible = false;

			this.askBtn.on(Event.CLICK,this,function():void{
				ViewManager.instance.showTipsPanel(Tools.getMsgById("sale_pay_09"));
			});

			// this.btn.on(Event.CLICK,this,function():void{
			// 	if(btn.gray) return;
			// 	btnClick(-1);
			// });
		}

		public override function onAdded():void{
			ModelManager.instance.modelUser.on(ModelUser.EVENT_PAY_SUCCESS,this,setList);
			this.text0.text = Tools.getMsgById("sale_pay_07");
			this.text1.text = "";//Tools.getMsgById("sale_pay_09");
			//this.text2.text = Tools.getMsgById("sale_pay_16");
			
			
			mId = this.currArg;
			//mSid = ModelSalePay.getSeletedByPid(mId);
			mMoney = ModelUser.getPayMoneyStr(ModelManager.instance.modelUser.getPayMoney(mId,ConfigServer.pay_config[mId][0])),
			setList();

			//this.text2.text = Tools.getMsgById("sale_pay_04",[mMoney]);//"实付xxx";
			//this.btn.gray = mSid == mId;
		}

		private function setList():void{
			var arr:Array = ModelSalePay.getSaleArrByPId(mId);
			var saleArr:Array = ModelManager.instance.modelUser.sale_pay ? ModelManager.instance.modelUser.sale_pay : [];
			var listData:Array = [];
			var now:Number = ConfigServer.getServerTimer();
			for(var i:int=0;i<saleArr.length;i++){
				if(arr.indexOf(saleArr[i][0])!=-1){
					var md:ModelSalePay = ModelSalePay.getModel(saleArr[i][0]);
					var n1:Number = Tools.getTimeStamp(saleArr[i][1]);
					var n2:Number = Tools.getTimeStamp(saleArr[i][2]);
					if(n2>now){
						listData.push({"id":md.id,
										"pid":md.payId2,
										"type":0,
										"n1":n1,
										"n2":n2,
										"skin":md.getIcon(),
										"money":ModelUser.getPayMoneyStr(ModelManager.instance.modelUser.getPayMoney(md.payId2,ConfigServer.pay_config[md.payId2][0])),
										"sort1":9999-md.getSaleMoney(),
										"sort2":n2-now});
					}
				} 
			}
			
			listData = ArrayUtils.sortOn(["sort1","sort2"],listData,false);

			listData.push({"id":mId,
							"skin":"later/pay_coupon_4.png",
							"type":1
							});

			this.list.array = listData;
		}

		private function listRender(cell:salePayItemUI,index:int):void{
			var o:Object = this.list.array[index];
			var id:String = o.id;
			var n2:Number = o.n2;
			cell.imgUse.visible = false;

			cell.btn1.off(Event.CLICK,this,btnClick);
			cell.img.skin = o.skin;
			cell.btn1.label = Tools.getMsgById("sale_pay_06");
			if(o.type==0){
				cell.text0.text = Tools.getMsgById("sale_pay_04",[o.money]);
				cell.text1.text = Tools.getMsgById("sale_pay_05",[Tools.dateFormat(n2,1)]);
				cell.btn1.on(Event.CLICK,this,btnClick,[index]);
			}else{
				cell.text0.text = Tools.getMsgById("sale_pay_04",[mMoney]);
				cell.text1.text = Tools.getMsgById("sale_pay_16");
				cell.btn1.on(Event.CLICK,this,btnClick,[-1]);
			}
			
		}

		private function btnClick(index:int):void{
			if(ConfigServer.system_simple.pay_warning_pf && ConfigServer.system_simple.pay_warning_pf.indexOf(ConfigApp.pf)>-1){
				
				return;
			}
			if(ModelSalePay.isCanClick()==false) return;
			
			if(index==-1){
				//mSid = mId;
				ModelGame.toPay(mId);
			}else{
				//mSid = this.list.array[index].id;
				var o:Object = this.list.array[index];
				var now:Number = ConfigServer.getServerTimer();
				if(now>=o.n2){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("sale_pay_19"));//"已过期"
					ModelManager.instance.modelGame.event(ModelGame.EVENT_PAY_LIST_UPDATE);
					setList();
					return;
				}
				ModelGame.toPay(this.list.array[index].pid);
			}
			this.closeSelf();
			//ModelSalePay.setSeletedObj(mId,mSid);
			//setList();
			//ModelManager.instance.modelGame.event(ModelGame.EVENT_PAY_LIST_UPDATE);
			//this.btn.gray = mSid == mId;
		}



		public override function onRemoved():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_PAY_SUCCESS,this,setList);
		}


	}

}