export default class ImageModel {
  id: string = ''             // 唯一标识，方便更新/删除
  src: string = ''            // 图片路径
  x: number = 0               // 坐标（自由拼接模式用）
  y: number = 0
  width: number = 100         // 显示宽度
  height: number = 100        // 显示高度
  scale: number = 1           // 缩放比例
  rotate: number = 0          // 旋转角度
  path: string = ''
}
