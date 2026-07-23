import { ExamManager } from 'exam'

export interface ROUTE_PARAM {
  title: string | Resource,
  type: EXAM_MANAGER_TYPE,
  questionId?: string,
  wrongOrCollect?:WRONG_COLLECT,
  keyword?:string,
  examManager?: ExamManager
}

export interface CLASSIFY_BY_TYPE {
  name: Resource,
  quantity: number,
  type: EXAM_MANAGER_TYPE,
}

export interface RouteCommonParam {
  fromPage?: string
}

export enum WRONG_COLLECT {
  WRONG,
  COLLECT
}

export enum EXAM_MANAGER_TYPE {
  sequence,  // 顺序
  random,    // 随机
  chapter_name,   // 章节名称
  easy,      // 容易
  simple,    // 简单
  normal,    // 一般
  mistake,   // 易错
  difficult, // 困难
  single,    // 单选
  multi,     // 多选
  judging,    // 判断
  error,     // 错题
  collect,   // 收藏
  search,    // 搜索
  mock_exam, // 模拟考试
}

@ObservedV2
export class QuestionType {
  name: Resource;
  type:EXAM_MANAGER_TYPE;
  @Trace quantity: number = 0;

  constructor(name:Resource, type:EXAM_MANAGER_TYPE) {
    this.name = name;
    this.type = type;
  }
}

export const CLASSIFY_DATA:QuestionType[] = [
  new QuestionType($r('app.string.easy_question'), EXAM_MANAGER_TYPE.easy),
  new QuestionType($r('app.string.simple_question'), EXAM_MANAGER_TYPE.simple),
  new QuestionType($r('app.string.normal_question'), EXAM_MANAGER_TYPE.normal),
  new QuestionType($r('app.string.mistake_question'), EXAM_MANAGER_TYPE.mistake),
  new QuestionType($r('app.string.difficult_question'), EXAM_MANAGER_TYPE.difficult)
]

export const DATA_BY_QUESTION_TYPE:CLASSIFY_BY_TYPE[] = [
  new QuestionType($r('app.string.single_choice'), EXAM_MANAGER_TYPE.single),
  new QuestionType($r('app.string.true_or_false'), EXAM_MANAGER_TYPE.judging)
]



@ObservedV2
export class Chapter {
  title: string;
  @Trace totalCount: number = 0;
  @Trace didCount: number = 0;
  @Trace correctCount: number = 0;
  @Trace examManger:ExamManager;
  serialBgColor: string = '#46B1E3'
  id: string;
  constructor(title: string, serialBgColor: string, examManger:ExamManager ) {
    this.title = title;
    this.id = new Date().getTime().toString();
    this.examManger = examManger;
    if (serialBgColor) {
      this.serialBgColor = serialBgColor;
    }
  }


  /**
   * 计算正确率
   * @returns
   */
  calAccuracyRate(): number {
    if (this.examManger.total === 0) {
      return 0;
    }
    return Math.ceil(this.examManger.correctNumber / this.examManger.total * 100);
  }
}

/**
 * 我的页面-各种服务信息
 */
export interface MinePageCommonService{
  /**
   * 图标
   */
  icon: string,
  /**
   * 标签名称
   */
  label: string,
  /**
   * 跳转到下一页
   */
  nextPage: string
}

export interface Video {
  poster: Resource | string,
  url: Resource | string,
  name: string,
  time: string,
  simpleDescription: string,
  description: string,
  copyrightNotice: string,
  needVip?: boolean,
}