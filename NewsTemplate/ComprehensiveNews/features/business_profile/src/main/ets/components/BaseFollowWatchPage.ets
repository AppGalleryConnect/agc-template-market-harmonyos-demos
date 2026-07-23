import { CommonConstants, loadingPage } from 'lib_common';
import { AuthorModel } from 'lib_news_api';
import { emptyBuilder } from 'lib_widget';
import { FollowerPageViewModel } from '../viewmodels/FollowerPageVM';
import { WatchPageViewModel } from '../viewmodels/WatchPageVM';
import { AuthorItem } from './AuthorItem';

@ComponentV2
export struct BaseFollowWatchPage {
  @Require @Param vm: FollowerPageViewModel | WatchPageViewModel;
  @Param loading: boolean = false;

  build() {
    Column() {
      if (this.loading) {
        loadingPage()
      } else if (this.vm.dataSource.totalCount() > 0) {
        WaterFlow() {
          LazyForEach(this.vm.dataSource, (v: AuthorModel) => {
            FlowItem() {
              AuthorItem({
                author: v,
                fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
              })
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
        .columnsTemplate(this.vm.getColumnsTemplate())
        .columnsGap(CommonConstants.SPACE_XXL)
        .rowsGap(CommonConstants.SPACE_M)
        .cachedCount(1)
        .padding({
          left: this.vm.breakPointModel.pagePadding,
          right: this.vm.breakPointModel.pagePadding,
          top: CommonConstants.SPACE_M,
          bottom: this.vm.windowModel.windowBottomPadding,
        })
      } else {
        Column() {
          emptyBuilder({
            text: this.vm.emptyTip,
            fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
          })
        }
        .layoutWeight(1)
        .padding({
          bottom: 100,
        })
      }
    }
    .layoutWeight(1)
  }
}