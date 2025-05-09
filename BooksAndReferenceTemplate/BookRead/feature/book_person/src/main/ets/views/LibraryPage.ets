import { BookApi, Constants, GetBookBorrowRsp, GetUserInfoRsp, LazyDataVM, NavHeaderBar, UserInfo } from 'common';
import { BorrowCard } from '../comp/BorrowCard';
import { BorrowInfo, BorrowInfoCard } from '../comp/BorrowInfoCard';

@ComponentV2
export struct LibraryPage {
  @Local userInfo: UserInfo | undefined = undefined;
  @Local borrowInfos: LazyDataVM<BorrowInfo> | undefined = undefined;

  async aboutToAppear(): Promise<void> {
    // 获取用户个人信息
    const rsp: GetUserInfoRsp = await BookApi.getUserInfo('123');
    this.userInfo = rsp.user;
    // 获取借阅信息
    if (this.userInfo?.id) {
      this.borrowInfos = await this.getBorrowInfo(this.userInfo?.id);
    }
  }

  async getBorrowInfo(userId: string): Promise<LazyDataVM<BorrowInfo>> {
    let rsp: GetBookBorrowRsp = await BookApi.getBorrowList(userId);
    return new LazyDataVM<BorrowInfo>(rsp.borrows);
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          NavHeaderBar({
            title: $r('app.string.library'),
            hasBackButton: true,
            hasBgColor: true,
            isMainPage: true,
          });
          Tabs() {
            TabContent() {
              BorrowCard({ userInfo: this.userInfo })
                .padding({ bottom: 130, left: 12, right: 12, })
            }
            .tabBar(SubTabBarStyle.of($r('app.string.borrow_card'))
              .labelStyle({ selectedColor: $r('app.color.slider_selected_color') }))
            .height(Constants.FULL_SIZE)

            TabContent() {
              Column() {
                List() {
                  LazyForEach(this.borrowInfos, (item: BorrowInfo) => {
                    ListItem() {
                      BorrowInfoCard({ info: item });
                    }
                  },(item: string) => new Date().toString())
                }
                .scrollBar(BarState.Off)
              }
              .justifyContent(FlexAlign.Center)
              .width(Constants.FULL_SIZE)
            }
            .padding({
              left: 12,
              right: 12,
            })
            .margin({
              bottom: 150
            })
            .tabBar(SubTabBarStyle.of($r('app.string.borrow_info'))
              .labelStyle({ selectedColor: $r('app.color.slider_selected_color') }))
          }
          .scrollable(false)
          .barBackgroundColor(Color.White)
        }
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
    }.hideTitleBar(true)
  }
}