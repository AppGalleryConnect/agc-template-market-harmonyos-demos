import { display } from '@kit.ArkUI';

@ObservedV2
export class ExamController {
  private static _instance: ExamController;

  public static get instance() {
    if (!ExamController._instance) {
      ExamController._instance = new ExamController();
    }
    return ExamController._instance;
  }

  // Swiper控制器
  swiperController: SwiperController = new SwiperController();
  // 是否显示下一页
  showNext: boolean = false;
  originFontSize:number  = 14;
  // 字体大小
  @Trace fontSize: number = 14;
  // 按返回键时打开模拟考试弹窗
  @Trace isShowMockExamDialog: boolean = false;
  // 仅用于答题卡，点击清空记录按钮后，对RadioComponent视图重新渲染
  @Trace renderView: boolean = false;

  // 自定义字体大小缩放倍数
  @Trace fontSizeRatio: number = 1;
  // 系统字体大小缩放系数
  @Trace sysFontSizeScale: number = 1;

  // 计算得到fontsize
  public getFg(fg: number, maxRatio: number = 3.2): number | string {
    const followSys:boolean | undefined  = AppStorage.get('followSys');
    if (followSys) {
      return fg;
    }
    return this.fp2pxUtil(fg * Math.min(this.fontSizeRatio, maxRatio));
  }

  fp2pxUtil(fp: number): string {
    const pxStr: string = 'px';
    let pxVal: number = 0;
    let displayClass: display.Display | null = null;
    try {
      displayClass = display.getDefaultDisplaySync();
      pxVal = fp * (displayClass.densityDPI / 160);
    } catch (err) {}
    return pxVal + pxStr;
  }
}