import { AccountUtil, RouterMap, RouterModule } from 'commonlib';
import { ServerItem } from '../types/Index';
import { MinePageVM } from '../viewModels/MinePageVM';

@Builder
export function MinePageBuilder() {
  MinePage();
}

@Preview
@ComponentV2
struct MinePage {
  @Local titleBgOpacity: number = 0;
  scroller: Scroller = new Scroller();
  vm: MinePageVM = MinePageVM.instance;

  @Builder
  titleBuilder() {
    Row() {
      Text('我的')
        .fontSize(24)
        .fontWeight(500)
        .padding({ left: 8 })
        .height(56)
        .margin({ left: 16 });
    }
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor(Color.White)
    .opacity(this.titleBgOpacity);
  }

  @Builder
  titleInside() {
    Text('我的')
      .fontSize(24)
      .fontWeight(500)
      .padding({ left: 8 })
      .margin({ left: 16 })
      .height(56)
      .width(192)
      .alignSelf(ItemAlign.Start)
      .opacity(1 - 2 * this.titleBgOpacity);
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll(this.scroller) {
          Column() {
            this.titleInside();
            Column() {
              this.userInfoBuilder();
              this.fansBuilder();

              Text('常用服务').margin({ top: 16, bottom: 12 }).fontSize(18).lineHeight(24).fontWeight(500);

              List({ space: 8 }) {
                ForEach(this.vm.serverList, (item: ServerItem) => {
                  ListItem() {
                    Row() {
                      Row({ space: 15 }) {
                        Image(item.icon).width(24).height(24);
                        Text(item.label)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('app.string.font_color_black'));
                      };

                      Image($r('app.media.ic_right')).width(12).height(24);
                    }.width('100%').padding(12).justifyContent(FlexAlign.SpaceBetween);
                  }
                  .width('100%')
                  .height(47)
                  .borderRadius(16)
                  .backgroundColor(Color.White)
                  .onClick(() => {
                    RouterModule.push({ url: item.page });
                  });

                }, (item: ServerItem) => item.label);
              };

            }.width('100%').padding({ left: 16, right: 16 })
            .alignItems(HorizontalAlign.Start);
          }.constraintSize({
            minHeight: '100%',
          })
          .alignItems(HorizontalAlign.Start)
          .width('100%');
        }
        .height('100%')
        .width('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.None)
        .onDidScroll(() => {
          this.titleBgOpacity = this.scroller.currentOffset().yOffset / 56;
        });

        this.titleBuilder();
      }
      .width('100%')
      .constraintSize({
        minHeight: '100%',
      })
      .align(Alignment.Top)
      .linearGradient({
        repeating: false, // 渐变颜色是否重复
        colors: [['rgb(255, 206, 198)', 0], ['rgb(241, 243, 245)', 1 / 3], ['rgb(241, 243, 245)', 1]],
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

    }.hideTitleBar(true);
  }

  @Builder
  userInfoBuilder() {
    Row() {
      Row({ space: 12 }) {
        Image(this.vm.userInfo.avatar ?
          this.vm.userInfo.avatar.startsWith('file://') ? this.vm.userInfo.avatar :
          $r(`app.media.${this.vm.userInfo.avatar}`) : $r('app.media.ic_avatar'))
          .width(64)
          .height(64)
          .borderRadius(32)
          .alt($r('app.media.ic_avatar'));
        Column({ space: 8 }) {
          Text(this.vm.userInfo.nickname ? this.vm.userInfo.nickname : '立即登录')
            .fontSize(18)
            .fontColor($r('app.string.font_color_black'));
        }.alignItems(HorizontalAlign.Start);
      }.onClick(() => {
        if (AccountUtil.getUserInfo().isLogin) {
          RouterModule.push({ url: RouterMap.PERSON_INFO_PAGE });
        } else {
          RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE });
        }
      });
    }
    .height(85)
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(12)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Top)
    .margin({ top: 6 });
  }

  @Builder
  fansBuilder() {
    Row() {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text('0')
            .fontSize(18)
            .lineHeight(24)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.string.font_color_black'));
          Text('关注').fontSize(12).lineHeight(16);
        }
        .padding({
          left: 12,
          right: 12,
          top: 7,
          bottom: 7,
        })
        .alignItems(HorizontalAlign.Start);

        Divider().strokeWidth(1).vertical(true).height('calc(100% - 42vp)');
        Column({ space: 4 }) {
          Text('0')
            .fontSize(18)
            .lineHeight(24)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.string.font_color_black'));
          Text('粉丝').fontSize(12).lineHeight(16).fontColor($r('app.string.font_color_black'));
        }
        .padding({
          left: 12,
          right: 12,
          top: 7,
          bottom: 7,
        })
        .alignItems(HorizontalAlign.Start);
      };

      Column({ space: 8 }) {
        Image($r('app.media.icon_basket')).width(32).height(32);
        Text('菜篮子').lineHeight(16).fontSize(12);
      }.width(80).height(64).padding(4).onClick(() => {
        RouterModule.push({ url: RouterMap.SHOPPING_BASKET_PAGE })
      });

    }
    .width('100%')
    .height(90)
    .padding({ left: 16, right: 16 })
    .borderRadius(16)
    .backgroundColor(Color.White)
    .margin({ top: 10 })
    .justifyContent(FlexAlign.SpaceBetween);
  }
}

