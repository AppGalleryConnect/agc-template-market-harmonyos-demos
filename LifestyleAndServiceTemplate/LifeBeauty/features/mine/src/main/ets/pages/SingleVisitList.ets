import {
  CommonUtils,
  UIEmpty,
  getMySingleVisitCardList,
  GetUserInfoResp,
  IMySingleCardInfo,
  IUseRecord,
  PopViewUtils,
} from 'utils';
import { DialogQRCodeBuilder, QRCodeParams } from '../components/DialogQRCode';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function SingleCardVisitListBuilder() {
  SingleCardVisitList()
}


@ComponentV2
export struct SingleCardVisitList {
  @Local userInfo: GetUserInfoResp = AppStorageV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local list: IMySingleCardInfo[] = [];

  aboutToAppear(): void {
    getMySingleVisitCardList().then((resp) => {
      this.list = resp as IMySingleCardInfo[];
    })
  }

  @Computed
  get isBindPhone() {
    return this.userInfo?.mobile !== '';
  }

  @Builder
  SingleVisitCard(item: IMySingleCardInfo) {
    Column() {
      Row() {
        Text(item.title).fontSize(14).fontWeight(500)
        Blank()
        Text(`可用次数：${item.leftNums}次`)
          .fontSize(14)
          .fontWeight(500)
          .fontColor(item.leftNums > 0 ? Color.Black : '#B3B3B3')
      }
      .width('100%')

      Row() {
        Column({ space: 10 }) {
          Text(`适用项目：${item.availableProName}`).fontSize(12)
          Text('有效期：' +
            (item.availablePeriod === -1 ? '永久有效' : CommonUtils.formatDateTime(item.availablePeriod)))
            .fontSize(12)
          Text('适用门店：全国所有门店').fontSize(12)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Image(item.leftNums > 0 ? $r('app.media.ic_public_qrcode') : $r('app.media.ic_public_qrcode_disable'))
          .width(48)
          .height(48)
          .enabled(item.leftNums > 0)
          .onClick(() => {
            PopViewUtils.showPopView<QRCodeParams>(wrapBuilder(DialogQRCodeBuilder),
              new QRCodeParams(item.singleCardSerialNo),
              { alignment: DialogAlignment.Center, autoCancel: true });
          })
      }
      .width('100%')
      .margin({ top: 14 })

      if (item.usageRecord.length) {
        Row() {
          Text('使用记录：').fontSize(12)
          Column({ space: 10 }) {
            ForEach(item.usageRecord, (v: IUseRecord) => {
              Row({ space: 10 }) {
                Text(v.useTime.toString()).fontSize(12)
                Text(v.storeName).fontSize(12).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
            }, (item: IUseRecord) => JSON.stringify(item))
          }
          .layoutWeight(1)
        }
        .margin({ top: 10 })
        .alignItems(VerticalAlign.Top)
      }
    }
    .width('100%')
    .padding({
      top: 16,
      bottom: 39,
      left: 16,
      right: 16,
    })
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isBindPhone && this.list.length) {
          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.list, (item: IMySingleCardInfo) => {
                this.SingleVisitCard(item)
              }, (v: IMySingleCardInfo) => JSON.stringify(v))
            }
          }
          .width('100%')
          .height('100%')
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .padding(10)
        } else {
          UIEmpty({ emptyDesc: this.isBindPhone ? '暂无次卡记录' : '关联手机号后查看次卡记录' })
            .margin({ top: 140, bottom: 20 })
        }
      }
    }
    .title('次卡', { backgroundColor: Color.White })
    .backgroundColor($r('app.color.common_page_bg'))
  }
}

