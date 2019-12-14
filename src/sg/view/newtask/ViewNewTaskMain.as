package sg.view.newtask
{
	import ui.newTask.newtask_mainUI;
	import ui.newTask.item_newtaskUI;
	import laya.utils.Handler;
	import laya.events.Event;
	import sg.manager.EffectManager;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import sg.model.ModelGame;
	import sg.scene.view.MapCamera;
	import sg.map.model.MapModel;
	import sg.model.ModelNewTask;
	import sg.cfg.ConfigServer;
	import sg.boundFor.GotoManager;

	/**
	 * ...
	 * 朝廷密旨
	 * @author
	 */
	public class ViewNewTaskMain extends newtask_mainUI{

		private var mData:Array;

		public function ViewNewTaskMain(){
			this.comTitle.setViewTitle(Tools.getMsgById('new_task_text0'));// '朝廷密旨');
			
			this.text0.text = Tools.getMsgById('new_task_text3');//'今日密旨已完成';

			this.list.scrollBar.visible = false;
			this.list.renderHandler = new Handler(this,listRender);

			this.btn.on(Event.CLICK,this,btnClick);
		}

		override public function onAdded():void{
			this.comHero.setHeroIcon(ConfigServer.new_task.hero_icon,false);
			//新的一天刷新任务列表
			//ModelManager.instance.modelUser.on(ModelUser.EVENT_IS_NEW_DAY,this,eventCallBack);
			ModelManager.instance.modelGame.on(ModelNewTask.EVENT_NEW_TASK_UPDATE,this,eventCallBack1);
			//服务器推送的
			ModelManager.instance.modelGame.on(ModelGame.EVENT_NEW_TASK_PUSH,this,eventCallBack1);

			ModelManager.instance.modelNewTask.on(ModelNewTask.EVENT_TALK_TYPE_CHANGE,this,changeTalk);
			this.boxTips.visible = false;
			this.textInfo.text = '';
			setData();
			setTalkType();
			changeTalk();
		}

		// private function eventCallBack():void{
		// 	NetSocket.instance.send('get_task',{},new Handler(this,function(np:NetPackage):void{
		// 		ModelManager.instance.modelUser.updateData(np.receiveData);
		// 		setData();
		// 		ModelManager.instance.modelGame.event(ModelNewTask.EVENT_NEW_TASK_UPDATE);
		// 	}));
		// }

		private function eventCallBack1():void{
			setData();
			setTalkType();
		}

		private function changeTalk():void{
			var n:Number = ModelManager.instance.modelNewTask.talkType;
			if(n>=0){
				var nn:Number = Tools.getRandom(0,2);
				var s:String = ConfigServer.new_task.hero_talk[n][nn];
			}
			this.textInfo.text = Tools.getMsgById(s);
		}

		private function setData():void{
			mData = ModelManager.instance.modelNewTask.getTaskData();
			this.list.array = mData;
			boxTips.visible = this.list.array.length == 0;
			this.btn.label = Tools.getMsgById(this.list.array.length == 0 ? '_public183' : 'new_task_text5');
		}

		private function listRender(cell:item_newtaskUI,index:int):void{
			var o:Object = this.list.array[index];
			cell.iconImg.skin = AssetsManager.getAssetLater(o.icon+'.png');
			EffectManager.changeSprColor(cell.iconBg,o.rarity); 
			cell.tName.text = o.name;
			cell.text0.text = Tools.getMsgById('_public206');// '奖励';

			cell.award0.off(Event.CLICK,this,rewardClick);
			cell.award1.off(Event.CLICK,this,rewardClick);

			var arr:Array = ModelManager.instance.modelProp.getRewardProp(o.reward);
			if(arr.length > 0){
				cell.award0.setData(AssetsManager.getAssetItemOrPayByID(arr[0][0]),arr[0][1]);
				cell.award1.setData(AssetsManager.getAssetItemOrPayByID(arr[1][0]),arr[1][1]);
				cell.award0.on(Event.CLICK,this,rewardClick,[arr[0][0]]);
				cell.award1.on(Event.CLICK,this,rewardClick,[arr[1][0]]);
			}

			cell.tInfo.style.fontSize = 18;
			cell.tInfo.style.leading = 4;
			cell.tInfo.style.color = '#abc9ff';
			
			cell.tInfo.innerHTML = o.info;
			
			var b:Boolean = o.finish;
			var s1:String = Tools.getMsgById('_jia0035');// '领取';
			cell.btnOk.label = s1;
			Tools.textFitFontSize(cell.btnOk, s2, 0);

			var s2:String = Tools.getMsgById('new_task_text1');//'打点使者';
			cell.btnNo.label = s2;
			Tools.textFitFontSize(cell.btnNo, s2, 0);

			cell.btnNo.visible = !b;
			cell.btnOk.visible = b;
			if(o.get){
				cell.btnOk.visible = cell.btnNo.visible = false;
			}

			cell.btnOk.off(Event.CLICK,this,itemClick,[index]);
			cell.btnOk.on(Event.CLICK,this,itemClick,[index]);

			cell.btnNo.off(Event.CLICK,this,itemClick,[index]);
			cell.btnNo.on(Event.CLICK,this,itemClick,[index]);
		}

		private function itemClick(index:int):void{
			var o:Object = this.list.array[index];
			if(o.finish){
				NetSocket.instance.send('get_new_task_reward',{task_id:o.id},new Handler(this,function(np1:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np1.receiveData);
					ViewManager.instance.showRewardPanel(np1.receiveData.gift_dict);
					setData();
					ModelManager.instance.modelGame.event(ModelNewTask.EVENT_NEW_TASK_UPDATE);
					setTalkType(3);
					if(list.array.length == 0){
						closeSelf();
					}
				}));
			}else{
				var n:Number = o.fast_finish;//需要的元宝数
				if(!Tools.isCanBuy('coin',n)){
					return;
				}
				ViewManager.instance.showAlert(Tools.getMsgById('new_task_text2'),function(index:int):void{
					if(index == 0){
						NetSocket.instance.send('fast_done_new_task',{task_id:o.id},new Handler(null,function(np2:NetPackage):void{
							ModelManager.instance.modelUser.updateData(np2.receiveData);
							ViewManager.instance.showTipsTxt(Tools.getMsgById('new_task_text4'));
							setData();
							setTalkType(2);
						}));
					}
				},['coin',n]);
			}
		}

		private function rewardClick(id:String):void{
			ViewManager.instance.showItemTips(id);
		}

		private function btnClick():void{
			if(this.list.array.length == 0){
				//this.closeSelf();
			}else{
				var troops:Object = ModelManager.instance.modelTroopManager.troops;
				var n:Number = 0;
				//前往首都或者战力第一的英雄的城市
				var cid:int = MapModel.instance.getCapital(ModelManager.instance.modelUser.country).cityId;
				for(var s:String in troops){
					var m:Number = ModelManager.instance.modelGame.getModelHero(troops[s].hero).getPower(); 
					if(m>n){
						n = m;
						cid = troops[s].entityCity.cityId;
					} 
				}
				GotoManager.instance.boundForMap(cid);
			}
			this.closeSelf();
			ViewManager.instance.closeScenes(true);
		}


		private function setTalkType(n:int = 0):void{
			//0 初始化状态  1 可领奖  2 使用打点之后  3 领奖后  4 无任务时
			if(n == 2){
				ModelManager.instance.modelNewTask.talkType = 2;
				return;
			}
			if(n == 3){
				ModelManager.instance.modelNewTask.talkType = 3;
				return;
			}
			var arr:Array = this.list.array;
			if(arr.length == 0){
				ModelManager.instance.modelNewTask.talkType = 4;
				return;
			}
			var len:int = arr.length;
			var num:int = 0;
			for(var i:int=0;i<arr.length;i++){
				var o:Object = arr[i];
				if(o.finish == true){
					ModelManager.instance.modelNewTask.talkType = 1;
					return;
				}
				if(o.pro == 0){
					num+=1;
				}
			}
			if(num == len){
				ModelManager.instance.modelNewTask.talkType = 0;
			}

		}


		override public function onRemoved():void{
			//ModelManager.instance.modelUser.off(ModelUser.EVENT_IS_NEW_DAY,this,eventCallBack);
			ModelManager.instance.modelGame.off(ModelNewTask.EVENT_NEW_TASK_UPDATE,this,eventCallBack1);
			ModelManager.instance.modelGame.off(ModelGame.EVENT_NEW_TASK_PUSH,this,eventCallBack1);
			ModelManager.instance.modelNewTask.off(ModelNewTask.EVENT_TALK_TYPE_CHANGE,this,changeTalk);
		}
	}

}