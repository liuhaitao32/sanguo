package sg.view.inside
{
	import ui.inside.pveInfoUI;
	import laya.events.Event;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.manager.ModelManager;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.model.ModelUser;
	import ui.bag.bagItemUI;
	import sg.model.ModelItem;
	import laya.ui.Box;
	import laya.ui.Image;
	import sg.model.ModelGame;
	import sg.model.ModelScience;
	import sg.manager.AssetsManager;
	import sg.festival.model.ModelFestival;

	/**
	 * ...
	 * @author
	 */
	public class ViewPVEInfo extends pveInfoUI{

		public var configData:Object={};
		public var battleName:String="";
		public var chapterName:String="";

		public var listData:Array=[];
		public var star_arr:Array;
		public var user_pve_cpt:Object={};
		private var color_arr:Array=["#a2f08a","#ffdf6f"];
		private var text_arr:Array=[];
		private var mIsCanRepeat:Boolean=false;
		public function ViewPVEInfo(){
			this.btn0.on(Event.CLICK,this,this.startClick);
			this.btn1.on(Event.CLICK,this,this.againClick);
			this.btn2.on(Event.CLICK,this,this.startClick);
			this.list.scrollBar.visible=false;
			//this.list.itemRender=bagItemUI;
			this.list.renderHandler=new Handler(this,this.listRender);
			this.text1.text = Tools.getMsgById('193000');
			this.text2.text = Tools.getMsgById('193001');
			this.text3.text = Tools.getMsgById('193002');
			
			this.btn0.label=Tools.getMsgById("_pve_text03");
			this.btn1.label=Tools.getMsgById("_pve_text04");
			this.btn2.label=Tools.getMsgById("_pve_text03");
			this.text4.text=Tools.getMsgById("_pve_text05");
		}

	    public function setData():void{//第几章   第几关
			text_arr=[this.text1,this.text2,this.text3];
			user_pve_cpt=ModelManager.instance.modelUser.pve_records.chapter;
			chapterName=this.currArg[0]<9?"0"+(this.currArg[0]+1):this.currArg[0]+1+"";
			chapterName="chapter0"+chapterName;			
			battleName=ConfigServer.pve.chapter[chapterName]["contain_battle"][this.currArg[1]]+"";
			configData=ConfigServer.pve.battle[battleName];
			star_arr=[0,0,0];	
			mIsCanRepeat=false;		
			if(configData.battle_type==0){
				//this.btn0.centerX=0;
				//this.btn1.visible=false;
				this.btn0.visible=this.btn1.visible=false;
				this.btn2.visible=true;				
			}else{
				if(user_pve_cpt[chapterName]){
					var o:Object=user_pve_cpt[chapterName];
					if(o.star[battleName]){
						star_arr=o.star[battleName];
					}
				}
				
				if(star_arr.indexOf(1)!=-1){
					this.btn0.visible=this.btn1.visible=true;
					this.btn2.visible=false;
					mIsCanRepeat=true;
				}else{
					this.btn0.visible=this.btn1.visible=false;
					this.btn2.visible=true;
				}
				
				//this.btn0.centerX=NaN;
				//this.btn0.x=121;
				//this.btn1.visible=true;
			}
			//this.titleLabel.text=Tools.getMsgById(battleName);// Tools.getNameByID(battleName);
			this.comTitle.setViewTitle(Tools.getMsgById(battleName));
			getListData();
			setStar();
		}

		public function getListData():void{
			listData=[];
			listData=ModelManager.instance.modelProp.getRewardProp(configData.reward);
			
			var fest:Array=ModelFestival.getRewardInterfaceByKey("pve");
			if(fest.length!=0)
				listData.unshift(fest);
			this.list.repeatX=listData.length>5 ? 5 : listData.length;
			this.list.centerX=0;
			this.list.array=listData;
		}

		public function listRender(cell:bagItemUI,index:int):void{
			var itemModel:Array=this.list.array[index];
			var n:Number=ModelScience.func_sum_type("pve_get");
			if(ModelManager.instance.modelProp.getItemProp(itemModel[0]).type==3){
				n = n==0 ? itemModel[1] : Math.floor(itemModel[1]*(1+n));
			}else{
				n=itemModel[1];
			}
			//cell.setData(itemModel.icon,itemModel.ratity,itemModel.name,n+"");
			cell.setData(itemModel[0],n);
		}

		override public function onAdded():void{
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,eventCallBack);
			setData();
		}

		private function eventCallBack(re:Object):void{
			if(re && re.pve_records){
				setData();
			}
		}

		public function startClick():void{
			var is_new:Boolean=true;
			var o:Object=ModelManager.instance.modelUser.pve_records.chapter;
			if(o.hasOwnProperty(chapterName)){
				if(o[chapterName].star.hasOwnProperty(battleName)){
					is_new=false;
				}
			}
			if(is_new){
				ViewManager.instance.showView(["ViewPVEDeploy",ViewPVEDeploy],[battleName,mIsCanRepeat]);	
				return;
			}
			if(Tools.isNewDay(ModelManager.instance.modelUser.pve_records.combat_time)){
				//ViewManager.instance.showView([ConfigClass.VIEW_PVE_READY],[battleName]);
				ViewManager.instance.showView(["ViewPVEDeploy",ViewPVEDeploy],[battleName,mIsCanRepeat]);	
				return;
			}
			var curTimes:Number=ModelManager.instance.modelUser.pve_records.combat_times;
			if(curTimes>0){
				//ViewManager.instance.showView(ConfigClass.VIEW_PVE_READY,[battleName]);
				ViewManager.instance.showView(["ViewPVEDeploy",ViewPVEDeploy],[battleName,mIsCanRepeat]);
			}else{
				var arr:Array=ModelManager.instance.modelUser.pveBuyArr();
				if(arr[1]==0){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_pve_tips12"));//次数不足
				}else{
					ViewManager.instance.showBuyTimes(2,arr[0],arr[1],arr[2]);
				}
				
			}
			
		}

		public function setStar():void{
			for(var i:int=0;i<3;i++){
				var box:Box=this.all.getChildByName("star"+i) as Box;
				var _img0:Image=box.getChildByName("img0") as Image;
				var _img1:Image=box.getChildByName("img1") as Image;
				var _img2:Image=box.getChildByName("img2") as Image;
				_img1.visible=_img2.visible=false;
				if(star_arr[i]==1){
					_img0.skin=AssetsManager.getAssetsUI("icon_64.png");
					_img1.visible=true;	
					this.text_arr[i].color=color_arr[0];
				}else{
					_img0.skin=AssetsManager.getAssetsUI("icon_64_0.png");
					_img2.visible=true;
					this.text_arr[i].color=color_arr[1];
				}
			}
		}

		public function againClick():void{
			var o:Object=ModelManager.instance.modelUser.pve_records.chapter;
			if(o.hasOwnProperty(chapterName)){
				var oo:Object=o[chapterName]["star"];
				if(!oo.hasOwnProperty(battleName)){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_building35"));//请先通关
					return;
				}
			}else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_building35"));//请先通关
				return;
			}
			if(Tools.isNewDay(ModelManager.instance.modelUser.pve_records.combat_time)){
				againFun();
				return;
			}
			var curTimes:Number=ModelManager.instance.modelUser.pve_records.combat_times;
			if(curTimes>0){
				againFun();
			}else{
				var arr:Array=ModelManager.instance.modelUser.pveBuyArr();
				if(arr[1]==0){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_pve_tips12"));//次数不足
				}else{
					ViewManager.instance.showBuyTimes(2,arr[0],arr[1],arr[2]);
				}
			}
		}
		public function againFun():void{
			var sendData:Object={};
			sendData["battle_id"]=battleName;
			sendData["repeat"]=1;
			NetSocket.instance.send("pve_combat",sendData,Handler.create(this,againCallBack));
		}
		/*
		public function startCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ModelManager.instance.modelUser.event(ModelUser.EVENT_PVE_UPDATE);
			if(np.receiveData.combat_result){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_building36"));//赢了
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			}else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_building37"));//输了  请重新打
			}
		}*/

		public function againCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			ModelManager.instance.modelGame.event(ModelGame.EVENT_PK_TIMES_CHANGE);
		}

		override public function onRemoved():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_USER_UPDATE,this,eventCallBack);
		}
	}

}