/**
 * 新闻类型
 */
export enum NewsEnum {
  /**
   * 文章
   */
  Article = 0,
  /**
   * 视频
   */
  Video,
  /**
   * 动态
   */
  Post,
  /**
   * 广播
   */
  Broadcast,
  /**
   * 电视
   */
  Television
}

/**
 * 视频类型
 */
export enum VideoEnum {
  /**
   * 竖屏
   */
  Portrait = 0,
  /**
   * 横屏
   */
  Landscape,
}

/**
 * 聊天内容枚举
 */
export enum ChatEnum {
  /**
   * 文本
   */
  Text = 'text',
  /**
   * 图片
   */
  Image = 'image',
  /**
   * 时间
   */
  Time = 'time',
}

/**
 * 文本片段信息接口
 */
export interface TextSpanInfo {
  text: string; // 文本内容
  type: 'topic' | 'contact' | 'default'; // 类型
}

/**
 * 搜索生成摘要的预置关键字
 */
export const PRESET_KEYWORD = '物流';

/**
 * 搜索预置关键字生成的摘要内容
 */
export const PRESET_KEYWORD_CONTENT =
  '2026年2月6日，一列满载203吨宁夏洋葱的铁路冷链列车驶出，通过银川至青岛港 “一单制” 铁海联运奔赴马来西亚、泰国等东南亚国家。该专列由宁夏商务厅统筹，银川铁路物流中心联合中外运（宁夏）及中铁特货兰州分公司打造，创新 “铁路 + 海运” 冷链联运模式，保障鲜蔬跨国运输新鲜度与效率，助力农产品跨境物流通道升级。';