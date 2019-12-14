package sg.view.country
{
	import ui.country.country_impeachUI;
	import laya.events.Event;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.model.ModelOfficial;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.manager.AssetsManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewImpeach extends country_impeachUI{

		private var cfgImpeach:Object;
		private var mImpeach:Object;
		private var mIsVoted:Boolean;
		private var mIsCanVoted:Boolean;
		private var mStatus:Number;
		private var mKingStr:String;
		private var mCandidateStr:String;
		public function ViewImpeach(){
			
			this.comTitle.setViewTitle(Tools.getMsgById("_country_impeach0"));
			this.comHero.setHeroIcon("hero404");
			
			this.btn0.on(Event.CLICK,this,btnClick,[0]);
			this.btn1.on(Event.CLICK,this,btnClick,[1]);
			this.btnImp.on(Event.CLICK,this,impClick);
			
		}

		override public function onAdded():void{
			ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_UPDATE_IMPEACH,this,eventCallBack);
			cfgImpeach=ConfigServer.country.impeach;
			
			
			infoLabel.style.color="#FFFFFF";
			infoLabel.style.fontSize=18;
			infoLabel.style.leading=6;
			infoLabel.style.wordWrap=true;
			infoLabel.style.align="center";
			setData();
		}

		private function eventCallBack():void{
			if(ModelOfficial.impeach){
				if(ModelOfficial.impeach.is_over==true){
					trace("=======弹劾投票结束");
					this.closeSelf();
					return;
				}
				setData();
			}
		}

		private function setData():void{
			mKingStr="【"+ModelOfficial.getOfficerName(0,ModelOfficial.getInvade())+"】"+ModelOfficial.getMyCountryCfg()["official"][0][1];
			mImpeach=ModelOfficial.impeach;
			mStatus=ModelOfficial.getImpeachStatus();
			if(mStatus==0){
				canImp();
			}else{
				canVote();
			}
			
		}

		private function canImp():void{
			this.box0.visible=true;
			this.box1.visible=false;
			this.infoBox.height=166;
			this.text0.text=Tools.getMsgById("_country_impeach1");//"发起弹劾需要买通宦官 帮你上下打点";

			infoLabel.innerHTML=Tools.getMsgById(cfgImpeach.info1,
								[ModelOfficial.getOfficerName(0,ModelOfficial.getInvade()),
								ModelOfficial.getMyCountryCfg()["official"][0][1]]);
			infoLabel.height=infoLabel.contextHeight;
			infoLabel.y=(infoBox.height-infoLabel.height)/2;
			this.btnImp.setData(AssetsManager.getAssetItemOrPayByID("coin"),Tools.getMsgById("_country_impeach0")+" "+cfgImpeach.pay);
		}

		private function canVote():void{
			this.box0.visible=false;
			this.box1.visible=true;
			this.infoBox.height=116;
			this.text0.text=Tools.getMsgById("_country_impeach2");//"正在进行弹劾";

			var s1:String=ModelOfficial.getOfficerNameByID(mImpeach.candidate[0]);
			this.title0.text=s1=="" ? mImpeach.data[0] : "【"+s1+"】"+mImpeach.data[0];
			mCandidateStr=this.title0.text;
			//var s2:String=ModelOfficial.getOfficerNameByID(mImpeach.candidate[1]);
			this.title1.text= mKingStr;//"【"+s2+"】"+ModelOfficial.getMyCountryCfg()["official"][0][1];

			infoLabel.innerHTML=Tools.getMsgById(cfgImpeach.info2,[ModelOfficial.getOfficerName(0,ModelOfficial.getInvade()),
																  ModelOfficial.getMyCountryCfg()["official"][0][1],
																  mCandidateStr]);
			infoLabel.height=infoLabel.contextHeight;
			infoLabel.y=(infoBox.height-infoLabel.height)/2;

			var n1:Number=0;
			var n2:Number=0;
			mIsVoted=false;
			mIsCanVoted=mImpeach.vote_users.hasOwnProperty(ModelManager.instance.modelUser.mUID);
			for(var s:String in mImpeach.vote_users){
				if(mImpeach.vote_users[s]==mImpeach.candidate[0]){
					n1+=1;
				}else if(mImpeach.vote_users[s]==mImpeach.candidate[1]){
					n2+=1;
				}
				if(s==ModelManager.instance.modelUser.mUID && mImpeach.vote_users[s]!=null){
					mIsVoted=true;
				}
			}
			this.info0.text=Tools.getMsgById("_country_impeach3",[n1]);// n1+"票";
			this.btn0.label=Tools.getMsgById("_country_impeach4");

			this.info1.text=Tools.getMsgById("_country_impeach3",[n2]);//n2+"票";
			this.btn1.label=Tools.getMsgById("_country_impeach4");
			this.btn0.gray=this.btn1.gray=!mIsCanVoted || mIsVoted;
		}

		private function btnClick(_index:int):void{
			if(mIsCanVoted){
				if(mIsVoted){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_country_impeach7"));//"已投票");
					return;
				}
			}else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_country_impeach8"));//("不可投票");
				return;
			}
			if(mImpeach){
				if(mImpeach.is_over==true){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_country_impeach9"));//("投票结束");
					return;
				}
				var n1:Number=Tools.getTimeStamp(mImpeach.start);
				var n2:Number=cfgImpeach.continued*Tools.oneMinuteMilli;
				var n:Number=ConfigServer.getServerTimer();
				if(n1+n2<n){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_country_impeach10"));//("投票过期");
					return;
				}
			}

			
			var s:String=_index==0 ? Tools.getMsgById("_country_impeach5",[mCandidateStr]):Tools.getMsgById("_country_impeach6",[mKingStr]);
			//"是否支持 "+mCandidateStr+" 当选国王？" : "是否支持 "+mKingStr+" 保持国王？";
			
			ViewManager.instance.showAlert(s,function(index:int):void{
				if(index==0){
					voteFunc(_index);
				}
			});
			
		}

		private function voteFunc(_index:int):void{
			NetSocket.instance.send("w.impeach_vote",{king_uid:mImpeach.candidate[_index]},new Handler(this,function(np:NetPackage):void{
				ModelOfficial.updateImpeach(np.receiveData);
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_country_impeach11"));//"投票成功");
				ModelManager.instance.modelOfficel.event(ModelOfficial.EVENT_UPDATE_IMPEACH);
				trace("=====我发起投票");
				//setData();
			}));
		}


		private function impClick():void{
			if(!Tools.isCanBuy("coin",cfgImpeach.pay)){
				return;
			}

			var s:String=Tools.getMsgById("_country_impeach13",[mKingStr]);//"是否对 "+mKingStr+" 进行弹劾？";
			ViewManager.instance.showAlert(s,function(index:int):void{
				if(index==0){
					impFunc();
				}
			});

			
		}

		private function impFunc():void{
			NetSocket.instance.send("w.start_impeach",{},new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ModelOfficial.updateImpeach(np.receiveData);
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_country_impeach12"));//"成功发起弹劾");
				ModelManager.instance.modelOfficel.event(ModelOfficial.EVENT_UPDATE_IMPEACH);
				trace("=====我发起弹劾");
				//setData();
			}));
		}


		override public function onRemoved():void{
			ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_UPDATE_IMPEACH,this,eventCallBack);
		}
	}

}