import { CheckInActivity } from 'commonlib';

const task1: CheckInActivity = {
  activityId: 1,
  name: '钢琴每日练习打卡',
  summary: '每天练习钢琴并上传演奏视频或音频，记录你的钢琴进步。',
  detail: '亲爱的音乐爱好者们！如果你是个音乐小白，或者想深入理解音乐的奥秘，那么这篇乐理基础笔记绝对是你的不二之选。\n' +
    '       课程共计20节课，带你们了解乐音的四个主要特性：高低（音调）、长短（音值）、强弱（音量）和色彩（音色）。让你在音乐的道路上更加自信和从容。让我们开启神奇的音乐之旅！不断探索和发现的旅程，享受这个过程吧！',
  mainDiagram: $r('app.media.img_course_cover1'),
  price: 0,
  orderTime: '2025-02-01T10:00:00',
  participationCount:100,
  historyCount:199,
  requirement: {
    textSwitch: 1,
    textMinLimit: 15,
    audioSwitch: 0,
    audioMinLimit: 0,
    videoSwitch: 0,
    videoMinLimit: 0,
    pictureSwitch: 1,
    pictureMinLimit: 3,
  },
  taskDirectory: [
    {
      taskName: '热身练习',
      taskId: 101,
      taskStatus:2,
      taskDetail: '每日进行10分钟热身练习，演奏简单的音阶或基础练习，确保手指灵活。',
    },
    {
      taskName: '曲目练习：小星星变奏曲',
      taskId: 102,
      taskStatus:1,
      taskDetail: '练习《小星星变奏曲》，要求保持节奏和音准。',
    },
  ],
};

const task2: CheckInActivity = {
  activityId: 2,
  name: '吉他进阶曲目练习打卡',
  summary: '上传你的吉他进阶曲目演奏，要求选择一首新学的曲子。',
  detail: '该任务要求学员每天练习一首新的吉他进阶曲目并上传演奏视频。教师会提供课程指导和反馈。',
  mainDiagram: $r('app.media.img_course_cover2'),
  price: 0,
  participationCount:20,
  historyCount:99,
  orderTime: '',
  requirement: {
    textSwitch: 0,
    textMinLimit: 0,
    audioSwitch: 1,
    audioMinLimit: 10,
    videoSwitch: 1,
    videoMinLimit: 1,
    pictureSwitch: 0,
    pictureMinLimit: 0,
  },
  taskDirectory: [
    {
      taskName: '吉他基础练习',
      taskId: 201,
      taskStatus:1,
      taskDetail: '进行吉他基础练习，包括和弦切换、指法练习等。',

    },
    {
      taskName: '曲目练习：小星星',
      taskId: 202,
      taskStatus:1,
      taskDetail: '练习吉他弹奏《小星星》，要求掌握和弦转换。',
    },
    {
      taskName: '技巧练习：扫弦练习',
      taskId: 203,
      taskStatus:1,
      taskDetail: '进行扫弦练习，练习右手的扫弦技巧。',
    },
    {
      taskName: '曲目演奏：简易吉他曲',
      taskId: 204,
      taskStatus:1,
      taskDetail: '演奏一首简易吉他曲，要求掌握基本节奏和和弦。',
    },
  ],
};

export class CheckInActivityDatasetMock {
  private static _activityList: CheckInActivity[] = [task1, task2];

  public static getActivityList(): CheckInActivity[] {
    return CheckInActivityDatasetMock._activityList;
  }

  public static getActivityDetail(taskId: number): CheckInActivity {
    const task = CheckInActivityDatasetMock._activityList.find((item) => item.activityId === taskId)!;
    return task;
  }

  public static createActivityOrder(taskId: number): boolean {
    const course = CheckInActivityDatasetMock._activityList.find((item) => item.activityId === taskId);
    if (course) {
      const orderTime = new Date().getTime().toString();
      course.orderTime = orderTime;
      return true;
    }
    return false;
  }

  public static cancelActivityOrder(taskId: number): boolean {
    const course = CheckInActivityDatasetMock._activityList.find((item) => item.activityId === taskId);
    if (course && course.orderTime) {
      course.orderTime = '';
      return true;
    }
    return false;
  }

  public static getActivityListOrdered(): CheckInActivity[] {
    const list = CheckInActivityDatasetMock._activityList.filter((item) => item.orderTime);
    return list;
  }
}