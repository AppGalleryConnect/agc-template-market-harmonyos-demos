import {
  CommonUtils,
  getGroupList,
  GetUserInfoResp,
  IGroupInfo,
  LoginButtonType4,
  OrderType,
  RouterMap,
  RouterModule,
  SimpleGoodInfo,
} from 'utils'
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct GroupBuy {
  @Require @Param groupInfo: IGroupInfo;
  @Local userInfo: GetUserInfoResp = AppStorageV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;

  buildRouteParam() {
    const param = new SimpleGoodInfo();
    param.type = OrderType.GROUP;
    param.id = this.groupInfo.id;
    param.title = this.groupInfo.title;
    param.subTitle = this.groupInfo.subTitle;
    param.vipPrice = this.groupInfo.vipPrice;
    param.image = this.groupInfo.images[0] ?? '';
    return param;
  }

  jumpOrder() {
    const param = this.buildRouteParam();
    RouterModule.push({ url: RouterMap.SUBMIT_ORDER, param: param });
  }

  build() {
    Row({ space: 7 }) {
      Image(CommonUtils.handleImgUrl(this.groupInfo.images[0])).width(86).aspectRatio(1).borderRadius(8)
      Column() {
        Text(this.groupInfo.title)
          .fontSize(14)
          .fontWeight(500)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row() {
          Text('随时退·过期自动退').fontSize(12).fontColor($r('app.color.common_grey'))
          Blank()
          Text(`年售${this.groupInfo.soldNum}+`).fontSize(12).fontColor($r('app.color.common_grey'))
        }
        .width('100%')
        .margin({ top: 6 })

        Blank()
        Row() {
          Text('￥' + CommonUtils.handleCash(this.groupInfo.vipPrice)).fontSize(14).fontColor('#E84026').fontWeight(500)
          Text('￥' + CommonUtils.handleCash(this.groupInfo.price))
            .fontSize(10)
            .decoration({ type: TextDecorationType.LineThrough })
            .margin({ left: 7 })
          Blank()
          if (this.userInfo.mobile) {
            Button() {
              Text('抢购')
                .fontSize(14)
                .fontWeight(500)
                .width(56)
                .height(20)
                .fontColor(Color.White)
                .textAlign(TextAlign.Center)
            }
            .padding({
              top: 4,
              bottom: 4,
              left: 8,
              right: 8,
            })
            .backgroundColor($r('app.color.common_theme_color'))
            .onClick(() => {
              this.jumpOrder();
            })
          } else {
            LoginButtonType4({
              onBind: () => {
                this.jumpOrder();
              },
            })
              .onClick(() => {
              })
          }

        }
        .width('100%')
      }
      .height(86)
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .onClick(() => {
      RouterModule.push({ url: RouterMap.GROUP_DETAIL, param: this.groupInfo });
    })
  }
}

@ComponentV2
export struct GroupBuyList {
  @Local list: IGroupInfo[] = [];

  aboutToAppear(): void {
    getGroupList().then((resp) => {
      this.list = resp;
    })
  }

  build() {
    Column({ space: 10 }) {
      Text('团购').fontSize(16).fontWeight(500).margin({ left: 3, bottom: 6 }).alignSelf(ItemAlign.Start)
      Column({ space: 10 }) {
        ForEach(this.list, (item: IGroupInfo) => {
          GroupBuy({ groupInfo: item })
        }, (item: IGroupInfo) => JSON.stringify(item))
      }
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }
}