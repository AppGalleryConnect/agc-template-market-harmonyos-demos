import { ClassificationTypeEnum, ExamDetail, ExamManager, QuestionTypeEnum } from 'exam';
import { Chapter, EXAM_MANAGER_TYPE, WRONG_COLLECT, Video } from './Model';


const COLOR_GARDEN = ['#46B1E3', '#61CFBE', '#ED6F21', '#A5D61D', '#AC49F5', '#64BB5C'];

// 试卷不需要缓存的场景
const NEED_NEW_LIST = [EXAM_MANAGER_TYPE.random, EXAM_MANAGER_TYPE.error, EXAM_MANAGER_TYPE.collect];

@ObservedV2
export class ExamService {
  private static _instance: ExamService;
  private examDetails: ExamDetail[] = [];
  @Trace mockExamCount: number = 0;
  @Trace mockExamScore: number[] = [];
  static context: Context;

  constructor() {
    this.examDetails = this.generateExamDetail();
  }

  public static instance(context: Context) {
    ExamService.context = context;
    if (!ExamService._instance) {
      ExamService._instance = new ExamService();
    }
    return ExamService._instance;
  }

  private examManagerList: Array<ExamManager> = [];
  private chapterList: Chapter[] = [];

  public addMockExamCount(score: number) {
    this.mockExamCount++;
    this.mockExamScore.push(score);
  }

  public getChapterList(): Chapter[] {
    if (this.chapterList.length === 0) {
      const chapterTitleList: string[] = [];
      this.examDetails.forEach((item: ExamDetail) => {
        if (chapterTitleList.indexOf(item.chapterName) === -1) {
          chapterTitleList.push(item.chapterName);
        }
      });

      chapterTitleList.forEach((item: string, index: number) => {
        const examManger = this.getManagerByName(item, EXAM_MANAGER_TYPE.chapter_name, 0, item);
        const color = COLOR_GARDEN[index % 6];
        this.chapterList.push(new Chapter(item, color, examManger));
      });
    }

    return this.chapterList;
  }

  public getChapterListByType(type: WRONG_COLLECT): Chapter[] {
    const chapterTitleList: string[] = [];
    const chapterList: Chapter[] = [];
    if (type === WRONG_COLLECT.WRONG) {
      this.examDetails.forEach((item: ExamDetail) => {
        if (chapterTitleList.indexOf(item.chapterName) === -1 && item.isCorrect === false) {
          chapterTitleList.push(item.chapterName);
        }
      });

      chapterTitleList.forEach((item: string, index: number) => {
        const examManger = this.getManagerByName(item, EXAM_MANAGER_TYPE.chapter_name, 0, item, WRONG_COLLECT.WRONG);
        const color = COLOR_GARDEN[index % 6];
        chapterList.push(new Chapter(item, color, examManger));
      });
    } else if (type === WRONG_COLLECT.COLLECT) {
      this.examDetails.forEach((item: ExamDetail) => {
        if (chapterTitleList.indexOf(item.chapterName) === -1 && item.isCollect === true) {
          chapterTitleList.push(item.chapterName);
        }
      });

      chapterTitleList.forEach((item: string, index: number) => {
        const examManger = this.getManagerByName(item, EXAM_MANAGER_TYPE.chapter_name, 0, item, WRONG_COLLECT.COLLECT);
        const color = COLOR_GARDEN[index % 6];
        chapterList.push(new Chapter(item, color, examManger));
      });
    }

    return chapterList;
  }

  /**
   * 根据考卷名称获取数据
   * @param name
   */
  getManagerByName(name: string | Resource, type: EXAM_MANAGER_TYPE, currentQuestionId: number = 0,
    chapterName: string = '', wrongOrCollect?: WRONG_COLLECT): ExamManager {
    let examManager = this.examManagerList.find(item => item.name === name);
    if (examManager === undefined || wrongOrCollect !== undefined) {
      const examList = this.getExamQuestionList(type, chapterName, name as string, wrongOrCollect);
      const correctCount = this.getCorrectCountByManger(examList);
      const errorCount = this.getErrorCountByManger(examList);
      examManager = new ExamManager(name, examList, currentQuestionId, correctCount, errorCount);
      NEED_NEW_LIST.indexOf(type) === -1 && this.examManagerList.push(examManager);
    }
    return examManager;
  }

  /**
   * 获取模拟考试考卷，每次获得一个新对象
   * @param name
   * @returns
   */
  getMockExamManager(name: string | Resource) {
    let examManager = new ExamManager(name, this.generateExamDetail());
    examManager.timeLimit = 1;
    return examManager;
  }

