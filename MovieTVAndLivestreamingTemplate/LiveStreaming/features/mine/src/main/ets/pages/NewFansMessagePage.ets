import { RouterModule } from '@agctemplate/router_module';
import { BarVM } from '@agctemplate/widgets';
import { TopBar } from '../component/TopBar';
import { AppStorageV2 } from '@kit.ArkUI';
import { deleteMyFollowing, getMyFollower } from '@agctemplate/server/src/main/ets/api/mock/mockLiveFactory';
import { Audience, LiveInteractionMgr } from 'live_interaction';
import { addFollowing, deleteFollowing, getFollowers } from '@agctemplate/detail/src/main/ets/models/AudienceData';

@ComponentV2
struct NewFansMessagePage {
  @Local newFansList: NewFansList = AppStorageV2.connect(NewFansList, () => new NewFansList())!
  liveInteractionMgr: LiveInteractionMgr = new LiveInteractionMgr()

  async aboutToAppear(): Promise<void> {
    // 模拟取粉丝后六位作为新粉丝
    this.newFansList.listArr.forEach(item => item.isRead = true)
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部
        this.topBuilder();
        Column() {
          if (this.newFansList.listArr.length > 0) {
            // 我的课程列表
            this.NewFansItemsBuilder()

          } else {
            Text('当前暂无新增粉丝。')
              .height('100%')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.icon_secondary'))
          }
        }
        .width('100%')
        .height('100%')
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .width('100%')
      .height('100%')
      .padding({ top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH })
    }.hideTitleBar(true)
    .onBackPressed(() => {
      RouterModule.pop('result')
      return true
    })
  }

  @Builder
  topBuilder() {
    Row() {
      TopBar({
        onClickBack: () => {
          RouterModule.pop('result')
        },
        title: '新增粉丝'
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
  }

  @Builder
  NewFansItemsBuilder() {
    List({ space: 0 }) {
      ForEach(this.newFansList.listArr, ((item: NewFansItem, index: number) => {
        ListItem() {
          Row() {
            Row() {
              Image(item.fansInfo.avatar)
                .width($r('app.float.vp_40'))
                .height($r('app.float.vp_40'))
              Text(item.fansInfo.nickName)
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Regular)
                .height(21)
                .margin({ left: 8 })
            }
            .alignItems(VerticalAlign.Center)

            Row() {
              Text(item.fansInfo.isFocused ? '互相关注' : '回关')
                .height(28)
                .width(72)
                .fontSize(14)
                .textAlign(TextAlign.Center)
                .borderRadius(14)
                .fontColor(item.fansInfo.isFocused ? '#EE5D1A' : $r('sys.color.comp_background_primary'))
                .backgroundColor(item.fansInfo.isFocused ? $r('sys.color.comp_background_tertiary') : '#EE5D1A')
                .onClick(() => {
                  if (item.fansInfo.isFocused) {
                    deleteFollowing(item.fansInfo.id)
                  }else {
                    addFollowing(item.fansInfo.id)
                  }
                  item.fansInfo.isFocused = !item.fansInfo.isFocused
                })
            }
            .height(40)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Top)
          .height(64)
        }
        .borderRadius($r('app.float.vp_16'))
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .margin({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), })
      }), (item: NewFansItem, index: number) => item.fansInfo.id + index)
    }
    .padding({
      top: $r('app.float.vp_20'),
      bottom: $r('app.float.vp_46')
    })
    .width('100%')
    .scrollBar(BarState.Off)
  }
}

@ObservedV2
export class NewFansList {
  @Trace listArr: NewFansItem[] = []

  constructor() {
    this.initData()
  }

  async initData(): Promise<void> {
    const ids = getMyFollower().slice(-6)
    const fansInfoList = await getFollowers(ids)
    this.listArr = fansInfoList.map(fansInfo => new NewFansItem(fansInfo, false))
  }
}

@ObservedV2
class NewFansItem {
  fansInfo: Audience
  @Trace isRead: boolean;

  constructor(fansInfo: Audience, isRead: boolean = false) {
    this.fansInfo = fansInfo
    this.isRead = isRead
  }
}

@Builder
export function NewFansMessagePageBuilder() {
  NewFansMessagePage()
}