// 文件操作数据模型
@ObservedV2
export class FileOperationModel {
  operationType: FileOperationType;
  name: ResourceStr = '';
  iconNormal: ResourceStr = '';
  iconSelected: ResourceStr = '';

  constructor(operationType: FileOperationType) {
    this.operationType = operationType;
    switch (operationType) {
      case FileOperationType.Download: {
        this.name = $r('app.string.operation_download');
        this.iconNormal = $r('app.media.download');
      }
        break;
      case FileOperationType.Delete: {
        this.name = $r('app.string.operation_delete');
        this.iconNormal = $r('app.media.delete');
      }
        break;
      case FileOperationType.Share: {
        this.name = $r('app.string.operation_share');
        this.iconNormal = $r('app.media.share');
      }
        break;
      case FileOperationType.Rename: {
        this.name = $r('app.string.operation_rename');
        this.iconNormal = $r('app.media.rename');
      }
        break;
      case FileOperationType.Move: {
        this.name = $r('app.string.operation_move_file');
        this.iconNormal = $r('app.media.move');
      }
        break;
      case FileOperationType.MoveToPrivateSpace:
      case FileOperationType.MoveOutPrivateSpace: {
        this.name =
          (operationType === FileOperationType.MoveOutPrivateSpace) ? $r('app.string.operation_privatespace_moveout') :
          $r('app.string.operation_privatespace_movein');
        this.iconNormal = $r('app.media.privatespace');
      }
        break;
      case FileOperationType.Collect: {
        this.name = $r('app.string.operation_collect');
        this.iconNormal = $r('app.media.uncollect');
        this.iconSelected = $r('app.media.collected');
      }
        break;
      case FileOperationType.BackUp: {
        this.name = '还原';
        this.iconNormal = $r('app.media.back_up');
      }
        break;
      case FileOperationType.DeleteForevery: {
        this.name = '永久删除';
        this.iconNormal = $r('app.media.delete');
      }
        break;
      case FileOperationType.CancleCollect: {
        this.name = '取消收藏';
        this.iconNormal = $r('app.media.cancle_collect');
      }
        break;
      case FileOperationType.CancleShare: {
        this.name = '取消分享';
        this.iconNormal = $r('app.media.cancle_share');
      }
        break;
      case FileOperationType.CopyLink: {
        this.name = '复制链接';
        this.iconNormal = $r('app.media.copy_link');
      }
        break;
      default:
        break;
    }
  }
}

// 文件操作枚举类型
export enum FileOperationType {
  Download = 0, // 下载
  Delete = 1, // 删除
  Share = 2, // 分享
  Rename = 3, // 重命名
  Move = 4, // 移动文件
  MoveToPrivateSpace = 5, // 移入隐私空间
  Collect = 6, // 收藏
  MoveOutPrivateSpace = 7, // 移出隐私空间
  BackUp = 8, // 还原
  DeleteForevery = 9, // 永久删除
  CancleCollect = 10, // 取消收藏
  CancleShare = 11, // 取消分享
  CopyLink = 12 //复制链接
}

