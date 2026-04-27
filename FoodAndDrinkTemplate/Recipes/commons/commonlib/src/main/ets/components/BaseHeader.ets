import { RouterMap } from '../constants/CommonEnums';
import { AccountUtil } from '../utils/AccountUtil';
import { RouterModule } from '../utils/RouterModule';
import { HeaderMenuBuilder } from './HeaderMenuBuilder';

@ComponentV2
export struct BaseHeader {
  @Param title: string = '首页';
  @Param showSearch: boolean = false;
  @Param showTitle: boolean = true;
  @Param showLeftMenu: boolean = false;
  @Param showRightMenu: boolean = false;
  @Param showMsg: boolean = false;
  @Param showService: boolean = false;
  @Param noticeNum: number = 0;
  @Param searchResults: Array<string> = ['精选推荐', '下饭菜', '快手菜', '减脂餐', '家常菜', '豆制品', '蔬菜'];
  @Param subTabIndex: number = 0;
  @Param themeColor: ResourceColor = '#FD4238';
  @Param showButton: boolean = false;
  @Param showBgColor: boolean = false;
  @Param gridCount: number = 2;
  @Local tabBarScroller: Scroller = new Scroller();
  @Event changeRecipes: (index: number, item: string) => void = () => {
  }
  @Event
  changeSideBar: (flag: boolean) => void = () => {
  }

  // 切换
  @Monitor('subTabIndex')
  changeIndex() {
    this.tabBarScroller.scrollToIndex(this.subTabIndex, false);
  }

  build() {
    Row() {
      Row() {
        if (this.showLeftMenu) {
          Image($r('app.media.ic_title_left_menu')).width(40).height(40).onClick(() => {
            this.changeSideBar(true)
          })
        }
        if (this.showTitle) {
          List({ space: 8, scroller: this.tabBarScroller }) {
            ForEach(this.searchResults, (item: string, index: number) => {
              ListItem() {
                Button(item)
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(this.subTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
                  .fontColor(this.subTabIndex === index ?
                    $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
                  .backgroundColor(this.subTabIndex === index ?
                    this.themeColor : $r('sys.color.comp_background_primary'))
                  .onClick(() => {
                    this.changeRecipes(index, item)
                    this.tabBarScroller.scrollToIndex(index, true);
                  })
                  .height(36)
                  .padding({
                    top: 8,
                    bottom: 8,
                    right: 16,
                    left: 16
                  })
              }
            }, (item: string) => JSON.stringify(item))
          }
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .padding({
            top: 18,
            bottom: 18,
          })
          .height(72)
          .layoutWeight(1)
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .visibility(this.showSearch ? Visibility.Visible : Visibility.None)

          Text(this.title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.showBgColor || this.gridCount === 4 ?
              $r('sys.color.font_primary') : 'rgba(255, 255, 255, 1)')
            .fontFamily('HarmonyHeiTi')
            .margin({ left: 8 })
            .visibility(this.showSearch ? Visibility.None : Visibility.Visible)
        }
      }
      .layoutWeight(1)

      Row({ space: 8 }) {
        if(this.gridCount === 4) {
          Search({ placeholder: '输入关键词' })
            .width(400)
            .onClick(() => {
              RouterModule.push(RouterMap.SEARCH)
            })
        } else {
          Image($r('app.media.ic_title_search'))
            .width(40).height(40).onClick(() => {
            RouterModule.push(RouterMap.SEARCH)
          })
            .visibility(this.showButton ? Visibility.Visible : Visibility.None)
          Image($r('app.media.ic_title_menu'))
            .width(40)
            .height(40)
            .bindMenu(HeaderMenuBuilder())
            .visibility(Visibility.None)
        }
      }
      .width(this.gridCount === 4 ? 440 : 46)
      .margin({right: this.gridCount === 4 ? 36 : 0})
      .justifyContent(FlexAlign.End)

      if (this.showMsg) {
        Row({ space: 8 }) {
          Badge({
            count: this.noticeNum,
            style: { fontSize: 10, badgeSize: 16 },
          }) {
            Image($r('app.media.ic_title_msg')).width(40).height(40).onClick(() => {
              if (AccountUtil.getUserInfo().isLogin) {
                RouterModule.push(RouterMap.NOTICE_CENTER_PAGE)
              } else {
                RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
              }
            })
          }
        }
      }
    }
    .height(96)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .shadow({
      offsetX: 0,
      offsetY: 4,
      color: '#1A000000',
      radius: this.showSearch ? 4 : 0,
    })
    .padding({ left: 16, right: 8, top: 40 })
  }
}
