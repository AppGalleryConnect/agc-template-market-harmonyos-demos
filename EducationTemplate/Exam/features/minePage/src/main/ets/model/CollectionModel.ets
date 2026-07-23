@ObservedV2
export class CollectionModel {
  title: string = '';
  keyID: string = '';
  @Trace isDelete: boolean = false;
}

// 订单数据
@ObservedV2
export class DownloadInfo {
  @Trace downloadMaterials: string[] = [];
}

/**
 *  科目练习
 */
export class SubjectExercises {
  // 选项图片
  imageSrc: ResourceStr;
  // 标题
  name: string;
  // 进度
  progress: number = 0;
  // 总数
  total: number = 0;
  type: string = 'pdf';
  url: string = '';

  constructor(imageSrc: ResourceStr, name: string, progress: number, total: number, type: string,
    url: string) {
    this.imageSrc = imageSrc;
    this.name = name;
    this.progress = progress;
    this.total = total;
    this.type = type;
    this.url = url;
  }
}

export const SUB_EXERCISES_DATA: SubjectExercises[] = [
  new SubjectExercises($r('app.media.ic_public_pdf_file_textured'), '建筑工程经济', 80, 100, 'pdf',
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-nkths' +
      '/test.pdf?token=9ef66402-ae35-4ba9-9507-caaf44513015' ),
  new SubjectExercises($r('app.media.ic_public_compressed_file_textured'), '建筑工程项目统筹', 10, 3411, 'zip', ''),
  new SubjectExercises($r('app.media.ic_public_word_file_textured'), '建筑工程项目管理', 20, 200, 'word',
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-nkths/' +
      'test1.docx?token=22a882b6-6818-4adb-9386-7aad59838806'),
]

@ObservedV2
export class DownloadModel {
  imageSrc: ResourceStr = '';
  name: string = '';
  progress: number = 0;
  total: number = 0;
  type: string = '';
  url: string = '';
  @Trace isDelete: boolean = false;
}
