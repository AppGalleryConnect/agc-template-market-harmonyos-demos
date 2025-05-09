import { CourseExpireTypeMap, CoursePaymentMap, CourseStatusMap, CourseTypeMap } from '../constants/CommonEnums';
import { CourseInfo } from '../types/Index';
import { FormatUtil } from './FormatUtil';


export class CourseUtil {
  public static getExpireLabel(courseInfo: CourseInfo | undefined | null) {
    if (courseInfo?.expireType === CourseExpireTypeMap.LONG_TERM) {
      return '长期有效';
    } else if (courseInfo?.expireType === CourseExpireTypeMap.LIMITED_TIME) {
      const startTime = new Date(Number(courseInfo.startTime));
      const endTime = new Date(Number(courseInfo.endTime));
      const startTimeLabel = FormatUtil.formatDate(startTime);
      const endTimeLabel = FormatUtil.formatDate(endTime);
      return `${startTimeLabel}至${endTimeLabel}`;
    }
    return '-';
  }

  public static getPaymentLabel(num: number) {
    if (num === CoursePaymentMap.OFFLINE) {
      return '线下支付';
    } else if (num === CoursePaymentMap.ONLINE) {
      return '华为支付';
    }
    return '';
  }

  public static getClassHourLabel(courseInfo: CourseInfo | undefined | null) {
    if (!courseInfo) {
      return '-- 课时';
    } else {
      return courseInfo.classHour + '课时';
    }
  }

  public static getHistoryHourLabel(courseInfo: CourseInfo | undefined | null) {
    if (!courseInfo) {
      return '-/- 课时';
    } else {
      return `${courseInfo.currentHour}/${courseInfo.classHour} 课时`;
    }
  }

  public static getCourseStatusLabel(status: number) {
    const labelMap: Map<CourseStatusMap, string> = new Map([
      [CourseStatusMap.NOT_STARTED, '未报名'],
      [CourseStatusMap.IN_PROGRESS, '进行中'],
      [CourseStatusMap.COMPLETED, '已结课'],
    ]);
    return labelMap.get(status) ?? '';
  }

  public static getCourseTypeLabel(type: number) {
    if (type === CourseTypeMap.ONLINE) {
      return '直播课';
    } else if (type === CourseTypeMap.OFFLINE) {
      return '线下课';
    }
    return '';
  }
}