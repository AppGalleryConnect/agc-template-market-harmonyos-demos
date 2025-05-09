import { goH5, getDataFromJSON } from 'h5';
import { CardInfo, NavigationParams, UserInfo, ItemInfo, SettingItem, commonToast } from 'common';

@Component
export struct MinePage {
  gridItems: Array<ItemInfo> = [];
  cardItems: Array<CardInfo> = [];
  settingItems: Array<SettingItem> = [];
  @StorageLink('isLogin') isLogin: boolean = AppStorage.get('isLogin') ?? false;
  @StorageLink('userInfo') userInfo: UserInfo = AppStorage.get('userInfo') ?? new UserInfo();
  @Consume('pageInfos') pageInfos: NavPathStack
  goLogInPage = () => {
    this.pageInfos.pushPathByName('LoginWithHuaweiIDComponent', null)
  }
  goMessagePage = () => {
    this.pageInfos.pushPathByName('Message', null)
  }
  goSettingsPage = (idx: number, title: string) => {
    if (idx === 0) {
      this.pageInfos.pushPathByName('Settings', null)
    } else {
      this.pageInfos.pushPathByName('AboutUs', null)
    }
  }
  goH5Page = (title: string) => {
    this.pageInfos.pushPathByName('Empty', new NavigationParams(title))
  }

  initDataSource() {
    this.gridItems = getDataFromJSON<ItemInfo>('MinePage-GridItems.json', this);
    this.cardItems = getDataFromJSON<CardInfo>('MinePage-CardItems.json', this);
    this.settingItems = getDataFromJSON<SettingItem>('MinePage-SettingItems.json', this);
  }

  build() {
    Scroll() {
      Column() {
        // 构建登录配置视图
        this.buildLogInSettingView()

        // 构建民声在线视图
        this.buildVoiceOnLineView()

        // 构建我的卡证视图
        if (this.isLogin) {
          this.buildMyCardView()
        }

        // 构建配置视图
        this.buildSettingsView()
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
      .alignItems(HorizontalAlign.Start)
      .padding({ top: Number(AppStorage.get('topRectHeight')), left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.TopStart)
    .backgroundImageSize(ImageSize.Auto)
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
    .scrollBarWidth(0)
    .edgeEffect(EdgeEffect.None)
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildLogInSettingView() {
    Row() {
      Row() {
        Image(
          this.userInfo.avatar ||
          $r('app.media.un_login_avatar'))
          .width(48)
          .height(48)
          .borderRadius($r('sys.float.corner_radius_level10'))
          .margin({ right: 14 })
          .objectFit(ImageFit.Fill);
        if (this.isLogin) {
          Column() {
            Text(this.userInfo.userName)
              .fontSize($r('app.integer.text_font_little_big'))
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 5 })
            Text(this.userInfo.phoneNumber.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
              .fontColor('#434343')
              .fontSize($r('app.integer.text_font_normal'))
          }.alignItems(HorizontalAlign.Start)
        }
        if (!this.isLogin) {
          Text($r('app.string.login'))
            .fontColor($r('sys.color.font_primary'))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
        }
      };

      Row() {
        Image($r('app.media.right_arrow'))
          .width(14).height(14)
      };
    }
    .width('100%')
    .margin({ top: 18 })
    .padding({
      left: 8,
      right: 8,
      top: 12,
      bottom: 12,
    })
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      if (this.isLogin) {
        this.pageInfos.pushPathByName('PersonInformation', null)
      } else {
        this.goLogInPage()
      }
    })
  }

  @Builder
  buildVoiceOnLineView() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.gridItems, (itemInfo: ItemInfo) => {
          buildGridItem(itemInfo, this.goH5Page)
        }, (itemInfo: ItemInfo) => JSON.stringify(itemInfo));
      }
      .width('100%')
      .borderRadius(16)
      .backgroundColor($r('sys.color.background_primary'))
    }
    .borderRadius($r('sys.float.corner_radius_level5'))
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ top: 12 })
    .padding(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildMyCardView() {
    Column({ space: 12 }) {
      Text($r('app.string.my_license'))
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Bold);
      Row() {
        ForEach(this.cardItems, (cardInfo: CardInfo) => {
          Column() {
            Row() {
              Image($r(cardInfo.icon))
                .width(16)
                .height(16)
                .margin({ left: 11 })
                .objectFit(ImageFit.Contain);
              Text(`${cardInfo.name}`)
                .fontColor($r('sys.color.font_on_primary'))
                .fontWeight(FontWeight.Medium)
                .margin({ left: 5 })
                .fontSize($r('sys.float.Body_S'));
            }
            .width('100%')
            .margin({ top: 10 })
            .justifyContent(FlexAlign.Start);

            Button(`${cardInfo.buttonName}`)
              .width('60%')
              .height(28)
              .backgroundColor($r('sys.color.background_primary'))
              .fontColor(cardInfo.color)
              .margin({ top: 30, bottom: 10 })
              .fontSize($r('sys.float.Body_M'))
          }
          .width('45%')
          .onClick(() => {
            this.pageInfos.pushPathByName('CodeMock', new NavigationParams(cardInfo.name))
          })
          .borderRadius($r('sys.float.corner_radius_level5'))
          .backgroundColor(cardInfo.color);
        }, (cardInfo: CardInfo) => JSON.stringify(cardInfo));
      }
      .width('100%')
      .backgroundColor($r('sys.color.background_primary'))
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .width('100%')
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ top: 10 })
    .padding(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSettingsView() {
    Column() {
      ForEach(this.settingItems, (settingItem: SettingItem, idx: number) => {
        Row() {
          Row() {
            Image($r(settingItem.icon))
              .width(18)
              .height(18)
              .margin({ right: 7 })
              .objectFit(ImageFit.Cover);
            Text(`${settingItem.name}`)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'));
          }
          .width(74)
          .height(16)
          .margin({ left: 12 });

          Image($r(settingItem.moreIcon))
            .width(20)
            .height(20)
            .margin({ right: 12 })
            .objectFit(ImageFit.Fill);
        }
        .width('100%')
        .margin({ top: 10, bottom: 15 })
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => this.goSettingsPage(idx, settingItem.name));
      }, (settingItem: SettingItem) => JSON.stringify(settingItem));
    }
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level5'))
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ top: 10 })
    .alignItems(HorizontalAlign.Start)
  }

  aboutToAppear() {
    this.initDataSource()
  }
}

@Builder
function buildGridItem(itemInfo: ItemInfo, event: (title: string) => void) {
  GridItem() {
    Column({ space: 5 }) {
      Image($r(itemInfo.pic))
        .width(48)
        .height(48)
        .margin({ top: 11 })
      Text(`${itemInfo.name}`)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular)
    }
    .onClick(() => {
      event(itemInfo.name)
    });
  }
}