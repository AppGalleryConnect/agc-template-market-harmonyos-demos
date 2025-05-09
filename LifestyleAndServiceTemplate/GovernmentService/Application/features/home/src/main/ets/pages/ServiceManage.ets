import { BusinessError } from '@kit.BasicServicesKit';
import { ItemInfo } from 'common';
import { getDataFromJSON } from 'h5';

@Component
export struct ServiceManage {
  allServiceItems: Array<ItemInfo> = [];
  @State changedItem: Array<ItemInfo> = [];
  @StorageLink('mineItem') mineItem: Array<ItemInfo> = [];
  @Consume('pageInfos') pageInfos: NavPathStack
  saveAndRouterBack = () => {
    try {
      this.mineItem = this.changedItem;
      this.pageInfos.pop();
    } catch (err) {
      console.log(`error code is: ${(err as BusinessError).name}, error message is: ${(err as BusinessError).message}`);
    }
  }

  isVisibility(info: ItemInfo) {
    let isIn: boolean = this.changedItem.some(item => item.name === info.name)
    return isIn ? Visibility.Hidden : Visibility.Visible
  }

  initDataSource() {
    this.changedItem = [...this.mineItem];
    this.allServiceItems = getDataFromJSON<ItemInfo>('ServiceMgntPage-AllService.json', this);
    this.mineItem = getDataFromJSON<ItemInfo>('HomePage-MineItem.json', this);
  }

  build() {
    NavDestination() {
      this.buildTitle();
      Scroll() {
        Column() {
          this.buildMyService();
          this.buildAllService();
        }
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .width('100%')
      .align(Alignment.TopStart)
      .backgroundImageSize(ImageSize.Auto)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.None)
      .padding({ left: 16, right: 16 })
    }
    .hideTitleBar(true)
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }

  @Builder
  buildTitle() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Row(){
          Image($r('app.media.chevron_backward'))
            .width(40)
            .height(40)
            .margin({ left: 16 })
            .onClick(() => this.pageInfos.pop())
            .padding(8)
            .borderRadius('50%')
            .backgroundColor($r('sys.color.background_secondary'))
        }
        Text($r('app.string.service_management'))
          .fontColor($r('sys.color.font_primary'))
          .margin({ left: 8 })
          .fontSize(18)
          .fontWeight(FontWeight.Medium);
      }

      Text($r('app.string.save'))
        .fontColor('#007DFD')
        .margin({ right: 16 })
        .fontSize($r('app.integer.text_font_big'))
        .fontWeight(FontWeight.Medium)
        .onClick(this.saveAndRouterBack);
    }
    .width('100%')
    .height(70)
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  buildMyService() {
    Column() {
      Text($r('app.string.my_service'))
        .fontColor(Color.Black)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Bold);
      Grid() {
        ForEach(this.changedItem,
          (item1: ItemInfo, idx1: number) => {
            GridItem() {
              Column({ space: 5 }) {
                Stack() {
                  Image($r(item1.pic))
                    .width(24)
                    .height(24)
                  Image($r('app.media.home_page_pic18'))
                    .width(11)
                    .height(11)
                    .offset({ x: 11, y: -11 })
                    .objectFit(ImageFit.Cover)

                }
                .width('100%')
                .height(35)

                Text(item1.name)
                  .width('100%')
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ top: 5 })
                  .textAlign(TextAlign.Center)
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Regular)
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .onClick(() => this.deleteItem(idx1));
            }
          }, (item1: ItemInfo) => JSON.stringify(item1));
      }
      .margin({ top: 12 })
      .width('100%')
      .columnsTemplate('1fr 1fr 1fr 1fr ');
    }
    .padding(12)
    .borderRadius(16)
    .margin({ top: 12 })
    .backgroundColor($r('sys.color.background_primary'))
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildAllService() {
    Column() {
      Text($r('app.string.medical_insurance'))
        .fontColor(Color.Black)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Bold);
      Grid() {
        ForEach(this.allServiceItems, (item: ItemInfo) => {
          GridItem() {
            Column() {
              Stack() {
                Image($r(item.pic))
                  .width(24)
                  .height(24)
                Image($r('app.media.home_page_pic17'))
                  .width(12)
                  .height(12)
                  .offset({ x: 11, y: -11 })
                  .objectFit(ImageFit.Cover)
                  .visibility(this.isVisibility(item))
              }
              .width('100%')
              .height(35)

              Text(`${item.name}`)
                .fontColor($r('sys.color.font_primary'))
                .margin({ top: 5 })
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular)
            }
            .width('100%')
            .height('100%')
            .onClick(() => this.addItem(item));
          }
          .width(56)
          .height(74);
        }, (item: ItemInfo) => JSON.stringify(item));
      }
      .width('100%')
      .borderRadius($r('sys.float.corner_radius_level4'))
      .backgroundColor($r('sys.color.background_primary'))
      .margin({
        top: 5,
      })
      .columnsTemplate('1fr 1fr 1fr 1fr ')
    }
    .padding(12)
    .margin({ top: 12 })
    .borderRadius($r('sys.float.corner_radius_level5'))
    .backgroundColor($r('sys.color.background_primary'))
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 删除服务配置
   **/
  deleteItem(idx: number): void {
    this.changedItem.splice(idx, 1)
  }

  /**
   * 添加服务配置
   **/
  addItem(addItem: ItemInfo): void {
    let isFind = this.changedItem.find(item => item.name === addItem.name)
    if (isFind) {
      return
    }
    this.changedItem.push(addItem)
  }

  aboutToAppear() {
    this.initDataSource();
  }
}