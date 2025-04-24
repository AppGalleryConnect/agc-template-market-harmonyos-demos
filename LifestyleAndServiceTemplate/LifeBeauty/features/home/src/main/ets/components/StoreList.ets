import { common } from '@kit.AbilityKit';
import { IBaseStore, PopViewUtils, SystemSceneUtils } from 'utils';
import { DialogCallBuilder, Params } from '../components/DialogCall';
import { HomeBaseVM } from '../viewmodel/HomeBaseVM';

@ComponentV2
export struct StoreList {
  homeVM: HomeBaseVM = HomeBaseVM.instance;
  scroller = new Scroller();

  getStoreLocation(item: IBaseStore) {
    return `距您${item.distance ?? '0m'} | ${item.address}`
  }

  @Builder
  StoreCard(item: IBaseStore) {
    Row() {
      Image($r('app.media.ic_location')).width(9).height(11)
      Column({ space: 4 }) {
        Text(item.storeName)
          .fontSize(12)
          .fontWeight(500)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)

        Text(this.getStoreLocation(item))
          .fontSize(12)
          .fontColor($r('app.color.common_grey'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
      }
      .margin({ left: 8 })
      .alignItems(HorizontalAlign.Start)
      .constraintSize({ maxWidth: 230 })

      Blank()

      Column({ space: 5 }) {
        Image($r('app.media.ic_navigation')).width(24).height(24)
        Text('导航').fontSize(10)
      }
      .margin({ left: 28 })
      .onClick(() => {
        const context = getContext(this) as common.UIAbilityContext;
        SystemSceneUtils.jumpPetalMap(context, item.address, item.coords.split(','))
      })

      Column({ space: 5 }) {
        Image($r('app.media.ic_call')).width(24).height(24)
        Text('电话').fontSize(10)
      }
      .onClick(() => {
        PopViewUtils.showPopView<Params>(wrapBuilder(DialogCallBuilder), new Params(item.mobile.split(',')),
          { alignment: DialogAlignment.Bottom, autoCancel: true });
      })
      .margin({ left: 16 })
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .alignItems(VerticalAlign.Top)
  }

  build() {
    Column() {
      List({
        space: 10,
      }) {
        LazyForEach(this.homeVM.dataSource, (item: IBaseStore) => {
          ListItem() {
            this.StoreCard(item)
          }
        }, (v: IBaseStore) => v.id + v.storeName)
        ListItem() {
          Text('--已经到底啦--').fontSize(12).margin({ top: 20, bottom: 30 }).width('100%').textAlign(TextAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .padding(10)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .cachedCount(1)
    }
    .width('100%')
    .height('100%')
  }
}