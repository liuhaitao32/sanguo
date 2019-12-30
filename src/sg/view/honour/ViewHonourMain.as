package sg.view.honour
{
	import ui.honour.honourMainUI;
	import laya.events.Event;
	import laya.utils.Handler;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigColor;
	import sg.cfg.ConfigClass;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.model.ModelHonour;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import ui.honour.heroHonourUI;
	import sg.model.ModelHero;

	/**
	 * ...
	 * @author
	 */
	public class ViewHonourMain extends honourMainUI{

		private var mRankData:Array;
		private var mModel:ModelHonour;
		private var mCfg:Object;
		private var heroList:Array;

		private var mTime:Number;//倒计时的数

		public function ViewHonourMain(){
			this.btnChallenge.on(Event.CLICK,this,this.btnClick,[btnChallenge]);
			this.btnHistory.on(Event.CLICK,this,this.btnClick,[btnHistory]);
			this.btnRank.on(Event.CLICK,this,this.btnClick,[btnRank]);

			this.tTips.text = "获得战功提升战绩等级，可在国战中获得属性加成";
			this.text0.text = "总等级战绩";
			this.btnRank.label = "查看排名";

			this.list.renderHandler = new Handler(this,listRender);
			this.list.scrollBar.visible = false;
		}

		override public function onAdded():void{
			mRankData = this.currArg;
			mModel = ModelHonour.instance;
			mCfg = ConfigServer.honour;

			var n:Number = mRankData[1].rank ? mRankData[1].rank : 0;
			var cfgNum:Number = mCfg.honour_rank;
			this.tRank.text = n<=cfgNum ? "当前排名："+ n : "大于"+cfgNum+"名";
			this.tLv.text = mModel.totalLv + '';

			heroList = mModel.getHeroList();
			this.list.array = heroList;

			this.tTime.text = '';
			setTime();
			
		}

		private function setTime():void{
			switch(mModel.mStatus){//-1未开启   0即将开启   1赛季中   2赛季休息日
				case 0:
					mTime = mModel.mStartTime;
					break;
				case 1:					
					mTime = mModel.mOverTime;
					break;
				case 2:
					mTime = mModel.mNextStartTime;
					break;
			}
			timeFun();
			timer.loop(1000,this,timeFun);
		}

		private function timeFun():void{
			
			var n:Number = mTime - ConfigServer.getServerTimer();
			switch(mModel.mStatus){//-1未开启   0即将开启   1赛季中   2赛季休息日
				case -1:
					this.tTime.text = '赛季即将开始';
					break;
				case 0:
					this.tTime.text = n>0 ? '距离首赛季开始:'+Tools.getTimeStyle(n) : '';
					break;
				case 1:
					this.tTime.text = n>0 ? '距离赛季结束:'+Tools.getTimeStyle(n) : '';
					break;
				case 2:
					this.tTime.text = n>0 ? '距离新赛季开始:'+Tools.getTimeStyle(n) : '';
					break;
			}
		}

		private function btnClick(obj:*):void{
			switch(obj){
				case this.btnChallenge:
					ViewManager.instance.showView(ConfigClass.VIEW_HONOUR_CHALLENGE);
					break;
				case this.btnHistory:
					ViewManager.instance.showView(ConfigClass.VIEW_HONOUR_HISTROY);
					break;
				case this.btnRank:
					ViewManager.instance.showView(ConfigClass.VIEW_HONOUR_RANK,mRankData);
					// NetSocket.instance.send("get_honour_history_reward",{"history_index":0},new Handler(this,function(np:NetPackage):void{
					// 	ModelManager.instance.modelUser.updateData(np.receiveData);
					// 	ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
					// }));
					break;
			}
		}

		private function listRender(cell:heroHonourUI,index:int):void{
			var o:Object = this.list.array[index];
			var hmd:ModelHero = ModelManager.instance.modelGame.getModelHero(o.id);
			cell.comHero.setHeroIcon(hmd.getHeadId(),true,hmd.getStarGradeColor());
			cell.comLv.setHonourLv(o.lv);

			cell.comHero.on(Event.CLICK,this,itemClick);
			cell.comHero.off(Event.CLICK,this,itemClick,[index]);
		}

		private function itemClick(index:int):void{
			ViewManager.instance.showView(ConfigClass.VIEW_HERO_INFO,this.list.array[index].id);
        }


		override public function onRemoved():void{
			timer.clear(this,timeFun);
		}

		
	}

}