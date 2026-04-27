import { image } from '@kit.ImageKit';
import { FirstPosterShareBuilder } from '../buider/FirstPosterShareBuilder'
import { PosterSharePop } from '../buider/PosterShareBuilder'
import { Screenshot } from '../componentScreenshot/Screenshot';
import { ShareEventDispatcher } from '../utils/EventDispatcher';
import { WxShareViewModel } from '../viewModel/WxShareViewModel';
import { QqShareViewModel } from '../viewModel/QqShareViewModel';
import { ShareOptions, ShareSheetParams } from '../model/Model';
import { PopViewUtils } from '../utils/PopViewUtils';

/**
 * @usage: 用于展示分享功能组件。提供文件分享功能，支持生成分享海报、二维码、微信分享、QQ分享等功能。
 * 关键数据结构包括ShareOptions（分享选项模型，包含qrCodeInfo二维码信息）、ShareSheetParams（分享弹窗参数，
 * 包含onPost回调和qrCodeInfo）、WxShareViewModel（微信分享视图模型，单例模式instance）、
 * QqShareViewModel（QQ分享视图模型，单例模式instance）、sharePopShow（控制分享弹窗显示）、
 * pixmap（海报图片PixelMap对象）。包含if逻辑：根据shareRenderBuilder是否存在判断渲染自定义内容或默认分享图标。
 * @layout: 页面采用Column垂直布局。主体根据shareRenderBuilder条件渲染：存在时渲染自定义内容，
 * 不存在时渲染默认分享图标Image（21x21、填充色为font_primary）。下方是PosterSharePop海报分享弹窗组件
 * （传入sharePopShow、qrCodeInfo、pixmap、onClose和popClose回调）。底部是Screenshot截图组件
 * （传入qrCodeInfo，位置left -2000、bottom 0，隐藏显示）。点击Column会触发分享弹窗，
 * 通过PopViewUtils.showSheet显示FirstPosterShareBuilder分享选择弹窗（标题"分享到"、背景色background_secondary、
 * 高度FIT_CONTENT）。
 * @constraints: QQ分享在aboutToAppear中初始化（qqShareViewModel.initQqShare()）不可修改；
 * ShareEventDispatcher.closeCallback会在关闭时调用onClose回调；分享弹窗参数ShareSheetParams包含onPost回调和qrCodeInfo；
 * Screenshot组件位置固定在屏幕外（left -2000）用于生成海报图片。
 * @isGen: true
 * @fileType: component
 * @zhName: 分享功能组件
 * @component: PosterSharePop,Screenshot,FirstPosterShareBuilder
 */

@ComponentV2
export struct Share {
  @BuilderParam shareRenderBuilder: () => void;
  @Param qrCodeInfo: ShareOptions = new ShareOptions()
  @Local sharePopShow: boolean = false
  @Local pixmap: image.PixelMap | undefined = undefined
  @Event onClose: () => void = () => {}
  @Event onOpen: () => void = () => {}
  @Local wxShareViewModel: WxShareViewModel = WxShareViewModel.instance
  @Local qqShareViewModel: QqShareViewModel = QqShareViewModel.instance

  aboutToAppear(): void {
    this.qqShareViewModel.initQqShare()
    ShareEventDispatcher.closeCallback = () => {
      this.onClose()
    }
  }

  onPost = (isOpen: boolean, pixmap: image.PixelMap) => {
    this.sharePopShow = isOpen
    this.pixmap = pixmap
  }

  build() {
    Column() {
      if (this.shareRenderBuilder) {
        this.shareRenderBuilder()
      } else {
        Image($r('app.media.share_active')).width(21).height(21).fillColor($r('sys.color.font_primary'))
      }
      PosterSharePop({
        sharePopShow: this.sharePopShow,
        qrCodeInfo:this.qrCodeInfo,
        pixmap:this.pixmap,
        onClose: () => {
          this.sharePopShow = false
          this.onClose()
        },
        popClose: (isClose: boolean) => {
          this.sharePopShow = isClose
        },
      })
      Screenshot({
        qrCodeInfo: this.qrCodeInfo,
      }).position({ left: -2000, bottom: 0 }).visibility(Visibility.Hidden)
    }
    .onClick(() => {
      this.onOpen()
      let params: ShareSheetParams = {
        onPost: this.onPost,
        qrCodeInfo: this.qrCodeInfo,
      }
      PopViewUtils.showSheet<ShareSheetParams>(wrapBuilder(FirstPosterShareBuilder), {
        showClose: true,
        title: {
          title: '分享到',
        },
        backgroundColor: $r('sys.color.background_secondary'),
        detents: [SheetSize.FIT_CONTENT],
      }, params);
    })
  }
}