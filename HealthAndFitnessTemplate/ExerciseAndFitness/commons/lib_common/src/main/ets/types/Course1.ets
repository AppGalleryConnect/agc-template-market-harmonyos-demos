export interface Course1 {
  id: string;
  label: string;
  courseTitle: string;
  description?: string; // 课程描述
  category?: number; // 1课程 2直播 3名师
  isFree?: boolean; // 是否付费
  isPay?: boolean; // 是否购买
  isCollection?: boolean; // 是否收藏
  isWatch?: boolean; // 是否观看过
  isComments?: boolean; // 是否评论过
  isStudy?: boolean; // 是否学习
  lecturer?: string; // 讲师
  videoUrl?: string; // 视频url
  cover?: ResourceStr; // 封面
  courseDuration?: number; // 课程时长 单位为秒
  learnProgress?: number; //进度
  learnNumber?: number; // 学习人数
  reservationTime?: number; // 直播开始时间
  liveNumber?: number; // 在线人数
  liveState?: number; //直播状态 1正在直播  0已结束
  time: number; // 发布时间
  courseCatalog?: CourseCatalog1[]; // 课程章节
}

export interface Record {
  duration: number;
  energy: number;
}

export interface CourseContent {
  id: string;
  careAbout: string[];
  contentCategory: string[];
  contentDuration: string[];
  difficulty: string;
  energy: string
  duration: string;
  isVideos: boolean[];
}

export interface CommonContent {
  id: string;
  intro: string;
  contentType: string;
  content: string[];
  type: string;
  advice: string[]
}

// 课程章节目录
export interface CourseCatalog1 {
  id: string;
  courseTitle: string; // 标题
  catalogTitle: string; // 目录标题
  description?: string; //
  category?: number; // 1课程 2直播 3名师
  lecturer?: string; // 讲师
  videoUrl?: string; // 视频url
  cover?: ResourceStr; // 封面
  totalTime?: number; // 视频时长 单位为秒
  learnProgress: number //进度
  learnNumber?: string // 学习人数
  time?: number; // 发布时间
  comments?: Comment1[]; // 课程章节评论
}

export interface Comment1 {
  id: string;
  icon: ResourceStr;
  nickName: string;
  comment: string;
  time: string;
  score: number;
}
