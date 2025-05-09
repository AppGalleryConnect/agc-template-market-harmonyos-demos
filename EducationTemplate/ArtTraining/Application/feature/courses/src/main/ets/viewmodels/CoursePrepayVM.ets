import { AccountUtil, CourseInfo,
  CoursePaymentMap,
  FullLoading,
  Logger,
  OrderSubmittedRouteParam,
  RouterMap, RouterModule, UserInfoModel, WindowUtil } from 'commonlib';
import { CourseOrderReq, https } from 'network';
import { UserInfoForOrderMap } from '../constants/Enums';
import { CourseOrderModel } from '../models/Index';
import { CoursePaymentMethod } from '../types/Index';
import { promptAction } from '@kit.ArkUI';
import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = '[CoursePrepayVM]';


@ObservedV2
export class CoursePrepayVM {
  @Trace courseInfo: CourseInfo | null = null;
  @Trace courseOrder: CourseOrderModel = new CourseOrderModel();
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace isLoading: boolean = false;
  @Trace isSubmitting: boolean = false;
  private static _instance: CoursePrepayVM;

  public static get instance() {
    if (!CoursePrepayVM._instance) {
      CoursePrepayVM._instance = new CoursePrepayVM();
    }
    return CoursePrepayVM._instance;
  }

  public async initCourseOrder() {
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
    this.courseOrder.courseId = this.courseInfo!.courseId;
    this.courseOrder.price = this.courseInfo!.price;
    this.courseOrder.paymentMethod = CoursePaymentMap.ONLINE;
    this.courseOrder.student = this.userInfo.nickname;
    this.courseOrder.phone = this.userInfo.phone;
  }


  public switchPaymentMethod(type: CoursePaymentMethod) {
    this.courseOrder.paymentMethod = type.id;
  }

  public clearOrderInfo(type: UserInfoForOrderMap) {
    if (type === UserInfoForOrderMap.NAME) {
      this.courseOrder.student = '';
    } else if (type === UserInfoForOrderMap.PHONE) {
      this.courseOrder.phone = '';
    }
  }

  public async submitCourseOrder() {
    if (!this.courseOrder.student) {
      promptAction.showToast({ message: '请输入学员姓名' });
      return;
    }
    if (!this.courseOrder.phone) {
      promptAction.showToast({ message: '请输入手机号' });
      return;
    }
    const reg = /^[1][0-9]{10}$/;
    if (!reg.test(this.courseOrder.phone)) {
      promptAction.showToast({ message: '手机号格式不正确' });
      return;
    }
    const req: CourseOrderReq = {
      courseId: this.courseOrder.courseId,
      paymentMethod: this.courseOrder.paymentMethod,
      student: this.courseOrder.student,
      phone: this.courseOrder.phone,
      price: this.courseOrder.price,
      remark: this.courseOrder.remark,
    };
    FullLoading.show('订单创建中...');
    const res = await https.createCourseOrder(req);
    if (res.ret.code === 0 && res.result) {
      const param: OrderSubmittedRouteParam = {
        orderNo: res.result.orderNo,
        paymentMethod: this.courseOrder.paymentMethod,
        orderStatus: res.result.orderStatus,
      };
      if (this.courseOrder.paymentMethod === CoursePaymentMap.OFFLINE) {
        this.jumpToOrderSubmittedPage(param);
      } else if (this.courseOrder.paymentMethod === CoursePaymentMap.ONLINE) {
        const context = WindowUtil.context as common.UIAbilityContext;
        paymentService
          .requestPayment(context, res.result.orderStr)
          .then(() => {
            promptAction.showToast({ message: '支付成功！' });
            this.jumpToOrderSubmittedPage(param);
          })
          .catch((err: BusinessError) => {
            Logger.error(TAG, `call payment service failed. code: ${err.code},message:${err.message}`);
            const timer = setTimeout(() => {
              this.jumpToOrderSubmittedPage(param);
              clearTimeout(timer);
            }, 500);
          });
      }
    } else {
      promptAction.showToast({ message: '订单创建失败，请稍后重试~' });
    }
    FullLoading.hide();
  }

  public jumpToOrderSubmittedPage(param: OrderSubmittedRouteParam) {
    RouterModule.push({
      url: RouterMap.COURSE_SUBMITTED,
      param,
    });
  }
}