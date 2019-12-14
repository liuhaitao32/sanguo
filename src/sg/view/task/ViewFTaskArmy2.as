package sg.view.task
{
	import laya.ui.Box;
	import sg.map.utils.TestUtils;
	import sg.model.ModelPrepare;
	import ui.map.alien_mainUI;
	//import ui.task.ftask_army2UI;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import ui.bag.bagItemUI;
	import sg.model.ModelItem;
	import laya.utils.Handler;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.model.ModelGame;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.utils.Tools;
	import sg.model.ModelCityBuild;
	import sg.cfg.ConfigColor;
	import sg.model.ModelUser;

	/**
	 * 民情叛军
	 * @author
	 */
	public class ViewFTaskArmy2 extends alien_mainUI{

		private var config_city_item:Object={};
		private var config_ftask:Object={};
		private var user_ftask:Object={};
		
		private var mCityId:String="";
		private var mTaskId:String="";
		private var degree_str_arr:Array=[Tools.getMsgById("alien_easy"),Tools.getMsgById("alien_normal"),Tools.getMsgById("alien_trouble")];
		private var v:*;
		private var powerValue:int;
		
		public function ViewFTaskArmy2(){
			this.list.scrollBar.hide = true;
			//this.list.itemRender=bagItemUI;
			this.list.renderHandler=new Handler(this,listRender);
			this.btn.on(Event.CLICK, this, this.btnClick);
			this.btn.label = Tools.getMsgById("_country8");
		}

		public override function onAdded():void{
			config_ftask=ConfigServer.ftask;
			mCityId=this.currArg[0];
			v=this.currArg[1];
			config_city_item=ConfigServer.city[mCityId];
			user_ftask=ModelManager.instance.modelUser.ftask;
			mTaskId = ConfigServer.city[this.mCityId].pctask_id[ModelUser.getCountryID()][user_ftask[mCityId][0]];
			setUI();
		}

		public function setData():void{


			
		}

		public function setUI():void{
			this.tLvName.text = Tools.getMsgById("_public188");
			this.tArmyName.text = Tools.getMsgById("_public189");
			this.tPowerName.text = Tools.getMsgById("_public187");
			this.tRewardTitle.text = Tools.getMsgById("_public190");
			this.tRewardInfo.text = '';
			this.tName.text = Tools.getMsgById("pctask_npc_name04");
			this.tArmy.text = '1/1';
			
			var arr:Array = config_city_item.rebel_army[ModelUser.getCountryID()];
			var lv:int = arr[1];
			this.tLv.text = lv + "";
			//弃用配置的战力，使用国战计算战力
			this.powerValue = ModelPrepare.getNPCPower(ConfigServer.ftask.people_condition_robotrange, lv, ConfigServer.ftask.people_enemy_power);
			var powerStr:String = this.powerValue +'';
			//if (TestUtils.isTestShow){
				//powerStr += ' 原:' + arr[3];
			//}
			this.comPower.setNum(powerStr);
			//this.tPower.text = powerStr;
			this.tType.text=degree_str_arr[Number(arr[0])];
			this.tType.color=ConfigColor.FONT_COLORS_BY_DIFF[Number(arr[0])];
			this.heroIcon.setHeroIcon( config_ftask.people_task[mTaskId].task_armyheroshow[ModelUser.getCountryID()]);
			//this.tTitle.text=Tools.getMsgById("pctask_ui_name",[ModelCityBuild.getCityName(this.mCityId+"")]);
			var s:String = Tools.getMsgById("pctask_ui_name",[ModelCityBuild.getCityName(this.mCityId+"")]);
			this.comTitle.setViewTitle(s);

			var list_data:Array=ModelManager.instance.modelProp.getRewardProp( config_ftask.rebel_army_rew[arr[0]]);
			
			this.list.repeatX = list_data.length > 5 ? 5 : list_data.length;
            this.list.array = list_data;
            this.list.centerX = 0;

		}

		public function listRender(box:Box,index:int):void{
			var it:Array=this.list.array[index];			
			var item:bagItemUI = box.getChildByName('item') as bagItemUI;
			item.setData(it[0],it[1]);
		}


		public function btnClick():void{
			var sendData:Object={};
			sendData["city_id"]=this.mCityId+"";
			//sendData["hid"]="hero701";
			sendData["fight"]=0;
			sendData["v"]=v;
            //NetSocket.instance.send("do_ftask",sendData,Handler.create(this,function(np:NetPackage):void{
				ModelManager.instance.modelGame.checkTroopToAction(mCityId,["ViewFtaskHeroSend",ViewFtaskHeroSend],sendData,true,0,-this.powerValue);
			//}));
			
			//ViewManager.instance.showView(["ViewFtaskHeroSend",ViewFtaskHeroSend],[mCityId,ModelManager.instance.modelTroopManager.getMoveCityTroop(Number(mCityId))]);
		}


		public override function onRemoved():void{

		}
	}

}