package sg.model
{
	import sg.utils.Tools;
	import sg.utils.SaveLocal;

	/**
	 * ...
	 * @author
	 */
	public class ModelRank extends ModelBase{
		
		public static var interval_time:Number=1000;//间隔毫秒


		public static var rank_power:Array;//个人战力榜
		public static var rank_hero_power:Array;//英雄战力榜
		public static var rank_kill_num:Array;//个人击杀榜
		public static var rank_guild_kill:Array;//军团击杀榜
		public static var rank_build_num:Array;//个人建设榜
		//public static var rank_type:Array=['power','hero_power', 'kill_num', 'guild_kill','build_num'];


		public static var tabData:Array=[
										{txt:Tools.getMsgById("_more_rank01"),index:0,type_key:"power"},
										{txt:Tools.getMsgById("_more_rank02"),index:1,type_key:"hero_power"},
										{txt:Tools.getMsgById("_more_rank03"),index:2,type_key:"kill_num"},//这个榜改成每日的了 2019.3.30
										{txt:Tools.getMsgById("_more_rank04"),index:3,type_key:"build_num"},
										//{txt:Tools.getMsgById("_more_rank05"),index:4,type_key:"guild_kill"}
										];

		//查看榜单状态 0 国家  1 所有
		public static var rankStatus:Object={"kill_num":0,"power":0,"hero_power":0,"build_num":0}

		public function ModelRank(){
			
		}





	}

}