package sg.view.map
{
	
	import ui.map.estateTaskUI;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.net.NetPackage;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelUser;
	import sg.model.ModelHero;
	import sg.model.ModelSkill;
	import sg.manager.AssetsManager;
	import sg.model.ModelItem;
	import sg.view.com.ComPayType;
	import sg.model.ModelProp;
	import ui.map.item_city_build_gearUI;
	import sg.model.ModelScience;
	import sg.model.ModelCityBuild;
	import sg.model.ModelVisit;
	import sg.model.ModelEstate;
	import sg.manager.LoadeManager;
	import sg.model.ModelOfficial;
	import sg.achievement.model.ModelAchievement;
	import sg.model.ModelOffice;
	import sg.utils.MusicManager;
	import sg.net.NetMethodCfg;
	import sg.model.ModelTask;
	import sg.model.ModelBuiding;
	import ui.com.payTypeS1UI;
	import sg.festival.model.ModelFestival;
	import sg.utils.SaveLocal;

	/**
	 * 产业主动挂机执行前面板
	 * @author
	 */
	public class ViewEstateTask extends estateTaskUI{

		private var curHid:String="";
		private var estate_index:int=0;
		private var work_type:int=0;		
		private var config_estate:Object={};
		private var skillId:String="";
		private var cost_arr:Array=[];
		private var cost_item_arr:Array=[];

		private var base_num:Number=0;
		private var add_num:Number=0;

		private var user_estate:Object={};
		private var estate_id:String;
		private var visit_obj:Object={};
		private var cb_obj:Object={};		
		private var list_data:Array=[];
		private var cur_radtio:Number=0;
		//private var more_num:Number=0;
		private var config_cb:Object={};
		private var mSkillAdd:Number;
		private var mAddNum:Number;//增加的建设值
		private var mBuildCostArr:Array;//建设消耗资源
		public function ViewEstateTask(){
			
			this.list.itemRender=Item;
			this.list.scrollBar.visible=false;
			this.list.renderHandler=new Handler(this,listRender);
			this.list.selectHandler=new Handler(this,listSelect);
			this.btn0.on(Event.CLICK,this,this.onClick,[1]);
			this.btn1.on(Event.CLICK,this,this.onClick,[0]);
			this.com3.btnChange.on(Event.CLICK,this,changeClick);
			ModelManager.instance.modelUser.on(ModelUser.EVNET_ESTATE_HERO,this,eventCallBack);
			this.com3.btnChange.label = Tools.getMsgById("ViewEstateTask_1");
		}

		public function eventCallBack(str:String):void{
			curHid=str;
			setComHero();
			if(work_type==0){
				if(estate_id==6+""){//狩猎
					setComGetHero();
				}else{
					setComGet();
				}
			}else if(work_type==2){
				setSkillAdd();
				setBuild();
			}
		}

		override public function onAdded():void{
			mBuildCostArr=[];
			curHid=this.currArg[0];
			setSkillAdd();
			
			this.all.height=764;
			this.text5.text=Tools.getMsgById("200804");
			this.text6.text=Tools.getMsgById("_city_build_text03");
			this.text7.text=Tools.getMsgById("_estate_text07");
			this.buildLabel00.text=this.buildLabel01.text="";
			
			work_type=this.currArg[2]?this.currArg[2]:0;//0 产业    1 拜访   2 筑造
			if(work_type==1){
				visit_obj=this.currArg[1];
			}else if(work_type==0){
				estate_index=this.currArg[1];
			}else if(work_type==2){
				cb_obj=this.currArg[1];//{cid,bid}
				config_cb=ConfigServer.city_build;
			}
			
			if(work_type==0){
				this.all.height=644;
				user_estate=ModelManager.instance.modelUser.estate[estate_index];
				estate_id = ConfigServer.city[user_estate.city_id].estate[user_estate.estate_index][0];
				config_estate=ConfigServer.estate.estate[estate_id];
				//this.imgBG.skin=AssetsManager.getAssetsAD(config_estate.background);
				LoadeManager.loadTemp(this.imgBG,AssetsManager.getAssetsAD(config_estate.background));
			}else if(work_type==1){
				this.all.height=644;
				//this.imgBG.skin=AssetsManager.getAssetsAD(ConfigServer.visit.background);
				LoadeManager.loadTemp(this.imgBG,AssetsManager.getAssetsAD(ConfigServer.visit.background));
			}else if(work_type==2){
				LoadeManager.loadTemp(this.imgBG,AssetsManager.getAssetsAD("jz000.jpg"));
				//this.imgBG.skin=AssetsManager.getAssetsAD(ConfigServer.visit.background);
			}
			setData();
			
		}

		private function setSkillAdd():void{
			mSkillAdd=0;
			var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(curHid);
			var smd:ModelSkill=ModelManager.instance.modelGame.getModelSkill("skill281");
			if(ConfigServer.skill["skill281"].city_build){
				var arr:Array=ConfigServer.skill["skill281"].city_build;
				var slv:Number=smd.getLv(hmd);
				if(slv>0){
					mSkillAdd=arr[0]*slv+arr[1];
				}
			}
			

		}

		public function setData():void{
			this.comHeroBig.visible=false;
			this.comGetCoin.visible=false;
			this.boxPro.visible=this.list.visible=this.buildBox.visible=false;
			this.costLabel.text=this.text0.text=this.text1.text=this.text2.text=this.text3.text="";
			this.cFest.visible=this.imgExtra.visible=this.comGetHero.visible=this.comGet0.visible=this.comGet1.visible=this.comGet2.visible=false;

			var use_time:Number=0;
			if(work_type==0){
				//this.titleLabel.text=Tools.getMsgById(config_estate["active_name"]);
				this.comTitle.setViewTitle(Tools.getMsgById(config_estate["active_name"]));
				this.text0.align="center";
				this.text0.text=Tools.getMsgById(config_estate["name"]);
				var _lv:Number=ConfigServer.city[user_estate.city_id].estate[user_estate.estate_index][1];
				this.text1.text=Tools.getMsgById("100001",[_lv]);// "等级 "+user_estate.lv;
				this.text2.text=Tools.getMsgById(ConfigServer.city[user_estate.city_id].name);
				skillId=(config_estate.hero_debris==0)?config_estate.active_get:"hero";
				skillId=ModelSkill.getEstateSID(skillId,estate_id);
				//cost_arr=config_estate.active_cost;//这个配置不用了
				use_time=Math.ceil(config_estate.active_time/(1+ModelOffice.func_estatetime(estate_id))*Tools.oneMinuteMilli);
				cost_arr[0]="coin";
				cost_arr[1]=ModelBuiding.getCostByCD(Math.ceil(use_time/Tools.oneMinuteMilli),4);
				this.btn0.setData(AssetsManager.getAssetItemOrPayByID(cost_arr[0]),Tools.getMsgById("_estate_text18",[cost_arr[1]]));// cost_arr[1]+" 立即完成"
				this.btn1.setData(AssetsManager.getAssetsUI("img_icon_02_big.png"),Tools.getTimeStyle(use_time)+" "+Tools.getMsgById(config_estate.active_name));
				cost_item_arr=config_estate.active_prop;
				if(estate_id==6+""){//狩猎
					setComGetHero();
				}else{
					setComGet();
				}
			}else if(work_type==1){
				setComGetHero();
				//this.titleLabel.text=Tools.getMsgById("_visit_text01");
				this.comTitle.setViewTitle(Tools.getMsgById("_visit_text01"));
				this.text0.align="left";
				this.text0.text=Tools.getMsgById(ConfigServer.city[visit_obj.cid].name)+"-"+ModelManager.instance.modelGame.getModelHero(visit_obj.hid).getName();
				this.text1.text=this.text2.text="";
				skillId="skill287";
				use_time=Math.ceil(ConfigServer.visit.visit_time/(1+ModelOffice.func_visittime())*Tools.oneMinuteMilli);
				cost_arr[0]="coin";
				cost_arr[1]=ModelBuiding.getCostByCD(Math.ceil(use_time/Tools.oneMinuteMilli),6);
				cost_item_arr=ConfigServer.visit.visit_consume;
				this.btn0.setData(AssetsManager.getAssetItemOrPayByID(cost_arr[0]),Tools.getMsgById("_estate_text18",[cost_arr[1]]));
				this.btn1.setData(AssetsManager.getAssetsUI("img_icon_02_big.png"),Tools.getTimeStyle(use_time)+" "+Tools.getMsgById("_visit_text01"));
			}else if(work_type==2){
				skillId="skill281";
				this.text0.text=Tools.getMsgById(this.config_cb.buildall[this.cb_obj.bid].name);
				this.comTitle.setViewTitle(Tools.getMsgById("_city_build_text01"));
				this.costLabel.text=Tools.getMsgById("_city_build_text04",[Tools.getMsgById("_city_build_text01")]);
				setBuildList();
			}
			setComHero();
			if(skillId!=""){
				var o:ModelSkill=ModelManager.instance.modelGame.getModelSkill(skillId);
				this.text3.text=Tools.getMsgById("_estate_text19",[o.getName()]);// "派遣英雄"+o.getName()+"等级越高，收益越多";
			}
			setComCost();

			this.text1.x=this.text0.width+this.text0.x+6;
			this.text2.x=this.text1.width+this.text1.x+6;
			this.boxPro.x=this.text2.x;
		}

		public function setComCost():void{
			this.comCost1.visible=false;
			var arr:Array;
			this.comCost1.off(Event.CLICK,this,clickCostItem);
			if(work_type==0 || work_type==1){
				if(work_type==0){
					arr=config_estate.active_prop;
				}else if(work_type==1){
					arr=ConfigServer.visit.visit_consume;
				}
				this.comCost1.visible=true;	
				this.comCost1.on(Event.CLICK,this,clickCostItem,[cost_item_arr[0]]);
				var color:Number=ModelItem.getMyItemNum(cost_item_arr[0])>=cost_item_arr[1]?0:1;
				var cp:ComPayType=this.comCost1.getChildByName("comType") as ComPayType;
				cp.setData(AssetsManager.getAssetItemOrPayByID(cost_item_arr[0]),ModelItem.getMyItemNum(cost_item_arr[0])+"/"+arr[1],color);
			}else if(work_type==2){
				this.boxBuild.destroyChildren();
				for(var i:int=0;i<mBuildCostArr.length;i++){
					var com:payTypeS1UI=new payTypeS1UI();
					var n:Number=ModelItem.getMyItemNum(mBuildCostArr[i][0])>=mBuildCostArr[i][1]?0:1;
					com.setData(AssetsManager.getAssetItemOrPayByID(mBuildCostArr[i][0]),mBuildCostArr[i][1]+"",n);
					this.boxBuild.addChild(com);
					com.x=160*i;
				}
				this.boxBuild.centerX=0;
			}
		
		}

		public function clickCostItem(id:String):void{
			ViewManager.instance.showItemTips(id);
		}

		public function setComGetHero():void{
			this.cFest.visible=this.comGetCoin.visible=this.comGet0.visible=this.comGet1.visible=false;
			this.comGetHero.visible=true;
			var hmd:ModelHero;				
			if(work_type==0){
				hmd=ModelManager.instance.modelGame.getModelHero(curHid);
				var emd:ModelEstate = ModelManager.instance.modelGame.getModelEstate(user_estate.city_id, user_estate.estate_index);
				var b:Boolean = emd.isGoldEstate();
				comGetCoin.visible=b;
				if(b) this.comGetCoin.num.text=ConfigServer.country_pvp.active_add.coin_add;
				if(b) this.comGetCoin.icon.setData("coin",-1,-1);

			}else if(work_type==1){
				hmd=ModelManager.instance.modelGame.getModelHero(visit_obj.hid);
			}
			this.comGet2.visible=true;
			this.comGet2.setHeroIcon(hmd.id,true,hmd.getStarGradeColor());

			var fest:Array=ModelFestival.getRewardInterfaceByKey("visit");
            cFest.visible=fest.length!=0;
            if(fest.length!=0)
                cFest.setData(fest[0],fest[1],-1);

			comGetCoin.x= cFest.visible ? 0 : cFest.x;
		}

		public function setComGet():void{
			this.imgExtra.visible=this.comGetCoin.visible=this.comGetHero.visible=this.cFest.visible=false;
			var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(curHid);
			var smd:ModelSkill=ModelManager.instance.modelGame.getModelSkill(skillId);
			var sLv:Number=smd.getLv(hmd);
			if(work_type==0){
				//base_num = Math.floor(config_estate.active * ConfigServer.estate.passive[user_estate.lv - 1]);
				var emd:ModelEstate = ModelManager.instance.modelGame.getModelEstate(user_estate.city_id, user_estate.estate_index);
				base_num = emd.getActiveNum();
				var n1:Number=ModelUser.estate_active_add(emd.id,hmd);//加成百分比
				var n2:Number=ModelScience.func_sum_type("estate_active",emd.id);//科技加成百分比
				add_num = Math.floor(base_num*n1);
				var b:Boolean = emd.isGoldEstate();
				comGetCoin.visible=b;
				if(b) this.comGetCoin.num.text=ConfigServer.country_pvp.active_add.coin_add;
				if(b) this.comGetCoin.icon.setData("coin",-1,-1);
				if(add_num==0){
					this.comGet1.visible=false;
					this.comGet0.visible=true;
					this.comGet0.num.text=Math.floor(base_num*(1+n2))+"";
					this.comGet0.icon.setData(config_estate["active_get"],-1,-1);
					//this.comGet0.setCostIcon(config_estate["active_get"],Math.floor(base_num*(1+n2)));
					this.comGetCoin.x=this.comGet1.x;
				}else{
					this.comGet0.visible=this.comGet1.visible=true;
					//this.comGet1.setCostIcon(config_estate["active_get"],Math.floor(base_num*(1+n2)));
					//this.comGet0.setCostIcon(config_estate["active_get"],add_num);
					this.comGet0.num.text=add_num+"";
					this.comGet0.icon.setData(config_estate["active_get"],-1,-1);

					this.comGet1.num.text=Math.floor(base_num*(1+n2))+"";
					this.comGet1.icon.setData(config_estate["active_get"],-1,-1);

					this.imgExtra.visible=true;
					this.comGetCoin.x=0;
				}
				
			}else if(work_type==2){
				setBuildLabel();//功勋、建设值
				
			}

		}

		public function setComHero():void{
			this.dimLabel.text="";
			this.dimBox.visible=false;
			var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(curHid);
			this.com3.nameLabel.text=hmd.getName();
			this.com3.comHero.setHeroIcon(hmd.getHeadId(),true,hmd.getStarGradeColor());
			this.com3.imgRatity.skin=hmd.getRaritySkin(true);
			//this.com3.comType.setHeroType(hmd.getType());
			this.text3.text=this.com3.statusLabel.text=this.com3.slvLabel.text=this.com3.typeLabel.text="";
			this.com3.atkNameLabel.text=this.com3.atkLabel.text="";
			this.com3.fateLabel.visible = this.com3.imgFinish.visible = this.com3.imgSelect.visible = this.com3.bg0.visible = this.com3.btnTH.visible = false;
			this.com3.heroLv.setNum(hmd.getLv());
			//this.com3.hlvLabel.text=hmd.getLv()+"";
			if(skillId!=""){
				var o:ModelSkill=ModelManager.instance.modelGame.getModelSkill(skillId);
				this.com3.typeLabel.text=o.getName();
				this.com3.slvLabel.text=o.getLv(hmd)+"";
			}
			if(work_type==1){
				this.com3.fateLabel.visible=(hmd.isMyFate(visit_obj.hid));
				this.com3.atkLabel.visible=this.com3.bg0.visible=this.com3.atkNameLabel.visible=true;
				var hd:ModelHero=ModelManager.instance.modelGame.getModelHero(visit_obj.hid);
				var n:Number=hd.getTopDimensional()[2];
				this.com3.atkNameLabel.text=hd.getTopDimensional()[0];
				this.com3.atkLabel.text=hmd.getOneDimensional(n)+"";
				this.dimLabel.text=Tools.getMsgById(ConfigServer.visit.ostentatious[hd.getTopDimensional()[2]]);
				this.dimBox.visible=true;
				this.comHeroBig.visible=true;
				this.comHeroBig.setHeroIcon(visit_obj.hid,false);
			}
		}


		public function setBuildList():void{
			this.list.visible=true;
			this.buildBox.visible=true;
			var gear:Array=config_cb.gear;
			list_data=[];
			for(var i:int=0;i<gear.length;i++){
				var o:Object={};
				o["radio"]=gear[i][0];
				o["text"]=Tools.getMsgById(gear[i][1]);
				list_data.push(o);
			}
			this.list.array=list_data;
			var temp:Object = SaveLocal.getValue(SaveLocal.KEY_CITY_BUILD_GEAR);
			var n:Number = 1;
			if(temp && temp.key!=null) n = temp.key;
			itemClick(n);
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(this.list.array[index]);
			cell.setSelection(index==this.list.selectedIndex);
			cell.off(Event.CLICK,this,this.itemClick);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
		}
		
		public function listSelect(index:int):void{
			if(index>=0){

			}
		}

		public function itemClick(index:int):void{
			this.list.selectedIndex=index;
			cur_radtio=this.list.array[index].radio;
			setBuild();
		}
		

		public function setBuild():void{
			var n:Number=config_cb.time*Tools.oneMillis*cur_radtio;//建造时间
			if(ModelAchievement.isGetAchi(config_cb.time_add[0])){
				n*=(1-config_cb.time_add[1]);
			}
			this.btn1.setData(AssetsManager.getAssetsUI("img_icon_02_big.png"),Tools.getTimeStyle(n)+" "+Tools.getMsgById("_city_build_text01"));
			cost_arr[0]="coin";
			cost_arr[1]=ModelBuiding.getCostByCD(Math.ceil(n/Tools.oneMinuteMilli),5);//Math.floor((config_cb.time*cur_radtio)/60)/ConfigServer.system_simple.cd_cost[5];
			this.btn0.setData(AssetsManager.getAssetItemOrPayByID(cost_arr[0]),Tools.getMsgById("_estate_text18",[cost_arr[1]+""]));

			var consume:Array=config_cb.consume;
			var more_cost:Array=config_cb.buildall[cb_obj.bid].more_cost;

			mBuildCostArr=[];
			for(var i:int=0;i<consume.length;i++){
				mBuildCostArr.push([consume[i][0],consume[i][1]*cur_radtio]);
			}

			for(var j:int=0;j<more_cost.length;j++){
				var a:Array=more_cost[j];
				for(var k:int=0;k<mBuildCostArr.length;k++){
					var b:Array=mBuildCostArr[k];
					if(b && a[0]==b[0]){
						b[1]=(consume[k][1]+a[1])*cur_radtio;
					}
				}
			}

			for(var l:int=0;l<more_cost.length;l++){
				var bb:Boolean = false;
				for(var m:int=0;m<mBuildCostArr.length;m++){
					if(mBuildCostArr[m][0] == more_cost[l][0]){
						bb = true;
						break;
					}
				}
				if(!bb){
					mBuildCostArr.push([more_cost[l][0],more_cost[l][1]*cur_radtio]);
				}
			}

			setComCost();
			setBuildLabel();
			setBuildPro();
		}

		public function setBuildPro():void{
			
			if(cb_obj.lv==config_cb.buildall[cb_obj.bid].max_lv){
				this.text1.text=Tools.getMsgById("_city_build_text02");// "已满级";
				this.boxPro.visible=false;
			}else{
				this.text1.text=Tools.getMsgById("100001",[cb_obj.lv]);// cb_obj.lv+"级";
				this.boxPro.visible=true;
				var max:Number=config_cb["exp"+(config_cb.buildall[cb_obj.bid].build_lv)][cb_obj.lv];
				var max_more:Number=0;
				if(config_cb.buildall[cb_obj.bid].more_exp && config_cb.buildall[cb_obj.bid].more_exp[cb_obj.lv]){
					max_more=config_cb.buildall[cb_obj.bid].more_exp[cb_obj.lv];
				}
				max+=max_more;
				var cur:Number=cb_obj.exp;
				this.pro.value=cur/max;
				this.proLabel.text=Tools.getMsgById("_city_build_text03")+" "+cur+" / "+max;// "建设度"+cur+"/"+max;
				
				this.imgMore.x=this.pro.width*this.pro.value;
				var n:Number=mAddNum/max;
				if(n>(1-this.pro.value)){
					n=1-this.pro.value;
				}
				this.imgMore.width=this.pro.width*n;
			}
		}


		public function setBuildLabel():void{
			//功勋
			var n:Number=Math.floor(config_cb.get1[1]*this.list.array[this.list.selectedIndex].radio);//功勋基础
			var n1:Number=ModelScience.func_sum_type("more_merit","city_build");//科技加成功勋百分比
			var n2:Number=0;//offcialAdd?offcialAdd[0][1]:0;//太守令
			n=Math.floor(n*(1+n1+n2));
			var buff_corps:Number=Math.floor(ModelOfficial.cityBuildAdd(cb_obj.cid,0)*n);
			this.buildLabel0.text="+"+ n;// + (buff_corps==0?"":"+"+buff_corps);
			this.buildLabel00.text=buff_corps==0 ? "" : "+"+buff_corps;
			this.buildLabel00.x=this.buildLabel0.x+this.buildLabel0.width+2;

			//建设度
			var m:Number=0;
			var base_num:Number=Math.floor(config_cb.get2[1]*this.list.array[this.list.selectedIndex].radio);//建设度
			var m1:Number=mSkillAdd;//技能加成建设度百分比
			var m2:Number=ModelCityBuild.getBuildAdd(cb_obj.cid);//建筑等级加成建设度百分比		
			var m3:Number=ModelOfficial.cityBuildAdd(cb_obj.cid,1);//建设令	
			m=Math.floor(base_num*(1+m1+m3)*(1+m2));
			var buff_country2:Number=m3==0?0:Math.floor(m - base_num*(1+m1)*(1+m2));//Math.floor(ModelOfficial.cityBuildAdd(cb_obj.cid,1)*more_num);
			this.buildLabel1.text="+"+ (m-buff_country2);// + (buff_country2==0?"" : "+"+buff_country2);
			this.buildLabel01.text=buff_country2==0 ? "" : "+"+buff_country2;
			this.buildLabel01.x=this.buildLabel1.x+this.buildLabel1.width+2;
			mAddNum=m;
			/*
			trace("基础建设度",config_cb.get2[1],
			"档位加成",this.list.array[this.list.selectedIndex].radio,
			"技能加成",m1,
			"匠坊加成",m2,
			"建设令加成",m3,
			"总共",base_num+"*"+"(1+"+m1+"+"+m3+")*(1+"+m2+"))");
			*/
		}

		public function onClick(type:int):void{
			if(type==1){
				if(!Tools.isCanBuy(cost_arr[0],cost_arr[1])){
					return;
				}
			}
			if(work_type==0 || work_type==1){
				if(!Tools.isCanBuy(cost_item_arr[0],cost_item_arr[1])){
					return;
				}
			}else{
				for(var i:int=0;i<mBuildCostArr.length;i++){
					if(!Tools.isCanBuy(mBuildCostArr[i][0],mBuildCostArr[i][1])){
						return;
					}
				}
			}
			

			var sendData:Object={};
			if(work_type==0){
				sendData["estate_index"]=estate_index;
				sendData["cost"]=type;
				sendData["hid"]=curHid;
				NetSocket.instance.send("estate_active_start",sendData,new Handler(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					var obj:Object=ModelManager.instance.modelUser.estate[estate_index];
					ModelManager.instance.modelGame.getModelEstate(obj.city_id,obj.estate_index).event(ModelEstate.EVENT_ESTATE_UPDATE);
					ViewManager.instance.closePanel(this);
				}));
			}else if(work_type==1){
				sendData["city_id"]=this.visit_obj.cid;
				sendData["hid"]=curHid;
				sendData["cost"]=type;
				NetSocket.instance.send("hero_city_visit",sendData,new Handler(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					ModelVisit.updateData(this.visit_obj.cid);
					ViewManager.instance.closePanel(this);
				}));
			}else if(work_type==2){
				sendData["cid"]=cb_obj.cid;
				sendData["bid"]=cb_obj.bid;
				sendData["hid"]=curHid;
				sendData["cost"]=type;
				sendData["gear"]=this.list.selectedIndex;
				SaveLocal.save(SaveLocal.KEY_CITY_BUILD_GEAR,{"key":sendData["gear"]});
				var _this:*=this;
								
				NetSocket.instance.send("build_city_build",sendData,new Handler(_this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					ModelOfficial.updateCityBuild(np.receiveData);
					MusicManager.playSoundUI(MusicManager.SOUND_BUILD);
					if(type==1){
						killCityBuild();
					}else{
						ModelManager.instance.modelUser.event(ModelUser.EVENT_CITY_BUILD_MAIN,[[np.receiveData.city_build,cb_obj,mAddNum]]);
						ModelCityBuild.addCityBuild(cb_obj.cid,cb_obj.bid);
						ViewManager.instance.closePanel(_this);	
					}
					
					if(ModelTask.gTask_city_is(cb_obj.cid)){
						NetSocket.instance.send(NetMethodCfg.WS_SR_GET_GTASK,{},new Handler(_this,function(np:NetPackage):void{
							ModelManager.instance.modelUser.updateData(np.receiveData);
						}));
					}
				}));
			}
		}
		/**
		 * 一键黄金升级建筑
		 */
		private function killCityBuild():void{
			var arr:Array=ModelManager.instance.modelUser.city_build[cb_obj.cid][cb_obj.bid];
			if(arr[2]){
				var arr2:Array=[arr[2],2,{"cid":cb_obj.cid,"bid":cb_obj.bid},1];
				ViewManager.instance.showView(["ViewEventTalk",ViewEventTalk],arr2);
			}else{
				NetSocket.instance.send("city_build_reward",{cid:cb_obj.cid,bid:cb_obj.bid},new Handler(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
					ModelManager.instance.modelUser.event(ModelUser.EVENT_CITY_BUILD_MAIN);
				}));
			}
			cb_obj.lv = ModelOfficial.cities[cb_obj.cid].build[cb_obj.bid][0];
			cb_obj.exp = ModelOfficial.cities[cb_obj.cid].build[cb_obj.bid][1];
			setBuildPro();
		}

		private function getBuildReward():void{
			
		}


		public function changeClick():void{
			ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_HERO,[0,this.currArg[1],work_type,-1]);
		}

		override public function onRemoved():void{
			this.boxBuild.destroyChildren();
			this.list.selectedIndex=-1;
		}
	}

}


import ui.map.item_city_build_gearUI;
import sg.utils.StringUtil;
import sg.utils.Tools;

class Item extends item_city_build_gearUI{

	public function Item(){

	}

	public function setData(obj:Object):void{
		this.label0.text=obj.text;
		this.label1.text=Tools.getMsgById("_city_build_text04",[StringUtil.numberToPercent(obj.radio)]); //StringUtil.numberToPercent(obj.radio*100)+"%消耗";
	}

	public function setSelection(b:Boolean):void{
		this.imgSelect.visible=b;
	}
}