package sg.model
{
	import laya.utils.Handler;
	import sg.cfg.ConfigApp;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.net.NetHttp;
	import sg.utils.Tools;
    import sg.task.model.ModelTaskDaily;
    import sg.task.model.ModelTaskTrain;
    import sg.task.model.ModelTaskBuild;
    import sg.task.model.ModelTaskOrder;
    import sg.task.model.ModelTaskPromote;
    import sg.task.model.ModelTaskCountry;
    import sg.activities.model.ModelHappy;
    import sg.explore.model.ModelExplore;
    import sg.altar.legend.model.ModelLegend;
    import sg.view.init.ViewAffiche;

	/**
	 * ...
	 * @author
	 */
	public class ModelQQDT extends ModelBase{		
		public static const EVENT_QQDT_CHANGE:String = "event_qqdt_change";
		
		static private var _instance:sg.model.ModelQQDT;

		//blue_vip_level: 0
		//figureurl: "http://qqgameplatcdn.qq.com/social_hall/face_icon/187-1.png"
		//gender: "男"
		//is_blue_vip: false
		//is_blue_year_vip: false
		//is_super_blue_vip: false
		//msg: ""
		//nickname: "LiarGame  "
		//pf: "qqgame"
		//re_params: {openid: "62619A254B22025CFD8020F0D83F60E0", pfkey: "2DD91287E81AD7DF0528E043F4F05339", access_token: "8395C51ECC4A44F9FFA650C99DF316B4", param: "", pf: "qqgame", …}
		//ret: 0
		//seq: 0
		//server_status: 0
		//uin: 0
		
		
		public function ModelQQDT(){
			
		}
		
		public function loadDT(handler:Handler):void {
			NetHttp.instance.send("user_zone.get_qqgame_blue", Tools.getURLexpToObj(ConfigApp.url_params), new Handler(this, function(data:Object):void {
				ModelQQDT.instance.data = data;					
				handler.run();
			}));
		}
		
		public static function get instance():ModelQQDT {
			return _instance ||= new ModelQQDT();
		}
		
	}


	
}