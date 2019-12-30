package sg.view.map
{
	import ui.map.estateHeroUI;
	import laya.utils.Handler;
	import sg.model.ModelHero;
	import sg.manager.ModelManager;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelUser;
	import sg.cfg.ConfigServer;
	import sg.model.ModelSkill;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.utils.Tools;
	import sg.view.inside.ViewBuildingQuickly;
	import sg.model.ModelCityBuild;
	import sg.model.ModelVisit;
	import sg.model.ModelEstate;
	import sg.utils.ObjectUtil;
	import laya.utils.Timer;

	/**
	 * ...
	 * @author
	 */
	public class VIewEstateHero extends estateHeroUI{

		private var mType:int=0;//0 派出英雄   1 英雄管理
		private var work_type:int=0;//0 产业  1 拜访   2 建造
		private var estate_index:int=0;
		private var visit_obj:Object={};
		private var listData:Array=[];
		private var estate_id:String="";
		private var curIndex:int=-1;
		private var config_estate:Object={};
		private var user_estate:Array=[];
		private var cb_obj:Object={};

		private var mAllRewardObj:Object;
		private var reData:Object;


		public function VIewEstateHero(){
			this.list.scrollBar.visible=false;
			this.list.itemRender=ItemHeroEstate;
			this.list.renderHandler=new Handler(this,listRender);
			this.list.selectHandler=new Handler(this,listSelect);
			this.okBtn.on(Event.CLICK,this,btnClick);
			this.getBtn.on(Event.CLICK,this,getAllReward,[0]);
			this.getBtn.label=Tools.getMsgById("_public228");
		}

		override public function onAdded():void{
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,eventCallBack);
			mAllRewardObj={};
			reData={};
			mType=this.currArg?this.currArg[0]:0;//[mtype,estate_index,(产业or拜访)]
			work_type=this.currArg[2];
			var s:String=mType==0?Tools.getMsgById("_estate_text11"):Tools.getMsgById("_estate_text12");
			if(work_type==0){
				estate_index=this.currArg[1];
			}else if(work_type==1){
				visit_obj=this.currArg[1];
				s=mType==0?Tools.getMsgById("_visit_text07",[ModelHero.getHeroName(visit_obj.hid)]):Tools.getMsgById("_estate_text12");
			}else if(work_type==2){
				cb_obj=this.currArg[1];
			}
			//this.titleLabel.text=mType==0?Tools.getMsgById("_estate_text11"):Tools.getMsgById("_estate_text12");// "选择英雄":"英雄管理";
			
			this.comTitle.setViewTitle(s);
			
			setData();
			if(mType==0){
				itemClick(0);
			}else{
				if(this.list.array.length!=0){
					itemClick(0);
				}
			}
		}

		public function eventCallBack():void{
			//this.list.array=listData;
			//if(work_type==0){
			//	if(ModelManager.instance.modelUser.estate[estate_index]==null){
			//		return;
			//	}
			//}
			setData();
			if(list.array.length==0){
				ViewManager.instance.closePanel(this);
				return;
			}
			var n:Number=list.selectedIndex==-1?0:list.selectedIndex;
			curIndex=-1;
			itemClick(n);
		}

		public function setData():void{
			user_estate=ModelManager.instance.modelUser.estate;
			var arr:Array=[];//ModelManager.instance.modelUser.getMyEstateHeroArr();
			
			var b:Boolean=false;
			if(mType==0){
				if(work_type==0){
					var user_estate:Object=ModelManager.instance.modelUser.estate[estate_index];
					estate_id = ConfigServer.city[user_estate.city_id].estate[user_estate.estate_index][0];
					config_estate=ConfigServer.estate.estate[estate_id];
					var s:String=(config_estate.hero_debris==0)?config_estate.active_get:"hero";
					s=ModelSkill.getEstateSID(s,estate_id);
					arr=ModelManager.instance.modelUser.getMyEstateHeroArr(work_type,Number(estate_id));
				}else if(work_type==1){
					arr=ModelManager.instance.modelUser.getMyEstateHeroArr(work_type,visit_obj.hid);//名士
				}else if(work_type==2){
					arr=ModelManager.instance.modelUser.getMyEstateHeroArr(work_type);//筑造
				}
			}else if(mType==1){
				arr=ModelManager.instance.modelUser.getEstateManagerArr();
				for(var i:int=0;i<arr.length;i++){
					var o:Object=arr[i];
					if(o.estateFinish && o.sortEvent==0){
						b=true;
						break;
					}
				}
				
			}
			if(b){
				this.okBtn.centerX=-150;
				this.getBtn.visible=true;
			}else{
				this.okBtn.centerX=0;
				this.getBtn.visible=false;
			}

			listData=arr;
			//trace(arr);
			this.list.array=listData;
			
			if(mType == 1){
				timeTick();
			}
		}	

		private function timeTick():void{
			timer.once(1000,this,timeFun);
		}

		private function timeFun():void{
			list.refresh();
			timeTick();
		}


		public function listSelect(index:int):void{
			//if(index>=0){
			//	curIndex=index;
			//}
		}

		public function listRender(cell:ItemHeroEstate,index:int):void{
			
			cell.gray=false;
			cell.mouseEnabled=true;
			cell.setData(this.list.array[index],this.currArg[1],this.currArg[2]);
			cell.off(Event.CLICK,this,this.itemClick);
			cell.on(Event.CLICK,this,this.itemClick,[index,cell]);
			cell.off(Event.CLICK,this,this.itemClick2);
			cell.on(Event.CLICK,this,this.itemClick2,[index]);
			cell.setSelection(index==this.list.selectedIndex);
			var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(this.list.array[index].hid);
			if(mType==0){
				cell.bg1.visible=true;
				//cell.mouseEnabled=(hmd.getHeroEstate().status==0);
				cell.gray=!(hmd.getHeroEstate().status==0) || this.list.array[index]["sortNot"]==0;
				if(work_type==1){
					cell.setFate(hmd.id,visit_obj.hid);
					cell.set4D(hmd,visit_obj.hid);
					var b:Boolean=hmd.id==visit_obj.hid;
					cell.setMine(b);
				}
				cell.timeLabel.text = "";
			}else if(mType==1){
				cell.bg1.visible=false;
				cell.setFinish(list.array[index].estateFinish);

				var n:Number = ConfigServer.getServerTimer();
				var m:Number = this.list.array[index].endTime;
				cell.timeLabel.text = m - n > 0 ? Tools.getMsgById('sale_pay_20',[Tools.getTimeStyle(m-n)]) : "";
			}

			
		}

		public function itemClick(index:int,cell:ItemHeroEstate=null):void{

			if(curIndex==index){
					return;
			}
			if(mType==0 && cell && cell.type==1){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_tips05"));
				return;
			}else if(mType==0 && cell && cell.type==2){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_tips06"));
				return;
			}else if(mType==0 && cell && cell.type==3){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_tips07"));
				return;
			}
			this.list.selectedIndex=index;
			curIndex=index;

			if(mType==0){
				this.okBtn.setData("",Tools.getMsgById("_public183"),-1,1);//确定
			}else if(mType==1){
				if(list.array[index].estate_index!=null){
					if(ModelManager.instance.modelUser.isEstateFinish(list.array[index].estate_index)){
						this.okBtn.setData("",Tools.getMsgById("_public170"),-1,1);//完成
					}else{
						this.okBtn.setData("",Tools.getMsgById("_building21"),-1,1);//加速
					}
				}else if(list.array[index].visit_obj){
					if(ModelManager.instance.modelUser.isVisitFinish(list.array[index].visit_obj.cid)){
						this.okBtn.setData("",Tools.getMsgById("_public170"),-1,1);
					}else{
						this.okBtn.setData("",Tools.getMsgById("_building21"),-1,1);
					}
				}else if(list.array[index].cb_obj){
					if(ModelManager.instance.modelUser.isCityBuildFinish(list.array[index].cb_obj)){
						this.okBtn.setData("",Tools.getMsgById("_public170"),-1,1);
					}else{
						this.okBtn.setData("",Tools.getMsgById("_building21"),-1,1);
					}
				}	
			}
		}

		public function itemClick2(index:int):void{
			if(mType==0){
				return;
			}
			var hid:String=list.array[index].id;
			if(list.array[index].event_id!=""){
				var arr:Array;
				var work:String=ModelManager.instance.modelGame.getModelHero(list.array[index].hid).getWork();
				if(list.array[index].estate_index!=null){
					arr=[list.array[index].event_id,0,list.array[index].estate_index];
				}else if(list.array[index].visit_obj){
					arr=[list.array[index].event_id,1,list.array[index].visit_obj.cid];
				}else if(list.array[index].cb_obj){
					arr=[list.array[index].event_id,2,list.array[index].cb_obj];
				}
				ViewManager.instance.showView(["ViewEventTalk",ViewEventTalk],arr);
			}
		}

		public function btnClick():void{
			if(curIndex==-1){
				//return;
			}
			if(this.list.cells[curIndex] && (this.list.cells[curIndex] as ItemHeroEstate).gray){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("msg_VIewEstateHero_0"));
				return;
			}
			if(mType==0){
				if(this.currArg[3] && this.currArg[3]==-1){
					ModelManager.instance.modelUser.event(ModelUser.EVNET_ESTATE_HERO,[this.list.array[curIndex].hid]);
				}else{
					ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_TASK,[this.list.array[curIndex].hid,this.currArg[1],this.currArg[2]]);
				}
				ViewManager.instance.closePanel(this);
			}else if(mType==1){
				var hid:String=list.array[curIndex].id;
				if(list.array[curIndex].event_id!=""){
					itemClick2(curIndex);
					return;
				}

				if(list.array[curIndex].estateFinish){
					var socketStr:String="estate_active_harvest";
					var sendData:Object={};
					if(list.array[curIndex].estate_index!=null){
						socketStr="estate_active_harvest";
						sendData["estate_index"]=this.list.array[curIndex].estate_index;
					}else if(list.array[curIndex].visit_obj){
						socketStr="hero_city_visit_reward";
						sendData["city_id"]=this.list.array[curIndex].visit_obj.cid;
					}else if(list.array[curIndex].cb_obj){//筑造
						socketStr="city_build_reward";
						sendData["cid"]=this.list.array[curIndex].cb_obj.cid;
						sendData["bid"]=this.list.array[curIndex].cb_obj.bid;
					}
					var _this:* = this;
					NetSocket.instance.send(socketStr,sendData,new Handler(this,function(np:NetPackage):void{
						if(socketStr=="hero_city_visit_reward"){
							var model:ModelVisit=ModelManager.instance.modelGame.getModelVisit(sendData["city_id"]);
							if(model){
								model.showFinishView(np);
								ModelManager.instance.modelUser.updateData(np.receiveData);
							}
						}else{
							ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
						}
						if(socketStr=="city_build_reward"){
							ModelCityBuild.removeCityBuild(sendData["cid"],sendData["bid"]);
							ModelManager.instance.modelUser.updateData(np.receiveData);
						}else if(socketStr=="estate_active_harvest"){
							var n:Number=list.array[curIndex].estate_index;
							var user_estate:Object=ModelManager.instance.modelUser.estate[n];
							var em:ModelEstate=ModelManager.instance.modelGame.getModelEstate(user_estate.city_id,user_estate.estate_index);
							
							ModelManager.instance.modelUser.updateData(np.receiveData);
							em.event(ModelEstate.EVENT_ESTATE_UPDATE);
							em.clearEstateHero();
						}
						setData();
						
						if(list.array.length==0){
							ViewManager.instance.closePanel(_this);
						}
					}));
				}else{
					if(list.array[curIndex].estate_index!=null){
						ViewManager.instance.showView(["ViewEstateQuickly",ViewEstateQuickly],this.list.array[curIndex].estate_index);
					}else if(list.array[curIndex].visit_obj){
						ViewManager.instance.showView(["ViewVisitQuickly",ViewVisitQuickly],this.list.array[curIndex].visit_obj.cid);
					}else if(list.array[curIndex].cb_obj){
						ViewManager.instance.showView(["ViewCityBuildQuickly",ViewCityBuildQuickly],this.list.array[curIndex].cb_obj);
					}
					
				}
			}
			
		}

		/**
		 * 一键完成（没有特殊事件的完成）
		 */
		private function getAllReward(index:Number):void{
			NetSocket.instance.send("estate_build_visit_reward",{},new Handler(this,function(np:NetPackage):void{
				var clone:Object=ObjectUtil.clone(ModelManager.instance.modelUser.estate);
				ModelManager.instance.modelUser.estate=np.receiveData.user.estate;
				for(var i:int=0;i<list.array.length;i++){
					var o:Object=list.array[i];
					if(o.event_id=="" && o.estateFinish){
						if(o.estate_index!=null){
							var n:Number=list.array[i].estate_index;
							var user_estate:Object=clone[n];
							var em:ModelEstate=ModelManager.instance.modelGame.getModelEstate(user_estate.city_id,user_estate.estate_index);
							em.event(ModelEstate.EVENT_ESTATE_UPDATE);
							em.clearEstateHero();
						}else if(o.visit_obj){
							var model:ModelVisit=ModelManager.instance.modelGame.getModelVisit(o.visit_obj.cid);
							if(model) model.showFinishView(np,false);
						}else if(o.cb_obj){
							ModelCityBuild.removeCityBuild(o.cb_obj.cid,o.cb_obj.bid);
						}
					}
				}
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				setData();
			}));

			return;
			//下面的不用了
			var _index:Number=index;
			if(_index>=this.list.array.length){
				clearAllReward();
				return;
			}
			var o:Object=list.array[_index];
			if(o==null){
				clearAllReward();
				return;
			}
			var socketStr:String="";
			if(o.event_id=="" && o.estateFinish){
				var sendData:Object={};
				if(o.estate_index!=null){
					socketStr="estate_active_harvest";
					sendData["estate_index"]=o.estate_index;
				}else if(o.visit_obj){
					socketStr="hero_city_visit_reward";
					sendData["city_id"]=o.visit_obj.cid;
				}else if(o.cb_obj){
					socketStr="city_build_reward";
					sendData["cid"]=o.cb_obj.cid;
					sendData["bid"]=o.cb_obj.bid;
				}

				if(socketStr!=""){
					NetSocket.instance.send(socketStr,sendData,new Handler(this,function(np:NetPackage):void{
						if(socketStr=="hero_city_visit_reward"){
							var model:ModelVisit=ModelManager.instance.modelGame.getModelVisit(sendData["city_id"]);
							if(model){
								model.showFinishView(np,false);
							}
						}else{
							//ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
						}
						if(socketStr=="city_build_reward"){
							ModelCityBuild.removeCityBuild(sendData["cid"],sendData["bid"]);
							//ModelManager.instance.modelUser.updateData(np.receiveData);
						}else if(socketStr=="estate_active_harvest"){
							var n:Number=list.array[_index].estate_index;
							var user_estate:Object=ModelManager.instance.modelUser.estate[n];
							var em:ModelEstate=ModelManager.instance.modelGame.getModelEstate(user_estate.city_id,user_estate.estate_index);
							ModelManager.instance.modelUser.estate=np.receiveData.user.estate;
							em.event(ModelEstate.EVENT_ESTATE_UPDATE);
							em.clearEstateHero();
						}
						if(np.receiveData.gift_dict){
							var o:Object=np.receiveData.gift_dict;
							for(var s:String in o){
								if(mAllRewardObj[s]){
									mAllRewardObj[s]+=o[s];
								}else{
									mAllRewardObj[s]=o[s];
								}
							}
						}
						if(np.receiveData.user){
							var o2:Object=np.receiveData.user;
							for(var s2:String in o2){
								reData[s2]=o2[s2];
							}
						}
						getAllReward(_index+1);
					}));
				}
			}else{
				getAllReward(_index+1);
			}
			
		}

		private function clearAllReward():void{
			if(reData){
				ModelManager.instance.modelUser.updateData({"user":reData});
				reData={};
			}
			if(mAllRewardObj){
				ViewManager.instance.showRewardPanel(mAllRewardObj);
				mAllRewardObj={};
			}
			
		}


		override public function onRemoved():void{
			timer.clear(this,timeFun);
			curIndex=this.list.selectedIndex=-1;
			this.list.scrollBar.value=0;
			ModelManager.instance.modelUser.off(ModelUser.EVENT_USER_UPDATE,this,eventCallBack);
		}
	}

}
