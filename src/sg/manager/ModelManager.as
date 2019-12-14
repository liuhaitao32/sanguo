package sg.manager
{
	import sg.home.model.HomeModel;
	import sg.map.model.MapModel;
	import sg.model.ModelUser;
	import sg.model.ModelGame;
	import sg.model.ModelInside;
	import sg.model.ModelProp;
	import sg.model.ModelItem;
	import sg.model.ModelTroopManager;
	import sg.model.ModelClimb;
	import sg.model.ModelGuild;
	import sg.model.ModelOfficial;
	import sg.model.ModelAlert;
	import sg.task.TaskHelper;
	import sg.achievement.model.ModelAchievement;
	import sg.model.ModelChat;
	import sg.activities.model.ModelActivities;
	import sg.guide.model.GuideChecker;
	import sg.model.ModelSettings;
	import sg.model.ModelClub;
	import sg.model.ModelShop;
	import sg.model.ModelCountryPvp;
	import sg.model.ModelArena;
	import sg.model.ModelNewTask;

	/**
	 * ...
	 * @author
	 */
	public class ModelManager{
		public static var sModelManager:ModelManager = null;
	
		public function ModelManager(){
		}
		public  static function get instance():ModelManager{
			return sModelManager ||= new ModelManager();
		}
		public var modelUser:ModelUser;
		public var modelGame:ModelGame;
		public var modelInside:ModelInside;
		public var modelProp:ModelProp;
		public var modelClimb:ModelClimb;
		public var modelGuild:ModelGuild;
		public var modelOfficel:ModelOfficial;
		public var modelAlert:ModelAlert;
		public var modelClub:ModelClub;
		public var modelCountryPvp:ModelCountryPvp;
		
		public var modelMap:MapModel = new MapModel();
		public var modelHome:HomeModel = new HomeModel();
		
		public var modelTroopManager:ModelTroopManager = new ModelTroopManager();

		public var taskHelper:TaskHelper = TaskHelper.instance;
		public var modelAchievement:ModelAchievement = ModelAchievement.instance;
		public var modelChat:ModelChat;
		public var modelSettings:ModelSettings = ModelSettings.instance;
		public var modelNewTask:ModelNewTask;
		
		public function init():void{
			this.modelGame = new ModelGame();
			this.modelUser = new ModelUser();
			this.modelCountryPvp = new ModelCountryPvp();
			this.modelInside = new ModelInside();
			this.modelProp = new ModelProp();
			this.modelClimb = new ModelClimb();
			this.modelGuild = new ModelGuild();
			this.modelOfficel = new ModelOfficial();
			this.modelAlert = new ModelAlert();
			this.modelChat = new ModelChat();
			this.modelClub = new ModelClub();
			modelNewTask = new ModelNewTask();
			ModelArena.instance;
			//
			Trace.log("===ModelManager===初始化===");
		}
		public static function clear():void{
			GuideChecker.clear();
			TaskHelper.clear();
			ModelAchievement.clear();
			ModelActivities.clear();
			ModelManager.sModelManager = null;
		}
	}

}