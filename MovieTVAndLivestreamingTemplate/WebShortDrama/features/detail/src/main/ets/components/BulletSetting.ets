import { fp2pxUtil } from '@agctemplate/widgets';
import { ComponentUtils } from '@kit.ArkUI';

@ObservedV2
class NodeParams {
  @Trace value: number
  @Trace isBlock: boolean

  constructor(value: number, isBlock: boolean) {
    this.value = value;
    this.isBlock = isBlock
  }
}

let offsetX: number = 0

@ComponentV2
export struct BulletSetting {
  @Param rowsNum: number = 2;
  @Param @Once notOpacity: number = 80;
  @Param danMuSpeed: string = '适中';
  @Param danMuSize: string = '适中';
  @Local blockNodeParams: NodeParams = new NodeParams(this.notOpacity, true)
  @Event setRowsNum: Function = (set: number) => {
  };
  @Event setNotOpacity: Function = (set: number) => {
  };
  @Event setDanMuSpeed: Function = (set: string) => {
  };
  @Event setDanMuSize: Function = (set: string) => {
  };
  private uiContext: UIContext = this.getUIContext();
  @Monitor('blockNodeParams.value')
  onChange(monitor:IMonitor){
    this.setNotOpacity(monitor.value()?.now)
  }

  build() {
    Column({ space: 16 }) {
      // 显示行数
      Row() {
        Text('显示行数')
          .width(56)
          .height(19)
          .fontSize(fp2pxUtil(14))
          .fontWeight(FontWeight.Regular)
        Row() {
          ForEach(
            [1, 2, 3, 4, 5, 6],
            (item: number) => {
              Text(`${item}`)
                .accessibilityText(`设置为${item}行`)
                .width(43)
                .height(36)
                .fontSize(fp2pxUtil(14))
                .fontWeight(FontWeight.Medium)
                .borderRadius(18)
                .textAlign(TextAlign.Center)
                .fontColor(this.rowsNum === item ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
                .backgroundColor(this.rowsNum === item ? $r('sys.color.comp_background_primary') : 'transparent')
                .shadow(this.rowsNum === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                .onClick(() => {
                  this.setRowsNum(item)
                })
            },
            (item: number) => item.toString()
          )
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
        .height(36)
        .padding({ left: 1, right: 1 })
        .margin({ left: 12 })
        .borderRadius(18)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .width('100%')
      .height(48)

      // 不透明度
      Row() {
        Text('不透明度')
          .width(56)
          .height(19)
          .fontSize(fp2pxUtil(14))
          .fontWeight(FontWeight.Regular)
        Row() {
          Stack({ alignContent: Alignment.Start }) {
            Slider({
              value: $$this.blockNodeParams.value,
              style: SliderStyle.NONE,
            })
              .id('slider')
              .trackColor($r('sys.color.comp_background_tertiary'))
              .trackThickness(36)
              .trackBorderRadius(18)
              .selectedColor($r('sys.color.comp_background_tertiary'))
              .margin({ left: 12 })
              .padding({ right: 12 })
              .width('100%')
            Row(){
              textBuilder(new NodeParams(0, false))
              textBuilder(new NodeParams(100, false))
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            Row() {
              textBuilder(this.blockNodeParams)
            }
            .width('100%')
            .padding({ left: 12, right: 52 })
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height(48)

      // 弹幕速度
      Row() {
        Text('弹幕速度')
          .width(56)
          .height(19)
          .fontSize(fp2pxUtil(14))
          .fontWeight(FontWeight.Regular)
        Row() {
          ForEach(
            ['慢', '', '适中', '', '快'],
            (item: string) => {
              Text(item)
                .width(52)
                .height(36)
                .fontSize(fp2pxUtil(14))
                .fontWeight(FontWeight.Medium)
                .borderRadius(18)
                .textAlign(TextAlign.Center)
                .fontColor(this.danMuSpeed === item ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
                .backgroundColor(this.danMuSpeed === item ? $r('sys.color.comp_background_primary') : 'transparent')
                .shadow(this.danMuSpeed === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                .onClick(() => {
                  if (item) {
                    this.setDanMuSpeed(item)
                  }
                })
            },
            (item: string, index: number) => item + '_' + index.toString()
          )
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
        .height(36)
        .padding({ left: 1, right: 1 })
        .margin({ left: 12 })
        .borderRadius(18)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .width('100%')
      .height(48)

      // 弹幕字号
      Row() {
        Text('弹幕字号')
          .width(56)
          .height(19)
          .fontSize(fp2pxUtil(14))
          .fontWeight(FontWeight.Regular)
        Row() {
          ForEach(
            ['小', '', '适中', '', '大'],
            (item: string) => {
              Text(item)
                .width(52)
                .height(36)
                .fontSize(fp2pxUtil(14))
                .fontWeight(FontWeight.Medium)
                .borderRadius(18)
                .textAlign(TextAlign.Center)
                .fontColor(this.danMuSize === item ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
                .backgroundColor(this.danMuSize === item ? $r('sys.color.comp_background_primary') : 'transparent')
                .shadow(this.danMuSize === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                .onClick(() => {
                  if (item) {
                    this.setDanMuSize(item)
                  }
                })
            },
            (item: string, index: number) => item + '_' + index.toString()
          )
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
        .height(36)
        .padding({ left: 1, right: 1 })
        .margin({ left: 12 })
        .borderRadius(18)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .width('100%')
      .height(48)
    }
  }
}

@Builder
function textBuilder(param: NodeParams) {
  Text(`${param.value}%`)
    .width(52)
    .height(36)
    .fontSize(fp2pxUtil(14))
    .fontWeight(FontWeight.Medium)
    .borderRadius(18)
    .textAlign(TextAlign.Center)
    .fontColor(param.isBlock ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
    .backgroundColor(param.isBlock ? $r('sys.color.comp_background_primary') : 'transparent')
    .shadow(param.isBlock ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
    .offset({ x: param.isBlock ? `${param.value}%` : param.value === 0 ? 11 : 0 })
    .gesture(
      PanGesture({ fingers: 1, direction: PanDirection.Horizontal, distance: 5 })
        .onActionStart((event: GestureEvent) => {
          offsetX = param.value
        })
        .onActionUpdate((event: GestureEvent) => {
          if (param.isBlock) {
            const uiContext: UIContext = AppStorage.get('UIContext')!
            let componentUtils: ComponentUtils = uiContext.getComponentUtils();
            let width: number = uiContext.px2vp(componentUtils.getRectangleById('slider').size.width);
            let offsetPercent: number = Math.round((event.offsetX / width) * 100)
            let temp: number = offsetX + offsetPercent
            if (temp > 100) {
              param.value = 100
            } else if (temp < 0) {
              param.value = 0
            } else {
              param.value = temp
            }
          }
        })
    )
}