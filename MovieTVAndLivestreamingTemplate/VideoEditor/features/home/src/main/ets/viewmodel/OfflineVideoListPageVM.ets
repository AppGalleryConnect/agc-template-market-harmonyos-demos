import { CommonConstants, VideoInfo } from 'offline_video_download/src/main/ets/CommonConstants';

@ObservedV2
export class OfflineVideoListPageVM {
  @Trace currentTab: number = 0; // 0: 下载中, 1: 已下载
  @Trace isEdit: boolean = false; // 是否处于编辑模式
  @Trace selectedVideos: Set<string> = new Set(); // 选中的视频id集合
  @Trace videoList: VideoInfo[] = []; // 本地视频列表副本
  @Trace refreshKey: number = 0; // 用于强制刷新列表
  private isToggling: boolean = false; // 防止重复触发全选

  constructor() {
    // 初始化时复制视频列表
    this.videoList = [...CommonConstants.VIDEO_HTTPS_LISTS];
  }

  // 获取过滤后的视频列表
  getFilteredVideos(): VideoInfo[] {
    // 使用 refreshKey 确保响应式更新
    const _ = this.refreshKey;

    if (this.currentTab === 0) {
      // 下载中：显示未完成下载的视频
      return this.videoList.filter(item => !item.isCached);
    } else {
      // 已下载：显示已完成下载的视频
      return this.videoList.filter(item => item.isCached);
    }
  }

  // 切换视频选中状态
  toggleVideoSelection(id: string) {
    if (this.selectedVideos.has(id)) {
      this.selectedVideos.delete(id);
    } else {
      this.selectedVideos.add(id);
    }
    // 触发UI更新
    this.selectedVideos = new Set(this.selectedVideos);
  }

  // 检查视频是否被选中
  isVideoSelected(id: string): boolean {
    return this.selectedVideos.has(id);
  }

  // 全选/取消全选
  toggleSelectAll() {
    // 防止重复触发
    if (this.isToggling) {
      return;
    }

    this.isToggling = true;

    try {
      const filteredVideos = this.getFilteredVideos();

      if (filteredVideos.length === 0) {
        return;
      }
      const allSelected = this.isAllSelected();
      if (allSelected) {
        // 取消全选：移除当前标签页的所有视频
        filteredVideos.forEach(item => {
          this.selectedVideos.delete(item.id);
        });
      } else {
        // 全选：添加当前标签页的所有视频
        filteredVideos.forEach(item => {
          this.selectedVideos.add(item.id);
        });
      }
      // 创建新的 Set 触发响应式更新
      this.selectedVideos = new Set(this.selectedVideos);
    } finally {
      // 延迟重置标志，防止快速连续点击
      setTimeout(() => {
        this.isToggling = false;
      }, 300);
    }
  }

  // 检查是否全选
  isAllSelected(): boolean {
    const filteredVideos = this.getFilteredVideos();
    if (filteredVideos.length === 0) {
      return false;
    }
    return filteredVideos.every(item => this.selectedVideos.has(item.id));
  }

  // 删除选中的视频
  deleteSelectedVideos() {
    if (this.selectedVideos.size === 0) {
      return;
    }

    // 从列表中删除选中的视频
    const idToDelete = Array.from(this.selectedVideos);

    // 过滤掉要删除的视频，创建新数组
    const newList = this.videoList.filter(item => !idToDelete.includes(item.id));

    // 更新本地列表
    this.videoList = newList;

    // 同步更新 CommonConstants 中的列表
    CommonConstants.VIDEO_HTTPS_LISTS.length = 0;
    CommonConstants.VIDEO_HTTPS_LISTS.push(...this.videoList);

    // 清空选中状态
    this.selectedVideos.clear();
    this.selectedVideos = new Set();

    // 触发列表刷新
    this.refreshKey++;

    // 退出编辑模式
    this.isEdit = false;
  }

  // 退出编辑模式时清空选中状态
  exitEditMode() {
    this.isEdit = false;
    this.selectedVideos.clear();
    this.selectedVideos = new Set();
  }
}