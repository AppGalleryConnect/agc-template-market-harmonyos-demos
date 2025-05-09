import { CourseInfo, CourseTypeMap, Logger, RouterMap, RouterModule } from 'commonlib';
import { https } from 'network';
import { CourseSortButton, CourseSortTypeMap } from '../constants/Enums';

const TAG = '[CoursesVM]';

@ObservedV2
export class CoursesVM {
  // 初始列表
  @Trace initList: CourseInfo[] = [];
  // 展示列表
  @Trace displayList: CourseInfo[] = [];
  // 加载状态
  @Trace isLoading: boolean = false;
  // 课程类型
  @Trace courseType: CourseTypeMap = CourseTypeMap.ALL;
  // 排序类型
  @Trace sortType: CourseSortTypeMap = CourseSortTypeMap.DEFAULT;
  // 关键字
  @Trace keyword: string = '';
  private static _instance: CoursesVM;

  public static get instance() {
    if (!CoursesVM._instance) {
      CoursesVM._instance = new CoursesVM();
    }
    return CoursesVM._instance;
  }

  public isSortActive(type: CourseSortTypeMap[]) {
    for (const item of type) {
      if (item === this.sortType) {
        return true;
      }
    }
    return false;
  }

  public switchCourseType(type: CourseTypeMap) {
    this.courseType = type;
    this.getCourseList(type);
  }

  public switchSortType(button: CourseSortButton) {
    if (button === CourseSortButton.DEFAULT) {
      if (this.sortType === CourseSortTypeMap.DEFAULT) {
        return;
      } else {
        this.sortCourseList(CourseSortTypeMap.DEFAULT);
      }
    } else if (button === CourseSortButton.PRICE) {
      if (this.sortType === CourseSortTypeMap.DEFAULT) {
        this.sortCourseList(CourseSortTypeMap.PRICE_LOW_TO_HIGH);
      } else {
        const isLowToHigh = Boolean(this.sortType === CourseSortTypeMap.PRICE_LOW_TO_HIGH);
        this.sortCourseList(isLowToHigh ? CourseSortTypeMap.PRICE_HIGH_TO_LOW : CourseSortTypeMap.PRICE_LOW_TO_HIGH);
      }
    }
  }

  public async getCourseList(type: CourseTypeMap = CourseTypeMap.ALL) {
    this.isLoading = true;

    try {
      const res = await https.getCourseList({
        type,
        keyword: this.keyword,
      });
      if (res.ret.code === 0) {
        this.initList = res.result.courseList;
        this.sortCourseList(CourseSortTypeMap.DEFAULT);
      }
    } catch (err) {
      Logger.error(TAG, 'load course list failed' + err);
    } finally {
      this.isLoading = false;
    }

  }

  public async sortCourseList(sortType: CourseSortTypeMap) {
    this.sortType = sortType;
    this.displayList = this.initList.slice();
    if (this.sortType === CourseSortTypeMap.PRICE_LOW_TO_HIGH) {
      this.displayList.sort((a, b) => a.price - b.price);
    } else if (this.sortType === CourseSortTypeMap.PRICE_HIGH_TO_LOW) {
      this.displayList.sort((a, b) => b.price - a.price);
    }
  }

  public handleClickCourseCard(course: CourseInfo) {
    RouterModule.push({
      url: RouterMap.COURSE_DETAIL,
      param: course,
    });
  }
}