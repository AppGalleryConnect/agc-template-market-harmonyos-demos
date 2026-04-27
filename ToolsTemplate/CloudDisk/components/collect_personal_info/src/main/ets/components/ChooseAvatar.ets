import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../common/Constant';
import { ConfigInfo } from '../common/ConfigModel';
import { ERROR_MSG_MAP } from '../common/ErrorMsgMap';

const DOMAIN = 0xff00;
const TAG = '[ChooseAvatar]';

/**
 * @usage: 用于用户选择和上传头像的场景。提供头像选择功能，支持从相册选择图片作为头像。
 * 关键数据结构：url（头像地址字符串）、avatarH（头像高度）、onChooseAvatar（选择头像回调函数，
 * 参数为头像URL字符串）、ConfigInfo（配置信息，包含themeColor主题色）。
 * 包含错误处理逻辑：根据error.code显示对应的错误提示信息。
 * @layout: 使用FunctionalButton组件，圆形按钮布局（宽高相等，圆角50%），背景图为头像图片，
 * 背景色为主题色。居中对齐。
 * @constraints: url头像地址必须有效，avatarH头像高度必须大于0，onChooseAvatar回调函数必须正确处理头像URL，
 * 选择的图片文件必须可访问
 * @isGen: true
 * @fileType: component
 * @zhName: 头像选择组件
 * @component: FunctionalButton
 */
@ComponentV2
export struct ChooseAvatar {
  /**
   * 传入的头像地址
   */
  @Param url: ResourceStr = '';
  /**
   * 头像高度
   */
  @Param avatarH: Length = 48;
  /**
   * 选择头像的回调
   */
  @Event onChooseAvatar: (url: string) => void;
  @Local configInfo: ConfigInfo = AppStorageV2.connect(ConfigInfo, () => new ConfigInfo())!;

  build() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
        label: '',
        styleOption: {
          styleConfig: new functionalButtonComponentManager.ButtonConfig()
            .type(ButtonType.Normal)
            .backgroundImage(this.url)
            .backgroundImageSize(ImageSize.Cover)
            .backgroundColor(this.configInfo.themeColor)
            .width(this.avatarH)
            .height(this.avatarH)
            .borderRadius(Constants.HALF_PERCENT),
        },
      },
      controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err, data) => {
        if (err) {
          this.handleError(err);
          return;
        }
        let url = data.avatarUri!;
        let avatarFile: fs.File | null = null;
        try {
          avatarFile = fs.openSync(url, fs.OpenMode.READ_ONLY);
          let newPath: string =
            this.getUIContext().getHostContext()?.cacheDir + `/${util.generateRandomUUID(false)}.png`;
          fs.copyFileSync(avatarFile.fd, newPath);
          url = 'file://' + newPath;
        } finally {
          if (avatarFile) {
            fs.closeSync(avatarFile);
          }
        }

        this.onChooseAvatar(url);
      }),
    })
  }

  handleError(error: BusinessError) {
    hilog.error(DOMAIN, TAG, 'onChooseAvatar failed, error: ' + JSON.stringify(error));
    const errorMsg: string = ERROR_MSG_MAP[error.code] ?? '';
    if (errorMsg) {
      this.getUIContext().getPromptAction().showDialog({
        title: '温馨提示',
        message: errorMsg,
        buttons: [
          { text: '确定', color: this.configInfo.themeColor },
        ],
      })
    }
  }
}
