package sg.view.hero
{
	import ui.hero.heroSuperInfoUI;
	import ui.bag.bagItemUI;
	import laya.utils.Handler;
	import sg.activities.model.ModelRoolPay;
	import sg.model.ModelHero;
	import sg.cfg.ConfigServer;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelTalent;
	import sg.manager.ModelManager;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.boundFor.GotoManager;
	import sg.model.ModelUser;
	import sg.utils.Tools;
	import sg.model.ModelSkill;
	import sg.manager.LoadeManager;
	import sg.manager.AssetsManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewSuperHeroInfo extends heroSuperInfoUI{

		public var mModel:ModelRoolPay;
		public var hmd:ModelHero;
		private var isCanGet:Boolean=false;
		public function ViewSuperHeroInfo(){
			// this.tTitle.text=Tools.getMsgById("_hero30");//"传奇降临";
			this.text0.text=Tools.getMsgById("_hero24");//"天赋";
			this.text2.text=Tools.getMsgById("happy_text03");//"进度";
			this.text3.text=Tools.getMsgById("_public94",[""]);
			this.list.renderHandler=new Handler(this,listRender);
			
			this.comTalent.on(Event.CLICK,this,function():void{
				ViewManager.instance.showView(ConfigClass.VIEW_HERO_TALENT_INFO,hmd);
			});

			this.btn.on(Event.CLICK,this,btnClick);

			Tools.textLayout(this.text2,this.tPro,this.imgText,this.textBox);
			this.textBox.centerX = 0;

			Tools.textLayout(this.text3,this.tTime,this.textImg3,this.bTimer);

		}


		override public function onAdded():void{
			LoadeManager.loadTemp(this.tempImg,AssetsManager.getAssetsAD("actPay1_15.png"));
			ModelManager.instance.modelUser.on(ModelUser.EVENT_PAY_SUCCESS,this,eventCallBack);
			ModelManager.instance.modelUser.on(ModelUser.EVENT_IS_NEW_DAY,this,newDayCallBack);
			mModel=ModelRoolPay.instance;
			if(mModel.active==false){
				this.closeSelf();
				return;
			}
			var obj:Object=mModel.cfgGoods;
			this.comHero.setHeroIcon(obj.hero,false);
			this.boxTalent.visible=this.boxSkill.visible=this.boxImg.visible=false;
			var n:Number=0;
			if(ConfigServer.hero[obj.hero]){
				hmd=new ModelHero(true);
				hmd.initData(obj.hero,ConfigServer.hero[obj.hero]);

				this.imgRa.skin=this.hmd.getRaritySkin();
				var mt:ModelTalent = ModelTalent.getModel(this.hmd.id);
				if(mt){
					this.comTalent.setTalentIcon(this.hmd.id);
					this.boxTalent.visible=true;
					n+=1;
				}else{
					this.boxTalent.visible=false;
				}
			}

			if(obj.show_skill && !Tools.isNullString(obj.show_skill)){
				this.boxSkill.visible=true;
				var smd:ModelSkill = ModelManager.instance.modelGame.getModelSkill(obj.show_skill);
				this.text1.text=smd.getName();
				this.comSkill.setData(smd.id,-1,-1);
				n+=1;
			}else{
				this.boxSkill.visible=false;
			}

				
			this.boxImg.y=103;
			this.boxImg.width=220;
			if(n==0){
				//this.boxImg.visible=false;
			}else if(n==1){
				this.boxImg.visible=true;
				this.boxSkill.y=24;
				this.boxImg.width=110;
				this.boxImg.y=68;
			}else if(n==2){
				this.boxImg.visible=true;
				this.boxSkill.y=120;
			}

			

			
			this.text4.text="";
			updateUI();
			this.tTime.text="";
			updateTime();
		}

		private function eventCallBack():void{
			updateUI();
		}

		private function newDayCallBack():void{
			this.closeSelf();
		}

		private function updateUI():void{			
			var m:Number=ModelManager.instance.modelUser.records.rool_pay[3];
			var n:Number=Math.floor(m/mModel.cfgGoods.pay_money);
			
			this.preLabel.text=mModel.cfgGoods.pay_money+"0";
			this.tNum.text=(n-mModel.getNum)+"";
			this.tPro.text=(m*10-n*mModel.cfgGoods.pay_money*10)+"/"+mModel.cfgGoods.pay_money*10;
			this.pro.value=(m-n*mModel.cfgGoods.pay_money)/mModel.cfgGoods.pay_money;

			isCanGet=(n-mModel.getNum>0);
			
			this.imgText.width=this.tPro.width+12;
			this.tPro.x=this.imgText.x+6;
			this.textBox.centerX=0;

			this.btn.label=isCanGet?Tools.getMsgById("_public138"):Tools.getMsgById("_public104");
			if(mModel.cfgReward){
				var arr:Array=ModelManager.instance.modelProp.getRewardProp(mModel.cfgReward);
				this.list.repeatX=arr.length;
				this.list.array=arr;
				this.list.centerX=0;
			}
		}

		private function updateTime():void{
			if(mModel.lastTime<=0){
				this.closeSelf();
			}else{
				this.tTime.text=Tools.getTimeStyle(mModel.lastTime);
				//大于一百天 则不显示时间了
				this.bTimer.visible=(mModel.lastTime<=100*Tools.oneDayMilli);
			}
			timer.once(1000,this,updateTime);
		}

		private function btnClick():void{
			if(isCanGet){
				NetSocket.instance.send("get_rool_pay_reward",{},new Handler(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
					updateUI();
				}));
			}else{
				GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
			}
			
			
		}

		private function listRender(cell:bagItemUI,index:int):void{
			var arr:Array=this.list.array[index];
			cell.setData(arr[0],arr[1],-1);
		}



		override public function onRemoved():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_PAY_SUCCESS,this,eventCallBack);
			ModelManager.instance.modelUser.off(ModelUser.EVENT_IS_NEW_DAY,this,newDayCallBack);
		}
	}

}