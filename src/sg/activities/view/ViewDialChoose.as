package sg.activities.view
{
	import laya.events.Event;
	import laya.ui.Button;
	import laya.utils.Handler;

	import sg.activities.model.ModelDial;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.Tools;

	import ui.activities.dial.dialChooseUI;
	import ui.activities.treasure.item_treasureUI;
	import ui.bag.bagItemUI;

	/**
	 * ...
	 * @author
	 */
	public class ViewDialChoose extends dialChooseUI{

		private var mSelectIndex:Number=0;
		private var awardLib:Array;
		protected var mData:Array;
		private var mCurSelectNum:Number=0;
		protected var mSelectArr:Array;
		public function ViewDialChoose(){
			this.btn0.label=Tools.getMsgById("dial_text07");//"普通密藏";
			this.btn1.label=Tools.getMsgById("dial_text08");//"传说密藏";
			this.btn2.label=Tools.getMsgById("dial_text09");//"史诗密藏";
			this.text0.text=Tools.getMsgById("dial_text10");//"已选择奖品";
			this.text1.text=Tools.getMsgById("dial_text11");//"本活动内，奖品可选择一次";
			this.btn.label=Tools.getMsgById("_public183");//"确定";
			this.comTitle.setViewTitle(Tools.getMsgById("_jia0012"),true);

			this.list1.itemRender=bagItemUI;
			this.list2.itemRender=item_treasureUI;
			this.list1.renderHandler=new Handler(this,listRender1);
			this.list2.renderHandler=new Handler(this,listRender2);
			this.btn0.on(Event.CLICK,this,btnClick,[0]);
			this.btn1.on(Event.CLICK,this,btnClick,[1]);
			this.btn2.on(Event.CLICK,this,btnClick,[2]);
			this.btn.on(Event.CLICK,this,okClick);
			Tools.textLayout(text0,getLabel,getImg,getBox);
		}


		public override function onAdded():void{
			awardLib = currArg;
			mSelectArr=[[],[],[]];
			mSelectIndex=0;
			mData=awardLib[mSelectIndex];
			setData();
			getAlreadGift();
			btnClick(mSelectIndex);
		}

		public function setData():void{
			
		}


		public function tabChange():void{
			for(var i:int=0;i<3;i++){
				(this["btn"+i] as Button).selected=false;
			}
			(this["btn"+mSelectIndex] as Button).selected=true;
			
		}

		public function btnClick(index:int):void{
			mSelectIndex=index;
			tabChange();
			mData=awardLib[mSelectIndex];
			mCurSelectNum=mSelectArr[mSelectIndex].length;
			this.numLabel.text=mCurSelectNum+"/"+mData[1];
			this.infoLabel.text=Tools.getMsgById("dial_text12",[(mData[0]*100)+"%"]);//"概率"+(mData[0]*100)+"%";
			this.list1.array=mData[2];
		}



		public function listRender1(cell:bagItemUI,index:int):void{
			var arr:Array=this.list1.array[index];
			cell.setData(arr[0],arr[1],-1);
			var arr2:Array=mSelectArr[mSelectIndex];
			cell.setSelecImg(arr2.indexOf(index)!=-1);
			cell.off(Event.CLICK,this,itemClick);
			cell.on(Event.CLICK,this,itemClick,[index]);

		}
		private function itemClick(index:int):void{
			var arr:Array=mSelectArr[mSelectIndex];
			if(arr.indexOf(index)!=-1){
				arr.splice(arr.indexOf(index),1);
			}else{
				if(arr.length<mData[1]){
					arr.push(index);
					arr.sort();
				}else{
					ViewManager.instance.showTipsTxt(Tools.getMsgById("dial_tips03",[this["btn"+mSelectIndex].label,mData[1]]));
					return;
				}
			}
			mCurSelectNum=arr.length;
			this.list1.refresh();
			getAlreadGift();
		}

		private function getAlreadGift():void{
			var arr:Array=[];
			var n:Number=0;
			for(var i:int=0;i<mSelectArr.length;i++){
				var a:Array=mSelectArr[i];
				for(var j:int=0;j<a.length;j++){
					var aa:Array=awardLib[i][2][a[j]];
					arr.push(aa);
					n+=1;
				}
			}
			while(arr.length<10){
				arr.push(null);
			}
			this.list2.array=arr;
			this.getLabel.text=n+"/10";
			this.numLabel.text=mCurSelectNum+"/"+mData[1];
			this.btn.gray=!(n==10);
		}


		public function listRender2(cell:item_treasureUI,index:int):void{
			if(list2.array[index]){
				cell.com.setData(list2.array[index][0],list2.array[index][1],-1);
				cell.com.visible=true;
			}else{
				cell.com.visible=false;
			}
			cell.boxAdd.visible=!cell.com.visible;
		}

		public function okClick():void{
			if(this.btn.gray){
				//trace("选择十个奖品");
				ViewManager.instance.showTipsTxt(Tools.getMsgById("dial_tips01"));
				return;
			}
			NetSocket.instance.send("set_dial_award",{"award_list":mSelectArr},new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				closeSelf();
			}));
		}


		public override function onRemoved():void{

		}
	}

}