  /**
   * 将模拟考试中的错题和收藏同步到全局题库
   * 模拟考试使用独立的数据对象，答题结果不会自动回写全局题库，
   * 通过题目内容匹配，将错题(isCorrect===false)和收藏(isCollect===true)同步到全局examDetails
   * @param examManager 模拟考试的考卷
   */
  public syncMockExamToGlobal(examManager: ExamManager): void {
    for (const mockItem of examManager.examDetails) {
      const globalItem = this.examDetails.find(item => item.question === mockItem.question);
      if (globalItem) {
        if (mockItem.isCorrect === false) {
          globalItem.isCorrect = false;
        }
        if (mockItem.isCollect) {
          globalItem.isCollect = true;
        }
      }
    }
  }

  /**
   * 计算考试平均分
   * @returns
   */
  calculateAverageScore(): number {
    if (this.mockExamCount === 0) {
      return 0;
    }
    return Math.ceil(this.mockExamScore.reduce((pre, next) => pre + next) / this.mockExamCount);
  }

  /**
   * 计算全部答题正确率
   * @returns
   */
  public calAccuracyRate(): number {
    const rightCount = this.getCorrectCount();
    const totalCount = this.getTotalCount();
    if (rightCount === 0) {
      return 0;
    }
    return Math.ceil(rightCount / totalCount * 100);
  }

  /**
   * 统计试卷正确题数量
   * @param examList
   * @returns
   */
  public getCorrectCountByManger(examList: ExamDetail[]): number {
    return examList.filter((item: ExamDetail) => item.isCorrect === true).length;
  }

  /**
   * 统计试卷错题数量
   * @param examList
   * @returns
   */
  public getErrorCountByManger(examList: ExamDetail[]): number {
    return examList.filter((item: ExamDetail) => item.isCorrect === false).length;
  }

  /**
   * 统计试卷收藏数量
   * @param examList
   * @returns
   */
  public getCollectCountByManger(examList: ExamDetail[]): number {
    return examList.filter((item: ExamDetail) => item.isCollect === false).length;
  }

  /**
   * 获取全部试题数量
   * @returns
   */
  public getTotalCount(): number {
    return this.examDetails.length;
  }

  /**
   * 获取全部错题数量
   * @returns
   */
  public getErrorCount(): number {
    return this.examDetails.filter(item => item.isCorrect === false).length;
  }

  /**
   * 获取全部收藏数量
   * @returns
   */
  public getCollectCount(): number {
    return this.examDetails.filter(item => item.isCollect === true).length;
  }

  /**
   * 获取全部已做数量
   * @returns
   */
  public getDidCount(): number {
    return this.examDetails.filter(item => item.isCorrect !== undefined).length;
  }

  /**
   * 获取全部正确数量
   * @returns
   */
  public getCorrectCount(): number {
    return this.examDetails.filter(item => item.isCorrect === true).length;
  }

  /**
   * 获取容易题数量
   * @returns
   */
  public getEasyQuestionCount(): number {
    return this.examDetails.filter(item => item.classificationType === ClassificationTypeEnum.EASY).length;
  }

  /**
   * 获取简单题数量
   * @returns
   */
  public getSimpleQuestionCount(): number {
    return this.examDetails.filter(item => item.classificationType === ClassificationTypeEnum.SIMPLE).length;
  }

  /**
   * 获取一般题数量
   * @returns
   */
  public getMiddleQuestionCount(): number {
    return this.examDetails.filter(item => item.classificationType === ClassificationTypeEnum.MIDDLE).length;
  }

  /**
   * 获取易错题数量
   * @returns
   */
  public getMistakeQuestionCount(): number {
    return this.examDetails.filter(item => item.classificationType === ClassificationTypeEnum.EASY_MISTAKE).length;
  }

  /**
   * 获取困难题数量
   * @returns
   */
  public getHardQuestionCount(): number {
    return this.examDetails.filter(item => item.classificationType === ClassificationTypeEnum.HARD).length;
  }

  /**
   * 获取单选题数量
   * @returns
   */
  public getRadioQuestionCount(): number {
    return this.examDetails.filter(item => item.questionType === QuestionTypeEnum.RADIO).length;
  }

  /**
   * 获取单选题数量
   * @returns
   */
  public getMultiQuestionCount(): number {
    return this.examDetails.filter(item => item.questionType === QuestionTypeEnum.CHECK_BOX).length;
  }

