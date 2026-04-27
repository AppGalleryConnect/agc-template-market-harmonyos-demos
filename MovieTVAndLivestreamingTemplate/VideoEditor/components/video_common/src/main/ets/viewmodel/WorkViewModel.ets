import WorkModel from '../model/WorkModel';

@ObservedV2
export class WorkViewModel {
  @Trace public id: string = '';
  @Trace public title: string = '';
  @Trace public duration: string = '';
  @Trace public thumbnail: string = '';
  @Trace public createTime: string = '';
  @Trace public fileSize: string = '';
  @Trace public status: string = '';
  @Trace public fileFormat: string = '';
  @Trace public videoCodeFormat: string = '';
  @Trace public audioCodeFormat: string = '';
  @Trace public resolutionRatio: string = '';
  @Trace public videoUrl: string = '';
  @Trace public createDate: string = '';
  @Trace public createTimestamp: number = 0;
  @Trace public aspectRatio: string = '';
  @Trace public routerParams: string = '';

  updateTask(work: WorkModel) {
    this.id = work.id;
    this.title = work.title;
    this.id = work.id;
    this.title = work.title;
    this.status = work.status;
    this.duration = work.duration;
    this.thumbnail = work.thumbnail;
    this.createTime = work.createTime;
    this.fileSize = work.fileSize;
    this.fileFormat = work.fileFormat;
    this.videoCodeFormat = work.videoCodeFormat;
    this.audioCodeFormat = work.audioCodeFormat;
    this.resolutionRatio = work.resolutionRatio;
    this.videoUrl = work.videoUrl;
    this.createDate = work.createDate;
    this.aspectRatio = work.aspectRatio;
    this.createTimestamp = work.createTimestamp;
    this.routerParams = work.routerParams;
  }
}