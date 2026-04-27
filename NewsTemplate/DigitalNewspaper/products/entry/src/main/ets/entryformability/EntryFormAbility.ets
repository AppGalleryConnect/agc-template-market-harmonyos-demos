import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FormUtils } from '../widget/common/FormUtils';
import { FormCardData } from '../widget/common/Types';

const TAG: string = '[EntryFormAbility]';

export default class EntryFormAbility extends FormExtensionAbility {
  private formData: FormCardData = {
    data: FormUtils.getDefaultFormData(),
  };

  // 卡片添加时调用
  onAddForm(want: Want) {
    let formId: string = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string;
    hilog.info(0x0000, TAG, `onAddForm formId: ${formId}`);
    if (formId) {
      FormUtils.addFormId(formId, this.context);
    }

    return formBindingData.createFormBindingData(this.formData);
  }

  // 卡片更新时调用
  onUpdateForm(formId: string): void {
    FormUtils.updateWidget(formId);
  }

  // 卡片移除时调用
  onRemoveForm(formId: string) {
    hilog.info(0x0000, TAG, `onRemoveForm, formId = ${formId}`);
    FormUtils.delFormId(formId, this.context);
  }

  onAcquireFormState(want: Want) {
    // 卡片提供方接收查询卡片状态通知接口，默认返回卡片初始状态。
    return formInfo.FormState.READY;
  }
}