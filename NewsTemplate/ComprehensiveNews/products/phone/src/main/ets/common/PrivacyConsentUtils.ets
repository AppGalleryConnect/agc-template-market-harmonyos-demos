import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger, PreferenceUtils, RouterMap, RouterUtils } from 'lib_common';
import { PrivacyConsentController, PrivacyDocument, TextType } from 'module_consent_dialog';
import { agreePrivacyKey } from './Constants';

const TAG: string = '[PrivacyConsentUtils] ';

export class PrivacyConsentUtils {
  // todo: 自行调整是否支持开屏广告
  private isShowAd: boolean = false;
  private document: PrivacyDocument = [
    {
      text: '本应用需',
      type: TextType.PLAIN,
    },
    {
      text: '联网',
      type: TextType.PLAIN,
      color: $r('sys.color.font_primary'),
      fontWeight: FontWeight.Medium,
    },
    {
      text: '，调用XX、XX权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅',
      type: TextType.PLAIN,
    },
    {
      text: 'XX业务与隐私的声明',
      type: TextType.LINK,
      color: $r('app.color.app_theme'),
      href: 'https://privacy.consumer.huawei.com/legal/id/authentication-terms.htm?code=CN&language=zh-CN',
    },
    {
      text: '、',
      type: TextType.PLAIN,
    },
    {
      text: '权限使用说明',
      type: TextType.LINK,
      color: $r('app.color.app_theme'),
      href: 'https://privacy.consumer.huawei.com/legal/id/authentication-terms.htm?code=CN&language=zh-CN',
    },
    {
      text: '。\n\n请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。',
      type: TextType.PLAIN,
    },
  ];
  private pageController: PrivacyConsentController;
  private dialogController: PrivacyConsentController;

  constructor(uiContext: UIContext) {
    this.pageController = new PrivacyConsentController(uiContext)
      .setAppIcon($r('app.media.startIcon'))
      .setAppName('新闻阅读')
      .setAppDescription('业务描述')
      .setQuitButtonText('取消')
      .setAgreeButtonText('同意')
      .setDocument(this.document)
      .onAccept(() => {
        this.agreeBtnClick();
      })
      .onReject(() => {
        this.dialogController.openDialog();
      });
    this.dialogController = new PrivacyConsentController(uiContext)
      .setTitle('您需要同意协议才能体验功能')
      .setDocument(this.document)
      .onAccept(() => {
        this.agreeBtnClick();
      })
      .onReject(() => {
        const ctx: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
        ctx.terminateSelf().catch((e: BusinessError<void>) => {
          Logger.error(TAG, 'terminateSelf fail, error: ' + JSON.stringify(e))
        });
      });
  }

  private agreeBtnClick() {
    PreferenceUtils.getInstance().put(agreePrivacyKey, true);

    this.pageController.close();
    this.dialogController.close();
    RouterUtils.clearStack();

    const targetPage = this.isShowAd ? RouterMap.SPLASH_PAGE : RouterMap.INDEX_PAGE;
    RouterUtils.pushPathByName(targetPage, null, undefined, false);
  }

  public openFullScreenDialog() {
    this.pageController.openFullScreenDialog();
  }
}
