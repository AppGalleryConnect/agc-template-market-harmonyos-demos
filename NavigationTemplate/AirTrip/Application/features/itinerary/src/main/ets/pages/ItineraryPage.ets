import { AppRouter, AuthenticationUtil,
  ItineraryApi,
  LoadingStatus, Trip, TripListResult, UserInfo, UserInfoStorage } from 'common';
import { BaseTitle, GlobalDialog } from 'components'
import { TabBarView } from '../components/TabBarView';
import { TabContentView } from '../components/TabContentView';
import { ItineraryTabItem } from '../model/ItineraryPageModel';
import { PersistenceV2 } from '@kit.ArkUI';

@Builder
export function itineraryPageBuilder() {
  ItineraryPage()
}

@ComponentV2
export struct ItineraryPage {
  @Local userInfoStorage: UserInfoStorage =
    PersistenceV2.connect(UserInfoStorage, 'UserInfoStorage', () => new UserInfoStorage())!;
  @Local loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @Local categoryTabIndex: number = 0;
  @Local tabNavs: ItineraryTabItem[] = [
    new ItineraryTabItem('待出行', 0, '1'),
    new ItineraryTabItem('已结束', 0, '2'),
  ];
  @Local allTripList: Trip[] = [];
  private controller: TabsController = new TabsController();
  context: UIContext = this.getUIContext();

  aboutToAppear(): void {
    if (this.userInfoStorage.isLogin) {
      this.geTripAllList();
    }
  }

  @Monitor('userInfoStorage.isLogin')
  onChangeLogin() {
    if (this.userInfoStorage.isLogin) {
      this.geTripAllList();
    }
  }

  geTripAllList() {
    GlobalDialog.showLoadingDialog();
    ItineraryApi.getTripList().then((res) => {
      let result = res.result as TripListResult;
      if (result.ret.code === 0) {
        this.allTripList = result.result ?? []
        // 按照起飞时间升序排序
        this.allTripList.sort((a: Trip, b: Trip): number => {
          let aTakeoffTime = new Date(a.planTakeoffTime).getTime()
          let bTakeoffTime = new Date(b.planLandingTime).getTime()
          return aTakeoffTime - bTakeoffTime
        })

        let uncomingTrip = this.allTripList.filter((item: Trip) => item.status === '1');
        let completedTrip = this.allTripList.filter((item: Trip) => item.status === '2');
        this.tabNavs[0].count = uncomingTrip.length;
        this.tabNavs[1].count = completedTrip.length;
      }
    }).finally(() => {
      GlobalDialog.close();
      this.loadingStatus = LoadingStatus.SUCCESS;
    });
  }

  @Builder
  ItineraryTitleBuilder() {
    Text('行程')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Bold)
  }

  build() {
    Column() {
      BaseTitle({
        customTitle: () => {
          this.ItineraryTitleBuilder();
        },
      });

      if (this.userInfoStorage.isLogin) {
        // TabNav
        Row({ space: 20 }) {
          ForEach(this.tabNavs, (item: ItineraryTabItem, index: number) => {
            TabBarView({
              tabNav: item,
              index,
              curIndex: this.categoryTabIndex,
              changeTab: () => {
                this.controller.changeIndex(index);
                this.categoryTabIndex = index;
              },
            });
          });
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .padding({
          left: 24,
          right: 24,
          top: 20,
          bottom: 20,
        });

        if (this.loadingStatus === LoadingStatus.SUCCESS) {
          // TabContent
          Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.categoryTabIndex }) {
            ForEach(this.tabNavs, (item: ItineraryTabItem, index: number) => {
              TabContent() {
                TabContentView({
                  tabItem: item,
                  allList: this.allTripList,
                  refreshList: () => {
                    this.geTripAllList();
                  },
                  onClickItem: (data: Trip) => {
                    AppRouter.push({
                      url: 'ItineraryDetailPage',
                      param: data
                    })
                  },
                });
              };
            });
          }
          .width('100%')
          .layoutWeight(1)
          .barHeight(0)
          .scrollable(false)
          .onChange((index: number) => {
            this.categoryTabIndex = index;
          });
        }
      } else {
        Column({ space: 16 }) {
          Column({ space: 16 }) {
            Image($r('app.media.ic_empty'))
              .width(100)
              .height(80);
            Text('关联手机号查看我的行程')
              .fontColor($r('sys.color.ohos_id_color_text_tertiary'));
          };

          Button('立即关联', { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor($r('sys.color.ohos_id_color_emphasize')).width('60%')
            .shadow(ShadowStyle.OUTER_DEFAULT_SM)
            .onClick(() => {
              GlobalDialog.showLoadingDialog()
              AuthenticationUtil.silentLogin((isSuccess: boolean, userInfo: UserInfo) => {
                GlobalDialog.close()
                // 账号关联登录成功
                if (isSuccess) {
                  this.userInfoStorage.isLogin = true;
                  this.userInfoStorage.userInfo = userInfo
                }
              });
            });
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center);
      }
    }
    .width('100%')
    .height('100%');
  }
}
