import { DiaryTableData } from '../commons/Interface';

@ObservedV2
export class DiaryExtraInfo {
  // 隐私日记密码
  @Trace password: string = '';
  // 日记编写时，是否自动保存
  @Trace showAutoSaveTip: boolean = true;
  // 日记编写时，自动保存的时间
  @Trace autoSaveTime: number = 30;
}

/**
 * 日记
 */
@ObservedV2
export class Diary {
  // id
  @Trace id: string = '';
  // 属性字符串内容转成的html字符串
  @Trace htmlContent: string = '';
  // 文本内容
  @Trace textContent: string = '';
  // 创建时间
  @Trace createTime: string = '';
  // 更新时间
  @Trace updateTime: string = '';
  // 天气
  @Trace weatherText: string = '';
  @Trace weatherIcon: string = 'sys.symbol.cloud_and_sun_filled';
  // 心情
  @Trace moodText: string = '';
  @Trace moodIcon: string = 'sys.symbol.face_smiling';
  // 富文本属性字符串内容
  @Trace styledString: MutableStyledString = new MutableStyledString('')
  // 保存日记的第一张图片
  @Trace firstImage: string = ''
  // 是否是隐私日记
  @Trace isPrivacy: boolean = false;

  constructor(data?: DiaryTableData) {
    if (data) {
      this.id = data.id;
      this.createTime = data.createTime;
      this.updateTime = data.updateTime;
      this.textContent = data.textContent;
      this.isPrivacy = data.isPrivacy;
      this.moodText = data.moodText;
      this.moodIcon = data.moodIcon;
      this.weatherText = data.weatherText;
      this.weatherIcon = data.weatherIcon;
      this.firstImage = data.firstImage;
      this.htmlContent = data.htmlContent;
    }
  }
}