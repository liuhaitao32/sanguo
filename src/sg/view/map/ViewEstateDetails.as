package sg.view.map
{
	import ui.map.estateDetailsUI;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.model.ModelItem;
	import sg.manager.ViewManager;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import laya.events.Event;
	import sg.cfg.ConfigClass;
	import sg.model.ModelOffice;
	import sg.model.ModelUser;
	import sg.model.ModelEstate;
	import sg.model.ModelPrepare;
	import sg.model.ModelHero;
	import sg.utils.StringUtil;

	/**
	 * ...
	 * @author
	 */
	public class ViewEstateDetails extends estateDetailsUI{

		
		private var mData:Array=[];
		private var user_estate:Array=[];
		private var config_estate:Object={};
		private var config_city:Object={};

		private var isMine:Boolean=false;
		private var cur_num:Number=0;
		private var total_times:Number=0;
		//private var estate_index:Number=0;
		private var item_estate:Object={};
		private var cost_item_arr:Array=[];
		private var user_estate_index:Number=0;
		private var emd:ModelEstate;
		private var v:*;
		public function ViewEstateDetails(){
			this.btn0.on(Event.CLICK,this,this.btnClick,[btn0]);
			this.btn1.on(Event.CLICK, this, this.btnClick, [btn1]);
			this.btn0.label = Tools.getMsgById("_ftask_text05");
			this.text5.text=Tools.getMsgById("_estate_text02");
			text5.width = text5.textField.textWidth;
		}

		override public function onAdded():void{
			
			mData=this.currArg[0];//["cid","tid","lv","act_times","total_times","estate_index"]
			v=this.currArg[1];
			//estate_index=ModelManager.instance.modelUser.estate[mData[5]].estate_index;
			//trace("==================",mData);
			isMine = mData[6];
			
			if (isMine){
				var n:Number = ModelManager.instance.modelUser.estate[mData[5]].estate_index;
				this.emd = ModelManager.instance.modelGame.getModelEstate(mData[0], n);
			}
			else{
				//mData[5]含义不同
				this.emd = ModelManager.instance.modelGame.getModelEstate(mData[0], mData[5]);
			}
			setData();
		}

		public function setData():void{
			this.comCoin.visible=false;
			this.com0.x=182;
			user_estate=ModelManager.instance.modelUser.estate;
			config_estate=ConfigServer.estate;
			config_city=ConfigServer.city;
			cur_num=user_estate.length;
			total_times=config_estate.vacancy+ModelOffice.func_indcount();
			var city:Object=config_city[mData[0]];
			item_estate=config_estate.estate[mData[1]];
			//for(var i:int=0;i<user_estate.length;i++){
			//	var o:Object=user_estate[i];
			//	if(o.city_id==mData[0] && o.estate_index==estate_index){
			//		user_estate_index=i;
			//		isMine=true;
			//		break;
			//	}
			//}
			
			user_estate_index=mData[5];
			//this.nameLabel.text=Tools.getMsgById(city.name) + ' ' + Tools.getMsgById('100001',[mData[2]]) +  Tools.getMsgById(item_estate.name);
			var s:String=Tools.getMsgById(city.name) + ' ' + Tools.getMsgById('100001',[mData[2]]) +  Tools.getMsgById(item_estate.name);
			this.comTitle.setViewTitle(s);
			this.text0.text=isMine?Tools.getMsgById("_estate_text25"):Tools.getMsgById("_estate_text29");// "已占领":"未占领";
			//this.text1.text=Tools.getMsgById("_estate_text17",[mData[2]]);//"等级"+mData[2];
			//this.text2.text=Tools.getMsgById(city.name);

			this.btn0.visible=isMine;
			if(isMine){
				this.btn1.centerX=110;
				this.activeLabel.text=Tools.getMsgById("_estate_text03",[Tools.getMsgById(item_estate.active_name)]);
				this.timesLabel.text=(mData[4]-mData[3])+"/"+mData[4];
			}else{
				this.btn1.centerX=0;
				this.activeLabel.text="";
				this.timesLabel.text="";
				this.activeLabel.text=Tools.getMsgById("_estate_text27");
				this.timesLabel.text=user_estate.length+"/"+ModelEstate.getTotalVacancy();
			}
			// this.activeLabel.x=0;
			// this.timesLabel.x=this.activeLabel.x+this.activeLabel.width+2;
			// this.imgText.x=this.timesLabel.x;
			// this.box1.width=this.activeLabel.width+this.timesLabel.width;

			//var power:int = ModelPrepare.getNPCPower([ConfigServer.estate.enemy_range, ConfigServer.estate.enemy_level[mData[2]]]) * ConfigServer.estate.enemy_power;
			this.boxPower.visible = !this.isMine;
			this.text4.visible = this.isMine;
			if (!this.isMine){
				this.tPowerName.text = Tools.getMsgById("_public187");
				this.comPower.setNum(this.emd.getPower());
				//this.tPower.text = this.emd.getPower() + '';
			}else{
				this.text4.text=Tools.getMsgById("_estate_text28");
			}
			//基本产出
			var passive:Number = config_estate.passive[mData[2] - 1];
			this.imgIcon.skin = AssetsManager.getAssetItemOrPayByID(item_estate.produce);
			var n:Number = Math.floor(passive * item_estate.ratio);
			var m:Number = Math.floor(n * (ModelUser.estate_produce_add(mData[1])));//额外收益
			this.numLabel.text = Tools.getMsgById("_estate_text05", [n, m]);// n+"(+"+m+")/时";
			
			cost_item_arr=item_estate.active_prop;
			this.box1.x=72;
			this.box1.visible = true;
			if(cost_item_arr){
				this.centerLabel.text="";
				this.com0.visible = true;
				this.box2.visible = this.isMine;
				var cim:ModelItem=ModelManager.instance.modelProp.getItemProp(item_estate.active_prop[0]);
				var color:Number=ModelItem.getMyItemNum(cost_item_arr[0])>=cost_item_arr[1]?0:1;
				this.com1.setData(AssetsManager.getAssetItemOrPayByID(item_estate.active_prop[0]),ModelItem.getMyItemNum(cost_item_arr[0])+"/"+cost_item_arr[1],color);
				this.iconLabel.text=cim.name;

				
				this.btn1.label=isMine?Tools.getMsgById(item_estate.active_name):Tools.getMsgById("_estate_text30");//"占领";
				this.btn1.gray=false;
				this.text3.text=Tools.getMsgById("_estate_text04",[Tools.getMsgById(item_estate.active_name)]);//+"收益";
				if(item_estate.hero_debris==1){//获得英雄碎片
					this.com0.setIcon("ui/icon_zhenbao06.png");
					this.com0.setSpecial(true);
					this.com0.setNum("");
					this.com0.setName("");
					this.com0.mCanClick=false;
				}else{//获得钱粮木铁
					var it:ModelItem=ModelManager.instance.modelProp.getItemProp(item_estate.active_get);
					//this.com0.setData(it.icon,it.ratity,"",Math.floor(passive*item_estate.active)+"",it.type);//主动收益
					//this.com0.setData(it.id, Math.floor(passive * item_estate.active));
					this.com0.setData(it.id,this.emd.getActiveNum(),-1);
					
					if(emd.isGoldEstate()){
						this.com0.x=75;
						this.comCoin.visible=true;
						this.comCoin.setData("coin",ConfigServer.country_pvp.active_add.coin_add,-1);
					}
				}
			}else{
				this.btn1.label=Tools.getMsgById("_estate_text30");//"占领";
				this.btn1.gray=isMine;
				this.text3.text="";
				this.centerLabel.text=Tools.getMsgById("_estate_text08");//"暂未开放 敬请期待";
				this.box1.visible = this.box2.visible = this.com0.visible = false;
			}
			this.text3.centerX=0;

			Tools.textLayout(activeLabel,timesLabel,imgText,box1);
			if(this.box2.visible==false){
				this.box1.x=(this.all.width-this.box1.width)/2;
			}
			Tools.textLayout(iconLabel,com1,null,box2);
			box2.right = 30;
			
			imgIcon.x = text5.x + text5.width+2;
			numLabel.x = imgIcon.x + imgIcon.width+2;
		}


		public function btnClick(obj:*):void{
			var _this:* = this;
			switch(obj){
				case btn0:
				if(isMine){
					if(!this.emd.isCanDrop()){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_tips04",[ConfigServer.system_simple.material_gift_cd[0]]));// "1小时之内不能放弃");
						return;
					}
					NetSocket.instance.send("drop_estate",{"estate_index":mData[5]},new Handler(this,function(np:NetPackage):void{
						//放弃
						var n:Number=emd.config_index;
						ModelManager.instance.modelUser.updateData(np.receiveData);
						ModelManager.instance.modelGame.removeEstate(emd.city_id,n);
						
						setData();
						mData[4]=mData[3]=0;						
						closeSelf();
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_tips03"));// "放弃产业成功");
					}));				
				}else{
					//ViewManager.instance.showTipsTxt("还没占领呢");
				}
				break;
				case btn1:
				if(isMine){
					//iewManager.instance.showTipsTxt("已占领");
					if(mData[1]+""=="2"){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_text08"));
						return;
					}
					if(!Tools.isCanBuy(cost_item_arr[0],cost_item_arr[1])){
						return;
					}
					if(mData[4]-mData[3]<=0){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_tips02"));// "次数不足");
						return;
					}
					ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_HERO,[0,user_estate_index,0]);
					ViewManager.instance.closePanel(this);
				}else{
					if(cur_num>=total_times){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_tips01"));//"超出占领总数上限");
						return;
					}

					var sendData:Object={"city_id":mData[0],"estate_index":mData[5],"fight":0,"v":v};					
					var b:Number=!ModelOffice.func_flyestate()?0:-2;
					ModelManager.instance.modelGame.checkTroopToAction(mData[0],["ViewEstateHeroSend",ViewEstateHeroSend],sendData,true,b,-this.emd.getPower());
					ViewManager.instance.closePanel(_this);
				}
				break;
				default:
				break;
			}

		}

		override public function onRemoved():void{
			
		}
	}

}