  /**
   * 获取判断题数量
   * @returns
   */
  public getJudgeQuestionCount(): number {
    return this.examDetails.filter(item => item.questionType === QuestionTypeEnum.JUDGE).length;
  }

  /**
   * 清空所有错题
   */
  public clearWrongQuestion(): void {
    this.examDetails.forEach((item: ExamDetail) => item.isCorrect = undefined);
  }

  /**
   * 清空所有收藏
   */
  public clearCollectQuestion(): void {
    this.examDetails.forEach((item: ExamDetail) => item.isCollect = false);
  }

  /**
   * 获取练习题目
   * @returns
   */
  getExamQuestionList(type: EXAM_MANAGER_TYPE, chapterName: string = '', searchCondition: string = '',
    wrongOrCollect?: WRONG_COLLECT) {
    const originData = this.examDetails;
    let examData: ExamDetail[] = [];
    switch (type) {
      case EXAM_MANAGER_TYPE.sequence:
        examData = originData;
        break;
      case EXAM_MANAGER_TYPE.random:
        const newArray = [...originData];
        examData = newArray.sort(() => ExamService.getRandomFloat() - 0.5);
        break;
      case EXAM_MANAGER_TYPE.chapter_name:
        examData = originData.filter(item => item.chapterName.includes(chapterName));
        if (wrongOrCollect === WRONG_COLLECT.WRONG) {
          examData = examData.filter((item: ExamDetail) => item.isCorrect === false);
        } else if (wrongOrCollect === WRONG_COLLECT.COLLECT) {
          examData = examData.filter((item: ExamDetail) => item.isCollect === true);
        }
        break;
      case EXAM_MANAGER_TYPE.easy:
        examData = originData.filter(item => item.classificationType === ClassificationTypeEnum.EASY);
        break;
      case EXAM_MANAGER_TYPE.simple:
        examData = originData.filter(item => item.classificationType === ClassificationTypeEnum.SIMPLE);
        break;
      case EXAM_MANAGER_TYPE.normal:
        examData = originData.filter(item => item.classificationType === ClassificationTypeEnum.MIDDLE);
        break;
      case EXAM_MANAGER_TYPE.mistake:
        examData = originData.filter(item => {
          item.classificationType === ClassificationTypeEnum.EASY_MISTAKE;
        });
        break;
      case EXAM_MANAGER_TYPE.difficult:
        examData = originData.filter(item => item.classificationType === ClassificationTypeEnum.HARD);
        break;
      case EXAM_MANAGER_TYPE.single:
        examData = originData.filter(item => item.questionType === QuestionTypeEnum.RADIO);
        break;
      case EXAM_MANAGER_TYPE.multi:
        examData = originData.filter(item => item.questionType === QuestionTypeEnum.CHECK_BOX);
        break;
      case EXAM_MANAGER_TYPE.judging:
        examData = originData.filter(item => item.questionType === QuestionTypeEnum.JUDGE);
        break;
      case EXAM_MANAGER_TYPE.error:
        examData = originData.filter(item => item.isCorrect === false);
        break;
      case EXAM_MANAGER_TYPE.collect:
        examData = originData.filter(item => item.isCollect === true);
        break;
      case EXAM_MANAGER_TYPE.search:
        examData = originData.filter(item => item.question.includes(searchCondition));
        break;
      case EXAM_MANAGER_TYPE.mock_exam:
        examData = originData;
        break;
    }
    return examData;
  }

  /**
   * 生成0-1随机数
   * @returns
   */
  public static getRandomFloat() {
    return Math.abs(Math.sin(Date.now()));
  }

