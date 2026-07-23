import { CourseBook } from './CourseBook';

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
// 订单数据
@ObservedV2
export class DownloadInfo {
  @Trace downloadMaterials: string[] = [];
}

@ObservedV2
export class Material {
  @Trace courseBook: CourseBook;
  @Trace isSelected: boolean;

  constructor(courseBook: CourseBook, isSelected: boolean) {
    this.courseBook = courseBook;
    this.isSelected = isSelected;
  }
}
