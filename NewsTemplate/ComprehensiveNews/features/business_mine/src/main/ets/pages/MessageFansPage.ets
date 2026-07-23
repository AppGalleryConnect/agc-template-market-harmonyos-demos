import { CommonConstants, RouterUtils } from 'lib_common';
import { AuthorModel } from 'lib_news_api';
import { NavHeaderBar } from 'lib_widget';
import { FanItem } from '../components/FanItem';
import { MsgFansViewModel } from '../viewmodels/MessageFansVM';

@Builder
export function MsgFansPageBuilder() {
  MsgFansPage()
}

@ComponentV2
struct MsgFansPage {
  @Local vm: MsgFansViewModel = new MsgFansViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '新增粉丝',
          onBack: () => {
            RouterUtils.pop('1');
          },
        })
        Column() {
          List({ space: CommonConstants.SPACE_M }) {
            LazyForEach(this.vm.fansDataSource, (v: AuthorModel) => {
              ListItem() {
                FanItem({ author: v })
              }
              .padding({
                top: CommonConstants.PADDING_M,
                bottom: CommonConstants.PADDING_M,
              })
            }, (v: AuthorModel) => v.authorId)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .cachedCount(1)
          .padding({
            left: this.vm.breakPointModel.pagePadding,
            right: this.vm.breakPointModel.pagePadding,
            top: CommonConstants.SPACE_M,
          })
        }
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      RouterUtils.pop('1');
      return true;
    })
  }
}