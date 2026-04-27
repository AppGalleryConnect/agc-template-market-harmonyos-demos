export function formatFileSize(bytes: number): string {
  if (isNaN(bytes) || bytes < 0) {
    return '0B';
  }
  if (bytes < 1024) {
    return `${bytes}B`;
  }
  const units = ['B', 'KB', 'MB', 'GB'];
  let size = bytes;
  let i = 0;
  while (size >= 1024 && i < units.length - 1) {
    size /= 1024;
    i++;
  }
  return `${size.toFixed(2)} ${units[i]}`;
}


// 毫秒转 时:分:秒（补零格式化）
export function formatTime(ms: number): string {
  const totalSec = Math.floor(ms / 1000);
  const h = String(Math.floor(totalSec / 3600)).padStart(2, '0');
  const m = String(Math.floor((totalSec % 3600) / 60)).padStart(2, '0');
  const s = String(totalSec % 60).padStart(2, '0');
  return `${h}:${m}:${s}`;
}