  /**
   * 生成全部考题
   * @returns 全部考题
   */
  private generateExamDetail(): Array<ExamDetail> {
    const videoUrl: string = ExamService.context.resourceManager.getStringSync($r('app.string.video_url').id);
    let examDetails: Array<ExamDetail> = [];
    examDetails.push(new ExamDetail('驾驶机动车通过学校时要注意什么 ?', '',
      ['观察标志标线',
        '减速慢行',
        '不要鸣喇叭',
        '快速通过'],
      ['观察标志标线', '减速慢行', '不要鸣喇叭'],
      QuestionTypeEnum.CHECK_BOX, ClassificationTypeEnum.SIMPLE,
      '驾驶机动车上路行驶必须随车携带机动车行驶证（' +
        '证明车辆合法上路资格）。其他选项如登记证，保' +
        '险单，合格证无需随车携带。\n' +
        '根据《道路交通安全法》的规定，驾驶机动车上道' +
        '路行驶，应当悬挂机动车号牌，放置检验合格标志' +
        '，保险标志，并随车携带机动车行驶证。',
      '驾驶证和机动车管理规定',
      videoUrl));
    examDetails.push(new ExamDetail('下列哪种证件是驾驶机动车上路行驶时，应当随身携带的?', '',
      ['机动车登记证',
        '机动车保险单',
        '机动车行驶证',
        '出厂合格证明'],
      ['机动车登记证'],
      QuestionTypeEnum.RADIO, ClassificationTypeEnum.SIMPLE,
      '驾驶机动车上路行驶必须随车携带机动车行驶证（' +
        '证明车辆合法上路资格）。其他选项如登记证，保' +
        '险单，合格证无需随车携带。\n' +
        '根据《道路交通安全法》的规定，驾驶机动车上道' +
        '路行驶，应当悬挂机动车号牌，放置检验合格标志' +
        '，保险标志，并随车携带机动车行驶证。',
      '驾驶证和机动车管理规定',
      videoUrl));

    examDetails.push(new ExamDetail('驾驶这种机动车上路行驶没有违法行为', 'app.media.question_image',
      ['正确',
        '错误'],
      ['错误'],
      QuestionTypeEnum.JUDGE, ClassificationTypeEnum.EASY,
      '驾驶机动车上路行驶必须随车携带机动车行驶证（' +
        '证明车辆合法上路资格）。其他选项如登记证，保' +
        '险单，合格证无需随车携带。\n' +
        '根据《道路交通安全法》的规定，驾驶机动车上道' +
        '路行驶，应当悬挂机动车号牌，放置检验合格标志' +
        '，保险标志，并随车携带机动车行驶证。',
      '驾驶证和机动车管理规定',
      videoUrl));

    examDetails.push(new ExamDetail('驾驶机动车行经下列那种路段不得超车?', '',
      ['主要街道',
        '高架路',
        '人行横道',
        '环城高速'],
      ['人行横道'],
      QuestionTypeEnum.RADIO, ClassificationTypeEnum.SIMPLE,
      '驾驶机动车上路行驶必须随车携带机动车行驶证（' +
        '证明车辆合法上路资格）。其他选项如登记证，保' +
        '险单，合格证无需随车携带。\n' +
        '根据《道路交通安全法》的规定，驾驶机动车上道' +
        '路行驶，应当悬挂机动车号牌，放置检验合格标志' +
        '，保险标志，并随车携带机动车行驶证。',
      '驾驶证和机动车管理规定',
      videoUrl));

    examDetails.push(new ExamDetail('驾驶人一边驾车，一边打手持电话是违法行为', '',
      ['正确',
        '错误'],
      ['正确'],
      QuestionTypeEnum.JUDGE, ClassificationTypeEnum.MIDDLE,
      '驾驶机动车上路行驶必须随车携带机动车行驶证（' +
        '证明车辆合法上路资格）。其他选项如登记证，保' +
        '险单，合格证无需随车携带。\n' +
        '根据《道路交通安全法》的规定，驾驶机动车上道' +
        '路行驶，应当悬挂机动车号牌，放置检验合格标志' +
        '，保险标志，并随车携带机动车行驶证。',
      '驾驶证和机动车管理规定',
      videoUrl));

    examDetails.push(new ExamDetail('驾驶机动车下陡坡时不得有哪些危险行为?', '',
      ['提前减档',
        '空挡滑行',
        '低档减速',
        '制动减速'],
      ['空挡滑行'],
      QuestionTypeEnum.RADIO, ClassificationTypeEnum.SIMPLE,
      '驾驶机动车上路行驶必须随车携带机动车行驶证（' +
        '证明车辆合法上路资格）。其他选项如登记证，保' +
        '险单，合格证无需随车携带。\n' +
        '根据《道路交通安全法》的规定，驾驶机动车上道' +
        '路行驶，应当悬挂机动车号牌，放置检验合格标志' +
        '，保险标志，并随车携带机动车行驶证。',
      '驾驶证和机动车管理规定',
      videoUrl));

    examDetails.push(new ExamDetail('机动车驾驶人在实习期内驾驶机动车不得牵引挂车', 'app.media.question_image',
      ['正确',
        '错误'],
      ['正确'],
      QuestionTypeEnum.JUDGE, ClassificationTypeEnum.HARD,
      '驾驶机动车上路行驶必须随车携带机动车行驶证（' +
        '证明车辆合法上路资格）。其他选项如登记证，保' +
        '险单，合格证无需随车携带。\n' +
        '根据《道路交通安全法》的规定，驾驶机动车上道' +
        '路行驶，应当悬挂机动车号牌，放置检验合格标志' +
        '，保险标志，并随车携带机动车行驶证。',
      '道路通行条件及通行规定',
      videoUrl));

    examDetails.push(new ExamDetail('驾驶机动车上路前应当检查车辆安全技术性能', '',
      ['正确',
        '错误'],
      ['正确'],
      QuestionTypeEnum.JUDGE, ClassificationTypeEnum.EASY_MISTAKE,
      '驾驶机动车上路行驶必须随车携带机动车行驶证（' +
        '证明车辆合法上路资格）。其他选项如登记证，保' +
        '险单，合格证无需随车携带。\n' +
        '根据《道路交通安全法》的规定，驾驶机动车上道' +
        '路行驶，应当悬挂机动车号牌，放置检验合格标志' +
        '，保险标志，并随车携带机动车行驶证。',
      '道路通行条件及通行规定',
      videoUrl));

    examDetails.push(new ExamDetail('行车中遇到后方车辆要求超车, 应怎样做?', '',
      ['及时减速、观察后靠右行驶让行',
        '保持原有车速行驶',
        '靠右侧加速行驶',
        '不让行'],
      ['及时减速、观察后靠右行驶让行'],
      QuestionTypeEnum.RADIO, ClassificationTypeEnum.EASY_MISTAKE,
      '驾驶机动车上路行驶必须随车携带机动车行驶证（' +
        '证明车辆合法上路资格）。其他选项如登记证，保' +
        '险单，合格证无需随车携带。\n' +
        '根据《道路交通安全法》的规定，驾驶机动车上道' +
        '路行驶，应当悬挂机动车号牌，放置检验合格标志' +
        '，保险标志，并随车携带机动车行驶证。',
      '道路通行条件及通行规定',
      videoUrl));

    examDetails.push(new ExamDetail('变更车道, 应开启转向灯, 迅速驶入侧方车道。', '',
      ['正确',
        '错误'],
      ['错误'],
      QuestionTypeEnum.JUDGE, ClassificationTypeEnum.EASY_MISTAKE,
      '驾驶机动车上路行驶必须随车携带机动车行驶证（' +
        '证明车辆合法上路资格）。其他选项如登记证，保' +
        '险单，合格证无需随车携带。\n' +
        '根据《道路交通安全法》的规定，驾驶机动车上道' +
        '路行驶，应当悬挂机动车号牌，放置检验合格标志' +
        '，保险标志，并随车携带机动车行驶证。',
      '道路通行条件及通行规定',
      videoUrl));

    return examDetails;
  }

