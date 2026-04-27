import { ChatContentSingleModel, ChatTypeEnum } from 'chat_base';
import { SearchModel } from '../viewmodel/SearchModel';
import { ContactSearchModel } from '../viewmodel/ContactSearchModel';
import { SearchCollectItem } from './SearchCollectItem';
import { SearchCollectLocationItem } from './SearchCollectLocationItem';
import { SearchFriendItem } from './SearchFriendItem';
import { SearchMessageItem } from './SearchMessageItem';
import { SearchEmptyView } from './SearchEmptyView';
import { SearchLoadingView } from './SearchLoadingView';

@ComponentV2
export struct SearchResultView {
  @Param @Require searchVM: SearchModel
  @Local onSearchResultClick: (clickResultItem: ChatContentSingleModel | ContactSearchModel) => void =
    (clickResultItem: ChatContentSingleModel | ContactSearchModel) => {
    };
  @Local selectTabIndex: number = 0;
  onSearchTypeClick = (type: number) => {
    this.searchVM.selectTabIndex = type;
  }

  aboutToAppear(): void {
    this.selectTabIndex = this.searchVM.selectTabIndex;
  }

  @Builder
  searchMessageView() {
    if (this.searchVM.messageSRList.length > 0) {
      Repeat<ChatContentSingleModel>(this.searchVM.messageSRList)
        .each((ri: RepeatItem<ChatContentSingleModel>) => {
          ListItem() {
            SearchMessageItem({ messageItem: ri.item, searchText: this.searchVM.searchText })
          }
        })
        .key((item: ChatContentSingleModel, index: number): string => item.chatId + index + new Date().getTime())
        .virtualScroll()
    } else {
      if (!this.searchVM.loading) {
        SearchEmptyView();
      } else {
        SearchLoadingView()
      }
    }
  }

  @Builder
  searchCollectView() {
    if (this.searchVM.collectSRList.length > 0) {
      Repeat<ChatContentSingleModel>(this.searchVM.collectSRList)
        .each((ri: RepeatItem<ChatContentSingleModel>) => {
          ListItem() {
            if (ri.item.chatType !== ChatTypeEnum.CHAT_TYPE_LOCATION) {
              SearchCollectItem({ collectMsg: ri.item, searchText: this.searchVM.searchText })
            } else {
              SearchCollectLocationItem({ collectMsg: ri.item, searchText: this.searchVM.searchText })
            }
          }
        })
        .key((item: ChatContentSingleModel, index: number): string => item.chatId + index + new Date().getTime())
        .virtualScroll()
    } else {
      if (!this.searchVM.loading) {
        SearchEmptyView();
      } else {
        SearchLoadingView()
      }
    }
  }

  @Builder
  searchFriendView() {
    if (this.searchVM.friendSRList.length > 0) {
      Repeat<ContactSearchModel>(this.searchVM.friendSRList)
        .each((ri: RepeatItem<ContactSearchModel>) => {
          ListItem() {
            SearchFriendItem({ friendItem: ri.item, searchText: this.searchVM.searchText })
          }
        })
        .key((item: ContactSearchModel, index: number): string => item.searchUserId + index + new Date().getTime())
        .virtualScroll()
    } else {
      if (!this.searchVM.loading) {
        SearchEmptyView();
      } else {
        SearchLoadingView()
      }
    }
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.search_chat_recorde'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.selectTabIndex === 0 ? Color.Black : $r('sys.color.icon_tertiary'))
          .lineHeight($r('app.float.vp_22'))
          .fontWeight(this.selectTabIndex === 0 ? FontWeight.Medium : FontWeight.Regular)
          .margin({
            right: $r('app.float.vp_30'),
            bottom: $r('app.float.vp_8'),
          })
          .onClick(() => {
            this.selectTabIndex = 0;
            this.onSearchTypeClick(0);
          })
        if (!this.searchVM.isSearchUserOrGroup()) {
          Text($r('app.string.search_chat_collect'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor(this.selectTabIndex === 1 ? Color.Black : $r('sys.color.icon_tertiary'))
            .lineHeight($r('app.float.vp_22'))
            .fontWeight(this.selectTabIndex === 1 ? FontWeight.Medium : FontWeight.Regular)
            .margin({
              right: $r('app.float.vp_30'),
              bottom: $r('app.float.vp_8'),
            })
            .onClick(() => {
              this.selectTabIndex = 1;
              this.onSearchTypeClick(1);
            })
          Text($r('app.string.search_chat_contact'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor(this.selectTabIndex === 2 ? Color.Black : $r('sys.color.icon_tertiary'))
            .lineHeight($r('app.float.vp_22'))
            .fontWeight(this.selectTabIndex === 2 ? FontWeight.Medium : FontWeight.Regular)
            .margin({
              right: $r('app.float.vp_30'),
              bottom: $r('app.float.vp_8'),
            })
            .onClick(() => {
              this.selectTabIndex = 2;
              this.onSearchTypeClick(2);
            })
        }
      }

      Divider()
        .strokeWidth('1px')
        .width('100%')
        .color($r('sys.color.comp_divider'))

      List() {
        if (this.searchVM.selectTabIndex === 0) {
          this.searchMessageView();
        } else if (this.searchVM.selectTabIndex === 1) {
          this.searchCollectView();
        } else if (this.searchVM.selectTabIndex === 2) {
          this.searchFriendView();
        }
      }
      .width('100%')
      .height('auto')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .layoutWeight(1)
    .margin({
      top: $r('app.float.vp_12'),
    })
  }
}