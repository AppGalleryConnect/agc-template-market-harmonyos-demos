import { CourseInfo, FrameworkUtil, RouterMap, RouterModule } from 'commonlib';
import { https } from 'network';

@ObservedV2
export class CourseDetailVM {
  @Trace courseInfo: CourseInfo | null = null;
  @Trace isLoading: boolean = false;
  private static _instance: CourseDetailVM;

  public static get instance() {
    if (!CourseDetailVM._instance) {
      CourseDetailVM._instance = new CourseDetailVM();
    }
    return CourseDetailVM._instance;
  }

  public async getCourseDetail() {
    const param = RouterModule.getNavParam<CourseInfo>({
      url: RouterMap.COURSE_DETAIL,
    });
    if (param) {
      this.isLoading = true;
      const res = await https.getCourseDetail({
        courseId: param.courseId,
      });
      if (res.ret.code === 0) {
        this.courseInfo = res.result;
      }
      this.isLoading = false;
    }
  }

  public jumpToPrepayPage() {
    if (this.courseInfo) {
      RouterModule.push({
        url: RouterMap.COURSE_PREPAY,
        param: this.courseInfo,
      });
    }
  }

  public backToHome() {
    FrameworkUtil.backToHome();
  }
}

