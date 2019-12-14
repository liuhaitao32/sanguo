package sg.view.countryPvp
{
	import ui.countryPvp.country_pvp_winnerUI;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	import sg.utils.Tools;
	import sg.model.ModelCountryPvp;
	import sg.manager.ModelManager;
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.hero_icon1UI;
	import sg.model.ModelUser;
	import sg.manager.AssetsManager;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigServer;
	import ui.com.country_flag1UI;
	import sg.model.ModelOfficial;
	import sg.manager.EffectManager;
	import sg.manager.LoadeManager;

	/**
	 * ...
	 * @author
	 */
	public class CountryPvpWinner extends country_pvp_winnerUI{//当前时局

		private var mArr:Array;		
		private var mModel:ModelCountryPvp;
		public function CountryPvpWinner(_data:*){
			this.on(Event.REMOVED,this,this.onRemove);
			var n:Number=Laya.stage.height-60-45-55;			
			if(n>788){
				this.height=n;
			}else{
				this.height=788;
			}
			
			mModel=ModelManager.instance.modelCountryPvp;
			mArr=_data?_data:[];
			this.tTitle.text=Tools.getMsgById("_countrypvp_text5");//"当前襄阳占有者";
			
			this.text3.text=Tools.getMsgById("_countrypvp_text11");
			this.text4.text=Tools.getMsgById("_countrypvp_text12");//"当前国家杀敌榜");
            this.text5.text=Tools.getMsgById("_countrypvp_text53");

			// this.direction0.on(Event.CLICK,this,clickDirection);
			// this.direction1.on(Event.CLICK,this,clickDirection);
			// this.direction2.on(Event.CLICK,this,clickDirection);
			// this.direction3.on(Event.CLICK,this,clickDirection);
			LoadeManager.loadTemp(tempimg,"ad/actPay1_26.png");
			this.btn.label=Tools.getMsgById("_countrypvp_text13");//"查看全部";
			this.btn.on(Event.CLICK,this,btnClick);
			this.list.scrollBar.visible=false;
			this.list.renderHandler=new Handler(this,listRender);
			setData();
		}

		
		private function clickDirection():void{
			ViewManager.instance.showTipsPanel(Tools.getMsgById("500047"));
		}

		private function setData():void{
			var arr:Array=[];
			for(var j:int=0;j<ConfigServer.country_pvp.kill_show;j++){
				mArr[j] && arr.push(mArr[j]);
			}
			this.list.array=arr;
			this.list.scrollBar.value=0;
			this.tTips.text=mArr.length==0 ? Tools.getMsgById("_countrypvp_text32") : "";
			
			var n:Number=mModel.getXYCountry();
			this.imgFlag.skin=AssetsManager.getAssetsUI(n<=2 && n>=0 ? "icon_country"+(n+1)+".png" : "icon_country4.png");
			this.tCountry.text=Tools.getMsgById("country_"+n);


			var cities:Array=[-1,-5,-4,-3,-2];
			for(var k:int=0;k<=4;k++){
				var _cid:Number=ModelOfficial.cities[cities[k]].country;
				if([0,1,2].indexOf(_cid)!=-1){
					this["country"+k].skin=AssetsManager.getAssetLater("icon_build"+(6+_cid)+".png");
					EffectManager.changeSprColor(this["light"+k],_cid,true,ConfigServer.world.COUNTRY_COLOR_FILTER_MATRIX);
					this["country"+k].visible=true;
					this["light"+k].visible=true;
				}else{
					this["country"+k].visible=false;
					this["light"+k].visible=false;
				}

			}

			var s:String=mModel.getDoorAdd(ModelManager.instance.modelUser.country)*100+"%";
			this.text0.text=Tools.getMsgById("_countrypvp_text50");
			this.text1.text=Tools.getMsgById("_countrypvp_text51",[s]);
			this.text2.text=Tools.getMsgById("_countrypvp_text52",[s]);
		}

		private function btnClick():void{
			if(mArr.length>0) ViewManager.instance.showView(["ViewCountryPvpKill",ViewCountryPvpKill],mArr);
			else ViewManager.instance.showTipsTxt(Tools.getMsgById("_countrypvp_text32"));
			
		}

		private function listRender(cell:Box,index:int):void{
			//[uid,uname,head,country,online,b001lv,power,kill,build,dead]
			var a:Array=this.list.array[index];
			var cRank:rank_inder_img_t_bigUI = cell.getChildByName("cRank") as rank_inder_img_t_bigUI;
			var cHead:hero_icon1UI           = cell.getChildByName("cHead") as hero_icon1UI;
			var cFlag:country_flag1UI        = cell.getChildByName("cFlag") as country_flag1UI;
			var tName:Label                  = cell.getChildByName("tName") as Label;
			var tNum:Label                   = cell.getChildByName("tNum") as Label;
			
			cRank.setRankIndex(index+1,"",true);
			cHead.setHeroIcon(ModelUser.getUserHead(a.data[2]));
			cFlag.setCountryFlag(a.data[3]);
			tName.text=a.data[1];
			tName.color=(a.data[0]+""==ModelManager.instance.modelUser.mUID)?"#10F010":"#FFFFFF";
			tNum.text=Tools.getMsgById("_countrypvp_text29")+a.num;
			
			cell.off(Event.CLICK,this,itemClick);
			cell.on(Event.CLICK,this,itemClick,[a.data[0]]);
		}

		private function itemClick(_uid:String):void{
			ModelManager.instance.modelUser.selectUserInfo(_uid);
		}


		private function onRemove():void{
            this.destroyChildren();
            this.destroy(true);
        }
	}

}