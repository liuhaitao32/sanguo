package sg.view.guild
{
	import ui.guild.guildStatisticsUI;
	import laya.ui.Box;
	import laya.ui.Label;
	import laya.utils.Handler;
	import sg.model.ModelGuild;
	import sg.manager.ModelManager;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewGuildStatistics extends guildStatisticsUI{
		public function ViewGuildStatistics(){
			this.list1.renderHandler=new Handler(this,listRender1);
			this.list2.renderHandler=new Handler(this,listRender2);

			this.btn.on(Event.CLICK,this,function():void{
				closeSelf();
				ViewManager.instance.showView(ConfigClass.VIEW_MORE_RANK_MAIN,4);
			});
			this.btn.label = Tools.getMsgById("ViewGuildStatistics_1");
		}

		public override function onAdded():void{
			this.comTitle.setViewTitle(Tools.getMsgById("_guild_text113"));
			this.text0.text=Tools.getMsgById("_guild_text111");
			this.text1.text=Tools.getMsgById("_guild_text112");
			this.list1.array=ModelManager.instance.modelGuild.getStatistics();
			this.list2.array=ModelManager.instance.modelGuild.getStatistics();
		}

		public function listRender1(cell:Box,index:int):void{
			var _name:Label=cell.getChildByName("name") as Label;
			var _num:Label=cell.getChildByName("num") as Label;
			_name.text=this.list1.array[index].text;
			_num.text=this.list1.array[index].num;
		}
		public function listRender2(cell:Box,index:int):void{
			var _name:Label=cell.getChildByName("name") as Label;
			var _num:Label=cell.getChildByName("num") as Label;
			_name.text=this.list1.array[index].text;
			_num.text=this.list1.array[index].num;
		}


		public override function onRemoved():void{

		}

		
	}

}