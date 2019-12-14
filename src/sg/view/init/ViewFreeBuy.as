package sg.view.init
{
	import ui.init.freeBuyUI;
	import laya.events.Event;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.manager.AssetsManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelUser;
	import sg.utils.SaveLocal;
	import laya.maths.MathUtil;
	import sg.manager.LoadeManager;
	import sg.activities.model.ModelFreeBuy;
	import laya.ui.Label;
	import sg.utils.ArrayUtil;
	import sg.view.task.ViewWorkAssessSpecial;
	import ui.bag.bagItemUI;
	import sg.boundFor.GotoManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewFreeBuy extends freeBuyUI{

		public var curId:String="";

		public var cost_num:Number=0;
		public var tab_arr:Array=[];

		public function ViewFreeBuy(){
			this.btn.on(Event.CLICK,this,this.btnCLick);
			this.tab.on(Event.CHANGE,this,tabChange);
			
			this.text3.text=Tools.getMsgById("_public94",[""]);

			this.rList.renderHandler=new Handler(this,listRender);
			this.rList.scrollBar.visible=false;
		}

		/**
		 * 充值成功推送
		 */
		public function eventCallBack():void{
			ModelFreeBuy.instance.checkData();
			tab_arr=ModelFreeBuy.instance.mData;
			setUI();
		}

		override public function onAdded():void{
			ModelManager.instance.modelUser.on(ModelUser.EVENT_PAY_SUCCESS,this,eventCallBack);
			//this.titleLabel.text=Tools.getMsgById("free_buy_name");
			this.comTitle.setViewTitle(Tools.getMsgById("free_buy_name"));
			this.tab.selectedIndex=-1;
			setData();
			LoadeManager.loadTemp(this.back0,AssetsManager.getAssetsUI("bg_19.png"));
			LoadeManager.loadTemp(this.back1,AssetsManager.getAssetsUI("bg_17.png"));
		}

		public function btnCLick():void{
			var o:Object=tab_arr[this.tab.selectedIndex];
			//直接购买的判断元宝数
			if(!Tools.isCanBuy("coin",cost_num)){
				return;
			}
			//需要充值的判断充值数额
			if(o.pay_num!=0 && o.my_num<o.pay_num){
				GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
				return;
			}

			if (o.id === 'gtask') {
				NetSocket.instance.send("get_pay_gtask_reward",{},Handler.create(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					var gift_dict:Object=np.receiveData.gift_dict;
					if(gift_dict && Tools.getDictLength(np.receiveData.gift_dict)>0){
						ViewManager.instance.showView(["ViewWorkAssessSpecial",ViewWorkAssessSpecial], [gift_dict, np.receiveData.get_gift_num_list]);
					}
					setData();
				}));
				return;
			}

			if (o.id === 'buy_weapon') {
				NetSocket.instance.send("get_buy_weapon_reward",{"equip_id":o.key},Handler.create(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					var gift_dict:Object=np.receiveData.gift_dict;
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
					setData();
				}));
				return;
			}

			if(o.id == "day_buy_weapon"){
				NetSocket.instance.send("get_day_buy_weapon_reward",{"reward_key":o.key},Handler.create(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					var gift_dict:Object=np.receiveData.gift_dict;
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
					setData();
				}));
				return;
			}


			NetSocket.instance.send("use_free_buy",{"free_type":o.key},Handler.create(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ModelManager.instance.modelUser.event(ModelUser.EVENT_ACT_TIME_OUT);
				if(np.receiveData.gift_dict && Tools.getDictLength(np.receiveData.gift_dict)>0){
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				}else{
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_public133"));//"购买成功"
				}
				setData();
			}));
		}



		public function setData():void{
			tab_arr=ModelFreeBuy.instance.mData;
			if(tab_arr.length==0){
				trace("===========free_buy 空的 关闭面板");
				ModelFreeBuy.instance.event(ModelFreeBuy.EVENT_ChANGE_FREE_BUY);	
				this.closeSelf();
				return;
			}
			if(this.currArg)
				ModelManager.instance.modelUser.free_buy_key=this.currArg;

			var str:String="";
			var n:Number=0;
			for(var i:int=0;i<tab_arr.length;i++){
				str+=Tools.getMsgById(tab_arr[i].title);
				str+=i==tab_arr.length-1?"":",";
				if(tab_arr[i].id+"_"+tab_arr[i].key==ModelManager.instance.modelUser.free_buy_key){
					n=i;
				}
			}
			//trace("===============",str);
			this.tab.labels=str;
			this.tab.selectedIndex=n;
			setUI();
			
			ModelManager.instance.modelUser.free_buy_key="";
		}

		public function setUI():void{
			this.timeLabel.text="";
			this.box_box.visible=this.box_gtask.visible = this.box_baggage.visible = this.box_weapon.visible = false;
			
			var o:Object=tab_arr[tab.selectedIndex] ? tab_arr[tab.selectedIndex] : tab_arr[0];//容错一下
			curId=o.id;

			this.comHero.setHeroIcon(o.hero,false);
			this.infoLabel.text=Tools.getMsgById(o.info);
			
			this.text1.text=Tools.getMsgById("_public131");//"获得";
			this.text0.text=Tools.getMsgById(o.buy_num!=0 ? "_public130" : "_public104");//"支付" "充值"
			if(curId=="buy"){
				this.btn.label = Tools.getMsgById("_public44");//"购买";
				this.compay0.setData(AssetsManager.getAssetItemOrPayByID("coin"),o.buy_num+"");
				this.compay1.setData(AssetsManager.getAssetItemOrPayByID(o.key),o.get_num+"");
				text1.visible=true;
				this.box_box.visible=true;
			}else if(curId=="baggage"){
				this.btn.label= Tools.getMsgById("_public44");//"购买";
				this.label0.text=Tools.getMsgById("_public134");//"额外获得";
				this.label1.text=" "+o.get_num+" ";
				this.label2.text=Tools.getMsgById("_public135");//"次辎重站";
				this.label3.text=Tools.getMsgById("_public136");//"购买机会，且必定";
				this.label4.text=Tools.getMsgById("_public137");//"暴击！！！";
				this.box_baggage.width=this.label0.width+this.label1.width+this.label2.width+this.label3.width+this.label4.width+this.img0.width;
				this.label0.x=0;
				this.label1.x=this.label0.x+this.label0.width;
				this.label2.x=this.label1.x+this.label1.width;
				this.img0.skin=AssetsManager.getAssetItemOrPayByID(o.key);
				this.img0.x=this.label2.x+this.label2.width;
				this.label3.x=this.img0.x+this.img0.width;
				this.label4.x=this.label3.x+this.label3.width;
				this.compay0.setData(AssetsManager.getAssetItemOrPayByID("coin"),o.buy_num+"");
				text1.visible=false;
				this.box_baggage.visible=true;
			}else if(curId=="pay" || curId=="gtask" || curId=="buy_weapon" || curId=="day_buy_weapon"){
				this.compay0.setData(AssetsManager.getAssetItemOrPayByID("coin"),o.my_num+"/"+o.pay_num);
				// 充值/领取
				this.btn.label = o.my_num<o.pay_num ? Tools.getMsgById("_public104") : Tools.getMsgById("_public138");
				
				text1.visible=true;
				this.box_box.visible=true;
				if(curId=="gtask"){
					this.box_box.visible=false;
					this.box_gtask.visible=true;
					var buy_gtask:Object = ConfigServer.ploy['buy_gtask'];
					(box_gtask.getChildByName('txt_name') as Label).text = Tools.getMsgById(ArrayUtil.find(ConfigServer.gtask.reward_mulit, function(array:Array):Boolean{return array[0] === buy_gtask['mulit'][0];})[1]);
					(box_gtask.getChildByName('txt_num') as Label).text = 'X' + buy_gtask['mulit'][1];
				}else if(curId=="buy_weapon" || curId =="day_buy_weapon"){
					this.box_box.visible=false;
					this.box_weapon.visible=true;
					this.compay0.setData(AssetsManager.getAssetItemOrPayByID("coin"),o.my_num+"/"+o.pay_num);
					this.rList.array=ModelManager.instance.modelProp.getRewardProp(o.reward);
				}else if(curId=="pay"){
					this.compay1.setData(AssetsManager.getAssetItemOrPayByID(o.key),o.get_num+"");
				}
			}
			box_time.visible = o.pay_num==0 || o.my_num<o.pay_num;
			cost_num=o.buy_num;//购买的数值
			time_tick();
			//Laya.timer.loop(1000,this,time_tick);

		}

		private function listRender(cell:bagItemUI,index:int):void{
			var a:Array=this.rList.array[index];
			cell.setSpecial(false);
			cell.setData(a[0],a[1],-1);
			//是宝物的话全都给个特效
			if(a[0].indexOf("equip")!=-1){
				cell.setSpecial(true);
			}
		}

		public function tabChange():void{
			if(tab.selectedIndex==-1){
				return;
			}

			setUI();
		}


		public function time_tick():void{
			var now:Number=ConfigServer.getServerTimer();
			var time:Number=tab_arr[this.tab.selectedIndex] ? Tools.getTimeStamp(tab_arr[this.tab.selectedIndex].time) : 0;
			if(time>0 && now>time){
				ModelFreeBuy.instance.checkData();
				setData();
				return;
			}
			this.timeLabel.text=Tools.getTimeStyle(time-now);
			Laya.timer.once(1000,this,time_tick);
		}


		override public function onRemoved():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_PAY_SUCCESS,this,eventCallBack);
			Laya.timer.clear(this,time_tick);
		}
	}

}