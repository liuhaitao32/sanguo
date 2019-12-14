package sg.view.countryPvp
{
	import ui.countryPvp.country_pvp_mainUI;
	import laya.utils.Handler;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.model.ModelCountryPvp;
	import sg.manager.ModelManager;
	import sg.map.utils.ArrayUtils;
	import sg.cfg.ConfigServer;
	import sg.manager.ViewManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewCountryPvpMain extends country_pvp_mainUI{

		private var mTabArray:Array=[Tools.getMsgById("_countrypvp_text1"),Tools.getMsgById("_countrypvp_text2"),
		Tools.getMsgById("_countrypvp_text3"),Tools.getMsgById("_countrypvp_text4")];//"当前时局","限时比拼","国家比拼","战功排行"];
		private var mView:*;
		private var mModel:ModelCountryPvp;
		public function ViewCountryPvpMain(){
			
			this.tab.selectHandler=new Handler(this,tabChange);
		}

		override public function onAdded():void{
			mModel=ModelManager.instance.modelCountryPvp;
			mModel.on(ModelCountryPvp.EVENT_XYZ_OVER,this,eventCallBack);
			this.setTitle(Tools.getMsgById("_countrypvp_text0"));//"襄阳争夺战");
			this.tab.labels=mTabArray.join(',');
			this.tab.selectedIndex=-1;
			this.tab.selectedIndex=0;
		}

		private function eventCallBack():void{
			this.click_closeScenes();
		}


		private function tabChange():void{
			var n:Number=this.tab.selectedIndex;
			if(n<0){
				clearView();
				return;
			}
			mModel.myCreditRound=mModel.myCredit=0;
			var o1:Object=mModel.xyz ? mModel.xyz.credit_round_rank.data : null;
			var o2:Object=mModel.xyz ? mModel.xyz.credit_rank : null;
			for(var s1:String in o1){	
				if(s1==ModelManager.instance.modelUser.mUID){
					mModel.myCreditRound=o1[s1];
					break;
				}
			}

			for(var s2:String in o2){	
				if(s2==ModelManager.instance.modelUser.mUID){
					mModel.myCredit=o2[s2];
					break;
				}
			}


			var uids:Array=[];
			var obj:Object;
			var length:Number=0;//列表长度
			switch(n){
				case 0://当前时局 kill_rank
					//var _index:Number=mModel.getXYCountry();//当前占有国
					//obj=mModel.xyz && _index<=2 && _index>=0 ? mModel.xyz.kill_rank[_index] : null;
					if(mModel.xyz){
						obj={};
						for(var k:int=0;k<mModel.xyz.kill_rank.length;k++){
							var o:Object=mModel.xyz.kill_rank[k];
							for(var ss:String in o){
								obj[ss]=o[ss];
							}
						}
					}else{
						obj=null;
					}
					
					length=ConfigServer.country_pvp.kill_list;
					break;
				case 1://限时比拼 credit_round_rank
					obj=mModel.xyz ? mModel.xyz.credit_round_rank.data : null;
					length=ConfigServer.country_pvp.personal.ranking.max;
					break;
				case 2://国家比拼 country_pvp
					break;
				case 3://战功排行 credit_rank
					obj=mModel.xyz ? mModel.xyz.credit_rank : null;
					length=ConfigServer.country_pvp.total_ranking.max;
					break;
			}
			if(obj){
				var arr:Array=[];
				for(var s:String in obj){	
					arr.push({"uid":s,"num":obj[s]});
				}
				arr=ArrayUtils.sortOn(["num"],arr,true);

				for(var i:int=0;i<arr.length;i++){
					if(i<length) uids.push(arr[i].uid);
					else break;
				}
			}
			if(uids.length!=0){
				NetSocket.instance.send("w.get_user_list",{"uids":uids},new Handler(this,function(np:NetPackage):void{
					//[uid,uname,head,online,b001lv,power,kill,build,dead]
					this.setIndexView(n,mModel.getUserList(obj,np.receiveData));
				}));
			}else{
				this.setIndexView(n,null);
			}
		}

		private function setIndexView(n:Number,_data:*):void{
			this.clearView();
			var _this:*=this;
			switch(n){
				case 0:
					this.mView=new CountryPvpWinner(_data);
					break;
				case 1:
					this.mView=new CountryPvpTime(_data);
					break;
				case 2:
					this.mView=new CountryPvpBattle();
					break;
				case 3:
					this.mView=new CountryPvpRank(_data);
					break;
			}
			if(this.mView){
                this.mView.y = 55;
                this.addChild(this.mView);
            }
		}

		private function clearView():void{
			if(this.mView) this.mView.destroy(true);
            this.mView = null;
		}


		override public function onRemoved():void{
			mModel.off(ModelCountryPvp.EVENT_XYZ_OVER,this,eventCallBack);
		}
	}

}