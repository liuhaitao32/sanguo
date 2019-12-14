package sg.view.inside
{
	import ui.inside.armyUpgradeUI;
	import laya.utils.Tween;
	import laya.ui.ProgressBar;
	import laya.utils.Handler;
	import laya.utils.Ease;
	import laya.events.Event;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import sg.view.com.ComPayType;
	import sg.cfg.ConfigServer;
	import sg.net.NetPackage;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelUser;
	import sg.model.ModelPrepare;
	import laya.ui.Image;
	import laya.ui.Label;
	import sg.manager.EffectManager;
	import laya.display.Animation;
	import laya.ui.Box;
	import sg.model.ModelHero;
	import sg.utils.StringUtil;
	import sg.utils.MusicManager;
	import sg.model.ModelBuiding;

	/**
	 * ...
	 * @author
	 */
	public class ViewArmyUpgrade extends armyUpgradeUI{

		public var configData:Object={};
		public var pro_arr:Array=[];
		public var curIndex:int=0;//当前阶段
		public var curValue:int=0;//当前强化值
		public var curEvNum:int=0;//当前每个阶段的max值
		public var curLv:int=0;//当前等级
		public var curArmy:int=0;//当前兵营索引
		public var curhNum:int=0;//当前锤子数
		public var use_wood_arr:Array=[];//消耗的木材
		public var use_iron_arr:Array=[];//消耗的铁
		public var use_ham_arr:Array=[];//消耗的锤子数
		public var str_arr:Array= [			
			Tools.getMsgById("skill_type_0"),
			Tools.getMsgById("skill_type_1"),
			Tools.getMsgById("skill_type_2"),
			Tools.getMsgById("skill_type_3")];
		public var icon_arr:Array=["icon_bu","icon_qi","icon_gong","icon_nu"];
		public var curBlv:int=0;//当前兵营建筑等级等级
		public var hammer_time:Number=0;//锤子刷新时间
		public var configHammer:Array=[];//锤子的配置
		public var maxLv:int=0;//最大等级
		public var maxValue:Number=0//最大等级的最大进度值
		public var userData:Array=[];//[当前等级，强化进度，时间，突破失败是1，强化失败是1,突破成功率]
		public var addNum:Number=0;//增加的强化值
		public var box_prop:Array=[];
		public var label_arr:Array=[];
		public var iSSuccess:Boolean=false;//强化是否成功
		public var reData:Object;//服务器返回的数据
		public var ani_arr:Array=[null,null,null];
		public var box_arr:Array;
		public var ani:Animation;
		public var tween:Tween;
		
		private var mIsComplete:Boolean=false;
		private var mAni:Animation;
		
		public function ViewArmyUpgrade(){
			
			//this.text1.text="防御";
			//this.text2.text="攻击";
			//this.text3.text="兵力";
			//this.text4.text="技能";
			this.text5.text=Tools.getMsgById("_public23");//"属性加成";
			this.text12.text="";//突破成功率
			this.btn0.label=Tools.getMsgById("_building4");//"研究一次";
			this.btn1.label=Tools.getMsgById("_building5");//"研究十次";
			pro_arr=[pro1,pro2,pro3];
			this.btn0.on(Event.CLICK,this,this.startClick,[0]);
			this.btn1.on(Event.CLICK,this,this.startClick,[1]);
			this.btn2.on(Event.CLICK,this,this.startClick,[2]);
			ModelManager.instance.modelUser.on(ModelUser.EVENT_UPDATE_ARMY_UPGRADE,this,eventCallBack);
			box_prop=[this.boxProp0,this.boxProp1,this.boxProp2];
			label_arr=[this.text6,this.text7,this.text8];
			this.text10.text = Tools.getMsgById("_jia0102");	
			this.btn2.label = Tools.getMsgById("_public176");

			Tools.textLayout(text10,com7,com7Img,com7Box);
			this.text11.x = com7Box.x + com7Box.width;
			Tools.textLayout2(text5,text5Img);

		}

		override public function onAdded():void{
			this.btn0.gray=this.btn1.gray=this.btn2.gray=false;
			if(!ani){
				ani=new Animation();
				ani.visible=false;
				ani=EffectManager.loadAnimation("glow026");
				ani.play(0,true,'stand');
				this.boxCenter.addChild(ani);
				ani.pos(this.boxCenter.width/2,this.boxCenter.height/2);
			}
			box_arr=[this.boxAtk,this.boxAtk2,this.boxAtk3];
			userData=ModelManager.instance.modelUser.home[this.currArg].science;
			this.imgAlert0.visible=this.imgAlert1.visible=false;
			configData=ConfigServer.army;
			this.box0.visible=this.box1.visible=this.box2.visible=false;
			curBlv=ModelManager.instance.modelInside.getBuildingModel(this.currArg).lv;
			var a:Array=configData.army_add_value[configData.army_add_value.length-1];
			maxLv=a[0];
			maxValue=a[1]*3;
			this.text11.text="";
			this.text14.text="";
			configHammer=configData.hammer_times;//[最大值,恢复一个的时间分钟数]

			if(this.currArg=="building009")
				curArmy=0;
			else if(this.currArg=="building010")
				curArmy=1;
			else if(this.currArg=="building011")
				curArmy=2;
			else if(this.currArg=="building012")
				curArmy=3;

			(this.boxCenter.getChildByName("armyImg"+curArmy) as Image).visible=true;
			(this.boxAtk.getChildByName("armyImg"+curArmy) as Image).visible=true;
			this.armyIcon.skin=AssetsManager.getAssetsUI(icon_arr[curArmy]+".png");//
			//this.text0.text=str_arr[curArmy]+Tools.getMsgById("_public24");
			this.comTitle.setViewTitle(str_arr[curArmy]+Tools.getMsgById("_public24"));
			this.text15.text=str_arr[curArmy]+Tools.getMsgById("_public24");
			setData();
			setUI();	
			setNumCom();//剩余的锤子数
			setConsume();//消耗值		
			initProCom();
			
		}

		public function eventCallBack(t1:int,t2:int,re:Object):void{
			reData=re;
			userData=re.user.home[this.currArg].science;
			if(t1==0 || t1==1){
				ModelManager.instance.modelUser.updateData(reData);
				setData();
				setUI();
				if(t2==0){
					//trace("强化补救失败");
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_building6"));//强化失败
					iSSuccess=false;
				}else if(t2==1){
					//trace("强化补救成功");
					//ViewManager.instance.showTipsTxt("强化成功");
				}
				addNum=(userData[1]>curValue) ? userData[1]-curValue : 0;
				setProTween();

			}else if(t1==2){
				//this.pro1.value=this.pro2.value=this.pro3.value=0;
				if(t2==0){
					//trace("突破补救失败");
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_building7"));//突破失败
					ModelManager.instance.modelUser.updateData(reData);
					setData();
					setUI();
					iSSuccess=false;
				}else if(t2==1){
					//trace("突破补救成功");
					//ViewManager.instance.showTipsTxt("突破成功");
					show_text(str_arr[curArmy]+Tools.getMsgById("_building8"),1);//科技+1
					initProCom();
				}

			}


			
		}



		public function setData():void{
			ModelManager.instance.modelInside.getBuildingModel(this.currArg).updateStatus(true);
			curLv=userData[0];
			curValue=userData[1];
			var d:Array=configData.army_add_value;
			var n:Number=0;
			for(var i:int=0;i<d.length;i++){
				var a:Array=d[i];
				if(curLv<=a[0]){
					n=i;
					break;
				}
			}
			curEvNum=d[n][1];
			curIndex=curValue>=(3*curEvNum)?3:Math.floor(curValue/curEvNum);
			curIndex=curIndex>3?3:curIndex;


			if(ModelManager.instance.modelInside.isArmyScienceMax(this.currArg)){//满级了
				this.btn2.gray=true;
			}
		}

		public function setUI():void{
			setTitleLabel();//标题（多少级了）
			setPropLabel();//属性增值
			//initProCom();
			setBreakLabel();//当前进度 或 突破成功率
			//setNumCom();//剩余的锤子数
			//setConsume();//消耗值
		}

		public function setTitleLabel():void{
			//var s:String="";
			//s=str_arr[curArmy];
			//this.text0.text=s+"科技"+curLv+"级";
			this.text16.text=Tools.getMsgById("_hero16",[curLv]);// curLv+"阶";
		}

		public function setBreakLabel():void{
			if(curIndex!=3){
				this.text12.text=Tools.getMsgById("_building10");//"当前进度"
				this.text13.text=curValue+"/"+(curEvNum*3)+"";
			}else{
				this.text12.text=Tools.getMsgById("_building11");//"突破成功率";
				this.text13.text=StringUtil.numberToPercent(userData[5]);
			}
			this.text12.width = this.text12.textField.textWidth;
			this.text13.width = this.text13.textField.textWidth;
			this.text13.x = this.text12.x + this.text12.width + 2;
			this.boxText.width = this.text12.width+this.text13.width + 2;
			this.boxText.centerX = 0;
		}

		public function setTimeLabel():void{
			//this.text11.text="(6分35秒后增加一次)";			
			var n:Number=configHammer[0];
			var now:Number=ConfigServer.getServerTimer();
			n=Math.floor((now-hammer_time)/(configHammer[1]*Tools.oneMinuteMilli));
			n=n>configHammer[0]?configHammer[0]:n;
			if(n<configHammer[0]){
				var m:Number=configHammer[1]*Tools.oneMinuteMilli-Math.floor((now-hammer_time)%(configHammer[1]*Tools.oneMinuteMilli));
				if(m>0){
					this.text11.text=Tools.getTimeStyle(m)+Tools.getMsgById("_building9");//"后增加一次";					
				}else{
					timer.clear(this,setTimeLabel);
					this.text11.text="";
					setNumCom();		
				}
			}else{
				timer.clear(this,setTimeLabel);
				this.text11.text="";
			}
			this.com7.setData(AssetsManager.getAssetsUI("icon_74.png"),n);
			curhNum=n;
			
		}


		public function setPropLabel():void{
			//{"type":0,"atk":90,"def":80,"hpm":65,"bashDmg":35,"bash":125}
			var o1:Object=ModelPrepare.getArmyAddData(curArmy,[curLv,0]);
			var data_arr1:Array=[o1.atk,o1.def,o1.hpm];
			var data_arr2:Array=[0,0,0];
			this.text6.text=str_arr[curArmy]+Tools.getMsgById("_public25");
			this.text7.text=str_arr[curArmy]+Tools.getMsgById("_public26");
			this.text8.text=str_arr[curArmy]+Tools.getMsgById("_public28");
			if(curArmy<maxLv){
				var o2:Object=ModelPrepare.getArmyAddData(curArmy,[curLv+1,0]);
				data_arr2=[o2.atk,o2.def,o2.hpm];
				//this.text6.text=str_arr[curArmy]+"攻击"+o1.atk+"——>"+o2.atk;
				//this.text7.text=str_arr[curArmy]+"防御"+o1.def+"——>"+o2.def;
				//this.text8.text=str_arr[curArmy]+"兵力"+o1.hpm+"——>"+o2.hpm;
			}else{
				//this.text6.text=str_arr[curArmy]+"攻击"+o1.atk;
				//this.text7.text=str_arr[curArmy]+"防御"+o1.def;
				//this.text8.text=str_arr[curArmy]+"兵力"+o1.hpm;
			}

			for(var i:int=0;i<3;i++){
				var _label0:Label=box_prop[i].getChildByName("propNum0") as Label;
				var _label1:Label=box_prop[i].getChildByName("propNum1") as Label;
				var _img:Image=box_prop[i].getChildByName("propImg0") as Image;
				_label0.text=data_arr1[i];
				_label1.text=data_arr2[i]==0?"":data_arr2[i];
				_img.visible=data_arr2[i]!=0;
				//_label0.width=_label0.textField.textWidth;
				_img.x=_label0.x+_label0.width+4;
				_label1.x=_img.x+_img.width+4;
				box_prop[i].width=label_arr[i].width+_label0.width+_img.width+_label1.width;
			}
			box_prop[0].left=120;
			box_prop[1].right=120;
			box_prop[2].left=120;
			var n1:Number=o2.bash/10;
			var n2:Number=o2.bashDmg*100;
			this.text9.text=Tools.getMsgById("_building12",[str_arr[curArmy],n1+"%",n2]);
			//"猛攻："+str_arr[curArmy]+"攻击"+n1+"%概率造成"+n2+"点固定伤害，该伤害仅会被兵种初始防御所抵挡";

		}

		public function setPropLabelColor(b:Boolean=false):void{
			var a:Array=[this.text6,this.text7,this.text8];
			for(var i:int=0;i<a.length;i++){
				var _label0:Label=box_prop[i].getChildByName("propNum0") as Label;
				var _label1:Label=box_prop[i].getChildByName("propNum1") as Label;
				var _img:Image=box_prop[i].getChildByName("propImg0") as Image;
				if(b){
					if(i<=curIndex-1){
						_label0.color=_label1.color=a[i].color="#acff75";
						EffectManager.changeSprColor(_img,1);
					}else{
						_label0.color=_label1.color=a[i].color="#ffffff";
						EffectManager.changeSprColor(_img,0);
					}
				}else{
					_label0.color=_label1.color=a[i].color="#ffffff";
					EffectManager.changeSprColor(_img,1);
				}
			}
		}

		public function setNumCom():void{
			hammer_time=Tools.getTimeStamp(userData[2]);
			setTimeLabel();
			timer.loop(1000,this,setTimeLabel);
			
		}

		public function initProCom():void{
			this.pro1.value=curIndex>1?1:curValue/curEvNum;
			this.pro2.value=this.pro1.value<1 ? 0 : ((curValue-curEvNum)/curEvNum);
			this.pro3.value=this.pro2.value<1 ? 0 : ((curValue-2*curEvNum)/curEvNum);
			
			this.box2.visible=(curIndex==3);
			this.box0.visible=this.box1.visible=!(curIndex==3);
			setPropLabelColor(true);
			for(var i:int=0;i<3;i++){
				if(ani_arr[i]==null){
					ani_arr[i]=EffectManager.loadAnimation("glow026");
					ani_arr[i].x=box_arr[i].width/2;
					ani_arr[i].y=box_arr[i].height/2;
					(box_arr[i] as Box).addChild(ani_arr[i]);
				}
				if(pro_arr[i].value==1){
					ani_arr[i].visible=true;
					ani_arr[i].play(0,true,'stand');
				}else{
					ani_arr[i].visible=false;
				}
				
			}
			this.ani.visible=(this.pro1.value==1 && this.pro2.value==1 && this.pro3.value==1);
		}

		public function setConsume():void{
			var add_cost:Array=configData.army_add_cost;
			var s_arr:Array=["wood","iron","hammer"];
			var n_arr:Array=[add_cost[0][0]["wood"],add_cost[0][0]["iron"],add_cost[0][0]["hammer"],
							add_cost[1][0]["wood"],add_cost[1][0]["iron"],add_cost[1][0]["hammer"],
							add_cost[2][0]["wood"],add_cost[2][0]["iron"],add_cost[2][0]["hammer"]];

			var n1:Number=ModelManager.instance.modelProp.isHaveItemProp(s_arr[0],n_arr[0])?0:1;
			com1.setData(AssetsManager.getAssetItemOrPayByID(s_arr[0]),n_arr[0],n1);

			var n2:Number=ModelManager.instance.modelProp.isHaveItemProp(s_arr[1],n_arr[1])?0:1;
			com2.setData(AssetsManager.getAssetItemOrPayByID(s_arr[1]),n_arr[1],n2);

			var n3:Number=(curhNum>=n_arr[2]) ? 0:1;
			com3.setData(AssetsManager.getAssetsUI("icon_74.png"),n_arr[2],n3);

			var n4:Number=ModelManager.instance.modelProp.isHaveItemProp(s_arr[0],n_arr[3])?0:1;
			com4.setData(AssetsManager.getAssetItemOrPayByID(s_arr[0]),n_arr[3],n4);

			var n5:Number=ModelManager.instance.modelProp.isHaveItemProp(s_arr[1],n_arr[4])?0:1;
			com5.setData(AssetsManager.getAssetItemOrPayByID(s_arr[1]),n_arr[4],n5);

			var n6:Number=(curhNum>=n_arr[5]) ? 0:1;
			com6.setData(AssetsManager.getAssetsUI("icon_74.png"),n_arr[5],n6);

			var n8:Number=ModelManager.instance.modelProp.isHaveItemProp(s_arr[0],n_arr[6])?0:1;
			com8.setData(AssetsManager.getAssetItemOrPayByID(s_arr[0]),n_arr[6],n8);

			var n9:Number=ModelManager.instance.modelProp.isHaveItemProp(s_arr[1],n_arr[7])?0:1;
			com9.setData(AssetsManager.getAssetItemOrPayByID(s_arr[1]),n_arr[7],n9);

			var n10:Number=(curhNum>=n_arr[8]) ? 0:1;
			com10.setData(AssetsManager.getAssetsUI("icon_74.png"),n_arr[8],n10);

			use_wood_arr=[n_arr[0],n_arr[3],n_arr[6]];
			use_iron_arr=[n_arr[1],n_arr[4],n_arr[7]];
			use_ham_arr=[n_arr[2],n_arr[5],n_arr[8]];
		}

		
		public function setProTween():void{
			probarTweener(0,curIndex+1);
		}

		public function probarTweener(index:int,count:int=1):void{//起始索引，长度
			//timer.clear(this,proOnupdate);
			if(index==-1 || index>=3)
				return;
			if(index>pro_arr.length)
				return;
			var pb:ProgressBar=pro_arr[index];
			var nextIndex:int=count>1?index+1:-1;
			if(pb.value==1){
				probarTweener(nextIndex,count-1);
				return;
			}
			var pb_old:Number=pb.value;
			var pb_new:Number=0;
			if(index==0){
				pb_new=curValue/curEvNum;
			}else if(index==1){
				pb_new=(curValue-curEvNum)/curEvNum;
			}else if(index==2){
				pb_new=(curValue-2*curEvNum)/curEvNum;
			}
			//trace("---------"+index,pb_old,pb_new);
			var t:Number=(pb_new-pb_old)*1000;
			//Tween.to(pb,{x:pb.x,ease:Ease.quadOut,update:new Handler(this,proOnupdate,[index,pb_old,pb_new,t]),
			//		complete:Handler.create(this,proOnComplete,[nextIndex,count-1])},t,null);
			if(tween){
				tween.complete();
			}
			tween = Tween.to(pb,{"value":pb_new,ease:Ease.quadOut,update:new Handler(this,proOnupdate,[index,pb_old,pb_new,t]),
					complete:Handler.create(this,proOnComplete,[nextIndex,count-1,pb_new,index])},t,null);
			
		}

		public function proOnupdate(index:int,n1:Number,n2:Number,t:Number):void{//弃用
			return;
			//trace("进度条update");
			//var count:Number=t/1000*30;
			//var v:Number=(n2-n1)/count;
			//pro_arr[index].value+=v;
			//trace(pro_arr[index].value);
		}

		public function proOnComplete(index:int,count:Number,value:Number,ind:int):void{
			// trace("进度条complete  ",index,count);
			//initProCom();
			var b:Boolean=false;
			if(value>=1){
				if(pro_arr[ind]){
					var ani:Animation=ani_arr[ind];
					ani.visible=true;
					ani.play(0,false,'in');
					ani.on(Event.COMPLETE,this,function():void{
						ani.play(0,true,'stand');
					})
					b=true;
				}
			}
			if(count==0 || index==3){
				//trace("动画完了");
				if(addNum>0){
					show_text(Tools.getMsgById("_building13",[addNum]),0);//强化值
					ModelManager.instance.modelUser.updateData(reData);		
					ModelManager.instance.modelInside.getBuildingModel(this.currArg).updateStatus(true);								
					addNum=0;
				}
				initProCom();
			}

			probarTweener(index,count);
		}


		public function startClick(index:int):void{
			
			if(use_ham_arr[index]>curhNum){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_building14"));//锤子不足
				return;
			}
			if(!Tools.isCanBuy("wood",use_wood_arr[index])){
				return;
			}
			if(!Tools.isCanBuy("iron",use_iron_arr[index])){
				return;
			}
			if(curLv>=maxLv && curValue>=maxValue){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public12"));//满级
				return;
			}
			if(index==2){
				var a:Array=configData.army_add_limit;
				var _lv:int=ModelManager.instance.modelInside.getBuildingModel(this.currArg).lv;
				if(curLv>=_lv*a[0]+a[1]){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_building15"));//等级到达兵营等级上限
					return;
				}
			}
			
			
			if(index==0){
				//trace("研究一次");
				rate_up(1);
				//probarTweener(0,3);
			}else if(index==1){
				//trace("研究十次");
				rate_up(10);
			}else if(index==2){
				//trace("强化");
				lv_up();
			}
		}

		public function rate_up(i:int):void{
			NetSocket.instance.send("army_science_rate_up",{"b_id":this.currArg,"up_num":i},Handler.create(this,rate_up_call_back,[i]));
		}

		public function rate_up_call_back(times:int,np:NetPackage):void{
			
			this.btn0.mouseEnabled=this.btn1.mouseEnabled=this.btn2.mouseEnabled=true;
			reData=np.receiveData;
			//ModelManager.instance.modelUser.updateData(np.receiveData);
			var re:Object=np.receiveData;
			userData=re.user.home[this.currArg].science;
			updateUI(reData);
			if(userData[4]!=0){
				var nnn:int=times==1?0:1;
				ViewManager.instance.showView(ConfigClass.VIEW_ARMY_UPGRADE_ALERT,[this.currArg,nnn,np.receiveData]);
				MusicManager.playSoundUI(MusicManager.SOUND_ARMY_SCIENCE_DEF);
			}else{
				iSSuccess=true;
				var n:Number=userData[1];
				addNum=(n>curValue) ? n-curValue : 0;				
				setData();
				setUI();
				setProTween();
				MusicManager.playSoundUI(MusicManager.SOUND_ARMY_SCIENCE_SUC);
			}
		}

		public function show_text(str:String,type:int=0):void{
			this.text14.text=str;
			this.imgAlert0.visible=this.imgAlert1.visible=true;
			this.comAlert.visible=true;
			this.imgAlert1.skin= AssetsManager.getAssetLater((type==0)?"img_name05.png":"img_name06.png");
			if(type==1){
				mAni=EffectManager.loadAnimation("glow027","",1);
				this.boxCenter.addChild(mAni);
				mAni.pos(this.boxCenter.width/2,this.boxCenter.height/2);
				this.btn0.mouseEnabled=this.btn1.mouseEnabled=this.btn2.mouseEnabled=false;
				mIsComplete=false;
				mAni.on(Event.COMPLETE,this,function():void{
					mIsComplete=true;
					btn0.mouseEnabled=btn1.mouseEnabled=btn2.mouseEnabled=true;
					ModelManager.instance.modelUser.updateData(reData);
					setData();
					setUI();
					initProCom();
				});
			}
			timer.once(1000,this,function():void{
				comAlert.visible=false;
				//this.text14.text="";
			});
		}


		public function lv_up():void{
			
			NetSocket.instance.send("army_science_lv_up",{"b_id":this.currArg},Handler.create(this,lv_up_call_back));
		}

		public function lv_up_call_back(np:NetPackage):void{
			//ModelManager.instance.modelUser.updateData(np.receiveData);
			this.btn0.mouseEnabled=this.btn1.mouseEnabled=this.btn2.mouseEnabled=true;
			reData=np.receiveData;
			userData=reData.user.home[this.currArg].science;
			updateUI(reData);
			if(userData[3]==1){
				ViewManager.instance.showView(ConfigClass.VIEW_ARMY_UPGRADE_ALERT,[this.currArg,2,np.receiveData]);
				MusicManager.playSoundUI(MusicManager.SOUND_ARMY_SCIENCE_DEF);
			}else{
				//ViewManager.instance.showTipsTxt("突破成功");
				show_text(str_arr[curArmy]+Tools.getMsgById("_building8"),1);
				iSSuccess=true;
				this.pro1.value=this.pro2.value=this.pro3.value=0;
				MusicManager.playSoundUI(MusicManager.SOUND_ARMY_SCIENCE_SUC);
				//initProCom();
			}
		}

		private function updateUI(re:Object):void{
			var a:Array=["food","iron","coin","wood","food"];
			var o:Object={};
			for(var s:String in re){
				if(a.indexOf(s)!=-1){
					o[s]=re[s];
				}
			}
			ModelManager.instance.modelUser.updateData(o);
			setNumCom();//剩余的锤子数
			setConsume();//消耗值
		}


		override public function onRemoved():void{
			if(tween){
				tween.complete();
			}
			(this.boxCenter.getChildByName("armyImg"+curArmy) as Image).visible=false;
			(this.boxAtk.getChildByName("armyImg"+curArmy) as Image).visible=false;

			if(mAni && mIsComplete==false){
				mAni.destroy();
				ModelManager.instance.modelUser.updateData(reData);
				this.btn0.mouseEnabled=this.btn1.mouseEnabled=this.btn2.mouseEnabled=true;
			}
		}
		
	}

}