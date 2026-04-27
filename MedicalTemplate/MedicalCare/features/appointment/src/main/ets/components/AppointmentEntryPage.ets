import { CommonNavDestination } from 'common';
import { HospitalSelectPage } from './HospitalSelectPage';

/**
 * 预约挂号入口页面
 */
@Builder
export function AppointmentEntryPageBuilder(name: string, param: Object) {
  CommonNavDestination({ title: '挂号' }) {
    HospitalSelectPage()
  }
}
