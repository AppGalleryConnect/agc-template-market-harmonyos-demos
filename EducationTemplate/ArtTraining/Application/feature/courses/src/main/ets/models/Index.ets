import { CourseOrderReq } from 'network';

@ObservedV2
export class CourseOrderModel implements CourseOrderReq {
  @Trace courseId: number = -1;
  @Trace paymentMethod: number = 1;
  @Trace student: string = '';
  @Trace phone: string = '';
  @Trace price: number = 0;
  @Trace remark: string = '';
}