import {
  CheckInActivity,
  Logger,
  RouterMap,
  RouterModule,
  CheckInTaskItem,
  PickerUtil,
  PickerPreviewItem,
  PickerResourceType,
  CheckInRecord,
  CloudStorageUtil,
  FullLoading,
} from 'commonlib';
import { CheckInRecordModel } from '../models/Index';
import { CheckInLogRouteParam, TaskCheckInPopParam } from '../types/Index';
import { promptAction } from '@kit.ArkUI';
import { https } from 'network';

const TAG = '[SubmitCheckInVM]';

@ObservedV2
export class SubmitCheckInVM {
  // 活动信息
  @Trace activity: CheckInActivity | null = null;
  // 任务信息
  @Trace taskItem: CheckInTaskItem | null = null;
  // 打卡内容
  @Trace checkInData = new CheckInRecordModel();
  videoController: VideoController = new VideoController();
  private static _instance: SubmitCheckInVM;

  public static get instance() {
    if (!SubmitCheckInVM._instance) {
      SubmitCheckInVM._instance = new SubmitCheckInVM();
    }
    return SubmitCheckInVM._instance;
  }

  @Computed
  public get previewGridHeight() {
    const rowNum = Math.ceil(PickerUtil.mediaPreviewList.length / 3);
    return rowNum * 118;
  }

  public initRecord() {
    const params = RouterModule.getNavParam<CheckInLogRouteParam>({
      url: RouterMap.ACTIVITY_SUBMIT,
    });
    if (params) {
      this.checkInData.activityId = params.activity.activityId;
      this.checkInData.taskId = params.task.taskId;
      this.taskItem = params.task;
      this.activity = params.activity;
    }
  }

  public async submitRecord() {
    if (!this.checkInData.taskId || !this.checkInData.activityId) {
      promptAction.showToast({ message: '任务信息获取失败，请稍后重试' });
    }
    const isValid = this._isCheckInDataValid();
    if (!isValid) {
      return;
    }
    this._uploadCheckInFile();
  }

  private _isCheckInDataValid() {
    const requirement = this.activity?.requirement;
    if (requirement) {
      if (requirement.textSwitch && this.checkInData.textDetail.length < requirement.textMinLimit) {
        promptAction.showToast({ message: `打卡文字不得少于${requirement.textMinLimit}个字~` });
        return false;
      }
      if (requirement.pictureSwitch) {
        const picsNum = PickerUtil.mediaPreviewList.filter((item) => item.type === PickerResourceType.IMAGE).length;
        if (picsNum < requirement.pictureMinLimit) {
          promptAction.showToast({ message: `打卡图片不得少于${requirement.pictureMinLimit}张~` });
          return false;
        }
      }
      if (requirement.audioSwitch) {
        const audioNum = PickerUtil.mediaPreviewList.filter((item) => item.type === PickerResourceType.AUDIO).length;
        if (!audioNum) {
          promptAction.showToast({ message: '请至少上传一个打卡音频~' });
          return false;
        }
      }
      if (requirement.videoSwitch) {
        const videoNum = PickerUtil.mediaPreviewList.filter((item) => item.type === PickerResourceType.VIDEO).length;
        if (!videoNum) {
          promptAction.showToast({ message: '请至少上传一个打卡视频~' });
          return false;
        }
      }
    }
    return true;
  }

