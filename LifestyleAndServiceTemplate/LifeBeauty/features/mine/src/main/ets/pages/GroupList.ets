import {
  UIEmpty,
  getMyGroupList,
  GetUserInfoResp,
  GroupOrderStatus,
  MyGroupInfo,
  CommonUtils,
  refund,
  RouterMap,
  RouterModule,
  UIOrderPart,
  OrderType,
} from 'utils';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function GroupListBuilder() {
  GroupList()
}

@ComponentV2
export struct GroupList {
  @Local list: MyGroupInfo[] = [];
  @Local isRefreshing: boolean = false;
  @Local userInfo: GetUserInfoResp = AppStorageV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;

  aboutToAppear(): void {
    this.queryList();
  }

  queryList() {
    getMyGroupList().then((resp) => {
      this.isRefreshing = false;
      this.list = resp as MyGroupInfo[];
    })
  }

  @Computed
  get isBindPhone() {
    return this.userInfo?.mobile !== '';
  }

  isAvailable(item: MyGroupInfo) {
    return item.status === GroupOrderStatus.AVAILABLE;
  }

  getTitle(item: MyGroupInfo) {
    if (item.status === GroupOrderStatus.REFUND) {
      return '已退款';
    }
    if (item.status === GroupOrderStatus.USE_UP) {
      return '已使用';
    }

    return '待使用';
  }

  @Builder
  GroupCard(item: MyGroupInfo) {
    Column() {
      // 上半部分
      Column({ space: 10 }) {
        Text(this.getTitle(item))
          .fontSize(12)
          .fontColor(this.isAvailable(item) ? '#0A59F7' : $r('app.color.common_grey'))
          .alignSelf(ItemAlign.End)

        UIOrderPart({
          goodInfo: {
            type: OrderType.GROUP,
            id: item.groupId,
            title: item.title,
            subTitle: item.subTitle,
            vipPrice: item.vipPrice,
            image: item.images[0] ?? '',
          },
        })
      }
      .padding(10)
      .width('100%')
      .backgroundColor(Color.White)
      .borderWidth(this.isAvailable(item) ? { bottom: 0.5 } : 0)
      .borderColor($r('app.color.grey_20'))
      .borderRadius({
        topLeft: 8,
        topRight: 8,
        bottomLeft: this.isAvailable(item) ? 0 : 8,
        bottomRight: this.isAvailable(item) ? 0 : 8,
      })
      .onClick(() => {
        RouterModule.push({ url: RouterMap.MY_BOOK_GROUP_DETAIL, param: item });
      })

      // 下半部分
      if (this.isAvailable(item)) {
        Row() {
          Button() {
            Text('退款')
              .fontSize(14)
              .fontWeight(500)
              .width(56)
              .height(20)
              .textAlign(TextAlign.Center)
          }
          .backgroundColor('#F2F2F2')
          .padding({
            top: 4,
            bottom: 4,
            left: 8,
            right: 8,
          })
          .onClick(() => {
            refund(item.orderNo).then(() => {
              CommonUtils.openNoticeDialog('已提交退款申请，等待商家退款，退款成功将短信通知您', '好的', () => {
                this.queryList();
              });
            });
          })
        }
        .width('100%')
        .padding(10)
        .backgroundColor(Color.White)
        .borderRadius({ bottomLeft: 8, bottomRight: 8 })
        .justifyContent(FlexAlign.End)
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isBindPhone && this.list.length) {
          Refresh({ refreshing: $$this.isRefreshing }) {
            Scroll() {
              Column({ space: 8 }) {
                ForEach(this.list, (item: MyGroupInfo) => {
                  this.GroupCard(item)
                }, (v: MyGroupInfo) => JSON.stringify(v))
              }
            }
            .width('100%')
            .height('100%')
            .align(Alignment.Top)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .padding(10)
          }
          .layoutWeight(1)
          .onRefreshing(() => {
            this.queryList();
          })
        } else {
          UIEmpty({ emptyDesc: this.isBindPhone ? '暂无团购记录' : '关联手机号后查看团购记录' })
            .margin({ top: 140, bottom: 20 })
        }
      }
      .width('100%')
    }
    .title('团购', { backgroundColor: Color.White })
    .backgroundColor($r('app.color.common_page_bg'))
  }
}

