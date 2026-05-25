@ObservedV2
export class MyCourseClass {
  @Trace courseList: CourseModel[] = []
}

@ObservedV2
export class CourseClass {
  @Trace courseList: CourseModel[] = []
}

// 课程模型
@ObservedV2
export class CourseModel {
  id: string = '';
  courseTitle: string = ''; // 课程标题
  description?: string; // 课程描述
  category?: number; // 1课程 2直播 3名师
  isFree?: boolean; // 是否付费
  @Trace isPay?: boolean; // 是否购买
  @Trace payStatus: number = 0; // 支付状态 0 未支付 1已支付 2待支付 3已取消
  @Trace isCollection: boolean = false; // 是否收藏
  @Trace isWatch: boolean = false; // 是否观看过
  watchTime: number = 0; // 观看记录时间排序
  @Trace isComments: boolean = false; // 是否评论过
  @Trace isStudy: boolean = false; // 是否学习
  studyTime: number = 0; // 学习时间排序
  lecturer?: string; // 讲师
  videoUrl?: string; // 视频url
  cover?: ResourceStr; // 封面
  courseDuration?: number; // 课程时长 单位为秒
  @Trace learnProgress: number = 0; //进度
  @Trace isStudyEnd: boolean = false; // 是否已学完课程 观看达到100时表明已学习完成
  learnNumber?: number; // 学习人数
  reservationTime?: number; // 直播开始时间
  liveNumber?: number; // 在线人数
  liveState?: number; //直播状态 1正在直播  0已结束
  time: number = 0; // 时间
  courseCatalog: CourseCatalogModel[] = []
  catalogIndex: number = 0
  selectItem: number = 0
  @Trace isDelete: boolean = false
}

//课程章节目录
@ObservedV2
export class CourseCatalogModel {
  id: string = ''; // 章节id
  courseId: string = ''; // 课程id
  catalogTitle: string = ''; // 章节标题
  description?: string; // 章节描述
  @Trace isStudyEnd: boolean = false; // 是否已学完 观看达到100时表明已学习完成
  learnProgress: number = 0; // 章节学习进度
  videoUrl?: string; // 视频url
  @Trace comments: CommentModel[] = []
}

//课程章节评论
@ObservedV2
export class CommentModel {
  courseId: string = '';
  catalogId: string = '';
  id: string = '';
  icon?: ResourceStr;
  nickName: string = '';
  catalogIndex: number = 0
  comment: string = '';
  time: number = 0;
  score: number = 1;
  cover?: ResourceStr; // 封面
  courseTitle: string = ''; // 课程标题
  @Trace isDelete: boolean = false
}

@ObservedV2
export class CourseDataModel {
  @Trace public courseProgress: Map<string, number> = new Map();
}

@ObservedV2
export class ExerciseRecord {
  @Trace duration: number = 0;  // 运动时长(分钟)
  @Trace energy: number = 0;  // 消耗能量(kcal)
}

@ObservedV2
export class ExerciseDays {
  @Trace totalDays: number = 0;  // 累计训练(天)
}