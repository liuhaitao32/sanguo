package sg.view.countryPvp
{
	import ui.countryPvp.country_pvp_battleUI;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import laya.utils.Handler;
	import ui.countryPvp.item_country_pvp_countryUI;
	import sg.utils.Tools;
	import sg.model.ModelCountryPvp;
	import sg.manager.ModelManager;
	import laya.ui.Box;
	import laya.ui.Label;
	import sg.cfg.ConfigServer;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.map.utils.ArrayUtils;
	import sg.cfg.ConfigColor;
	import ui.bag.bagItemUI;
	import laya.maths.MathUtil;

	/**
	 * ...
	 * @author
	 */
	public class CountryPvpBattle extends country_pvp_battleUI{//国家比拼

		private var mViewHight:Number=0;
		private var mTotalScore:Array;
		private var mModel:ModelCountryPvp;
		public function CountryPvpBattle(){
			mModel=ModelManager.instance.modelCountryPvp;
			this.on(Event.REMOVED,this,this.onRemove);
			this.list.scrollBar.touchScrollEnable=true;
			this.list.scrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);
			//788~928
			var n:Number=Laya.stage.height-60-45-55;			
			if(n>928){
				mViewHight=928;
				this.list.scrollBar.touchScrollEnable=false;
			}else if(n>788){
				mViewHight=n;
			}else{
				mViewHight=788;
			}
			this.height=mViewHight;			
			

			this.tLabel.text=Tools.getMsgById("_countrypvp_text24");//"每小时根据占领情况结算一次【阶段积分】\n争夺结束时根据【总积分】进行排名并发放奖励";
			this.cTitle.setSamllTitle(Tools.getMsgById("_countrypvp_text25"));//"占领的每个城门在结算时+30分，占领襄阳在结算时+100分");
			setData();
		}


		private function setData():void{
			mTotalScore=mModel.xyz ? mModel.xyz.country_pvp.score : [0,0,0];
			var rankArr:Array=[2,2,2];
			var socreArr:Array=[];
			for(var j:int=0;j<mTotalScore.length;j++){
				if(mTotalScore[j]!=0 && socreArr.indexOf(mTotalScore[j])==-1){
					socreArr.push(mTotalScore[j]);
				}
			}
			socreArr.sort(function(a:*,b:*):Number{
				return MathUtil.sortNumBigFirst(a,b);
			});	
			//分数最高
			var maxSocre:Number = socreArr[0];
			//最高分数
			var maxNum:Number = 0;
			for(var m:int=0;m<mTotalScore.length;m++){
				maxNum = mTotalScore[m] == maxSocre ? maxNum+1 : maxNum;
			}

			for(var k:int=0;k<mTotalScore.length;k++){				
				if(socreArr[0] && mTotalScore[k]==socreArr[0]){
					rankArr[k]=0;
				}
				if(socreArr[1] && mTotalScore[k]==socreArr[1]){
					//两个第一   分数第二的就是第三名
					rankArr[k]=(maxNum==2) ? 2 : 1;
				}
				
			}
			var arr:Array=[];
			var cfgReward:Array = ConfigServer.country_pvp.country['reward_'+ModelManager.instance.modelUser.mergeNum];
			for(var i:int=0;i<mTotalScore.length;i++){
				var n:Number=mTotalScore[i];
				arr.push({"country":i,"totle_score":n,"stage_score":getStageScore(i),"mid":mModel.getXYCountry()==i,"rank":rankArr[i],
				          "door":mModel.getDoorByCountry(i),
						  "reward":n==0?null:ModelManager.instance.modelProp.getCfgPropArr(cfgReward[i])});
			}
			arr=ArrayUtils.sortOn(["totle_score","country"],arr,true);
			for(var l:int=0;l<arr.length;l++){
				var nn:Number=arr[l]["totle_score"];
				var rank:Number = arr[l]["rank"];
				arr[l]["reward"]=nn==0?null:ModelManager.instance.modelProp.getCfgPropArr(cfgReward[rank]);
			}
			this.list.array=arr;
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(this.list.array[index],index);
		}

		/**
		 * 获得阶段性得分
		 */
		private function getStageScore(_country:Number):Number{
			var arr:Array=mModel.getDoorByCountry(_country);
			var n:Number=Math.round(ConfigServer.country_pvp.country.score_gate*arr.length);
			if(mModel.getXYCountry()==_country) 
				n+=ConfigServer.country_pvp.country.score_city;

			return n;
		}

		
		


		private function onRemove():void{
            this.destroyChildren();
            this.destroy(true);
        }
	}

}


import ui.countryPvp.item_country_pvp_countryUI;
import ui.bag.bagItemUI;
import laya.utils.Handler;
import sg.utils.Tools;
import sg.manager.AssetsManager;
import sg.manager.EffectManager;
import laya.ui.Box;
import laya.ui.Label;
import sg.cfg.ConfigColor;
import laya.display.Sprite;

class Item extends item_country_pvp_countryUI{
	private var mTextArr:Array=[Tools.getMsgById("_countrypvp_text6"),Tools.getMsgById("_countrypvp_text7"),
									Tools.getMsgById("_countrypvp_text10"),Tools.getMsgById("_countrypvp_text8"),Tools.getMsgById("_countrypvp_text9")];
		
	public function Item(){
		this.list.renderHandler=new Handler(this,rListRender);
	}

	public function setData(obj:Object,index:int):void{
		var o:Object=obj;
		for(var i:int=0;i<5;i++){
			var com:Box=this["com"+i];
			(com.getChildByName("text") as Label).text=mTextArr[i];
		}
		this.com0.gray=o.door.indexOf(-2)==-1;
		this.com1.gray=o.door.indexOf(-3)==-1;
		this.com2.gray=!o.mid;
		this.com3.gray=o.door.indexOf(-4)==-1;
		this.com4.gray=o.door.indexOf(-5)==-1;

		EffectManager.changeSprColor(this.imgColor1 as Sprite,o.rank,false,ConfigColor.COLOR_MEDAL);
		EffectManager.changeSprColor(this.imgColor2 as Sprite,o.rank,false,ConfigColor.COLOR_MEDAL);
		
		this.imgRank.skin=AssetsManager.getAssetsUI(o.totle_score==0 ?"icon_win20.png" : "icon_win"+(17+o.rank)+".png");
		this.imgFlag.skin=AssetsManager.getAssetsUI("icon_country"+(o.country+1)+".png");
		this.text1.text=Tools.getMsgById("_countrypvp_text30");
		this.text2.text=Tools.getMsgById("_countrypvp_text31");
		this.tNum1.text=o.totle_score+"";
		this.tNum2.text=o.stage_score+"";

		this.list.array=o.reward;

		Tools.textLayout(text1,tNum1,img1,box1);
		Tools.textLayout(text2,tNum2,img2,box2);
	}

	private function rListRender(cell:bagItemUI,index:int):void{
		cell.setData(this.list.array[index][0],this.list.array[index][1],-1);
	}
}