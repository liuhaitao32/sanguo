package sg.activities.view
{
	import ui.activities.salePay.salePayAlertUI;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.model.ModelSalePay;
	import sg.utils.Tools;
	import sg.model.ModelUser;
	import sg.boundFor.GotoManager;
	import sg.manager.QueueManager;
	import sg.model.ModelGame;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigApp;
	import laya.events.Event;
	import ui.activities.salePay.salePayItemUI;
	import laya.utils.Handler;
	import laya.ui.Box;
	import laya.ui.Label;
	import sg.manager.LoadeManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewSalePayAlert extends salePayAlertUI{

		private var mTime:int;//最快过期的抵扣券的时间
		public function ViewSalePayAlert(){
			this.list.renderHandler = new Handler(this,listRender);
			this.list.scrollBar.visible = false;

			this.btn.label = Tools.getMsgById('_country7');
			this.btn.on(Event.CLICK,this,btnClick);

			this.text0.text = Tools.getMsgById(ConfigServer.system_simple.sale_tips.title);
			this.text1.text = Tools.getMsgById("_public114");

			
		}

		private function paySuccessCallBack():void{
			setData();
		}

		override public function onAdded():void{
			ModelManager.instance.modelUser.on(ModelUser.EVENT_PAY_SUCCESS,this,paySuccessCallBack);
			this.heroIcon.setHeroIcon(ConfigServer.system_simple.sale_tips.show_hero,false);
			LoadeManager.loadTemp(this.tempImg,'ad/actdkq_1.png');
			if(!this.currArg) return;
			var arr:Array = this.currArg;
			setList(arr);
			
		}

		private function setList(arr:Array):void{
			var now:Number = ConfigServer.getServerTimer();
			mTime = 0;
			for(var i:int=0;i<arr.length;i++){
				var n:Number = arr[i]['n2'] - now;
				if(mTime == 0) mTime = n;
				else if(mTime>n) mTime = n;
			}
			this.list.array = arr;
			Laya.timer.clear(this,listOnTimer);
			listOnTimer();
		}

		private function listOnTimer():void{
			Laya.timer.once(1000,this,listOnTimer);
			if(mTime <= 0) {
				setData();
			}else{
				mTime -= 1000;
				this.list.refresh();
			}
		}

		private function setData():void{
			var arr:Array = ModelSalePay.getOverdueList();
			if(arr.length == 0){
				this.closeSelf();
			}else{
				setList(arr);
			}
		}

		private function listRender(cell:Box,index:int):void{
			var now:Number = ConfigServer.getServerTimer();
			var o:Object = this.list.array[index];
			var id:String = o.id;
			var n2:Number = o.n2;
			var com:salePayItemUI = cell.getChildByName('com') as salePayItemUI;
			com.imgUse.visible = false;

			com.btn1.off(Event.CLICK,this,itemClick);
			com.img.skin = o.skin;
			com.btn1.label = Tools.getMsgById("sale_pay_06");
			com.text0.text = o.name;
			com.text1.text = n2 - now > 0 ? Tools.getMsgById('sale_pay_20',[Tools.getTimeStyle(n2 - now)]) : "";
			com.btn1.on(Event.CLICK,this,itemClick,[index]);

			var label:Label = cell.getChildByName('text') as Label;
			label.text = o.money;
			
		}

		private function itemClick(index:int):void{
			if(ConfigServer.system_simple.pay_warning_pf && ConfigServer.system_simple.pay_warning_pf.indexOf(ConfigApp.pf)>-1){
				return;
			}
			if(ModelSalePay.isCanClick()==false) return;
			
			var o:Object = this.list.array[index];
			var now:Number = ConfigServer.getServerTimer();
			if(now>=o.n2){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("sale_pay_19"));//"已过期"
				setData();
				return;
			}
			ModelGame.toPay(this.list.array[index].pid);
			this.closeSelf();
		}

		private function btnClick():void{
			QueueManager.instance.mIsGoto=true;
			GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
			this.closeSelf();
		}

		override public function onRemoved():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_PAY_SUCCESS,this,paySuccessCallBack);
			Laya.timer.clear(this,listOnTimer);
		}
	}

}