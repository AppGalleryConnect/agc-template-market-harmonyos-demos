import { fileIo as fs } from '@kit.CoreFileKit';
import { TValueType } from 'video_common';
import { SubtitlesSingleModel } from '../model/SubtitlesSingleModel';

@ObservedV2
export class CreateSubtitlesVM {
  stack: NavPathStack | null = null;
  scroller: ListScroller = new ListScroller();
  @Trace subtitlesList: SubtitlesSingleModel[] = [];

  initParam(subParams: TValueType) {
    try {
      this.subtitlesList = subParams as SubtitlesSingleModel[]
    } catch (err) {
    }
  }

  backPage() {
    this.stack?.popToName('VideoEditDetailPage', [...this.subtitlesList], true);
  }

  createSubtitles() {
    this.stack?.pushPathByName('EditSubtitlesPage', [[...this.subtitlesList], -1],
      (popInfo: PopInfo) => {
        try {
          let subtitles = popInfo.result as SubtitlesSingleModel;
          this.insertSubtitlesList(subtitles);
        } catch (err) {
        }
      }, true);
  }


  deleteSubtitles(index: number) {
    let model = this.subtitlesList.splice(index, 1)[0];
    if (model.url.length > 0 && fs.accessSync(model.url)) {
      // 删除沙箱中对应字幕数据的截屏图片
      fs.unlinkSync(model.url);
    }
  }

  editSubtitles(index: number) {
    this.stack?.pushPathByName('EditSubtitlesPage', [[...this.subtitlesList], index],
      (popInfo: PopInfo) => {
        try {
          let subtitles = popInfo.result as SubtitlesSingleModel;
          this.subtitlesList.splice(index, 1, subtitles);
        } catch (err) {
        }
      }, true);
  }

  insertSubtitlesList(subtitles: SubtitlesSingleModel) {
    if (this.subtitlesList.length === 0) {
      // 空数据直接添加
      this.subtitlesList.push(subtitles);
    } else if (subtitles.endTimestamp <= this.subtitlesList[0].startTimestamp) {
      // 在开始的地方添加
      this.subtitlesList.splice(0, 0, subtitles);
    } else if (subtitles.startTimestamp >= this.subtitlesList[this.subtitlesList.length - 1].endTimestamp) {
      // 在结尾的地方添加
      this.subtitlesList.push(subtitles);
    } else {
      // 中间空白插入
      for (let index = 0; index < this.subtitlesList.length; index++) {
        const element = this.subtitlesList[index];
        const nextElement = this.subtitlesList[index + 1];
        if (subtitles.startTimestamp >= element.endTimestamp &&
          subtitles.startTimestamp < nextElement?.startTimestamp) {
          this.subtitlesList.splice(index + 1, 0, subtitles);
          break;
        }
      }
    }
  }
}