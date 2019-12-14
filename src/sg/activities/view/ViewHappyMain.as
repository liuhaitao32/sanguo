package sg.activities.view
{
	import laya.ui.Box;
	import laya.utils.Handler;

	import sg.activities.model.ModelHappy;
	import sg.manager.ModelManager;
	import sg.model.ModelAlert;
	import sg.model.ModelGame;
	import sg.model.ModelUser;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.Tools;
	import sg.view.com.ItemBase;

	import ui.activities.activitiesSceneUI;

	/**
	 * ...
	 * @author
	 */
	public class ViewHappyMain extends activitiesSceneUI{

		private var mBox:Box;
        private var mFuncPanel:ItemBase;
		private var mKey:String="";
		private var mDoubleTime:Number;
		public function ViewHappyMain(){
			this.tabList.itemRender = IconBase;
            this.tabList.scrollBar.hide = true;
            this.tabList.renderHandler = new Handler(this, this.tabListRender);
			this.tabList.selectEnable = true;
            this.tabList.selectHandler = new Handler(this, this.tabSelect);
			this.tabList.scrollBar.touchScrollEnable=false;
			this.mBox = new Box();
            this.box.addChild(this.mBox);
            this.tabList.zOrder = this.mBox.zOrder + 1;
			
		}

		
		public override function onAdded():void{
			ModelManager.instance.modelUser.on(ModelUser.EVENT_PAY_SUCCESS,this,eventCallBack,[1]);
			ModelManager.instance.modelUser.on(ModelUser.EVENT_IS_NEW_DAY,this,eventCallBack,[0]);
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,updateTab);
			ModelHappy.instance.on(ModelHappy.EVENT_UPDATE_SPARTA,this,updateSparta);			
			this.setTitle(Tools.getMsgById("happy_buy_name"));
			mKey=this.currArg?this.currArg:"";
			getTabData();
			mDoubleTime=ModelHappy.instance.getDoubleTime();
			timeTick();
		}

		public function updateTab(re:Object):void{
			if(re.hasOwnProperty("user") && re.user.hasOwnProperty("records")){
				updateSparta();
			}
		}

		public function eventCallBack(index:int):void{
			if(index==0){
				trace("新的一天 调用get_happy_login");
				NetSocket.instance.send("get_happy_login",{},new Handler(this,function(np:NetPackage):void{					
					ModelManager.instance.modelUser.updateData(np.receiveData);
					updateUI();
				}));
			}else{
				updateUI();
			}
			
		}

		public function updateUI():void{
			this.tabList.refresh();
			var key:String = this.tabList.array[this.tabList.selectedIndex][0];
			switch(key){
				case "login":
					(this.mFuncPanel as pageHappyLogin).updateUI();
					break;
				case "sparta":
					(this.mFuncPanel as pageHappySparta).updateUI();
					break;
				case "purchase":
					(this.mFuncPanel as pageHappyPurchase).updateUI();
					break;
				case "addup":
					(this.mFuncPanel as pageHappyAddup).updateUI();
					break;
				case "once":
					(this.mFuncPanel as pageHappyOnce).updateUI();
					break;
			}
		}

		public function updateSparta():void{
			this.tabList.refresh();
			var key:String = this.tabList.array[this.tabList.selectedIndex][0];
			switch(key){
				case "sparta":
					(this.mFuncPanel as pageHappySparta).updateUI();
					break;
			}
		}



		public function getTabData():void{
			var arr:Array=ModelHappy.instance.tabData;
			var data:Array=[];
			var b:Boolean = ModelManager.instance.modelUser.canPay;
			
			for(var i:int=0;i<arr.length;i++){
				if(ModelHappy.instance.cfg.hasOwnProperty(arr[i])){
					if(b == false && (arr[i] == 'purchase' || arr[i] == 'addup' || arr[i] == 'once')){
						trace('happy hide ',arr[i]);
					}else{
						data.push([arr[i],ModelHappy.instance.cfg[arr[i]].title,ModelHappy.instance.cfg[arr[i]].icon]);
					}
					
					
				}
			}
			this.tabList.array=data;
			this.tabList.selectedIndex=-1;
			this.tabList.selectedIndex=mKey==""?0:(arr.indexOf(mKey)!=-1?arr.indexOf(mKey):0);
			
		}

		public function tabListRender(item:IconBase, index:int):void{
			var data:Array = this.tabList.array[index];
            item.setData({id: data[2], name: Tools.getMsgById(data[1])});
			item.setSelcetion(this.tabList.selectedIndex === index);
			item.setTimeLabel(data[0]=="addup" ? mDoubleTime : 0);
			ModelGame.redCheckOnce(item, ModelAlert.red_happy_by_key(data[0]),[item.width-25,0]);


		}

		public function tabSelect(index:int):void{
			if (index === -1 || this.tabList.length === 0)   return;
			var cell:IconBase = this.tabList.getCell(index) as IconBase;
            cell.setSelcetion(true);
			this.clearFuncPanel();
			this.mBox.x = 0;
            this.mBox.y = this.tabList.y + this.tabList.height;
			var key:String = this.tabList.array[index][0];
			switch(key){
				case "login":
					this.mFuncPanel = new pageHappyLogin() as ItemBase;
					break;
				case "sparta":
					this.mFuncPanel = new pageHappySparta() as ItemBase;
					break;
				case "purchase":
					this.mFuncPanel = new pageHappyPurchase() as ItemBase;
					break;
				case "addup":
					this.mFuncPanel = new pageHappyAddup() as ItemBase;
					break;
				case "once":
					this.mFuncPanel = new pageHappyOnce() as ItemBase;
					break;
			}
		    if(this.mFuncPanel){
                this.mBox.addChildren(this.mFuncPanel);
            }
			
		}
		
		private function clearFuncPanel():void{
            this.mBox.destroyChildren();
            this.mFuncPanel = null;
        }


		private function timeTick():void{
			if(mDoubleTime>0){
				mDoubleTime-=1000;
				this.tabList.refresh();
			}else{
				this.tabList.refresh();
				return;
			}
			Laya.timer.once(1000,this,timeTick);
		}


		public override function onRemoved():void{
			clearFuncPanel();
			ModelManager.instance.modelUser.off(ModelUser.EVENT_PAY_SUCCESS,this,eventCallBack);
			ModelManager.instance.modelUser.off(ModelUser.EVENT_IS_NEW_DAY,this,eventCallBack);
			ModelManager.instance.modelUser.off(ModelUser.EVENT_USER_UPDATE,this,updateTab);
			ModelHappy.instance.off(ModelHappy.EVENT_UPDATE_SPARTA,this,updateSparta);
			this.tabList.selectedIndex=-1;
		}
	}

}

import ui.shop.shop_icon_textUI;
import sg.utils.Tools;

class IconBase extends shop_icon_textUI{
	public function IconBase(){
		this.box1.visible=false;
	}

	public function setData(obj:*):void{
		this.img0.skin="ui/"+obj.id+".png";
		this.label0.text=this.label1.text= obj.name;
	}	

	public function setSelcetion(b:Boolean):void{
		this.box1.visible=b;
		this.label0.visible=!b;
	}

	public function setTimeLabel(n:Number):void{
		this.boxTime.visible=(n>0);
		if(n>0) this.tTime.text=Tools.getMsgById("happy_text09",[Tools.getTimeStyle(n)]);
	}
}