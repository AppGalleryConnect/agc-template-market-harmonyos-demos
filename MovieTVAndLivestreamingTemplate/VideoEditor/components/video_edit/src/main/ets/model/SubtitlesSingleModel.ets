import { systemDateTime } from '@kit.BasicServicesKit';

@ObservedV2
export class SubtitlesSingleModel {
  @Trace content: string = '';
  @Trace startTime: string = '00:00';
  @Trace startTimestamp: number = 0;
  @Trace endTime: string = '00:00';
  @Trace endTimestamp: number = 0;
  @Trace url: string = '';
  @Trace keyId: string = systemDateTime.getTime(true).toString();

  copyModel() {
    let tempModel = new SubtitlesSingleModel();
    tempModel.content = this.content;
    tempModel.startTime = this.startTime;
    tempModel.startTimestamp = this.startTimestamp;
    tempModel.endTime = this.endTime;
    tempModel.endTimestamp = this.endTimestamp;
    tempModel.url = this.url;
    return tempModel;
  }
}