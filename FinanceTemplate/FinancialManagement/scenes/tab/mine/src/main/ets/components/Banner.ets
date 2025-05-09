import { display, window } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';

@ComponentV2
export struct Banner {
  @Param
  private x: number = 16;
  @Param
  private y: number = 9;
  @Local
  private _swiperHeight: string = '0px';
  @Local
  private _swiperBottomAnchor: string = '0px';
  private readonly _ID: string = util.generateRandomUUID(false);

  async aboutToAppear(): Promise<void> {
    let _display: display.Display = display.getDefaultDisplaySync();
    let screenWidth: number = _display.width;

    let iWindow: window.Window = await window.getLastWindow(getContext(this));
    let avoidAreaByTypeSystem: window.AvoidArea = iWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    let topAvoidHeight: number = avoidAreaByTypeSystem.topRect.height;
    let swiperHeight: number = screenWidth / this.x * this.y;
    this._swiperHeight = swiperHeight + 'px';
    this._swiperBottomAnchor = swiperHeight - topAvoidHeight + 'px';
  }

  build() {
    RelativeContainer() {
      Column()
        .height(this._swiperBottomAnchor)
        .width('100%')
        .id(this._ID)
      Row()
        .width('100%')
        .height(this._swiperHeight)
        .alignRules({
          'bottom': { 'anchor': this._ID, 'align': VerticalAlign.Bottom },
          'left': { 'anchor': this._ID, 'align': HorizontalAlign.Start }
        })
        .linearGradient({
          direction: GradientDirection.Bottom, // 渐变方向
          repeating: true, // 渐变颜色是否重复
          colors: [[0xFEE0C8, 0.0], [0xF3E8E0, 0.56], [0xF1F3F5, 1]] // 数组末尾元素占比小于1时满足重复着色效果
        })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .width('100%')
    .height('auto')
  }
}