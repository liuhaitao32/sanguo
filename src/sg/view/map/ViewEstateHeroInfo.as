package sg.view.map
{
	import sg.model.ModelHero;
	import ui.map.estateHeroInfoUI;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelUser;
	import laya.events.Event;
	import sg.model.ModelMapHero;
	import sg.model.ModelCityBuild;

	/**
	 * ...
	 * @author
	 */
	public class ViewEstateHeroInfo extends estateHeroInfoUI{

		private var work_type:int=0;// 产业  拜访  建造
		private var city_id:String="";
		private var other_para:*;//0:estate_index   1:{cid}   2:{cid,bid}
		private var hmd:ModelHero;
		private var user_data:*;
		private var max_time:Number=0;
		private var cur_time:Number=0;
		private var reduce_rate:Number=1;//科技、爵位 减少时间的百分比
		private var mapHero:ModelMapHero;
		public function ViewEstateHeroInfo(){
			
			this.btn.on(Event.CLICK,this,this.btnClick);
		}

		public override function onAdded():void{
			this.text0.text=Tools.getMsgById("_hero14");
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,eventCallBack);
			work_type=this.currArg[0];
			city_id=this.currArg[1];
			other_para=this.currArg[2];
			mapHero=new ModelMapHero(work_type,other_para);
			var hid:String="";
			if(work_type==0){
				user_data=ModelManager.instance.modelUser.estate;
				var estate_id:String=ConfigServer.city[user_data[other_para].city_id].estate[user_data[other_para].estate_index][0];
				max_time=ConfigServer.estate.estate[estate_id].active_time*Tools.oneMinuteMilli;
				cur_time=Tools.getTimeStamp(user_data[other_para].active_harvest_time);
				hid=user_data[other_para].active_hid;
			}else if(work_type==1){
				user_data=ModelManager.instance.modelUser.visit;
				max_time=ConfigServer.visit.visit_time * Tools.oneMinuteMilli;
				cur_time=Tools.getTimeStamp(user_data[city_id][2]);
				hid=user_data[city_id][0];
			}else if(work_type==2){
				user_data=ModelManager.instance.modelUser.city_build;
				var gear:Number=user_data[city_id][other_para.bid][3];
				//max_time=ConfigServer.city_build.gear[gear][0]*ConfigServer.city_build.time * 1000;
				max_time=gear*ConfigServer.city_build.time * 1000;
				cur_time=Tools.getTimeStamp(user_data[city_id][other_para.bid][1]);
				hid=user_data[city_id][other_para.bid][0];
			}
			cur_time-=ConfigServer.getServerTimer();
			max_time*=reduce_rate;
			hmd=ModelManager.instance.modelGame.getModelHero(hid);
			setData();
		}

		public function eventCallBack():void{
			if(work_type==0){
				if(user_data[other_para]){
					user_data=ModelManager.instance.modelUser.estate;
					cur_time=Tools.getTimeStamp(user_data[other_para].active_harvest_time);
				}
			}else if(work_type==1){
				user_data=ModelManager.instance.modelUser.visit;
				cur_time=Tools.getTimeStamp(user_data[city_id][2]);
			}else if(work_type==2){
				if(ModelManager.instance.modelUser.city_build[city_id][other_para.bid]){
					user_data=ModelManager.instance.modelUser.city_build;
					cur_time=Tools.getTimeStamp(user_data[city_id][other_para.bid][1]);
				}
			}
			cur_time-=ConfigServer.getServerTimer();
			setTimeUI();
		}


		public function setData():void{
			this.comTitle.setViewTitle(hmd.getName());
			//this.titleLabel.text=hmd.getName();
			this.nameLabel.text=hmd.getName();
			//this.typeCom.setHeroType(hmd.getType());
			this.comPower.setNum(hmd.getPower(hmd.getPrepare()));
			//this.atkLabel.text=hmd.getPower(hmd.getPrepare())+"";
			this.lvLabel.text=hmd.getLv()+"";
			this.comHero.setHeroIcon(hmd.getHeadId(),true,hmd.getStar());
			this.btn.setData("",Tools.getMsgById("_building21"),-1,1);
			//this.infoLabel.text= ModelCityBuild.getCityName(city_id)+"-"+mapHero.getWorkName()+"中";
			this.infoLabel.text = Tools.getMsgById("_estate_text16",[ModelCityBuild.getCityName(city_id)+"-"+mapHero.getWorkName()]);
			this.imgType.skin=mapHero.getRidURL();
			
			setTimeUI();
			timer.loop(1000,this,setTimeUI);
		}

		public function setTimeUI():void{
			this.timePro.value=(max_time-cur_time)/max_time;
			this.timeLabel.text=Tools.getTimeStyle(cur_time);
			cur_time-=1000;
			if(cur_time<=0){
				this.closeSelf();
			}
		}

		public function btnClick():void{
			if(work_type==0){
				ViewManager.instance.showView(["ViewEstateQuickly",ViewEstateQuickly],other_para);
			}else if(work_type==1){
				ViewManager.instance.showView(["ViewVisitQuickly",ViewVisitQuickly],city_id);
			}else if(work_type==2){
				ViewManager.instance.showView(["ViewCityBuildQuickly",ViewCityBuildQuickly],other_para);
			}
		}




		public override function onRemoved():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_USER_UPDATE,this,eventCallBack);
			timer.clear(this,setTimeUI);
		}


	}

}