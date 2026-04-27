/**
 * 提词板设置选项
 */
@ObservedV2
export class PrompterConfigOptions {
  /**
   * 背景颜色
   */
  @Trace backgroundColorList: ResourceStr[] = ['#000000', '#061A39', '#E7E9EE', '#170149', '#02363A'];
  /**
   * 背景颜色
   */
  @Trace deepColorList: ResourceStr[] = ['#000000', '#061A39', '#170149', '#02363A'];
  /**
   * 字体颜色
   */
  @Trace fontColorList: ResourceStr[] = ['#FFFFFF', '#000000', '#FFFCEB', '#CED3FF', '#E8FFE4'];
  /**
   * 字体大小
   */
  @Trace fontSizeList: number[] = [10, 100];
  /**
   * 语速
   */
  @Trace speechRateList: number[] = [1, 10];
  /**
   * 倒计时
   */
  @Trace countdownList: number[] = [0, 10];
  /**
   * 倒计时
   */
  @Trace fastOrBackTimeList: number[] = [5, 15];

  init(backgroundColorList: ResourceStr[], deepColorList: ResourceStr[], fontColorList: ResourceStr[],
    fontSizeList: number[],
    speechRateList: number[],
    countdownList: number[]) {
    this.backgroundColorList = backgroundColorList;
    this.deepColorList = deepColorList;
    this.fontColorList = fontColorList;
    this.fontSizeList = fontSizeList;
    this.speechRateList = speechRateList;
    this.countdownList = countdownList;
  }
}


/**
 * 提词板设置
 */
@ObservedV2
export class PrompterConfig {
  /**
   * 背景颜色
   */
  @Trace backgroundColor: ResourceStr;
  /**
   * 字体颜色
   */
  @Trace fontColor: ResourceStr;
  /**
   * 字体大小
   */
  @Trace fontSize: number = 20;
  /**
   * 语速
   */
  @Trace speechRate: number = 2;
  /**
   * 倒计时
   */
  @Trace countdown: number = 3;
  /**
   * 提词器快进或快退秒数
   */
  @Trace fastOrBackTime: number = 5;
  /**
   * 提词器快进或快退秒数
   */
  @Trace isFlip: boolean = false;

  constructor(backgroundColor: ResourceStr, fontColor: ResourceStr) {
    this.backgroundColor = backgroundColor;
    this.fontColor = fontColor;
  }
}