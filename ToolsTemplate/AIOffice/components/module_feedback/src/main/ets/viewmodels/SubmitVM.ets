import { AppStorageV2 } from '@kit.ArkUI';
import { Constants, RouterMap } from '../common/Constants';
import { MediaUtils } from '../common/MediaUtils';
import { FeedbackModel } from '../common/FeedbackModel';
import { FeedbackService } from '../services/FuncService';
import { SubmitFeedbackParams } from '../services/RequestModel';
import { GlobalContext } from 'lib_common';

@ObservedV2
export class SubmitVM {
  @Trace feedbackModel: FeedbackModel = AppStorageV2.connect(FeedbackModel, () => new FeedbackModel())!;
  @Trace body: string = '';
  @Trace imgArr: string[] = [];
  @Trace contactPhone: string = '';
  @Trace maxSelectNumber: number = Constants.MAX_IMG_COUNT;
  @Trace stack: NavPathStack = new NavPathStack();
  @Trace loading: boolean = false;
  @Trace gridCount: number = 3;
  @Trace breakpoint: string = 'sm';

  async selectPhoto() {
    const uriList = await MediaUtils.selectMedia(this.maxSelectNumber - this.imgArr.length);
    this.imgArr.push(...uriList);
  }

  submit() {
    const isValid = this.validInfo();
    if (!isValid) {
      return;
    }
    this.loading = true;
    const cacheImgList = this.imgArr.map((v: string) => {
      return MediaUtils.handleUri(v);
    })
    const params: SubmitFeedbackParams = {
      problemDesc: this.body,
      screenShots: cacheImgList,
      contactPhone: this.contactPhone,
    };
    FeedbackService.addFeedback(params).then(() => {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '提交成功' });
      setTimeout(() => {
        this.stack.pop();
        this.stack.pushPathByName(RouterMap.FEEDBACK_RECORD_LIST_PAGE, null);
      }, 300);
    }).finally(() => {
      this.loading = false;
    });
  }

  validInfo() {
    if (!this.body) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '请描述您的问题' });
      return false;
    }
    if (this.contactPhone && !Constants.PHONE_REG.test(this.contactPhone)) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '请输入正确的手机号码' });
      return false;
    }
    return true;
  }

  onBreakpointChange(bp: string) {
    this.breakpoint = bp;
    if (bp === 'sm') {
      this.gridCount = 3;
    } else if (bp === 'md') {
      this.gridCount = 6;
    } else {
      this.gridCount = 8;
    }
  }

  @Computed
  get getColumnsTemplate() {
    return Array(this.gridCount).fill('1fr').join(' ');
  }
}