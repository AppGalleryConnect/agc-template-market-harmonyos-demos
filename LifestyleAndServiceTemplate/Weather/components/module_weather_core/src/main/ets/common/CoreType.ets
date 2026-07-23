/**
 * 实时天气
 */
export interface RealTimeWeather {
  /**
   * 采集时间
   */
  time: string;

  /**
   * 温度
   */
  temp: number;

  /**
   * 最高温度
   */
  maxTemp: number;

  /**
   * 最低温度
   */
  minTemp: number;

  /**
   * 体表温度
   */
  shellTemp: number;

  /**
   * 湿度
   */
  humidity: number;

  /**
   * 降雨概率
   */
  rain: number;

  /**
   * 相关文字描述
   */
  desc: string;

  /**
   * 相关图标描述
   */
  icon: string;

  /**
   * 气压
   */
  pressure: number;

  /**
   * 紫外线
   */
  uv: number;

  /**
   * 风向
   */
  windDir: string;

  /**
   * 风速
   */
  windSpeed: number;

  /**
   * 空气质量
   */
  airQuality: string;
}

/**
 * 每日天气
 */
export interface DailyWeather {
  /**
   * 采集时间
   */
  time: string;

  /**
   * 最高气温
   */
  maxTemp: number;

  /**
   * 最低气温
   */
  minTemp: number;

  /**
   * 白天天气描述
   */
  dayDesc: string;

  /**
   * 白天天气图标
   */
  dayIcon: string;

  /**
   * 晚上天气描述
   */
  nightDesc: string;

  /**
   * 晚上天气图标
   */
  nightIcon: string;

  /**
   * 空气质量
   */
  airQuality: string;

  /**
   * 降雨概率
   */
  rain: number;
}

/**
 * 逐小时天气
 */
export interface HourlyWeather {
  /**
   * 采集时间
   */
  time: string;

  /**
   * 当前温度
   */
  temp: number;

  /**
   * 天气描述
   */
  desc: string;

  /**
   * 天气图标
   */
  icon: string;

  /**
   * 空气质量
   */
  airQuality: string;
}

/**
 * 天气指数
 */
export interface IndicesWeather {
  /**
   * 预报日期
   */
  time: string;

  /**
   * 指数类型
   */
  type: number;

  /**
   * 指数名称
   */
  name: string;

  /**
   * 指数等级
   */
  level: number;

  /**
   * 预报名称
   */
  category: string;

  /**
   * 详细描述
   */
  text: string;

  /**
   * 显示图标
   */
  icon: string;
}

/**
 * 卡片碰撞区域（单位：px）
 */
export interface CardRect {
  x: number;
  y: number;
  width: number;
  height: number;
}