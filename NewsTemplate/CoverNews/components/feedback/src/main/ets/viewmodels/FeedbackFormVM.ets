import { UIContext } from '@kit.ArkUI';

import { isPhoneOrEmail } from '../utils/ValidationUtils';
import { Config } from '../common/Config';
import { FeedbackSubmitDTO } from '../models/FeedbackSubmitDTO';

@ObservedV2
export class FeedbackFormVM {

  private uiContext: UIContext;

  @Trace
  public description: string = '';

  @Trace
  public selectedUris: string[] = [];

  @Trace
  public contact: string = '';

  @Trace
  public contactErrorMessage: string = '';

  @Trace
  public descriptionErrorMessage: string = '';

  /**
   * 联系方式校验
   *
   * 可以为空，但处于非空时格式需正确
   *
   * @param showToast - 是否弹出错误提示信息
   * @returns 校验结果
   */
  public validateContact(showToast: boolean = true): boolean {
    if (this.contact && !isPhoneOrEmail(this.contact)) {
      this.contactErrorMessage = '手机号或邮箱格式不正确';
      if (showToast) {
        this.uiContext.getPromptAction().showToast({ message: this.contactErrorMessage });
      }
      return false;
    } else {
      this.contactErrorMessage = '';
      return true;
    }
  }

  /**
   * 问题描述校验
   *
   * 不可为空，且至少需要 DESC_TEXT_MIN_LENGTH 个字符
   *
   * @param showToast - 是否弹出错误提示信息
   * @returns 校验结果
   */
  public validateDescription(showToast: boolean = true): boolean {
    if (!this.description || this.description.length < Config.DESC_TEXT_MIN_LENGTH) {
      this.descriptionErrorMessage = `请至少用 ${Config.DESC_TEXT_MIN_LENGTH} 个字描述问题`;
      if (showToast) {
        this.uiContext.getPromptAction().showToast({ message: this.descriptionErrorMessage });
      }
      return false;
    } else {
      this.descriptionErrorMessage = '';
      return true;
    }
  }

  /**
   * 逐一校验所有字段，有任一失败项立即返回
   *
   * @returns 校验结果
   */
  public validateAll(): boolean {
    return this.validateDescription() && this.validateContact();
  }

  /**
   * 生成用于问题反馈提交 API 的数据传输对象
   *
   * @returns Feedback Submit Data Transfer Object
   */
  public toSubmitDTO(): FeedbackSubmitDTO {
    return {
      description: this.description,
      images: [...this.selectedUris],
      contact: this.contact
    };
  }

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }
}
