package sg.view.task
{
	import sg.fight.FightMain;
	import sg.fight.logic.utils.FightUtils;
	import sg.manager.EffectManager;
	import ui.task.ftask_mainUI;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.model.ModelUser;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.model.ModelGame;
	import sg.model.ModelItem;
	import sg.model.ModelFTask;
	import sg.scene.view.MapCamera;
	import sg.manager.AssetsManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewFTaskMain extends ftask_mainUI{

		private var mCityId:String="";
		private var user_ftask_item:Object={};
		private var config_city_item:Object={};
		private var config_ftask:Object={};
		private var is_get:Boolean=false;
		private var is_done:Boolean=false;
		private var curTid:String="";//当前任务id
		private var curTtype:String="";//当前任务类型
		private var need_num:Number=0;
		private var mTroops:Array=[];
		private var ftaskModel:ModelFTask;
		public function ViewFTaskMain(){
			ModelManager.instance.modelGame.on(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE,this,this.event_hero_troop_edit_ui_change);
			this.btn0.on(Event.CLICK,this,this.btnClick,[0]);
			this.btn1.on(Event.CLICK,this,this.btnClick,[1]);
			this.btn2.on(Event.CLICK,this,this.btnClick,[2]);
			this.text0.text=Tools.getMsgById("_public113");
			Tools.textLayout2(text0,img0,290,230);
		}
	
		public override function onAdded():void{
			
			this.btn0.label=Tools.getMsgById("_ftask_text05");

			mCityId=this.currArg;
			ftaskModel=ModelManager.instance.modelGame.getModelFtask(mCityId);
			config_city_item=ConfigServer.city[mCityId];
			config_ftask=ConfigServer.ftask;

			setData();
			setBtn();
			var arr:Array=config_ftask.people_task[curTid].pctask_rew;
			var it:ModelItem=ModelManager.instance.modelProp.getItemProp(arr[0]);
			this.comItem.setData(it.id,arr[1],-1);
		}

		public function event_hero_troop_edit_ui_change():void{
			getTroops();
		}

		public function setData():void{
			user_ftask_item=ModelManager.instance.modelUser.ftask[mCityId];
			curTid=config_city_item.pctask_id[ModelUser.getCountryID()][user_ftask_item[0]];
			curTtype=config_ftask.people_task[curTid].type;
			is_get=user_ftask_item[1]==1;
			is_done=user_ftask_item[2]==1;
			var cname:String=Tools.getMsgById(config_city_item.name);
			//this.titleLabel.text=Tools.getMsgById("_ftask_text06",[cname]);// cname+"民情";
			this.comTitle.setViewTitle(Tools.getMsgById("_ftask_text06",[cname]));
			var n:Number=0;
			if(curTtype=="2"){
				need_num=config_ftask.people_task[curTid].need[1];
				n=is_done?need_num:0;
				this.infoLabel.text=Tools.getMsgById(config_ftask.people_task[curTid].info,[cname,need_num,n,need_num]);
			}else{
				n=is_done?1:0;
				this.infoLabel.text=Tools.getMsgById(config_ftask.people_task[curTid].info,[cname,n]);
			}
			
		}

		public function getTroops():void{
			mTroops=ModelManager.instance.modelTroopManager.getMoveCityTroop(Number(mCityId));
		}

		public function setBtn():void{
			
			this.btn0.visible=this.btn1.visible=this.btn2.visible=false;
			if(is_get){

				if(curTtype=="2"){
					this.btn2.label=Tools.getMsgById("_ftask_text01");//"捐赠";
				}else{
					this.btn2.label=Tools.getMsgById("_ftask_text02");//"前往";
				}

				if(is_done){
					this.btn1.visible=true;
					this.btn1.label=Tools.getMsgById("_ftask_text04");//"不负所托";
				}else{
					this.btn0.visible=this.btn2.visible=true;
				}
			}else{
				this.btn1.visible=true;
				this.btn1.label=Tools.getMsgById("_ftask_text03");//"欣然接受";
			}
		}

		public function btnClick(index:int):void{
			switch(index){
				case 0://放弃
					giveUpTask();
				break;
				case 1://领取 or 提交
					if(is_get){
						if(is_done){
							submitTask();
						}
					}else{
						getTask();
					}
				break;
				case 2://前往 or 捐赠
					doTask();
				break;
			}
		}


		public function getTask():void{
			NetSocket.instance.send("receive_ftask",{"city_id":mCityId,"do":1},new Handler(this,function(np:NetPackage):void{
				if(np.receiveData){
					user_ftask_item[1]=1;
					is_get=true;
					ftaskModel.event(ModelFTask.EVENT_UPDATE_FTASK);/////////////
					setBtn();
					
				}
			}));
		}

		public function giveUpTask():void{
			NetSocket.instance.send("receive_ftask",{"city_id":mCityId,"do":"0"},new Handler(this,function(np:NetPackage):void{
				if(np.receiveData){
					user_ftask_item[1]=0;
					ViewManager.instance.closePanel(this);
					ftaskModel.event(ModelFTask.EVENT_UPDATE_FTASK);/////////////
				}
			}));
		}

		public function submitTask():void{
			NetSocket.instance.send("get_ftask_reward",{"city_id":mCityId},new Handler(this,function(np:NetPackage):void{
				if(np.receiveData){
					var re:*=np.receiveData;
					ModelManager.instance.modelUser.updateData(re);
					var fun:*=null;
					
					if(ModelManager.instance.modelUser.ftask[mCityId]){
						ViewManager.instance.closePanel();
						fun=function():void{
							if(ModelManager.instance.modelUser.isFinishFtask(mCityId)){
								ViewManager.instance.showView(["ViewFTaskOpen",ViewFTaskOpen],[mCityId,re.total_gift_dict]);
								ModelManager.instance.modelGame.removeFtask(mCityId);//完成民情之后移除这个model
							}
						};
					}else{
						setData();
					}
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict,fun);
					//ModelManager.instance.modelUser.event(ModelUser.EVENT_FTASK_UPDATE);
					ViewManager.instance.closePanel(this);
					ftaskModel.event(ModelFTask.EVENT_UPDATE_FTASK);/////////////
				}
			}));
		}

		public function doTask():void{
			if(!is_get){
				// trace("还没领取任务");
				return;
			}
			
			//trace("=================================do_ftask");
			
			
			if(curTtype=="2"){
					var need_arr:Array=config_ftask.people_task[curTid].need;
					if(!Tools.isCanBuy(need_arr[0],need_arr[1])){
						return;
					}
			}else if(curTtype=="1"){
				//ViewManager.instance.showView(["ViewFTaskArmy2",ViewFTaskArmy2],[mCityId]);
				this.closeSelf();
				MapCamera.lookAtFtask(Number(mCityId),500);
				return;
			}else if(curTtype=="0"){
				this.closeSelf();
				MapCamera.lookAtFtask(Number(mCityId),500);
				//NetSocket.instance.send("do_ftask", {"city_id":mCityId,"fight":0}, new Handler(this, function(np:NetPackage):void{
				//	ViewManager.instance.showView(["ViewFTaskArmy1",ViewFTaskArmy1],[mCityId,mTroops,np.receiveData.team[1].troop[0]]);	
				//}));
				return;
			}
			var sendData:Object={};
			sendData["city_id"]=mCityId;
			NetSocket.instance.send("do_ftask", sendData, new Handler(this, function(np:NetPackage):void{

				if(curTtype == "2"){
					var need_item:String=config_ftask.people_task[curTid].need[0];
					var a:Array=ViewManager.instance.pos_dict_pos[need_item];
					EffectManager.createIconFlight(AssetsManager.getAssetItemOrPayByID(need_item),a[0],a[1],Laya.stage.width/2,Laya.stage.height/2,1,20);
				}
				
				
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ftaskModel.event(ModelFTask.EVENT_UPDATE_FTASK);/////////////
				setData();
				setBtn();
				
			}));
		}


		public override function onRemoved():void{


		}
	
	
	
	}



}