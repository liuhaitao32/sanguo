package sg.view.map
{
	import ui.map.creditGiftUI;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import ui.map.item_credit_gift_dayUI;
	import laya.utils.Handler;
	import laya.ui.Label;
	import laya.ui.Image;
	import sg.manager.AssetsManager;
	import sg.utils.Tools;
	import sg.manager.ViewManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewCreditGift extends creditGiftUI{
		
		private var mtype:int=0;//0 每日   1  每年
		private var mrank:Number=-1;
		private var list_data:Array=[];
		private var config_list_data:Array=[];
		private var mCfg:Object;
		public function ViewCreditGift(){
			
			this.dayList.itemRender=ItemDay;
			this.dayList.scrollBar.visible=false;
			this.dayList.renderHandler=new Handler(this,listRender1);

			this.yearList.itemRender=ItemYear;
			this.yearList.scrollBar.visible=false;
			this.yearList.renderHandler=new Handler(this,listRender2);

			ModelManager.instance.modelUser.on(ModelUser.EVENT_UPDATE_CREDIT,this,closeHandler);
		}

		public function closeHandler():void{
			this.closeSelf();
		}


		public override function onAdded():void{
			mCfg=ConfigServer.credit;
			mtype=this.currArg[0];
			mrank=this.currArg[1];
			this.dayList.visible=this.yearList.visible=false;
			//this.titleLabel.text=mtype==0?"":Tools.getMsgById("_credit_text11");//"每年奖励";
			var s:String = mtype==0?"":Tools.getMsgById("_credit_text11");//"每年奖励";
			this.comTitle.setViewTitle(s);

			this.text1.text=Tools.getMsgById("_credit_text12",[mCfg.list_reward_time[1][0]]);//"每年冬季"+ConfigServer.credit.list_reward_time[1][0]+"点发放年度奖励";
			this.text2.text=Tools.getMsgById("_credit_text13",[mCfg.list_reward_long]);//"排名前"+ConfigServer.credit.list_reward_long+"名可获得奖励";
			setData();		
		}
		
		public function setData():void{
			list_data=[];
			var list_length:Number=mCfg.list_reward_long;
			if(mtype==0){
				config_list_data=mCfg.list_reward_day;
			}else{
				config_list_data=mCfg.list_reward_year;
			}
			for(var i:int=0;i<config_list_data.length;i++){
				var o:Array=config_list_data[i];
				var n:Number=0;
				n=(i==config_list_data.length-1)?list_length+1:config_list_data[i+1][0];
				//trace(o[0],n);
				for(var j:int=o[0];j<n;j++){
					var a:Array= o.concat();
					a[0]=j;
					list_data.push(a);
				}
				
			}
			//trace("----------------------------",list_data);
			if(mtype==0){
				this.dayList.visible=true;
				this.dayList.array=list_data;
			}else{
				this.yearList.visible=true;
				this.yearList.array=list_data;
			}

			//this.comUser.indexLabel.text=mrank==-1?"未上榜":mrank+"";
			/*
			this.comIndex.setRankIndex(mrank+1);
			comIndex.visible=(mrank!=-1);
			this.text0.text=(mrank==-1)?Tools.getMsgById("_public101"):"";
			//this.comUser.indexLabel.fontSize=mrank==-1?22:30;
			comCountry.setCountryFlag(ModelUser.getCountryID());
			comHead.setHeroIcon(ModelUser.getUserHead(ModelManager.instance.modelUser.head));
			comNum.setData(AssetsManager.getAssetItemOrPayByID("item041"),ModelManager.instance.modelUser.year_credit+"");
			nameLabel.text=ModelManager.instance.modelUser.uname;
			//this.comUser.guildLabel.text=mrank==-1?"未进入前100名没有奖励":"";
			*/
		}

		private function listRender1(id:ItemDay,index:int):void{
			id.setData(this.dayList.array[index]);
		}

		private function listRender2(iy:ItemYear,index:int):void{
			iy.setData(this.yearList.array[index]);
		}



		public override function onRemoved():void{
			this.yearList.scrollBar.value=0;
			this.dayList.scrollBar.value=0;
		}
	}
}


import ui.map.item_credit_gift_dayUI;
import ui.map.item_credit_gift_yearUI;
import ui.bag.bagItemUI;
import sg.model.ModelItem;
import sg.manager.ModelManager;
import laya.utils.Handler;
import laya.ui.Label;
import laya.ui.Image;
import laya.events.Event;
import sg.manager.ViewManager;

class ItemDay extends item_credit_gift_dayUI{
	public function ItemDay(){
		//this.scaleX=0.75;
		//this.scaleY=0.75;
	}

	public function setData(arr:Array):void{
		//this.indexLabel.text=arr[0]+"";
		this.comIndex.setRankIndex(arr[0],"",true);
		var a:Array=[];
		for(var i:int=1;i<arr.length;i++){
			if(arr[i].length!=0){
				a.push(arr[i]);
			}
		}
		//this.list.itemRender=bagItemUI;
		this.list.renderHandler=new Handler(this,listRender);
		this.list.array=a;

	}
	public function listRender(item:bagItemUI,index:int):void{
		var a:Array=this.list.array[index];
		var it:ModelItem=ModelManager.instance.modelProp.getItemProp(a[0]);
		if(it){
			var num:Number=a[1]==null?1:a[1];
			//item.setData(it.icon,it.ratity,"",num+"");	
			item.setData(it.id,num,-1);
		}else{
			item.setData(a[0]);	
		}
		
	}
}

class ItemYear extends item_credit_gift_yearUI{
	public function ItemYear(){
		//this.scaleX=0.75;
		//this.scaleY=0.75;
	}

	public function setData(arr:Array):void{
		//this.indexLabel.text=arr[0]+"";
		this.comIndex.setRankIndex(arr[0],"",true);
		var a:Array=[];
		for(var i:int=1;i<arr.length;i++){
			if(arr[i].length!=0){
				a.push(arr[i]);
			}
		}
		//this.list.itemRender=bagItemUI;
		this.list.renderHandler=new Handler(this,listRender);
		this.list.array=a;
	}

	public function listRender(item:bagItemUI,index:int):void{
		var a:Array=this.list.array[index];
		item.off(Event.CLICK,this,titleClick);
		if(a[0].indexOf("title")==-1){
			var it:ModelItem=ModelManager.instance.modelProp.getItemProp(a[0]);
			var num:Number=a[1]==null?1:a[1];
			item.setData(it.id,num,-1);
		}else{
			var s:String = a.length == 1 ? a[0] : a[0]+"_0";
			item.on(Event.CLICK,this,this.titleClick,[s]);
			item.setData(a[0]);	
		}
	}
	private function titleClick(tid:String):void{
		 ViewManager.instance.showItemTips(tid);
	}
}


