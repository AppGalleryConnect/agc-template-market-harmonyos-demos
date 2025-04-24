import { BaseViewModel } from 'common';
import { NotificationApi } from '../api/NotificationApi';
import { NotificationType } from '../constant/Constant';
import { NotificationModel } from '../model/NotificationModel';

@ObservedV2
export class NotificationViewModel extends BaseViewModel {
  @Trace notificationList: NotificationModel[] = []
  private api: NotificationApi = new NotificationApi()

  public constructor() {
    super()
    this.api.config.showLoading = false
    this.api.config.onLoadingCallback = this.getLoadingCallback()
  }

  public loadNotificationList() {
    this.api.getNotificationList().then((data) => {
      this.notificationList = data
    })
  }

  public toNotificationDetail(index: number) {
    let notification = this.notificationList[index];
    switch (notification.type) {
      case NotificationType.NOTIFICATION_APPOINTMENT:
        this.toPage('AppointmentOrderPage', notification.data)
        break
      case NotificationType.NOTIFICATION_REPORT:
        this.toPage('ReportQueryPage')
        break
      case NotificationType.NOTIFICATION_NORMAL:
        break
    }
  }
}