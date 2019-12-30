package sg.view.map
{
	
import sg.utils.Tools

	import ui.map.itemHeroEstateUI;
	import sg.model.ModelHero;
	import sg.manager.ModelManager;
	import sg.model.ModelSkill;
	import sg.cfg.ConfigServer;
	import sg.cfg.ConfigColor;

	/**
	 * ...
	 * @author
	 */
	public class ItemHeroEstate extends itemHeroEstateUI{

		public var type:int=0;//0.正常  1.忙碌  2.本人  3.今日已围猎
		public function ItemHeroEstate(){

		}

		public function setData(obj:Object,estate_index:*,work_type:int):void{
			//trace("-------------",obj);
			this.gray=false;
			var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(obj.hid);
			type=(hmd.getHeroEstate().status==0)?0:1;
			this.fateLabel.visible=this.bg0.visible=this.imgSelect.visible=this.imgFinish.visible=this.btnChange.visible=this.btnTH.visible=false;
			this.typeLabel.text=this.slvLabel.text=this.atkNameLabel.text=this.atkLabel.text="";
			this.nameLabel.text = hmd.getName();
			this.nameLabel.color = hmd.getNameColor();
			//this.comType.setHeroType(hmd.getType());//
			this.comHero.setHeroIcon(hmd.getHeadId(), true, hmd.getStarGradeColor());
			this.heroLv.setNum(hmd.getLv());
			//this.hlvLabel.text=hmd.getLv()+"";
			this.imgRatity.skin=hmd.getRaritySkin(true);
			var o:ModelSkill;
			if(work_type==1){
				o=ModelManager.instance.modelGame.getModelSkill("skill287");
			}else if(work_type==2){
				o=ModelManager.instance.modelGame.getModelSkill("skill281");
			}else{
				if(estate_index!=null && estate_index is int){
					var user_estate:Object=ModelManager.instance.modelUser.estate[estate_index];
					var eid:String=ConfigServer.city[user_estate.city_id].estate[user_estate.estate_index][0];
					var config_estate:Object=ConfigServer.estate.estate[eid];
					var s:String=(config_estate.hero_debris==0)?config_estate.active_get:"hero";
					s=ModelSkill.getEstateSID(s,eid);
					if(s!=""){
						o=ModelManager.instance.modelGame.getModelSkill(s);
					}
					if(obj["sortNot"]==0){
						type=3;
					}
				}
			}
			if(o){
				this.typeLabel.text=o.getName();
				this.slvLabel.text=o.getLv(hmd)+"";
			}
			//this.btnTH.visible=!(ModelHero.getEventById(hmd.id)=="");//事件
			this.btnTH.visible=(obj["event_id"] && obj["event_id"]!="");
			this.statusLabel.text=hmd.getHeroEstate().text;
			this.statusLabel.color="#FFFFFF";
		}

		public function setFate(hid1:String,hid2:String):void{
			var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(hid2);
			this.fateLabel.visible=hmd.isMyFate(hid1);
		}

		public function set4D(hmd:ModelHero,hid:String):void{
			this.atkLabel.visible=this.bg0.visible=this.atkNameLabel.visible=true;
			var hd:ModelHero=ModelManager.instance.modelGame.getModelHero(hid);
			var n:Number=hd.getTopDimensional()[2];
			this.atkNameLabel.text=hd.getTopDimensional()[0];
			this.atkLabel.text=hmd.getOneDimensional(n)+"";
		}

		public function setMine(b:Boolean):void{
			if(b){
				this.statusLabel.text=Tools.getMsgById("msg_ItemHeroEstate_0");
				this.statusLabel.color="#FF5040";
				//this.gray=true;
				//this.mouseEnabled=false;
				this.type=2;
			}
		}


		public function setSelection(b:Boolean):void{
			this.imgSelect.visible=b;
		}

		public function setBtn(b:Boolean):void{
			this.btnTH.visible=b;
		}

		public function setFinish(b:Boolean):void{
			this.imgFinish.visible=b;
		}

	}

}