package sg.view.inside
{
	import ui.inside.propResolveCheckUI;
	import laya.ui.Box;
	import laya.utils.Handler;
	import laya.ui.Label;
	import sg.model.ModelSkill;
	import sg.manager.ModelManager;
	import sg.model.ModelHero;
	import laya.ui.List;
	import laya.events.Event;
	import laya.ui.CheckBox;
	import sg.manager.ViewManager;
	import sg.model.ModelUser;
	import laya.ui.Button;
	import laya.maths.MathUtil;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.map.utils.ArrayUtils;

	/**
	 * ...
	 * @author
	 */
	public class ViewPropResolveCheck extends propResolveCheckUI{
		public var titleText:Array = [
			Tools.getMsgById("_public37"),Tools.getMsgById("_public38"),Tools.getMsgById("_public39"),Tools.getMsgById("_public40")];
		public var list_arr:Array=[];
		public var skillData1:Array=[];
		public var skillData2:Array=[];
		public var skillData3:Array=[];
		public var skillData4:Array=[];
		public var prevItem:Item;
		//public var skill_arr:Array=[];
		public var skillID:String="";
		public var skillIndex:int=0;//选中技能的列表
		public function ViewPropResolveCheck(){
			this.comTitle.setViewTitle(Tools.getMsgById("_star_text20"));
			this.nameLabel1.text=titleText[0];
			this.nameLabel2.text=titleText[1];
			this.nameLabel3.text=titleText[2];
			this.nameLabel4.text=titleText[3];
			this.pan.vScrollBar.visible=false;
			this.btn.on(Event.CLICK,this,function():void{
				closeSelf();
			});
			this.btn.label = Tools.getMsgById('_public183');
		}

		override public function onAdded():void{
			//skill_arr=[];
			skillID="";
			skillIndex=-1;
			list_arr=[this.skillList1,this.skillList2,this.skillList3,this.skillList4];
		 	setdata();		
			this.skillList1.itemRender=Item;
			this.skillList2.itemRender=Item;
			this.skillList3.itemRender=Item;
			this.skillList4.itemRender=Item;	
			this.skillList1.scrollBar.visible=false;
			this.skillList2.scrollBar.visible=false;
			this.skillList3.scrollBar.visible=false;
			this.skillList4.scrollBar.visible=false;
			this.skillList1.renderHandler=new Handler(this,skillListRender1);
			this.skillList2.renderHandler=new Handler(this,skillListRender2);
			this.skillList3.renderHandler=new Handler(this,skillListRender3);
			this.skillList4.renderHandler=new Handler(this,skillListRender4);
		}

		public function setdata():void{
			var allSkins:Object=ConfigServer.skill;
			var allHeros:Object=ModelManager.instance.modelUser.hero;
			skillData1=[];
			skillData2=[];
			skillData3=[];
			skillData4=[];
			for(var s:String in allSkins)
			{
				if(s.indexOf("skill")!=-1){
					var o:Object={};
					o["id"]=s;
					o["type"]=allSkins[s].type;
					o["name"]=allSkins[s].name;
					o["have"]=0;
					var itemSkill:ModelSkill=ModelManager.instance.modelGame.getModelSkill(s);
					for(var h:String in allHeros){
						var itemHero:ModelHero=ModelManager.instance.modelGame.getModelHero(h);
						if(itemSkill.isResolve(itemHero)){
							o["have"]=1;
							break;
						}
					}
					if(o["type"]==4){
						skillData1.push(o);
					}else if(o["type"]>=0 && o["type"]<=3){
						skillData2.push(o);
					}else if(o["type"]==5){
						skillData3.push(o);
					}else if(o["type"]==6){
						skillData4.push(o);
					}
				}
			}
			
			skillData1.sort(MathUtil.sortByKey("have",true,true));
			//skillData2.sort(MathUtil.sortByKey("have",true,true));
			ArrayUtils.sortOn(["have","type"],skillData2,true);
			skillData3.sort(MathUtil.sortByKey("have",true,true));
			skillData4.sort(MathUtil.sortByKey("have",true,true));
			this.skillList1.array=skillData1;
			this.skillList2.array=skillData2;
			this.skillList3.array=skillData3;
			this.skillList4.array=skillData4;
			//trace("==============================",skillData1);
			//trace("==============================",skillData2);
			//trace("==============================",skillData3);
			//trace("==============================",skillData4);
			setPanel();
		}

		public function setPanel():void{
			this.skillList1.height=Math.ceil(this.skillData1.length/3)*65+5;
			this.box1.height=this.nameLabel1.height+this.skillList1.height;

			this.skillList2.height=Math.ceil(this.skillData2.length/3)*65+5;
			this.box2.height=this.nameLabel1.height+this.skillList2.height;

			this.skillList3.height=Math.ceil(this.skillData3.length/3)*65+5;
			this.box3.height=this.nameLabel1.height+this.skillList3.height;

			this.skillList4.height=Math.ceil(this.skillData4.length/3)*65+5;
			this.box4.height=this.nameLabel1.height+this.skillList4.height + 20;

			box2.y=box1.height+20;
			box3.y=box2.y+box2.height+20;
			box4.y=box3.y+box3.height+20;

			//trace(this.box1.height,this.box1.y);
			//trace(this.box2.height,this.box2.y);
			//trace(this.box3.height,this.box3.y);
			//trace(this.box4.height,this.box4.y);
		}

		public function skillListRender1(cell:Item,index:int):void{
			cell.setdata(skillData1[index]);
			cell.off(Event.CLICK,this,checkClick);
			cell.on(Event.CLICK,this,checkClick,[cell,skillData1[index].id,0]);
		}
		public function skillListRender2(cell:Item,index:int):void{
			cell.setdata(skillData2[index]);
			cell.off(Event.CLICK,this,checkClick);
			cell.on(Event.CLICK,this,checkClick,[cell,skillData2[index].id,1]);
		}
		public function skillListRender3(cell:Item,index:int):void{
			cell.setdata(skillData3[index]);
			cell.off(Event.CLICK,this,checkClick);
			cell.on(Event.CLICK,this,checkClick,[cell,skillData3[index].id,2]);
		}
		public function skillListRender4(cell:Item,index:int):void{
			cell.setdata(skillData4[index]);
			cell.off(Event.CLICK,this,checkClick);
			cell.on(Event.CLICK,this,checkClick,[cell,skillData4[index].id,3]);
		}

		public function checkClick(c:Item,s:String,index:int):void{
			if(c.gray){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_building30"));//没有对应技能的英雄碎片
				return;
			}
			if(skillID!=""){
				prevItem.btnCheck.selected=false;
				if(skillID!=s){
					skillID=s;
					c.btnCheck.selected=true;
					prevItem=c;
					skillIndex=index;
				}else{
					skillID="";
					skillIndex=-1;
				}
			}else{
				skillID=s;
				c.btnCheck.selected=true;
				prevItem=c;
				skillIndex=index;
			}
			/*
			if(!skill_arr.hasOwnProperty(s)){
					skill_arr.push(s);
					c.label="1";
					c.selected=true;
			}else{
				var n:int=skill_arr.indexOf(s);
				if(n!=-1){
					skill_arr.splice(n,1);
					c.selected=false;
				}
			}*/
			
		}


		override public function onRemoved():void{
			if(skillID!=""){
				ModelManager.instance.modelUser.event(ModelUser.EVENT_PROP_CHECK,skillID);
			}
		}
	}

}


import ui.com.skillItemUI;
import laya.events.Event;
import sg.utils.Tools;
import sg.model.ModelSkill;
import sg.manager.ModelManager;
import laya.ui.Button;

class Item extends skillItemUI{

	public var btnCheck:Button;
	public function Item(){
		btnCheck=this.getChildByName("btnCheck") as Button;
		btnCheck.visible=true;
		btnCheck.mouseEnabled=false;
	}

	public function setdata(obj:Object):void{
		//this.typeIcon.skin="";
		var itemSkill:ModelSkill=ModelManager.instance.modelGame.getModelSkill(obj.id);
		//this.nameLabel.text=Tools.getMsgById(obj.name);
		//this.lvLabel.text="";
		this.setSkillItem(itemSkill,null);
		this.setSkillBgColor(2,null);
		this.btnCheck.visible=true;
		this.btnCheck.selected=false;
		if(obj["have"]==0){
			this.gray=true;
		}else{
			this.gray=false;
		}
	}
}
