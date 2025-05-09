import {
  ItemRestriction,
  promptAction,
  SegmentButton,
  SegmentButtonIconTextItem,
  SegmentButtonItemTuple,
  SegmentButtonOptions,
  SegmentButtonTextItem
} from '@kit.ArkUI'
import { RealTimeBus } from './realTimeBus';
import { RouteEntryVM } from 'common'
import { TravelPlan } from './TravelPlan';
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { RandomCountdown } from '../components/RandomCountdown';

@Builder
export function BusLinePlanBuilder() {
  BusLinePlan()
}

@Component
export struct BusLinePlan {
  @Provide('busLineTimeList') busLineTimeList: Map<string, RandomCountdown> = new Map()
  permissions: Array<Permissions> = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION'];
  vm: RouteEntryVM = RouteEntryVM.instance;
  @State @Watch('refreshIndex') mTabSelectedIndex: number[] = [0]
  @State @Watch('refreshPage') mCurrentIndex: number = 0;
  private context = getContext(this) as common.UIAbilityContext;
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.capsule({
    buttons: [
      { text: '实时公交', icon: $r('app.media.bus'), selectedIcon: $r('app.media.bus_select') },
      { text: '路线规划', icon: $r('app.media.route'), selectedIcon: $r('app.media.route_select') },
    ] as ItemRestriction<SegmentButtonIconTextItem>,
    imageSize: { width: '24lpx', height: '24lpx' },
    selectedBackgroundColor: $r('app.color.system_color_green'),
    selectedFontColor: $r('sys.color.font_on_primary'),
    fontColor: $r('sys.color.font_secondary'),
    fontSize: $r('sys.float.Body_M'),
    selectedFontSize: $r('sys.float.Body_M'),
    textPadding: '4lpx'
  });
  @State tabSelectedIndexes: number[] = [0];
  private controller: TabsController = new TabsController();
  scroller: Scroller = new Scroller()
  //Tabs刷新SegmentButton (Tabs => SegmentButton)
  refreshPage() {
    this.mTabSelectedIndex = [this.mCurrentIndex]
  }

  //SegmentButton刷新Tabs (SegmentButton => Tabs)
  refreshIndex() {
    this.controller.changeIndex(this.mTabSelectedIndex[0])
  }
  @Builder
  topTitle(){
    Row(){
      Text('出行')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(70)
    .padding({left:24})
    .justifyContent(FlexAlign.Start)
  }
  build() {
    NavDestination() {

      Column() {
        this.topTitle()
        Row() {
          SegmentButton({
            options: this.tabOptions,
            selectedIndexes: this.mTabSelectedIndex
          })
            .width('328lpx')
            .height('63lpx')
        }
        .height('64lpx')
        .width('330lpx')
        .margin({ bottom: '24lpx' })
        .justifyContent(FlexAlign.SpaceBetween)

        Tabs({ controller: this.controller }) {
          TabContent() {
            RealTimeBus()
          }

          TabContent() {
            TravelPlan()
          }
        }.barHeight(0)
        // .height('70%')
        .onChange((index: number) => {
          this.mCurrentIndex = index;

        })
        // 注意：如果使用onChange回调，会导致Tabs滑动切换完才会执行该回调，进而导致SegmentButton会慢一拍刷新
        // .onChange((index: number) => {
        //   this.mCurrentIndex = index;
        // })

        //使用onAnimationStart，动画开始执行至targetIndex时进行刷新
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          if (index === targetIndex) {
            return
          }
          this.mCurrentIndex = targetIndex
        })

      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')
    }
    .hideTitleBar(true)
  }
}