  private async _uploadCheckInFile() {
    this.checkInData.pictureDetail = [];
    this.checkInData.audioDetail = [];
    this.checkInData.videoDetail = [];
    const fileNum = PickerUtil.mediaPreviewList.length;
    let completedNum: number = 0;
    FullLoading.show('文件上传中...');
    let flag = true;
    for (const item of PickerUtil.mediaPreviewList) {
      if (!flag) {
        return;
      }
      try {
        await CloudStorageUtil.upload(item.uri as string, async (url: string, isSuccess: boolean = true) => {
          flag = isSuccess;
          if (!flag) {
            Logger.error(TAG, 'upload file failed');
            promptAction.showToast({ message: '打卡失败，请稍后重试~' });
            FullLoading.hide();
            return;
          }
          completedNum++;
          if (item.type === PickerResourceType.IMAGE) {
            this.checkInData.pictureDetail.push(url);
          } else if (item.type === PickerResourceType.VIDEO) {
            this.checkInData.videoDetail.push(url);
          } else if (item.type === PickerResourceType.AUDIO) {
            this.checkInData.audioDetail.push(url);
          }
          if (completedNum === fileNum) {
            Logger.info(TAG, 'files upload completed');
            try {
              const res = await https.commitUserCheckIn(this.checkInData);
              if (res.ret.code === 0) {
                promptAction.showToast({ message: '打卡成功！' });
                this.clearData();
                const popInfo: TaskCheckInPopParam = {
                  needUpdate: true,
                };
                RouterModule.pop(popInfo);
              } else {
                promptAction.showToast({ message: '打卡失败，请稍后重试~' });
              }
            } catch (err) {
              Logger.error(TAG, 'commit check-in data failed:' + err);
              promptAction.showToast({ message: '打卡失败，请稍后重试~' });
            } finally {
              FullLoading.hide();
            }
          }
        });
      } catch (err) {
        Logger.error(TAG, 'upload failed,error:' + err);
        promptAction.showToast({ message: '打卡失败，请稍后重试~' });
        FullLoading.hide();
      }
    }
  }

  public jumpToFullScreenPage(type: PickerResourceType, uri: ResourceStr) {
    if (type === PickerResourceType.AUDIO) {
      promptAction.showToast({ message: '暂不支持播放音频' });
      return;
    }
    const item: PickerPreviewItem = {
      type,
      uri,
    };
    RouterModule.push({
      url: RouterMap.ACTIVITY_FULL_SCREEN_MEDIA,
      param: item,
    });
  }

  public backToLastPage() {
    RouterModule.pop();
    PickerUtil.clearResource();
  }

  public async submitCheckInData() {
    if (!this.activity || !this.taskItem) {
      return;
    }
    const requirement = this.activity.requirement;
    if (requirement.textSwitch && this.checkInData.textDetail.length < requirement.textMinLimit) {
      promptAction.showToast({
        message: `文字内容不得少于${requirement.textMinLimit}字`,
      });
      return;
    }
    if (requirement.pictureSwitch && this.checkInData.pictureDetail.length < requirement.pictureMinLimit) {
      promptAction.showToast({
        message: `图片内容不得少于${requirement.textMinLimit}张`,
      });
      return;
    }
    if (requirement.videoSwitch && this.checkInData.videoDetail.length < requirement.videoMinLimit) {
      promptAction.showToast({
        message: `视频内容不得少于${requirement.textMinLimit}个`,
      });
      return;
    }
    PickerUtil.mediaPreviewList.forEach((item) => {
      if (item.type === PickerResourceType.IMAGE) {
        this.checkInData.pictureDetail.push(item.uri);
      } else if (item.type === PickerResourceType.VIDEO) {
        this.checkInData.videoDetail.push(item.uri);
      }
    });
    const data: CheckInRecord = {
      taskId: this.taskItem?.taskId,
      activityId: this.activity.activityId,
      textDetail: this.checkInData.textDetail,
      videoDetail: this.checkInData.videoDetail,
      pictureDetail: this.checkInData.pictureDetail,
      audioDetail: this.checkInData.audioDetail,
      createTime: new Date().getTime().toString(),
    };
    const res = await https.commitUserCheckIn(data);
    if (res.ret.code === 0) {
      promptAction.showToast({ message: '打卡成功！' });
      const timer = setTimeout(() => {
        RouterModule.pop();
        clearTimeout(timer);
      }, 1000);
    }
  }

  public clearData() {
    PickerUtil.clearResource();
    this.checkInData.textDetail = '';
    this.checkInData.pictureDetail = [];
    this.checkInData.videoDetail = [];
    this.checkInData.audioDetail = [];
  }
}