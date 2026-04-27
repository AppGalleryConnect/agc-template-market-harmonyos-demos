import { TextSpanInfo } from 'lib_common';
import { QQShareData, ShareOptions, SharePicker, ShareRecordData, ShareAppType } from 'module_share';

/**
 * 统一分享
 */
@ComponentV2
export struct Share {
  @Param shareData: ShareRecordData = { title: '' };
  @Param options: ShareOptions = {
    autoClose: true,
    excludedAbilities: [ShareAppType.WEIBO],
  };
  @BuilderParam shareRenderBuilder: () => void;

  // todo 需填写实际的签名方法
  signQQ(shareJson: string): Promise<QQShareData> {
    const signData = new QQShareData();
    signData.shareJson = shareJson;
    signData.timestamp = Date.parse(new Date().toString()) / 1000;
    signData.nonce = 62695688;
    signData.shareJsonSign = 'Hsvqs0IpjiN6DfFfhboGp+r3XzQ=';
    return Promise.resolve(signData);
  }

  handleTitle(title: string) {
    try {
      return (JSON.parse(title || '[]') as TextSpanInfo[]).map(v => v.text).join('');
    } catch (e) {
      return title || '';
    }
  }

  build() {
    Column() {
      if (this.shareRenderBuilder) {
        this.shareRenderBuilder()
      } else {
        Image($r('app.media.share_active'))
          .width(20)
          .height(20)
          .fillColor($r('sys.color.font_primary'))
          .draggable(false)
      }
    }
    .onClick(() => {
      this.shareData.title = this.handleTitle(this.shareData.title);
      const picker: SharePicker =
        new SharePicker(this.shareData).setSignQQShareDataCB((shareJson: string) => this.signQQ(shareJson));
      picker.show(this.getUIContext(), this.options);
    })
  }
}