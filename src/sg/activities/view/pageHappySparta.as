package sg.activities.view
{
	import laya.events.Event;
	import laya.ui.Button;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.manager.EffectManager;

	import sg.activities.model.ModelHappy;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelAlert;
	import sg.model.ModelGame;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.SaveLocal;
	import sg.utils.StringUtil;
	import sg.utils.Tools;

	import ui.activities.carnival.happySpartaUI;

	/**
	 * ...
	 * @author
	 */
	public class pageHappySparta extends happySpartaUI{

		private var mScore:Number=0;
		private var mIsGet:Boolean = false;
		private var mTemp:int=0;
		
		public function pageHappySparta(){
			this.text0.text=Tools.getMsgById("happy_text01");
			this.tabList.selectEnable = true;
			this.tabList.renderHandler=new Handler(this,tabListRender);
			this.tabList.selectHandler=new Handler(this,tabSelect);
			this.pan.vScrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);

			Tools.textLayout(this.text0,this.timerLabel,this.timerImg);
			setData();
			setTimerLabel();
			//this.imgBox.on(Event.CLICK, this, boxClick);
			this.comBox.on(Event.CLICK, this, this.boxClick);
			//this.comBox.on(Event.CLICK, this, this.updateBox);
		}

		public function setData():void{
			//this.imgClip.rotation=0;
			
			this.mIsGet=this.getLocalData();
			var arr:Array=[];
			for(var i:int=0;i<5;i++){
				arr.push([Tools.getMsgById("_jia0046",[StringUtil.numberToChinese(i+1)])]);
			}
			this.tabList.array=arr;
			this.tabList.selectedIndex = 0;
			
			this.updateBox();
			
			//this.imgBoxBG.visible=(ModelHappy.instance.openDays>7) && mScore>0;
			//if(this.imgBoxBG.visible){
				//setLocalData(false);
				//mIsGet=false;
			//}
			setPro();
			this.infoLabel.wordWrap=true;
			this.infoLabel.text=Tools.getMsgById(ModelHappy.instance.cfg.sparta.info);
		}
		public function updateBox():void{
			mScore = ModelHappy.instance.getSpartaScore();
			var type:int;
			if (this.mIsGet){
				type = 2;
			}
			else if (ModelHappy.instance.openDays > 7 && mScore > 0){
				type = 1;
			}
			else{
				type = 0;
			}
			//type = this.mTemp = (this.mTemp + 1) % 3;
			this.comBox.setRewardBox(type);
			
			//if (ModelHappy.instance.openDays > 7 && mScore > 0){
				////this.imgBoxBG.visible = true;
				//setLocalData(false);
				//mIsGet = false;
				//EffectManager.tweenShake(this.imgBox, {rotation:10}, 100, Ease.sineInOut, null, 300, -1, 1000);
			//}
			//else{
				//Tween.clearAll(this.imgBox);
				////this.imgBoxBG.visible = false;
			//}
			//this.imgBoxBG.visible = false;
			//this.imgGet.visible=mIsGet;
		}

		public function updateUI():void{
			mScore=ModelHappy.instance.getSpartaScore();
			this.tabList.refresh();
			this.list.refresh();
			this.updateBox();
		}

		public function setPro():void{
			var m:Number=ModelHappy.instance.cfg.sparta.big_reward_num;
			this.proLabel.text=Tools.getMsgById("happy_text04",[mScore>m?m:mScore,m]);
			this.proBar.value=mScore/m;
		}


		public function tabListRender(cell:Button,index:int):void{
			cell.label=this.tabList.array[index];
			cell.selected=(this.tabList.selectedIndex==index);
			ModelGame.redCheckOnce(cell,ModelAlert.red_happy_sparta_by_index(index+1),[cell.width-20,0]);
		}


		public function tabSelect(index:int):void{
			if(index<0){
				return;
			}
			this.list.array=ModelHappy.instance.getSpartaTaskByType(index+1);

		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(this.list.array[index]);
			cell.off(Event.CLICK,this,this.itemClick);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
			var b:Boolean=(this.tabList.selectedIndex+1)<=ModelHappy.instance.openDays;
			ModelGame.redCheckOnce(cell,b && ModelAlert.red_happy_sparta_by_key(this.list.array[index].id),[cell.width-23,3]);
		}

		public function itemClick(index:int):void{
			ViewManager.instance.showView(["ViewSparta",ViewSparta],this.list.array[index]);
		}

		public function boxClick():void{
			if(ModelHappy.instance.openDays>7){
				if(mScore==0){
					//ViewManager.instance.showTipsTxt(Tools.getMsgById("happy_tips05"));
					return;
				}
				NetSocket.instance.send("get_happy_sparta_big_reward",{},new Handler(this,function(np:NetPackage):void{
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
					ModelManager.instance.modelUser.updateData(np.receiveData);
					updateUI();
					//imgGet.visible=true;
					boxGet.visible=false;
					mIsGet=true;
					setLocalData(true);
				}));
			}else{
				//ViewManager.instance.showTipsTxt(Tools.getMsgById("happy_tips04"));
			}
		}

		public function setTimerLabel():void{
			var n:Number=ModelHappy.instance.endTime;
			if(n<=0){
				this.timerLabel.text = Tools.getMsgById("happy_text02");//"已经结束";		
				boxGet.visible=false;
				//if(mScore>0){
					//this.boxLabel.text=Tools.getMsgById("_jia0006");	
					//clipRFunc();
				//}else{
					//boxGet.visible=false;
				//}
				//return;
			}else{
				boxGet.visible=true;
				var s:String=Tools.getTimeStyle(n);
				this.timerLabel.text=s;
				this.boxLabel.text=Tools.getMsgById("happy_tips06",[s]);
			}
			//timer.once(1000,this,setTimerLabel);
		}

		//private function clipRFunc():void
        //{
			//if(mIsGet){
				//return;
			//}
			//this.imgClip.rotation+=0.2;
			//timer.frameOnce(1,this,clipRFunc);
        //}

		public function getLocalData():Boolean{
            var o:Object=SaveLocal.getValue(SaveLocal.KEY_HAPPY_SPARTA+ModelManager.instance.modelUser.mUID,true);
			if(o){
				return o.isGet;
			}else{
				return false;
			}
            
        }

        public function setLocalData(b:Boolean):void{
            var o:Object={"isGet":b};
            SaveLocal.save(SaveLocal.KEY_HAPPY_SPARTA+ModelManager.instance.modelUser.mUID,o,true);
            
        }
	}

}

import sg.utils.Tools;

import ui.activities.carnival.item_SpartaUI;

class Item extends item_SpartaUI{
	public function Item(){

	}

	public function setData(obj:Object):void{
		this.titleLabel.text=Tools.getMsgById(obj.title);
		this.infoLabel.text=Tools.getMsgById(obj.info);
		this.heroCom.setHeroIcon(obj.hero);
	}
}