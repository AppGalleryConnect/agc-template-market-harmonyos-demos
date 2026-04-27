import { QQShareData, SharePicker } from 'aggregated_share';
import { AccountUtil, RouterMap, RouterModule } from 'commonlib';
import { BasketItem } from 'shopping_basket';
import { Score } from '../model/CommentModel';
import { CommentPopup } from '../pages/CommentPopup';
import { DishesVM } from '../viewModels/DishesVM';

@ComponentV2
export struct BottomZone {
  @Local arr: Score[] = [
    new Score('0', true),
    new Score('1', false),
    new Score('2', false),
    new Score('3', false),
    new Score('4', false),
  ];
  @Param @Require dishesVm: DishesVM;
  @Param isShowDishModel: boolean = false;
  @Local isShow: boolean = false;

  aboutToAppear(): void {

  }

  @Computed
  get isInBasket() {
    return this.dishesVm.basketList.list.some((item: BasketItem) => item.id === this.dishesVm.recipeDetail?.id);
  }

  submitResult(count: number, content: string) {
    this.dishesVm.addComment(content, count);
    this.isShow = false;
    if (this.dishesVm.breakPoint === 'sm') {
      this.dishesVm.scroller.scrollEdge(Edge.Bottom)
    } else {
      this.dishesVm.stepScroller.scrollEdge(Edge.Bottom)
    }
    this.dishesVm.commentsScroller.scrollEdge(Edge.Top);
  }

  @Builder
  commentSheet() {
    CommentPopup({
      submitEvent: (count: number, content: string) => {
        this.submitResult(count, content);
      }
    })
      .width('100%')
  }

  build() {
    // 底部互动专区
    Row({ space: 12 }) {
      Column({ space: 2 }) {
        Image(this.dishesVm.collection ? $r('app.media.ic_star') : this.dishesVm.isFullScreen ?
          $r('app.media.ic_star_white') : $r('app.media.ic_star_fill'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Fill)

        Text(this.dishesVm.collection ? '已收藏' : '收藏')
          .textStyles(this.dishesVm.isFullScreen)
      }
      .onClick(() => {
        this.dishesVm.collectCb()
      })
      .height(40)
      .width(30)


      Column({ space: 2 }) {
        Image(this.dishesVm.isFullScreen ? $r('app.media.ic_comment_white') : $r('app.media.ic_comment'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Fill)

        Text('评论')
          .textStyles(this.dishesVm.isFullScreen)
      }
      .height(40)
      .width(30)
      .onClick(() => {
        this.dishesVm.isFullScreen = false;
        setTimeout(() => {
          if (this.dishesVm.breakPoint === 'sm') {
            this.dishesVm.scroller.scrollEdge(Edge.Bottom)
          } else {
            this.dishesVm.stepScroller.scrollEdge(Edge.Bottom)
          }
        }, 200)
      })

      Column({ space: 2 }) {
        Image(this.dishesVm.isFullScreen ? $r('app.media.ic_share_white') : $r('app.media.ic_bottom_share'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Fill)
        Text('分享')
          .textStyles(this.dishesVm.isFullScreen)
      }
      .height(40)
      .width(30)
      .onClick(() => {
        const picker: SharePicker = new SharePicker({
          title: this.dishesVm.recipeDetail?.title ?? '',
          subTitle: this.dishesVm.recipeDetail?.author,
          coverUrl: this.dishesVm.recipeDetail?.thumbnail,
          createTime: new Date('2025/09-15 08:00:00').getTime(),
          thumbUrl: '', // 实际需要传入url(png)，例：https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/commonwidget%2Fexample960x720.png
          landingPageUrl: '', // 二维码生成,例：https://www.xxxxxx.com/recipes?action=recipesList
        });

        picker.setSignQQShareDataCB((shareJson: string) => {
          const signData = new QQShareData();
          signData.shareJson = shareJson;
          signData.timestamp = Date.parse(new Date().toString()) / 1000;
          signData.nonce = 62695688;
          signData.shareJsonSign = 'Hsvqs0IpjiN6DfFfhboGp+r3XzQ=';
          return Promise.resolve(signData);
        })

        picker.show(this.getUIContext(), {
          autoClose: true,
        });
      })

      Button({
        type: ButtonType.Capsule,
        stateEffect: true,
      }) {
        Text('发表评论')
          .fontSize($r('sys.float.Body_L'))
          .fontColor(this.dishesVm.isFullScreen ? 'rgba(255, 255, 255, 0.6)' : $r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .alignSelf(ItemAlign.Start);
      }
      .padding({ left: 12 })
      .align(Alignment.Start)
      .backgroundColor(this.dishesVm.isFullScreen ? 'rgba(255, 255, 255, 0.2)' :
        $r('sys.color.comp_background_tertiary'))
      .height(40)
      .layoutWeight(1)
      .bindSheet(this.isShow, this.commentSheet(), {
        // 半模态高度
        height: 340,
        dragBar: true, // 是否显示控制条
        showClose: true, // 是否显示关闭图标
        preferType: SheetType.CENTER,
        shouldDismiss: ((sheetDismiss: SheetDismiss) => { // 半模态页面交互式关闭回调函数
          sheetDismiss.dismiss();
          this.isShow = false;
        })
      })
      .onClick(() => {
        // 需要先判断是否登录
        if (!AccountUtil.getUserInfo().isLogin) {
          RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
          return
        }
        this.isShow = true;
      });
    }
    .width('100%')
    .height(85)
    .padding({ left: 16, right: 16, bottom: 26 })
    .backgroundColor(this.dishesVm.isFullScreen ? Color.Black : $r('sys.color.comp_background_gray'))
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Extend(Text)
function textStyles(isFullScreen: boolean) {
  .fontSize(10)
  .fontFamily('HarmonyHeiTi')
  .fontColor(isFullScreen ? Color.White : $r('sys.color.font_primary'))
}