// 云盘文件操作数据模型
@ObservedV2
export class OperationItemModel {
  operationType: OperationItemType;
  iconName: ResourceStr = '';
  iconSource: ResourceStr = '';

  constructor(operationType: OperationItemType) {
    this.operationType = operationType;
    switch (operationType) {
      case OperationItemType.DOWNLOAD: {
        this.iconName = $r('app.string.operation_item_download');
        this.iconSource = $r('app.media.operation_download');
      }
        break;
      case OperationItemType.DELETE: {
        this.iconName = $r('app.string.operation_item_delete');
        this.iconSource = $r('app.media.operation_delete');
      }
        break;
      case OperationItemType.SHARE: {
        this.iconName = $r('app.string.operation_item_share');
        this.iconSource = $r('app.media.operation_share');
      }
        break;
      case OperationItemType.RENAME: {
        this.iconName = $r('app.string.operation_item_rename');
        this.iconSource = $r('app.media.operation_rename');
      }
        break;
      case OperationItemType.MOVE: {
        this.iconName = $r('app.string.operation_item_movefile');
        this.iconSource = $r('app.media.operation_move');
      }
        break;
      case OperationItemType.MOVETO_PRIVATESPACE: {
        this.iconName = $r('app.string.operation_item_movein_privatespace');
        this.iconSource = $r('app.media.operation_move_privatespace');
      }
        break;
      case OperationItemType.MOVEOUT_PRIVATESPACE: {
        this.iconName = $r('app.string.operation_item_moveout_privatespace');
        this.iconSource = $r('app.media.operation_move_privatespace');
      }
        break;
      case OperationItemType.COLLECTED: {
        this.iconName = $r('app.string.operation_item_collect');
        this.iconSource = $r('app.media.operation_collected');
      }
        break;
      case OperationItemType.UNCOLLECTED: {
        this.iconName = $r('app.string.operation_item_collect');
        this.iconSource = $r('app.media.operation_uncollect');
      }
        break;
      case OperationItemType.CANCELSHARE: {
        this.iconName = $r('app.string.operation_item_cancel_share');
        this.iconSource = $r('app.media.operation_cancle_share');
      }
        break;
      case OperationItemType.COPYLINK: {
        this.iconName = $r('app.string.operation_item_copylink');
        this.iconSource = $r('app.media.operation_copy_link');
      }
        break;
      default:
        break;
    }
  }
}

// 文件操作枚举类型
export enum OperationItemType {
  // 下载
  DOWNLOAD = 0,

  // 删除
  DELETE = 1,

  // 分享
  SHARE = 2,

  // 重命名
  RENAME = 3,

  // 移动文件
  MOVE = 4,

  // 移入隐私空间
  MOVETO_PRIVATESPACE = 5,

  // 移出隐私空间
  MOVEOUT_PRIVATESPACE = 6,

  // 未收藏
  UNCOLLECTED = 7,

  // 已收藏
  COLLECTED = 8,

  // 取消分享
  CANCELSHARE = 9,

  //复制链接
  COPYLINK = 10
}

