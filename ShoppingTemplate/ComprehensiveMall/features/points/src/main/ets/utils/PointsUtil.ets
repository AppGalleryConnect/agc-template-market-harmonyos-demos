import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { SafeJson, WindowUtil } from 'lib_foundation'
import { RedemptionOrderStatus } from '../commons/Enums'

export class PointsUtil {
  public static copyText(text: string) {
    try {
      const pasteboardData = pasteboard.createData(
        pasteboard.MIMETYPE_TEXT_PLAIN,
        text
      )
      const systemPasteboard = pasteboard.getSystemPasteboard()
      systemPasteboard
        .setData(pasteboardData)
        .then(() => {
          WindowUtil.toast('复制成功!')
        })
        .catch((err: BusinessError) => {
          WindowUtil.toast('复制失败!')
          SafeJson.jsonStringify(err)
        })
    } catch (err) {
      WindowUtil.toast('复制失败!')
      SafeJson.jsonStringify(err)
    }
  }

  public static getLogisticStatusLabel(status: number): string {
    const labelMap: Map<number, string> = new Map([
      [101, '待确认'],
      [102, '待发货'],
      [201, '已发货'],
      [202, '已揽收'],
      [203, '运输中'],
      [204, '派件中'],
      [205, '待收货'],
      [301, '已签收'],
    ]);
    return labelMap.get(status) ?? '';
  }

  public static getStatusLabel(status: number): string {
    if (status === RedemptionOrderStatus.PENDING_SHIPMENT) {
      return '待发货'
    } else if (status === RedemptionOrderStatus.PENDING_RECEIPT) {
      return '待收货'
    }
    return '已完成'
  }
}
