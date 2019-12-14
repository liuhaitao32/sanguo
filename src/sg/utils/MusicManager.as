package sg.utils {
	import laya.media.SoundChannel;
	import laya.media.SoundManager;
	import laya.utils.Browser;
	/**
	 * 游戏音乐。
	 * @author light
	 */
	public class MusicManager {
		
		public static const BG_PATH:String 		= "music/bg/";
		public static const SOUND_PATH:String 	= "music/sound/";
		public static const MUSIC_TYPE:String 	= ".aac";
		public static const SOUND_TYPE:String 	= ".aac";
		public static const SOUND_PATH_UI:String 	= SOUND_PATH + "ui/";
		public static const SOUND_PATH_HERO:String 	= SOUND_PATH + "hero/";
		public static const SOUND_PATH_FIGHT:String = SOUND_PATH + "fight/";
		

		public static const BG_MAP:String 	= BG_PATH + "map" + MUSIC_TYPE;
		public static const BG_LOGIN:String = BG_PATH + "login" + MUSIC_TYPE;
		public static const BG_HOME:String 	= BG_PATH + "home" + MUSIC_TYPE;
		public static const BG_HUNT:String 	= BG_PATH + "hunt" + MUSIC_TYPE;

		public static const SOUND_GET_REWARD:String   = "get_reward";  //获得奖励
		public static const SOUND_PUB_GET:String      = "pub_get";     //抽卡发牌
		public static const SOUND_PUB_DOWN:String     = "pub_down";    //抽卡牌落地
		public static const SOUND_GET_STAR:String     = "get_star";    //观星
		public static const SOUND_GET_BAGGAGE:String  = "get_baggage"; //辎重购买
		public static const SOUND_CLICK:String        = "click";       //点击音效
		public static const SOUND_SHOW_UI:String      = "show_ui";     //展开UI
		public static const SOUND_BUILD:String        = "build";       //建设
		public static const SOUND_BUILD_LV_UP:String  = "build_lv_up"; //建筑升级
		public static const SOUND_HERO_STAR_UP:String = "hero_star_up";  //英雄升星&英雄招募

		//2018.11.6新增
		public static const SOUND_ARMY_SCIENCE_SUC:String   = "army_science_suc";  //兵营突破兵种科技成功
		public static const SOUND_ARMY_SCIENCE_DEF:String   = "army_science_def";  //兵营突破兵种科技失败
		public static const SOUND_ARMY_MAKE:String		    = "army_make";  //兵营训练士兵
		public static const SOUND_ARMY_COMPLETE:String      = "army_complete"; //兵营训练完成
		public static const SOUND_EQUIP_MAKE:String       	= "equip_make";  //珍宝阁打造宝物
		public static const SOUND_POWER_UP:String       	= "power_up";  //最强战力提升
		public static const SOUND_TROOP_MOVE:String   	    = "troop_move";  //部队前往

		public static const SOUND_UNLOCK_FATE:String		= "unlock_fate";  //解锁宿命
		public static const SOUND_HERO_LV_UP:String   		= "hero_lv_up";  //英雄升级
		public static const SOUND_HERO_SKILL_UP:String		= "hero_skill_up";  //英雄技能升级

		public static const SOUND_PROP_RESOLVE:String		= "prop_resolve";  //问道
		public static const SOUND_UNLOCK_RIGHT:String		= "unlock_right";  //解锁爵位特权
		public static const SOUND_OFFICE_UP:String	        = "office_up";  //爵位提升

		public static const SOUND_GET_MATERIAL:String   	= "get_material";//收取钱粮木铁

		public static const SOUND_FORMATION_STAR_UP:String  = "formation_star_up"//阵法进阶
		public static const SOUND_FORMATION_LV_UP:String    = "formation_lv_up"//阵法升级
		public static const SOUND_FORMATION_CHOOSE:String   = "formation_choose"//阵法激活

		public static const SOUND_EQUIP_BOX_TEN:String      = "equip_box_ten";//轩辕铸宝十连抽
		public static const SOUND_EQUIP_BOX_SHOW:String     = "equip_box_show";//轩辕铸宝展示道具
		
		public static const SOUND_XYZ_1:String      = "xyz01";//襄阳战 创建部队
		public static const SOUND_XYZ_2:String      = "xyz02";//襄阳战 倒计时对话
		public static const SOUND_XYZ_3:String      = "xyz03";//襄阳战 开战通告
		public static const SOUND_XYZ_4:String      = "xyz04";//襄阳战 造车
		public static const SOUND_XYZ_5:String      = "xyz05";//襄阳战 造车成功
		public static const SOUND_XYZ_6:String      = "xyz06";//襄阳战 占领城门
		public static const SOUND_XYZ_7:String      = "xyz07";//襄阳战 占领襄阳
		public static const SOUND_XYZ_8:String      = "xyz08";//襄阳战 战胜通告

		public static const SOUND_ENHANCE_FAIL:String    = "enhance_fail";//强化失败
		public static const SOUND_ENHANCE_SUCCESS:String = "enhance_success";//强化成功

		///如果是chrome浏览器，捕获用户点击后可以播放声音
		public static var canPlay:Boolean;
		
		public static var lastPlayMusicTime:int = (new Date()).getTime();
		
		public function MusicManager() {
			
		}
		
		public static function miniGameShow():void {
			if (!MusicManager.musicMuted) {
				MusicManager.musicMuted = true;
				MusicManager.musicMuted = false;
			}
			
			if (!MusicManager.soundMuted) {
				MusicManager.soundMuted = true;
				MusicManager.soundMuted = false;
			}
		}
		
		public static function playBackMusic():void {
			if (parentUrl) playMusic(parentUrl);
		}
		
		public static function init():void {
			SoundManager.autoStopMusic = true;
			
			if (!Browser.onIOS && !Browser.onAndroid && !Browser.onWP && Browser.userAgent && Browser.userAgent.indexOf("Chrome") > -1){
				//Chrome浏览器下，必须等待用户响应才能播放音频
				if (Browser.document){
					Browser.document.addEventListener('click', MusicManager.setCanPlay); 
					Browser.document.addEventListener('touchend', MusicManager.setCanPlay);
				}
				MusicManager.canPlay = false;
			}else{
				MusicManager.canPlay = true;
			}
		}
		public static function setCanPlay():void {
			if (Browser.document){
				MusicManager.canPlay = true;
				if (MusicManager.currUrl)MusicManager.playMusic(MusicManager.currUrl);
				Browser.document.removeEventListener('click', MusicManager.setCanPlay); 
				Browser.document.removeEventListener('touchend', MusicManager.setCanPlay); 
			}
		}
		
		
		private static var _isMusicPlay:Boolean = false;
		private static var _isSoundPlay:Boolean = false;
		public static function pause():void {
			_isMusicPlay = MusicManager.musicMuted;
			_isSoundPlay = MusicManager.soundMuted;
			MusicManager.soundMuted = true;
			MusicManager.musicMuted = true;
		}
		
		public static function resume():void {
			MusicManager.musicMuted = _isMusicPlay;
			MusicManager.soundMuted = _isSoundPlay;
		}
		
		public static var parentUrl:String = null;
		public static var currUrl:String = null;
		public static function playMusic(url:String):void {
			parentUrl = currUrl;
			currUrl = url;
			if (!MusicManager.canPlay)	return;
			var playInterval:int = 1500;
			Laya.timer.clear(MusicManager, MusicManager._playMusicReal);
			if ((new Date()).getTime() - lastPlayMusicTime > playInterval) {
				MusicManager._playMusicReal(url);
			} else {
				Laya.timer.once(playInterval, MusicManager, MusicManager._playMusicReal, [url]);
			}
			
		}
		
		private static function _playMusicReal(url:String):void {
			lastPlayMusicTime = (new Date()).getTime();
			SoundManager.playMusic(url);
		}
		
		public static function stopMusic():void {
			SoundManager.stopMusic();
		}
		
		public static function setMusicVolume(volume:Number):void {
			SoundManager.setMusicVolume(volume);
		}
		
		/**
		 * 播放ui音效。音效可以同时播放多个。
		 * @param url			声音文件地址。
		 * @param volume		默认音量。
		 * @param loops			循环次数,0表示无限循环。
		 */
		public static function playSoundUI(url:String, volume:Number = -1, loops:int = 1):SoundChannel {
			if (!MusicManager.canPlay) return null;
			return SoundManager.playSound(SOUND_PATH_UI + url + SOUND_TYPE, loops, null, null, 0, volume);
		}
		
		/**
		 * 播放hero音效。音效可以同时播放多个。
		 * @param url			声音文件地址。
		 * @param volume		默认音量。
		 * @param loops			循环次数,0表示无限循环。
		 */
		public static function playSoundHero(url:String, volume:Number = -1, loops:int = 1):SoundChannel {
			if (!MusicManager.canPlay) return null;
			return SoundManager.playSound(SOUND_PATH_HERO + url + SOUND_TYPE, loops, null, null, 0, volume);
		}
		
		/**
		 * 播放战斗音效。音效可以同时播放多个。
		 * @param url			声音文件地址。
		 * @param volume		默认音量。
		 * @param loops			循环次数,0表示无限循环。
		 */
		public static function playSoundFight(url:String, volume:Number = -1, loops:int = 1):SoundChannel {
			if (!MusicManager.canPlay) return null;
			return SoundManager.playSound(SOUND_PATH_FIGHT + url + SOUND_TYPE, loops, null, null, 0, volume);
		}
		
		/**
		 * 背景音乐（不包括音效）是否静音。
		 */
		public static function set musicMuted(value:Boolean):void {
			SoundManager.musicMuted = value;
			if (!value) {
				MusicManager.playMusic(MusicManager.currUrl);
			}
		}
		
		public static function get musicMuted():Boolean {
			return SoundManager.musicMuted;
		}
		
		/**
		 * 所有音效（不包括背景音乐）是否静音。
		 */
		public static function set soundMuted(value:Boolean):void {
			SoundManager.soundMuted = value;
		}
		
		public static function get soundMuted():Boolean {
			return SoundManager.soundMuted;
		}
	}

}