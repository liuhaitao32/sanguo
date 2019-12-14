package sg.view.country
{
	import ui.country.country_bag_mainUI;
	import laya.events.Event;
	import sg.model.ModelOfficial;
	import laya.utils.Handler;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import sg.utils.Tools;
	import sg.model.ModelUser;
	import sg.manager.AssetsManager;
	import sg.net.NetSocket;
	import sg.manager.ModelManager;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import laya.html.dom.HTMLDivElement;
	import ui.com.hero_icon1UI;
	import sg.model.ModelClub;
	import sg.manager.EffectManager;
	import sg.cfg.ConfigServer;
	import ui.com.comCountryOfficialUI;
	import laya.utils.Ease;
	import laya.utils.Tween;
	import laya.display.Animation;

	/**
	 * ...
	 * @author
	 */
	public class CountryBagMain extends country_bag_mainUI{
		private var mCountryData:Object;
		private var mStoreBudget:Array = [];
		private var mIsCanGet:Boolean=false;
		private var mBoxLv:Number=0;
		private var ani1:Animation;
		private var ani2:Animation;
		public function CountryBagMain(){
			this.on(Event.REMOVED,this,this.onRemove);		
			ModelManager.instance.modelClub.on(ModelClub.EVENT_COUNTRY_REDBAG,this,redbagCallBack);
			this.list1.scrollBar.hide=true;
			this.list1.renderHandler=new Handler(this,listRender1);
			this.list1.scrollBar.visible = false;

			this.btnGet.on(Event.CLICK, this, getClick);	
			this.comBox.on(Event.CLICK,this,boxClick);
			this.init();
			this.text0.text=Tools.getMsgById("_country56");
			this.text1.text=Tools.getMsgById("_country57");

			this.title0.text = Tools.getMsgById("_country76");
			this.title1.text = Tools.getMsgById("_country77");
			this.title2.text = Tools.getMsgById("_country78");

			this.btnAsk0.on(Event.CLICK,this,askClick,[0]);
			this.btnAsk1.on(Event.CLICK,this,askClick,[1]);
			this.btnAsk2.on(Event.CLICK,this,askClick,[2]);

			Tools.textLayout2(title0,imgTitle0,360,180);
			Tools.textLayout2(title1,imgTitle1,360,180);
			Tools.textLayout2(title2,imgTitle2,360,180);
		}

		

		private function redbagCallBack():void{
			setBox1();
			 this.bagList.refresh();
		}

		public function getClick():void{
			if(!mIsCanGet){
				return;
			}
			NetSocket.instance.send("get_club_redbag_reward",{},Handler.create(this,function(np:NetPackage):void{
                ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				ModelManager.instance.modelClub.event(ModelClub.EVENT_COUNTRY_REDBAG);
			}));
		}

		private function init():void{
			
			setBox1();
			setBox2();
			setBag();
		}

		private function setBox1():void{
			var n:Number=ModelManager.instance.modelClub.redbag_num-ModelManager.instance.modelClub.u_redbag_num;
			mIsCanGet=n>0;
			this.btnGet.gray = !mIsCanGet;
			//n = Math.floor(Math.pow(9,Math.random() * 6));
			var btnGetText:String = Tools.getMsgById("_jia0036") + "(" + (n < 0?0:n) + ")";
			//this.btnGet.label = Tools.getMsgById("_jia0036") + "(" + (n < 0?0:n) + ")";
			//this.btnGet.label = 'Alles erhalten' + "(" + (n < 0?0:n) + ")";
			Tools.textFitFontSize(this.btnGet, btnGetText, 0);

			var arr:Array=[];
			var temp:Array=ModelManager.instance.modelClub.redbag.concat();
			//temp.reverse();
			for(var i:int=temp.length-1;i>=0;i--){
				var a:Array=temp[i];//[uid,name,head,time,num]
				var nn:Number=a[4];//>=50 ? 50 : a[4];
				for(var j:int=0;j<nn;j++){
					arr.push(a);
					if(arr.length>=50){
						break;
					}
				}
				if(arr.length>=50){
					break;
				}
			}
			this.list1.array=arr;
			this.list1.scrollBar.value=0;
		}

		private function listRender1(cell:Box,index:int):void{
			var a:Array=this.list1.array[index];//[uid,uname,head,time,num]
			var html:HTMLDivElement=cell.getChildByName("html") as HTMLDivElement;
			html.style.color="#FFFFFF";
			html.style.fontSize=20;
			html.style.leading=0;
			html.height=html.contextHeight;
			html.style.wordWrap=false;
			html.y=(cell.height-html.height)/2;
			html.innerHTML=Tools.getMsgById("_guild_text24",[a[1]]);
			
			var com:hero_icon1UI=cell.getChildByName("comHead") as hero_icon1UI;
			com.setHeroIcon(ModelUser.getUserHead(a[2]));

			var comOfficer:comCountryOfficialUI=cell.getChildByName("comOfficer") as comCountryOfficialUI;
			var n:Number=ModelOfficial.getUserOfficer(a[0]);
			if(n>=0){
				comOfficer.visible = true;
				comOfficer.setOfficialIcon(n,ModelOfficial.getInvade(ModelManager.instance.modelUser.country), ModelManager.instance.modelUser.country);
				html.x = comOfficer.x + comOfficer.width;
			}else{
				comOfficer.visible = false;
				html.x = comOfficer.x;
			}
		}


		private function setBox2():void{
			(this.taskBox0.getChildByName("task_title") as Label).text=Tools.getMsgById("_country52");
			(this.taskBox1.getChildByName("task_title") as Label).text=Tools.getMsgById("_country53");
			(this.taskBox2.getChildByName("task_title") as Label).text=Tools.getMsgById("_country54");

			var model:ModelUser=ModelManager.instance.modelUser;
			var b:Boolean=model.quota_gift==null && !ModelUser.isNewYear() && isSendGift();
			(this.taskBox0.getChildByName("task_num") as Label).text=b ? "0" : model.year_kill_num+"";
			(this.taskBox1.getChildByName("task_num") as Label).text=b ? "0" : model.year_dead_num+"";
			(this.taskBox2.getChildByName("task_num") as Label).text=b ? "0" : model.year_build+"";

			var parameter:Array=ConfigServer.country.warehouse.quota.parameter;
			var cake:Array=ConfigServer.country.warehouse.quota.cake;
			var n:Number=b ? 0 : parameter[0]*model.year_kill_num + parameter[1]*model.year_dead_num + parameter[2]*model.year_build;
			var nn:Number=0;
			for(var i:int=0;i<cake.length;i++){
				var nnn:Number=cake[i][0];
				if(n>=nnn){
					nn=cake[i][1];
				}
			}
			
			if(nn<=1){
				this.boxLabel.text="";
				this.numImg.visible=false;
			}else{
				this.boxLabel.text=Tools.getMsgById("_country55",[nn]);
				this.numImg.visible=true;
				EffectManager.changeSprColor(this.numImg,nn-1>5?5:nn-1);
			}
			mBoxLv = nn>6 ? 6 : nn;
			setGiftBox();
		}

		private function boxClick():void{
			if(ModelManager.instance.modelUser.quota_gift){
				NetSocket.instance.send("del_quota_gift",{},Handler.create(this,function(np:NetPackage):void{
                    ModelManager.instance.modelUser.updateData(np.receiveData);
                    ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
					ModelManager.instance.modelClub.event(ModelClub.EVENT_COUNTRY_REDBAG);
					setBox2();//setGiftBox();
				}));
			}
		}

		private function setGiftBox():void{
			//this.comBox.setRewardBox(ModelManager.instance.modelUser.quota_gift==null?0:1,"icon_countrybox_0"+(mBoxLv+1)+".png");
			
			var box:Box = comBox.getChildByName("box") as Box;
			if(ani1){
				ani1=EffectManager.loadAnimation("glow048","",0,ani1);
			}else{
				ani1=EffectManager.loadAnimation("glow048","",0);
				box.addChild(ani1);
				//ani1.zOrder=-1;
				ani1.x=box.width/2;
				ani1.y=box.height/3;
			}

			if(ani2){
				ani2=EffectManager.loadAnimation("glow049","",0,ani2);
			}else{
				ani2=EffectManager.loadAnimation("glow049","",0);
				box.addChild(ani2);
				ani2.zOrder=-1;
				ani2.x=box.width/2;
				ani2.y=box.height/2;
			}
			ani1.visible=ani2.visible=false;
			var canImg:Image = box.getChildByName("canImg") as Image;//可领奖
			var boxImg:Image = box.getChildByName("boxImg") as Image;//宝箱图片
			var bgImg:Image = box.getChildByName("bgImg") as Image;//宝箱描边
			var n:Number=mBoxLv+1;
			n=n>7 ? 7 : n;
			boxImg.skin=AssetsManager.getAssetLater("icon_countrybox_0"+n+".png");
			if(mBoxLv>=2){
				bgImg.visible=false;
				ani1.visible=true;
			}
			box.rotation = 0;	
			box.scale(1,1);
			Tween.clearAll(box);
			var quota:Object=ModelManager.instance.modelUser.quota_gift;
			if(quota!=null){
				EffectManager.tweenLoop(box, {scaleX:1.15, scaleY:1.15}, 300, Ease.sineInOut, null, 50, -1, 600);
				EffectManager.tweenShake(box, {rotation:5}, 100, Ease.sineInOut, null, 650, -1, 900);
				EffectManager.startFrameRotate(canImg, 0.2);
				//canImg.visible=true;	
				ani2.visible=true;
				if(quota.v && quota.v>=1){
					var nn:Number=quota.v+1;
					nn=nn>7 ? 7 : nn;
					boxImg.skin=AssetsManager.getAssetLater("icon_countrybox_0"+nn+".png");

					if(quota.v<=1){
						this.boxLabel.text="";
						this.numImg.visible=false;
					}else{
						this.boxLabel.text=Tools.getMsgById("_country55",[quota.v]);
						this.numImg.visible=true;
						EffectManager.changeSprColor(this.numImg,quota.v-1>5?5:quota.v-1);
					}
				}
			}else{
				canImg.visible=false;
			}
		}

		private function setBag():void{
			this.mCountryData = ModelOfficial.getMyCountryCfg();
			this.mStoreBudget = [0,0,0];
            //
            var cities:Array = ModelOfficial.getMyCities(ModelUser.getCountryID());
            var len:int = cities.length;
            var ccfg:Object;
            var pArr:Array;
            for(var i:int = 0; i < len; i++)
            {
                ccfg = ModelOfficial.getCityCfg(cities[i].cid);
                pArr = ModelOfficial.getStoreToSeason(ModelOfficial.getCityStoreToCountry(cities[i].cid));
                //
                this.mStoreBudget[0]+=pArr[0];
                this.mStoreBudget[1]+=pArr[1];
                this.mStoreBudget[2]+=pArr[2];
                
            }
            var arr:Array = ["coin","gold","food"];
            this.bagList.array = arr;
			this.bagList.renderHandler=new Handler(this,this.bagListRender);
		}

		private function bagListRender(cell:Box,index:int):void{
			var type:String=this.bagList.array[index];
			var img:Image=cell.getChildByName("img") as Image;
			var label0:Label=cell.getChildByName("label0") as Label;
			var label1:Label=cell.getChildByName("label1") as Label;
			var label2:Label=cell.getChildByName("label2") as Label;
			img.skin=AssetsManager.getAssetItemOrPayByID(type);
			label0.text=Tools.getMsgById("_public"+(80+index));
			if(type == "coin"){
				var n:Number=Math.floor(this.mCountryData[type]);
				label1.text=n+"";//==0 ? "0" : n+"0";
				var m:Number=ModelOfficial.getDayCoin();
				label2.text=Tools.getMsgById("_country58")+"："+m;//":"+(m==0 ? "0" : m+"0");
            }else if(type == "gold"){
				label1.text=Math.floor(this.mCountryData[type]+ModelOfficial.getTributeNum("gold"))+"";
				label2.text=Tools.getMsgById("_public83")+"："+Math.floor(this.mStoreBudget[1]);
            }else if(type == "food"){
				label1.text=Math.floor(this.mCountryData[type]+ModelOfficial.getTributeNum("food"))+"";
				label2.text=Tools.getMsgById("_public83")+"："+Math.floor(this.mStoreBudget[2]);;
            }
		}

		private function askClick(index:int):void{
			if(index==0){
				ViewManager.instance.showTipsPanel(Tools.getMsgById(ConfigServer.country_club.welfare.info));
			}else if(index==1){
				ViewManager.instance.showTipsPanel(Tools.getMsgById(ConfigServer.country.warehouse.quota.info));
			}else if(index==2){
				ViewManager.instance.showTipsPanel(Tools.getMsgById(ConfigServer.country.warehouse.info));
			}
		}

		/**
		 * 个人年度奖励是否已经发放(当前时间是否在发奖时间之后 且在新的一年之前)
		 */
		private function isSendGift():Boolean{
			var cfg:Array=ConfigServer.country.warehouse.quota.time;
			if(ModelManager.instance.modelUser.getGameSeason()==cfg[0]){
				var now:Number=ConfigServer.getServerTimer();
				var dt:Date=new Date(now);
				var dt1:Date=new Date(dt.getFullYear(),dt.getMonth(),dt.getDate(),cfg[1][0],cfg[1][1],0,0);//发奖时间
				var dt2:Date=new Date(Tools.gameDay0hourMs(now)+Tools.oneDayMilli);//新的一天的时间
				if(now>dt1.getTime() && now<dt2.getTime()){
					return true;
				}
			}
			return false;
		}

		private function onRemove():void{
			ModelManager.instance.modelClub.off(ModelClub.EVENT_COUNTRY_REDBAG,this,redbagCallBack);
			this.destroyChildren();
            this.destroy(true);
		}



	}

}