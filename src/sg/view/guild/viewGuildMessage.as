package sg.view.guild
{
	import ui.guild.guildMessageUI;
	import sg.manager.ModelManager;
	import laya.ui.Box;
	import laya.utils.Handler;
	import sg.model.ModelGuild;
	import laya.ui.Label;
	import sg.utils.Tools;
	import sg.model.ModelCityBuild;
	import laya.html.dom.HTMLDivElement;

	/**
	 * ...
	 * @author
	 */
	public class viewGuildMessage extends guildMessageUI{
		public function viewGuildMessage(){
			this.list.renderHandler=new Handler(this,this.listRender);
			this.list.scrollBar.visible=false;
		}


		public override function onAdded():void{
			this.comTitle.setViewTitle(Tools.getMsgById("_guild_text02"));
			var arr:Array=ModelManager.instance.modelGuild.msg;
			arr=arr.concat();
			if(arr.length<ModelGuild.total_news){
				arr.push({msg_type:"0",msg_time:ModelManager.instance.modelGuild.add_time,data:[Tools.getMsgById("_guild_text69")]});
			}
			//arr.reverse();
			this.list.array=arr;
		}


		public function listRender(cell:Box,index:int):void{
			var _label0:Label=cell.getChildByName("label0") as Label;
			var _label1:HTMLDivElement=cell.getChildByName("label1") as HTMLDivElement;
			_label1.style.fontSize=20;
			_label1.style.color="#ffffff";		

			var o:Object=this.list.array[index];
			_label0.text=" "+Tools.dateFormat(o.msg_time,0);
			if(o.msg_type=="0"){
				_label1.innerHTML=o.data[0];
			}else if(o.msg_type=="effort"){
				_label1.innerHTML=ModelGuild.htmlStr2(o); 
			}else if(o.msg_type=="attack"){
				_label1.innerHTML=ModelGuild.htmlStr1(o);
			}else if(o.msg_type=="official"){
				_label1.innerHTML=ModelGuild.htmlStr3(o);
			}else if(o.msg_type=="mayor"){
				_label1.innerHTML=ModelGuild.htmlStr4(o);
			}else if(o.msg_type=="team_award"){
				_label1.innerHTML=ModelGuild.htmlStr5(o);
			}
		}


		public override function onRemoved():void{
			
		}
	}

}