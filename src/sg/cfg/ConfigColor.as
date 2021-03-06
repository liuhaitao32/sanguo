package sg.cfg
{
    public class ConfigColor{
        public static const TXT_STATUS_OK:String = "#e2eaff";//#afff68
        public static const TXT_STATUS_NO:String = "#ff6655";
        public static const TXT_STATUS_OK_GREEN:String = "#afff68";
		/**
		 * 0 金色 1 红色 2 紫色 3 绿色
		 */
		public static const COLOR_RUNE_FTYPE:Object = {
			0:[
				0.9, 0.5, 0.5, 0, 0,
				0.8, 0.6, 0.4, 0, 0,
				0.2, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],	
			1:[
				1, 0, 0, 0, 0,
				0, 1, 0, 0, 0,
				0, 0, 1, 0, 0,
				0, 0, 0, 1, 0,
			],	
			2:[
				0.8, 0.3, 0.3, 0, 0,
				0.2, 0.4, 0.2, 0, 0,
				0.8, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],	
			3:[
				0.1, 0.8, 0, 0, 0,
				0.9, 0.5, 0, 0, 0,
				0.2, 0, 0.2, 0, 0,
				0, 0, 0, 1, 0,
			]									
		}

		///使用变色滤镜时，对应不同type的颜色矩阵  -1无效灰0白1绿2蓝3紫4金5红
		public static const COLOR_FILTER_MATRIX:Object = {
			'-1':[
				0.2, 0.2, 0.2, 0, 0,
				0.2, 0.2, 0.2, 0, 0,
				0.2, 0.2, 0.2, 0, 0,
				0, 0, 0, 1, 0,
			],
			'0':[
				0.6, 0.2, 0.2, 0, 0,
				0.6, 0.2, 0.2, 0, 0,
				0.6, 0.2, 0.2, 0, 0,
				0, 0, 0, 1, 0,
			],
			'1':[
				0.2, 0.3, 0.3, 0, 0,
				0.7, 0.3, 0.3, 0, 0,
				0.2, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],
			'2':[
				0.3, 0.2, 0.3, 0, 0,
				0.5, 0.5, 0.3, 0, 0,
				0.8, 0.2, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],
			'3':[
				0.8, 0.3, 0.3, 0, 0,
				0.2, 0.4, 0.2, 0, 0,
				0.8, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],
			'4':[
				1, 0.5, 0.5, 0, 0,
				0.7, 0.8, 0.4, 0, 0,
				0.2, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			]
		};
		
		///使用变色滤镜时，对应不同type的颜色 色相 饱和度 亮度  -1无效灰0白1绿2蓝3紫4金5红
		public static const COLOR_FILTER_TRANS:Object = {
			//色相,饱和度,亮度
			'-1':[0, 0, 0.5],    //无效灰
			'0':[0, 0, 1],      //白
			'1':[0.62, 0.65, 1],    //绿
			'2':[0.44, 1.1, 1],    //蓝
			'3':[0.14, 1.5, 1],    //紫
			'4':[0.86, 1.6, 1],    //金
			'5':[0, 1, 1]        //红
		};
		
		///比武膜拜，对应不同type的颜色矩阵  0金1银2暗铜3亮铜
		public static const COLOR_WORSHIP:Object = {	
			1:[
				0.7, 0.2, 0.3, 0, 0,
				0.9, 0.3, 0.2, 0, 0,
				1, 0.2, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],
			2:[
				0.6, 0.3, 0.3, 0, 0,
				0.1, 0.4, 0.2, 0, 0,
				0, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],
			3:[
				0.8, 0.3, 0.3, 0, 0,
				0.1, 0.6, 0.2, 0, 0,
				0, 0.4, 0.4, 0, 0,
				0, 0, 0, 1, 0,
			]	
		}
		
		///修改纯红图到奖牌颜色，对应不同type的颜色矩阵  0金1银2铁
		public static const COLOR_MEDAL:Object = {	
			0:[
				0.9, 0.3, 0.3, 0, 0,
				0.55, 0.5, 0.2, 0, 0,
				0, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],	
			1:[
				0.85, 0.2, 0.3, 0, 0,
				0.85, 0.3, 0.2, 0, 0,
				0.9, 0.2, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],
			2:[
				0.5, 0.5, 0.4, 0, 0,
				0.5, 0.5, 0.4, 0, 0,
				0.5, 0.5, 0.4, 0, 0,
				0, 0, 0, 1, 0,
			]		
		}
		/**
		 * 0黄1白2橙
		 */
		public static const COLOR_CHAMPION_RANK:Object = {
			0:[
				0.9, 0.5, 0.5, 0, 0,
				0.8, 0.6, 0.4, 0, 0,
				0.2, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],			
			1:[
				0.8, 0.4, 0.4, 0, 0,
				0.7, 0.4, 0.4, 0, 0,
				0.6, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],
			2:[
				1, 0.5, 0.5, 0, 0,
				0.6, 0.6, 0.4, 0, 0,
				0.2, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			]		
			
		}
		///无效字字体颜色 
		public static const FONT_COLOR_NULL:String = "#666666";
		///使用变色时，对应不同lv的字体颜色  0白1绿2蓝3紫4金5红
		public static const FONT_COLORS:Array = ["#F0F0F0", "#20E020", "#20BBFF", "#F860FF", "#FFCC40", "#FF5040"];
		
		///使用变色描边时（白色字），对应不同lv的字体颜色  0白1绿2蓝3紫4金5红
		public static const FONT_STROKE_COLORS:Array = ["#666666", "#22AA22", "#2266BB", "#9933CC", "#EE8822", "#EE4422"];

		public static const FONT_COLORS_OTHER:Array = ["#ffff81"];//黄

		///难度颜色值  简单/普通/困难
		public static const FONT_COLORS_BY_DIFF:Array = ["#83afff", "#d583ff", "#ff8a50"];
		
		//public static var FONT_COLOR_STR:Array = ["白色","绿色","蓝色","紫色","金色","红色"];
		
		///使用变色滤镜时，对应不同type的颜色矩阵(战斗中伤害专用)  0灰1白2黄3橙4红5绿6粉7蓝
		public static const DAMAGE_COLOR_FILTER_MATRIX:Object = {
			0:[
				0.7, 0.3, 0.3, 0, 0,
				0.7, 0.3, 0.3, 0, 0,
				0.7, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],
			1:[
				0.8, 0.4, 0.4, 0, 0,
				0.7, 0.4, 0.4, 0, 0,
				0.6, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],
			2:[
				0.9, 0.5, 0.5, 0, 0,
				0.8, 0.6, 0.4, 0, 0,
				0.2, 0.3, 0.3, 0, 0,
				0, 0, 0, 1, 0,
			],
			3:[
				1, 0.5, 0.5, 0, 0,
				0.4, 0.4, 0.4, 0, 0,
				0.2, 0.2, 0.2, 0, 0,
				0, 0, 0, 1, 0,
			],
			5:[
				0.1, 0.8, 0.3, 0, 0,
				0.9, 0, 0.4, 0, 0,
				0.05, 0, 0, 0, 0,
				0, 0, 0, 1, 0,
			],
			6:[
				1, 0.7, 0.5, 0, 0,
				0.9, 0.9, 0.5, 0, 0,
				0.3, 0.5, 0.2, 0, 0,
				0, 0, 0, 1, 0,
			],
			7:[
				0, 0.7, 0.5, 0, 0,
				0.2, 0.9, 0.8, 0, 0,
				1, 0.5, 0.2, 0, 0,
				0, 0, 0, 1, 0,
			]
		};
		
		///使用饱和度滤镜时，RGB分别的分量
		public static const RGB_BRIGHTNESS:Array = [0.2126, 0.7152, 0.0722];
		
		///找到英雄品质对应的背景粒子配置[粒子资源，每秒发射，最大粒子，相对于英雄X，相对于英雄Y，是否顶层]  
		public static const PARTICLE_CONFIG_BY_HERO_RARITY:Object = {
			0:[],
			1:[['p004', 20, 400, 320, 600, 1]],
			//2:[['p003', 30, 600, 320, 600, 1]],
			2:[['p003', 30, 600, 320, 600, 1],['p004', 30, 600, 320, 600, 1]],
			3:[['p001', 10, 200, 320, 200, 1]],
			4:[['p008', 2, 2, 320, 320, 0],['p009', 30, 600, 320, 320, 1]]
		}
		///找到英雄觉醒对应的背景粒子配置[粒子资源，每秒发射，最大粒子，相对于英雄X，相对于英雄Y，是否顶层]  
		public static const PARTICLE_CONFIG_AWAKEN:Array = [['p014', 60, 800, 320, 400, 0]];

		
    }


		
}