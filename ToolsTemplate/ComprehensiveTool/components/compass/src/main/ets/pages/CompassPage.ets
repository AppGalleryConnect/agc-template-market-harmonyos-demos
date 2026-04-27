import { CompassView } from '../components/CompassView';
import { CompassController } from '../controller/CompassController';
import { common } from '@kit.AbilityKit';
import { CompassItem } from '../model/Index';
import { COMPASS_LIST } from '../common/Constants';
import { PersistenceV2 } from '@kit.ArkUI';

const TAG: string = '[CompassPage]';

@Builder
export function CompassPageBuilder() {
  CompassPage();
}

@Preview
@ComponentV2
struct CompassPage {
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local compassList: CompassItem[] = COMPASS_LIST;
  @Local angle: number = 0;
  @Local pitch: number = 0;
  @Local roll: number = 0;
  @Local angleShow: ResourceStr = $r('app.string.N', 0);
  @Local sittingAngleShow: ResourceStr = $r('app.string.S', 0);
  @Local sittingDirection: string = ''; // 坐山
  @Local facingDirection: string = ''; // 朝向
  @Local hasPermission: boolean = false
  @Local isLock: boolean = false
  @Local compassBg: CompassItem =
    PersistenceV2.connect(CompassItem, () => new CompassItem(0, $r('app.media.compass_1')))!;
  @Local controller: CompassController = new CompassController();

  aboutToAppear(): void {
    this.controller.setAngleUpdateListener((angle: number, pitch: number, roll: number) => {
      if (this.isLock) {
        return
      }
      this.angle = angle;
      this.pitch = pitch;
      this.roll = roll;
      this.angleShow = this.controller.getBasicDirectionName(this.angle);
      let sittingAngle = this.controller.calculateSittingAngle(this.angle)
      this.sittingAngleShow = this.controller.getBasicDirectionName(sittingAngle);
      // 获取二十四山名称
      this.facingDirection = this.controller.findMountain(this.angle);
      this.sittingDirection = this.controller.findMountain(sittingAngle);
    });
  }

  aboutToDisappear(): void {
    this.controller.destroy()
  }

  build() {
    NavDestination() {
      // 方向
      Scroll() {
        Column() {
          Row() {
            Column({ space: 8 }) {
              Text('坐')
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Medium)
              Text(this.sittingAngleShow)
                .fontSize($r('sys.float.Subtitle_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
            }.layoutWeight(1)

            Column({ space: 8 }) {
              Text('向')
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Medium)
              Text(this.angleShow)
                .fontSize($r('sys.float.Subtitle_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
            }.layoutWeight(1)

            Column({ space: 8 }) {
              Text('横')
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Medium)
              Text(`${this.roll}°`)
                .fontSize($r('sys.float.Subtitle_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
            }.layoutWeight(1)

            Column({ space: 8 }) {
              Text('竖')
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Medium)
              Text(`${this.pitch}°`)
                .fontSize($r('sys.float.Subtitle_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
            }.layoutWeight(1)
          }
          .width('100%')
          .borderRadius(16)
          .margin({ top: 8 })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .padding({
            top: 16,
            bottom: 16,
            left: 12,
            right: 12,
          })

          // 罗盘
          CompassView({ compassBg: this.compassBg, angle: this.angle }).margin({ top: 24 }).zIndex(2000)

          // 角度方位
          Row() {
            Text() {
              Span(this.angleShow)
              Span(`${this.angle}°`)
            }
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)

            Text() {
              Span('坐')
              Span(this.sittingDirection)
              Span('向')
              Span(this.facingDirection)
            }
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 12, right: 12 }).margin({ top: 16 })

          // 罗盘皮肤
          List({ space: 88 }) {
            ForEach(this.compassList, (item: CompassItem) => {
              ListItem() {
                Row() {
                  Image(item.name).width(48).height(48)
                }
                .padding(4)
                .layoutWeight(1)
                .borderRadius(28)
                .backgroundColor($r('sys.color.comp_background_primary'))
                .border(this.compassBg.id === item.id ? { width: 2, color: '#955D0C' } : { width: 0 })
                .onClick(() => {
                  if (this.compassBg.id !== item.id) {
                    this.compassBg.update(item)
                  }
                })
              }
            }, (item: CompassItem) => item.id.toString())
          }
          .listDirection(Axis.Horizontal)
          .height(56)
          .margin({ top: 70 })
        }
      }
      .height('100%')
      .width('100%')
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({ left: 16, right: 16 })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }.title(this.navBarBuilder()).onShown(() => {
      this.controller.getAngle();
    })
  }

  @Builder
  navBarBuilder() {
    Row() {
      Text('罗盘')
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
      Image(this.isLock ? $r('app.media.ic_locked') : $r('app.media.ic_unlock')).width(40).onClick(() => {
        this.isLock = !this.isLock
      })
    }
    .height(56)
    .layoutWeight(1)
    .margin({ left: 8, right: 16 })
    .padding({ top: 8, bottom: 8 })
    .constraintSize({ maxWidth: '100%' })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}