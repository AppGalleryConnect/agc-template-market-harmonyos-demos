import { fileIo as fs } from '@kit.CoreFileKit';
import { TValueType } from 'video_common';
import { SubtitlesSelectTimeDialog, SubtitlesTimeModel } from '../components/SubtitlesSelectTimeDialog';
import { SubtitlesSingleModel } from '../model/SubtitlesSingleModel';
import { saveScreenshot } from '../utils/CommonUtils';

@ObservedV2
export class EditSubtitlesVM {
  subtitlesList: SubtitlesSingleModel[] = [];
  stack: NavPathStack | null = null;
  @Trace subtitlesModel: SubtitlesSingleModel = new SubtitlesSingleModel();
  @Trace timeIndex: number = -1;

  initParam(pageParams: TValueType) {
    try {
      const params: Object[] = pageParams as Object[];
      const list = params[0] as SubtitlesSingleModel[];
      const index: number = params[1] as number;
      if (index >= 0) {
        const tempModel = list[index];
        this.subtitlesModel = tempModel.copyModel();
        list.splice(index, 1);
      } else {
        this.subtitlesModel = new SubtitlesSingleModel();
      }
      this.subtitlesList = list
    } catch (err) {
    }
  }

  backPage() {
    this.stack?.pop();
  }

  selectStartTime(uiContext: UIContext) {
    this.timeIndex = 1;
    this.popupSelectTime(uiContext, this.subtitlesModel.startTime, (model: SubtitlesTimeModel) => {
      this.timeIndex = -1;
      const timestamp = Number(model.minuteValue) * 60 + Number(model.secondValue);
      if (timestamp >= this.subtitlesModel.endTimestamp && this.subtitlesModel.endTimestamp > 0) {
        uiContext.getPromptAction().showToast({
          message: '结束时间需要大于开始时间'
        })
        return;
      }

      this.subtitlesModel.startTimestamp = timestamp;
      this.subtitlesModel.startTime = model.minuteValue + ':' + model.secondValue;
    })
  }

  selectEndTime(uiContext: UIContext) {
    this.timeIndex = 2;
    this.popupSelectTime(uiContext, this.subtitlesModel.endTime, (model: SubtitlesTimeModel) => {
      this.timeIndex = -1;
      const timestamp = Number(model.minuteValue) * 60 + Number(model.secondValue);
      if (timestamp <= this.subtitlesModel.startTimestamp) {
        uiContext.getPromptAction().showToast({
          message: '结束时间需要大于开始时间'
        })
        return;
      }
      this.subtitlesModel.endTimestamp = timestamp;
      this.subtitlesModel.endTime = model.minuteValue + ':' + model.secondValue;
    })
  }

  popupSelectTime(uiContext: UIContext, timeString: string, callback: (model: SubtitlesTimeModel) => void) {
    uiContext.getFocusController().clearFocus();
    let dialogVM = new SubtitlesTimeModel();
    const times = timeString.split(':');
    dialogVM.minuteValue = times[0];
    dialogVM.minuteSelect = dialogVM.minuteList.indexOf(times[0]);
    dialogVM.secondValue = times[1];
    dialogVM.secondSelect = dialogVM.secondList.indexOf(times[1]);
    dialogVM.onValueConfirmClick = callback;
    dialogVM.onValueCancelClick = () => {
      this.timeIndex = -1;
    }
    SubtitlesSelectTimeDialog.ShowPopup(dialogVM, uiContext);
  }

  async saveSubtitles(uiContext: UIContext) {
    if (this.subtitlesModel.content.length === 0) {
      uiContext.getPromptAction().showToast({
        message: '请填写字幕文案'
      })
      return;
    }

    if (this.subtitlesModel.endTimestamp === 0) {
      uiContext.getPromptAction().showToast({
        message: '请选择字幕时间'
      })
      return;
    }

    if (this.subtitlesModel.endTimestamp <= this.subtitlesModel.startTimestamp) {
      uiContext.getPromptAction().showToast({
        message: '字幕开始时间需要小于结束时间'
      })
      return;
    }


    for (let index = 0; index < this.subtitlesList.length; index++) {
      if (!this.parseEverySubtitles(index, uiContext)) {
        return;
      }
    }

    //根据字幕组件ID获取对应的 image.PixelMap
    if (this.subtitlesModel.url.length > 0 && fs.accessSync(this.subtitlesModel.url)) {
      // 删除老的图片数据
      fs.unlinkSync(this.subtitlesModel.url);
    }
    const pixelMap = await uiContext.getComponentSnapshot().get('editTextSubTitle', {})
    this.subtitlesModel.url = await saveScreenshot(uiContext, pixelMap, 2, '')
    uiContext.getPromptAction().showToast({
      message: '保存成功'
    })

    this.stack?.popToName('CreateSubtitlesPage', this.subtitlesModel, true);
  }

  parseEverySubtitles(index: number, uiContext: UIContext) {
    const element = this.subtitlesList[index];
    // 当前字幕开始时间或结束时间 不能在任一字幕时间之内
    if ((this.subtitlesModel.startTimestamp >= element.startTimestamp &&
      this.subtitlesModel.startTimestamp < element.endTimestamp) ||
      (this.subtitlesModel.endTimestamp > element.startTimestamp &&
        this.subtitlesModel.endTimestamp <= element.endTimestamp)) {
      uiContext.getPromptAction().showToast({
        message: '当前字幕时间和其他字幕时间不能重叠'
      })
      return false;
    }

    // 当前字幕开始时间小于循环位字幕的开始时间时，当前字幕的结束时间不能大于循环位字幕的开始时间
    if (this.subtitlesModel.startTimestamp < element.startTimestamp &&
      this.subtitlesModel.endTimestamp > element.startTimestamp) {
      uiContext.getPromptAction().showToast({
        message: '当前字幕时间和其他字幕时间不能重叠'
      })
      return false;
    }

    if (index < this.subtitlesList.length - 1) {
      const nextElement = this.subtitlesList[index + 1];
      // 当前字幕开始时间大于等于循环位字幕的开始时间时，当前字幕的开始时间和结束时间不能大于循环位字幕的开始时间
      if (this.subtitlesModel.startTimestamp >= element.endTimestamp &&
        this.subtitlesModel.startTimestamp < nextElement.startTimestamp &&
        this.subtitlesModel.endTimestamp > nextElement.startTimestamp) {
        uiContext.getPromptAction().showToast({
          message: '当前字幕时间和其他字幕时间不能重叠'
        })
        return false;
      }
    }
    return true;
  }
}