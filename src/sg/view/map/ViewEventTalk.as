package sg.view.map
{
	import ui.map.eventTalkUI;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.manager.AssetsManager;
	import laya.events.Event;
	import sg.model.ModelEstate;
	import sg.model.ModelVisit;
	import sg.model.ModelCityBuild;
	import sg.manager.LoadeManager;
	import sg.model.ModelUser;

	/**
	 * ...
	 * @author
	 */
	public class ViewEventTalk extends eventTalkUI{
		

		private var work_type:int=0;
		private var eventId:String="";
		private var config_event:Object={};
		private var talk_arr1:Array=[];
		private var talk_arr2:Array=[];
		private var other_data:*;
		private var click_count:Number=0;
		private var select_index:int=0;
		private var isGetReward:Boolean=false;
		public function ViewEventTalk(){
			this.isAutoClose=false;
			this.btn0.on(Event.CLICK,this,this.btnClick2,[1]);
			this.btn1.on(Event.CLICK,this,this.btnClick2,[2]);
			this.btn2.on(Event.CLICK,this,this.btnClick);
		}

		override public function onAdded():void{
			eventId=this.currArg[0];
			work_type=this.currArg[1];
			other_data=this.currArg[2];
			isGetReward=this.currArg[3]?this.currArg[3]:0;

			config_event=ConfigServer.estate.events[eventId];	
			talk_arr2=[];
			if(config_event.talk is String){
					talk_arr1=[config_event.talk];
			}else if(config_event.talk is Array){
				talk_arr1=config_event.talk;
			}
			select_index=click_count=0;
			this.btn2.visible=true;
			this.btnBox.visible=false;
			LoadeManager.loadTemp(this.imgBG,AssetsManager.getAssetsAD(ConfigServer.estate.events[eventId].bgp));
			setUI();
		}


		public function setUI(type:int=0):void{
			var hid:String="";
			if(work_type==0){
				hid=ModelManager.instance.modelUser.estate[other_data].active_hid;
			}else if(work_type==1){
				hid=ModelManager.instance.modelUser.visit[other_data][0];
				//if(click_count%2==0){
				//	hid=ModelManager.instance.modelUser.visit[other_data][1];
				//}
			}else if(work_type==2){
				hid=ModelManager.instance.modelUser.city_build[other_data.cid][other_data.bid][0];
			}
			//this.img0.skin=AssetsManager.getAssetsHero(hid,true);
			this.img0.setHeroIcon(hid,true,-1,true,true);
			this.label0.text=(type==0)?Tools.getMsgById(talk_arr1[click_count]):Tools.getMsgById(talk_arr2[0]);
			if(click_count+1==talk_arr1.length){
				if(config_event.reward.length==0){
					this.btnBox.visible=true;
					this.btn2.visible=false;
					this.btn0.label=Tools.getMsgById(config_event.cae1[0]);
					this.btn1.label=Tools.getMsgById(config_event.cae2[0]);	
				}else{
					
				}
			}

		}

		public function btnClick():void{
			if(click_count+1==talk_arr1.length+talk_arr2.length){
				if(config_event.reward.length==0){
					socket_func("cae"+select_index);
				}else{
					socket_func("reward");
				}				
				return;
			}
			click_count+=1;
			setUI();
		}

		public function btnClick2(index:int):void{
			//if(index==1){
			//	ViewManager.instance.closePanel(this);
			//	return;
			//}
			select_index=index;
			talk_arr2=[config_event["cae"+index][1]];
			setUI(1);
			this.btn2.visible=true;
			this.btnBox.visible=false;
			click_count+=1;
			//socket_func("cae"+index);
		}


		public function socket_func(key:String):void{
			var str:String="";
			var sendData:Object={};
			if( work_type==0){
				str="estate_event_reward";
				sendData["estate_index"]=other_data;
			}else if(work_type==1){
				str="visit_event_reward";
				sendData["city_id"]=other_data;
			}else if(work_type==2){
				str="city_build_event_reward";
				sendData["cid"]=other_data["cid"];
				sendData["bid"]=other_data["bid"];
			}
			sendData["event_key"]=key;
			NetSocket.instance.send(str,sendData,new Handler(this,socket_call_back));
		}

		public function socket_call_back(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);

			if(isGetReward){
				
			}else{
				if(work_type==0){
					var user_estate:Object=ModelManager.instance.modelUser.estate[other_data];
					ModelManager.instance.modelGame.getModelEstate(user_estate.city_id,user_estate.estate_index).event(ModelEstate.EVENT_ESTATE_UPDATE);
				}else if(work_type==1){
					ModelVisit.updateData(other_data);
				}else if(work_type==2){
					ModelCityBuild.updateCityBuild(other_data.cid,other_data.bid);
				}
				ViewManager.instance.closePanel(this);
			}
			
			ViewManager.instance.showRewardPanel(np.receiveData.gift_dict,function():void{
				if(isGetReward){
					autoGetReward();
				}
			});
			
		}

		public function autoGetReward():void{
			var str:String="";
			var sendData:Object={};
			if(work_type==2){
				str="city_build_reward";
				sendData["cid"]=other_data["cid"];
				sendData["bid"]=other_data["bid"];
			}
			NetSocket.instance.send(str,sendData,new Handler(this,socket_call_back2));
			ViewManager.instance.closePanel(this);
		}

		public function socket_call_back2(np:NetPackage):void{
			if(work_type==2){
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				ModelManager.instance.modelUser.event(ModelUser.EVENT_CITY_BUILD_MAIN);
			}
			
		}

		override public function onRemoved():void{

		}
	}

}