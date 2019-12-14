package sg.view.inside
{
	import laya.particle.Particle2D;
	import ui.inside.starGetUI;
	import sg.cfg.ConfigServer;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import laya.events.Event;
	import sg.manager.AssetsManager;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import sg.utils.MusicManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewStarGet extends starGetUI{
		private var configData:Object=[];
		private var userData:Object={}; 
		public var price1:Array=[];
		public var price2:Array=[];
		public var ani:Animation;
		private var mParticle:Particle2D;
		private var useTimes:Number;
		private var reData:*;
		private var mIsPlaying:Boolean;
		public function ViewStarGet(){
			configData=ConfigServer.system_simple["star_price"];
			this.btnCheck.on(Event.CLICK,this,this.onClick,[this.btnCheck]);
			this.btnInfo.on(Event.CLICK,this,this.onClick,[this.btnInfo]);
			this.btnOne.on(Event.CLICK,this,this.onClick,[this.btnOne]);
			this.btnTen.on(Event.CLICK,this,this.onClick,[this.btnTen]);
			//this.text0.text=Tools.getMsgById("540159");
			this.comTitle.setViewTitle(Tools.getMsgById("540159"));
		}
		

		override public function onAdded():void{
			mIsPlaying=false;
			this.textLabel00.text=this.textLabel00.text=Tools.getMsgById("_star_text01");
			this.textLabel11.text=this.textLabel00.text=Tools.getMsgById("_star_text01");
			this.textLabel0.text=Tools.getMsgById("_star_text02");
			this.textLabel1.text=Tools.getMsgById("_star_text03");
			//this.text0.text=Tools.getMsgById("540159");
			this.text1.text=Tools.getMsgById("_star_text04");
			this.btnCheck.label=Tools.getMsgById("_star_text05");

			if(!this.ani){
				this.ani = EffectManager.loadAnimation("look_star", "stand");
				this.box.addChild(this.ani);
				
				this.mParticle = EffectManager.loadParticle("p005", 30, 600, ViewManager.instance.mLayerEffect, true, 320, this.stage.height * 0.4);
			}
			this.img.visible = false;
			this.mParticle.visible = true;
			this.mParticle.play();
			
			this.ani.pos(this.img.x+this.img.width/2,this.img.y+this.img.height/2);
			this.box.setChildIndex(ani,1);
			
			this.com0.setData(AssetsManager.getAssetItemOrPayByID("gold"),configData[2]);
			this.com1.setData(AssetsManager.getAssetItemOrPayByID("gold"),configData[3]);
			setData();	
		}

		public function setData():void{
			userData=ModelManager.instance.modelUser.star_records;
			price1=ModelManager.instance.modelProp.isHaveItemProp(configData[5],1)?[configData[5],1]:["coin",configData[0]];
			price2=ModelManager.instance.modelProp.isHaveItemProp(configData[5],10)?[configData[5],10]:["coin",configData[1]];
			this.btnOne.setData(AssetsManager.getAssetItemOrPayByID(price1[0]),price1[1]);
			this.btnTen.setData(AssetsManager.getAssetItemOrPayByID(price2[0]),price2[1]);
			//this.limitLabel.text="今日限购次数: "+(configData[4]-userData.get_times)+"/"+configData[4];
			this.text1.text=Tools.getMsgById("_public62");//"今日限购次数：";
			useTimes=Tools.isNewDay(userData.get_time)?0:userData.get_times;
			this.text2.text=(configData[4]-useTimes)+"/"+configData[4];
			// this.img0.width=this.text2.width+20;
			// this.img0.x=this.text1.width;
			// this.text2.x=(this.img0.width-this.text2.width)/2+this.img0.x;
			
			Tools.textLayout(this.text1,this.text2,this.img0,this.boxText);
			this.boxText.centerX = 0;
		}

		public function onClick(obj:*):void{
			
			switch(obj)
			{
				case this.btnCheck:
					var arr:Array = ConfigServer.system_simple['show_chance_'+ModelManager.instance.modelUser.mergeNum];
					ViewManager.instance.showView(ConfigClass.VIEW_SHOW_PROBABILITY,
							['540163', arr, true]);
					break;
				case this.btnInfo:
					
					break;
				case this.btnOne:
					getStar(1);
					break;
				case this.btnTen:
					getStar(10);
					break;
			
				default:
					break;
			}
		}

		public function getStar(n:int):void{
			if(configData[4]<useTimes+n){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_star_text06"));
				return;
			}
			var pri:Array=(n==1)?price1:price2;
			if(!Tools.isCanBuy(pri[0],pri[1])){
				return;
			}
			if(mIsPlaying){
				aniCallBack();
				return;
			}
			var sendData:Object={};
			sendData["random_num"]=n;
			MusicManager.playSoundUI(MusicManager.SOUND_GET_STAR);
			NetSocket.instance.send("get_random_star",sendData,Handler.create(this,this.socketCallBack));
		}

		public function socketCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			//
			ModelManager.instance.modelInside.getBuildingModel("building006").updateStatus();
			//
			this.ani.play(0,false,"start");
			//this.mouseEnabled=false;
			mIsPlaying=true;
			reData=np.receiveData;
			this.ani.on(Event.COMPLETE,this,aniCallBack);
			setData();
		}

		private function aniCallBack():void{
			//this.mouseEnabled=true;	
			this.ani.play(0,true,"stand");		
			mIsPlaying=false;	
			ViewManager.instance.showRewardPanel(reData.gift_dict);
			reData=null;
			this.ani.off(Event.COMPLETE,this,aniCallBack);
		}

		override public function onRemoved():void{
			this.mouseEnabled = true;
			if(this.mParticle){
				this.mParticle.visible = false;
				this.mParticle.stop();
			}
			if(this.ani){
				this.ani.play(0,true,"stand");
				if(reData){
					ViewManager.instance.showRewardPanel(reData.gift_dict);
					reData=null;
				}
				this.ani.off(Event.COMPLETE,this,aniCallBack);
			}
		}
	}

}