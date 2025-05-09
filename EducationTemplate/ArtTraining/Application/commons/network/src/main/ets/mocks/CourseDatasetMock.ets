import { CourseInfo } from 'commonlib';

export const course1: CourseInfo = {
  courseId: 101,
  type: 1,
  name: '钢琴基础入门课程',
  summary: '5-10岁 | 零基础入门',
  detail: '本课程由专业钢琴教师设计，包含钢琴基础知识、练习曲、音乐理论等内容，帮助你从零开始掌握钢琴演奏技巧。',
  mainDiagram: $r('app.media.img_course_cover1'),
  price: 199,
  expireType: 1,
  startTime: '1741046400000',
  endTime: '1762137600000',
  orderTime: '1735699200000',
  classHour: 15,
  status: 1,
  currentHour: 0,
  timetable: {
    weekdays: [0, 4],
    startTime: '09:00',
    endTime: '10:00',
  },
};

export const course2: CourseInfo = {
  courseId: 102,
  type: 1,
  name: '吉他初学者进阶课程',
  summary: '适合有基础的吉他爱好者，提升演奏技巧。',
  detail: '本课程针对有一定吉他基础的学员，教授吉他进阶技巧、常用和弦和经典吉他曲目。让你在短时间内提高吉他水平。',
  mainDiagram: $r('app.media.img_course_cover3'),
  price: 299,
  expireType: 1,
  startTime: '1741046400000',
  endTime: '1762137600000',
  orderTime: '',
  classHour: 15,
  status: 2,
  currentHour: 10,
  timetable: {
    weekdays: [2, 4],
    startTime: '19:00',
    endTime: '20:00',
  },
};

export const course3: CourseInfo = {
  courseId: 201,
  type: 2,
  name: '高级吉他技巧课程',
  summary: '深入学习吉他高级技巧，包括即兴演奏、指法和演奏风格。',
  detail: '课程内容包括吉他指法、即兴演奏技巧和各类风格的吉他演奏，让你成为吉他高手，精通多种演奏方法。',
  mainDiagram: $r('app.media.img_course_cover2'),
  price: 399,
  expireType: 0,
  startTime: '',
  endTime: '',
  orderTime: '',
  classHour: 15,
  status: 3,
  currentHour: 15,
  timetable: {
    weekdays: [0, 6],
    startTime: '12:00',
    endTime: '13:00',
  },
};

const course4: CourseInfo = {
  courseId: 202,
  type: 2,
  name: '高级吉他技巧课程2',
  summary: '深入学习吉他高级技巧，包括即兴演奏、指法和演奏风格。',
  detail: '课程内容包括吉他指法、即兴演奏技巧和各类风格的吉他演奏，让你成为吉他高手，精通多种演奏方法。',
  mainDiagram: $r('app.media.img_course_cover2'),
  price: 399,
  expireType: 0,
  startTime: '',
  endTime: '',
  orderTime: '',
  classHour: 15,
  status: 2,
  currentHour: 5,
  timetable: {
    weekdays: [6],
    startTime: '17:00',
    endTime: '18:00',
  },
};

export class CourseDatasetMock {
  private static _courseList: CourseInfo[] = [course1, course2, course3, course4];

  public static getCourseList(type?: number, keyword?: string): CourseInfo[] {
    if (!type && !keyword) {
      return CourseDatasetMock._courseList;
    }
    const list = CourseDatasetMock._courseList.filter((item) => {
      if (type && item.type !== type) {
        return false;
      }
      if (keyword && !item.name.includes(keyword)) {
        return false;
      }
      return true;
    });
    return list;
  }

  public static getCourseDetail(courseId: number): CourseInfo {
    const course = CourseDatasetMock._courseList.find((item) => item.courseId === courseId)!;
    return course;
  }

  public static getCourseListOrdered(status: number): CourseInfo[] {
    const list = CourseDatasetMock._courseList.filter((item) => item.status === status);
    return list;
  }
}