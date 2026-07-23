import { CommonConstants, loadingPage } from 'lib_common';
import { NewsModel } from 'lib_news_api';
import { emptyBuilder } from 'lib_widget';
import { LikeViewModel } from '../viewmodels/LikeVM';
import { MarkViewModel } from '../viewmodels/MarkVM';
import { UniformNewsCard } from './UniformNewsCard';

@ComponentV2
export struct BaseMarkLikePage {
  @Require @Param vm: LikeViewModel | MarkViewModel;

  build() {
    Column() {
      if (this.vm.loadingModel.loading) {
        loadingPage()
      } else if (this.vm.list.length <= 0) {
        Column() {
          emptyBuilder({
            fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
          })
        }
        .layoutWeight(1)
        .padding({
          bottom: 100,
        })
      } else {
        Column() {
          List({ space: CommonConstants.SPACE_M }) {
            ForEach(this.vm.list, (v: NewsModel) => {
              ListItem() {
                this.contentItemBuilder(v)
              }
            }, (v: NewsModel) => v.id)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .lanes(this.vm.lanesMap.getValue(this.vm.breakPointModel.currentBreakpoint), 12)
          .padding({
            left: this.vm.breakPointModel.pagePadding,
            right: this.vm.breakPointModel.pagePadding,
            top: CommonConstants.SPACE_M,
            bottom: CommonConstants.SPACE_M,
          })
        }
        .layoutWeight(1)
      }
    }
    .layoutWeight(1)
  }

  @Builder
  contentItemBuilder(v: NewsModel) {
    Row() {
      UniformNewsCard({
        newsInfo: v,
        customStyle: {
          bodyFg: 16 * this.vm.settingInfo.fontSizeRatio,
        },
        operateBuilder: () => {
          this.operateBuilder(v)
        },
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: CommonConstants.PADDING_M,
      bottom: CommonConstants.PADDING_M,
    })
  }

  @Builder
  operateBuilder(v: NewsModel) {
    Row() {
      Image($r('app.media.ic_public_ellipsis_circle'))
        .width($r('app.float.medium_img_width'))
        .aspectRatio(1)
        .draggable(false)
        .fillColor($r('sys.color.icon_secondary'))
    }
    .accessibilityText('取消按钮')
    .onClick(() => {
      this.vm.popDialog(v);
    })
  }
}