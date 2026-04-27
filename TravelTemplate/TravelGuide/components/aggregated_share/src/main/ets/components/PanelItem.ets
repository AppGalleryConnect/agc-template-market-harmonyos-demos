import { image } from '@kit.ImageKit';
import { CommonConstants } from '../common/Constants';
import { ShareAppType, ShareWay } from '../common/ShareEnum';
import { ShareKinds, ShareViewData } from '../common/ShareParams';
import { saveImgToAlbum } from '../utils/FileUtils';
import { WXShareUtils } from '../utils/WXShareUtils';
import { QQShareUtils } from '../utils/QQShareUtils';
import { WeiboShareUtils } from '../utils/WeiboShareUtils';
import { SystemShareUtils } from '../utils/SystemShareUtils';
import { CustomTouchModifier } from '../common/Styles';

@ComponentV2
export struct PanelItem {
  @Require @Param value: ShareKinds;
  @Require @Param data: ShareViewData;
  @Param @Require pixmap: image.PixelMap;
  @Event showPoster: () => void = () => {
  };
  @Local systemShare: SystemShareUtils = SystemShareUtils.instance;
  @Local wxShare: WXShareUtils = WXShareUtils.instance;
  @Local qqShare: QQShareUtils = QQShareUtils.instance;
  @Local weiboShare: WeiboShareUtils = WeiboShareUtils.instance;
  @Local touchModifier: CustomTouchModifier = new CustomTouchModifier();

  sendTextOrUrl() {
    switch (this.value.kindId) {
      case ShareAppType.WECHAT_SESSION:
      case ShareAppType.WECHAT_TIMELINE:
        this.wxShare.shareWebpage(this.data, this.value.kindId);
        break;
      case ShareAppType.QQ:
        this.qqShare.share(this.data);
        break;
      case ShareAppType.WEIBO:
        this.weiboShare.share(this.data);
        break;
      case ShareWay.POSTER:
        this.showPoster();
        break;
      case ShareWay.COPY_TO_PASTEBOARD:
        this.systemShare.copy(this.data);
        this.handleAutoClose();
        break;
      case ShareWay.SYSTEM:
        this.systemShare.share().then(() => {
          this.handleAutoClose();
        });
        break;
    }
  }

  sendImage() {
    switch (this.value.kindId) {
      case ShareAppType.WECHAT_SESSION:
      case ShareAppType.WECHAT_TIMELINE:
        this.wxShare.shareImage(this.pixmap, this.value.kindId);
        break;
      case ShareAppType.WEIBO:
        this.weiboShare.share(this.data, this.pixmap);
        break;
      case ShareWay.SAVE_TO_ALBUM:
        saveImgToAlbum(this.pixmap).then(() => {
          this.handleAutoClose();
        });
        break;
    }
  }

  handleAutoClose() {
    if (this.data.autoClose) {
      this.data.closeSheet();
    }
  }

  build() {
    Column() {
      Column({ space: CommonConstants.PADDING_XS }) {
        Image(this.value.icon)
          .width(40)
          .height(40)
          .draggable(false)
        Text(this.value.label)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'))
      }
      .constraintSize({ minWidth: 60 })
    }
    .padding({
      left: CommonConstants.PADDING_XS,
      right: CommonConstants.PADDING_XS,
      top: CommonConstants.PADDING_S,
      bottom: CommonConstants.PADDING_XS,
    })
    .borderRadius(8)
    .attributeModifier(this.touchModifier)
    .onClick(() => {
      if (this.value.isPoster) {
        this.sendImage();
      } else {
        this.sendTextOrUrl();
      }
    })
  }
}