  public getVideList(): Video[] {
    const videoUrl: string = ExamService.context.resourceManager.getStringSync($r('app.string.video_url').id);
    return [
      {
        poster: $r('app.media.video_poster'),
        url: videoUrl,
        name: '倒车入库',
        simpleDescription: '两步掌握倒车入库',
        description: '侧方位停车有两个地方需要注意：一是左右后视镜要调整，左边后视镜尽量压低，能看到左边的后轮就行。右边后视镜能看到车身即可。上下调到前门把手在后视镜中间。二是车内后视镜要调整，要调整到抬头的时候可以看到车的后面挡风玻璃中间。',
        copyrightNotice: '未经许可，请勿转载使用',
        time: '01:04',
      },
      {
        poster: $r('app.media.video_poster'),
        url: videoUrl,
        name: '侧方位停车',
        simpleDescription: '三步掌握侧方位停车',
        description: '侧方位停车有两个地方需要注意：一是左右后视镜要调整，左边后视镜尽量压低，能看到左边的后轮就行。右边后视镜能看到车身即可。上下调到前门把手在后视镜中间。二是车内后视镜要调整，要调整到抬头的时候可以看到车的后面挡风玻璃中间。',
        copyrightNotice: '未经许可，请勿转载使用',
        time: '01:04',
        needVip: true
      },
      {
        poster: $r('app.media.video_poster'),
        url: videoUrl,
        name: '爬坡',
        simpleDescription: '轻松掌握半坡起步',
        description: '侧方位停车有两个地方需要注意：一是左右后视镜要调整，左边后视镜尽量压低，能看到左边的后轮就行。右边后视镜能看到车身即可。上下调到前门把手在后视镜中间。二是车内后视镜要调整，要调整到抬头的时候可以看到车的后面挡风玻璃中间。',
        copyrightNotice: '未经许可，请勿转载使用',
        time: '01:04',
        needVip: true
      },
    ];
  }
}