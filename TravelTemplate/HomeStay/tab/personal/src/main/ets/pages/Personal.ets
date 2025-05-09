import { Constants, NavPathName, OrderTextModel, OtherTabNavModel } from 'constant';
import { OrderParam } from 'type';
import { AccountUtil } from 'account';
import { PersonalInfoVM } from '../viewmodel/PersonalInfoVM';
import { TitleBar } from 'component';

@Builder
export function PersonalBuilder() {
  Personal();
}

@Component
export struct Personal {
  vm: PersonalInfoVM = PersonalInfoVM.instance;
  @State avatar: ResourceStr = $r('app.media.avatar');
  @State nickname: string = '华为用户';
  @StorageLink('currentUser') currentUser: string | undefined = AccountUtil.getCurrentUser();
  @State windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  controller: TabsController = new TabsController();
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  routeByIndex(value: number) {
    const navItem = Constants.OTHER_NAV_TABLE.find((item: OtherTabNavModel) => item.index === value);
    this.mainPathStack.pushPathByName(navItem?.page, null);
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: false, title: '我的', clickEvent: () => {
            this.mainPathStack.pop();
          },
        }).backgroundColor('#5c6383');

        Stack({ alignContent: Alignment.Center }) {
          Column() {
          }.height(120).width(Constants.FULL_SCREEN).backgroundColor('#5c6383');

          Row() {
            Image(this.currentUser ? this.avatar : $r('app.media.default_avatar'))
              .width(52)
              .height(52)
              .borderRadius(26)
              .aspectRatio(1);
            Text(this.currentUser ? this.nickname : '立即登录')
              .fontSize(15)
              .fontColor(Color.White)
              .margin({ left: 12 })
              .fontWeight(600);
          }.padding(16).width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Start).onClick(() => {
            if (!this.currentUser) {
              this.mainPathStack.pushPathByName(NavPathName.QUICK_LOGIN_PAGE, null, (popInfo: ESObject) => {
                this.avatar = $r('app.media.avatar');
                this.nickname = '华为用户';
                this.currentUser = popInfo.result;
              });
            }
          });
        };

        Column() {
          Column() {
            Column() {
              Text('我的订单').fontSize(14).width(Constants.FULL_SCREEN).textAlign(TextAlign.Start);

              Grid() {
                ForEach(Constants.orderText, (item: OrderTextModel) => {
                  GridItem() {
                    Column() {
                      Image($r(`${item.icon}`)).size({ width: 24, height: 24 });

                      Text(`${item.title}`).fontSize(12).margin({ top: 6 });
                    }.onClick(() => {
                      this.mainPathStack.pushPathByName(NavPathName.ORDER_LIST, {
                        orderStatus: item.value,
                        orderType: 0,
                      } as OrderParam);
                    });
                  };
                }, (item: OrderTextModel) => item.title);
              }
              .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
              .columnsGap(10)
              .rowsGap(10)
              .margin({ top: 16 });
            };
          }
          .height(120)
          .width(Constants.FULL_SCREEN)
          .margin({ top: 16 })
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8);

          Column() {
            Row() {
              Text('其他服务').fontSize(14);
            }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Start);

            Grid() {
              ForEach(Constants.COMMON_SERVICE_INFO,
                (item: OrderTextModel) => {
                  GridItem() {
                    Column() {
                      Image($r(`${item.icon}`)).size({ width: 24, height: 24 }).objectFit(ImageFit.Contain);

                      Text(`${item.title}`).fontSize(12).margin({ top: 6 });
                    };
                  }.onClick(() => {
                    this.routeByIndex(item.value);
                  });
                }, (item: OrderTextModel) => item.title);
              if (this.currentUser) {
                GridItem() {
                  Column() {
                    Image($r('app.media.icon_my_center')).size({ width: 24, height: 24 }).objectFit(ImageFit.Contain);

                    Text('个人中心').fontSize(12).margin({ top: 6 });
                  };
                }.onClick(() => {
                  this.mainPathStack.pushPathByName(NavPathName.PERSONAL_INFO, null, (popInfo: ESObject) => {
                    this.avatar = popInfo.result.avatar;
                    this.nickname = popInfo.result.nickname;
                    this.currentUser = (popInfo.result.type === 0 ? AccountUtil.getCurrentUser() : '');
                  });
                });
              }
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .columnsGap(10)
            .rowsGap(10)
            .width(Constants.FULL_SCREEN)
            .margin({ top: 16 });
          }
          .height(this.currentUser ? 172 : 120)
          .margin({ top: 16 })
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8);
        }.backgroundColor('#f5f6fa').padding({ left: 16, right: 16 }).height(Constants.FULL_SCREEN);
      };
    }.hideTitleBar(true);
  }
}