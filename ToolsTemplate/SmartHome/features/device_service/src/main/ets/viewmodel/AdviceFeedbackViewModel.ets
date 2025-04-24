import { LogUtil, prompt } from 'utils';

export class AdviceFeedbackViewMode {
  submit(issue: string, contact: string): boolean {
    LogUtil.debug('Advice', issue + ' ' + contact);
    if (issue === '') {
      prompt('请填写问题');
      return false
    } else {
      prompt('提交成功');
      return true
    }
  }
}