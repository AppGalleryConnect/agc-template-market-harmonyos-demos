import { CourseDetail } from '../utils/CourseUtil';

export interface RouterInfo {
  from?: string;
}

export interface CourseDetailRouterInfo extends RouterInfo {
  dateTime: Date;
  courseInfo: CourseDetail | undefined;
}