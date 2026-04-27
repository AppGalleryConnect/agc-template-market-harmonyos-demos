import { GlobalContextUtils, Logger, PushUtils, RouterModule, SettingModel } from 'commonlib';
import { BusinessError } from '@kit.BasicServicesKit';
import { RecipeStep, uploadMyRecipe, UploadRecipeBody } from 'network';
import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { Step, UploadRecipeData } from 'upload_recipe';
import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';


const TAG = '[UploadRecipeVM]';

@ObservedV2
export class UploadRecipeVM {
  @Trace settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  private context: common.UIAbilityContext = GlobalContextUtils.globalUIAbilityContext;

  public async uploadRecipe(data: UploadRecipeData) {
    const requestBody: UploadRecipeBody = {
      description: data.description,
      title: data.title,
      ingredients: data.ingredients,
      image: data.mainImg,
      video: data.video,
      coverUrl: data.coverUrl,
      steps: data.steps.map((item: Step, index: number) => {
        const val: RecipeStep = {
          description: item.description,
          stepNumber: index + 1,
          stepImg: item.stepImg
        };
        return val;
      }),
    };
    try {
      const res = await uploadMyRecipe(requestBody)
      if (res.status === 200) {
        GlobalContextUtils.showToast({ message: '上传成功！' });
        this.sendPushNotice(this.context);
        RouterModule.pop('success')
      }

    } catch (err) {
      GlobalContextUtils.showToast({ message: '上传失败！' });
      Logger.error(TAG, err)
    }
  }

  sendPushNotice(context: common.UIAbilityContext) {
    if (!this.settingInfo.pushSwitch) {
      notificationManager.requestEnableNotification(context).then((err) => {
        this.settingInfo.pushSwitch = true;
        this.sendPushMessage();
      }).catch((error: BusinessError) => {
        this.settingInfo.pushSwitch = false;
      });
    } else {
      this.sendPushMessage();
    }
  }

  // mock 开启随机推送
  async sendPushMessage() {
    PushUtils.randomPushMessage({})
  }
}