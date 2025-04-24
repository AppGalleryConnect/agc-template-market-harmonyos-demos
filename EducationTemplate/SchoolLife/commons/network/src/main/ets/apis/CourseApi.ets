import { RequestUrl } from '../constants/NetworkEnums';
import request from '../models/AxiosRequest';
import { ClassSignInReq } from '../models/request/ClassSignInReq';
import { QueryDayCourseReq } from '../models/request/QueryDayCourseReq';
import { ClassSignInResp } from '../models/response/ClassSignInResp';
import { CourseScheduleConfigResp } from '../models/response/CourseScheduleConfigResp';
import { QueryAllCourseResp } from '../models/response/QueryAllCourseResp';
import { QueryDayCourseResp } from '../models/response/QueryDayCourseResp';
import { BaseResponse } from '../types/ResponseTypes';


class CourseApi {
  public getScheduleConfig(): Promise<BaseResponse<CourseScheduleConfigResp>> {
    return request.get({ url: RequestUrl.SCHEDULE_CONFIG });
  }

  public queryDayCourse(req: QueryDayCourseReq): Promise<BaseResponse<QueryDayCourseResp>> {
    return request.post({
      url: RequestUrl.QUERY_DAY_COURSE,
      data: req,
    });
  }

  public queryAllCourse(semester: number): Promise<BaseResponse<QueryAllCourseResp>> {
    return request.post({
      url: RequestUrl.QUERY_ALL_COURSE,
      data: { semester },
    });
  }

  public signIn(req: ClassSignInReq): Promise<BaseResponse<ClassSignInResp>> {
    return request.post({
      url: RequestUrl.CLASS_SIGN_IN,
      data: req,
    });
  }
}

const courseApi = new CourseApi();

export { courseApi as CourseApi };