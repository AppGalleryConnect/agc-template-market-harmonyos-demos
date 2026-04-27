import { image } from '@kit.ImageKit';
import { EditTextSnapModel } from './EditTextSnapModel';
import { BasicVideoData } from './VideoParams';

// 导出页路由参数接口
export interface ExportVideoParam {
  uri: string;
  simulatedDetail: simulatedDetail;
  simulate?: boolean;
  startTimeMs?: number;
  endTimeMs?: number;
}

// ArkTS: 用接口替代对象字面量类型声明
export interface ClipParams {
  hasClip: boolean;
  sStr?: string;
  tStr?: string;
}

// 显式接口类型：用于 ArkTS 检查，避免内联对象类型
export interface SelectedCodecs {
  videoCodec: string;
  audioCodec: string;
}

export interface CodecInfo {
  container: string;
  videoCodec: string;
  audioCodec: string;
}

export interface SimpleAVMetadata {
  mime?: string;
  videoCodecName?: string;
  audioCodecName?: string;
}

// ArkTS: ensureExportDir 返回类型的命名接口，避免对象字面量类型
export interface ExportDirInfo {
  exportDir: string;
  inputPath: string;
  outputPath: string;
}

// 命名接口：用于 getResolutionAndAspect 返回类型，避免对象字面量类型
export interface ResolutionAspect {
  width: number;
  height: number;
  aspect: number;
  duration: number;
  hasAudio: string;
}

// ArkTS：解析分辨率字符串的返回类型，避免内联对象字面量
export interface TargetResolution {
  w: number;
  h: number;
}

// ArkTS：统一声明可排序的项类型，避免在泛型约束中使用对象字面量
export interface Orderable {
  order?: number;
}

// ArkTS 接口声明：为对象字面量提供显式类型
export interface EncodeConfig {
  // 按顺序尝试，若失败自动降级，设备缺少 libx264 时自动尝试 libopenh264 或退化到 copy 。
  videoCodecOrder: string[];

  // 音频编码器优先顺序：若 aac 不可用，代码会尝试 copy （不重编码，保留原音频）
  audioCodecOrder: string[];

  /***
   * libx264 的编码速度/压缩效率档位:
   * 可选： ultrafast 、 superfast 、 veryfast 、 faster 、 fast 、 medium 、 slow 、 slower 、 veryslow 、 placebo 。
   * 越“快”→速度高、码率更高（体积更大）、质量略降；越“慢”→更省码率、质量更好但更耗时。
   * 推荐：通用用 medium ；追求速度用 veryfast ；追求体积/质量用 slow 或 slower
   */
  preset: string;

  /***
   *  音频码率（单位 kbps ），对应 -b:a <值>k 。
   *  典型范围： 96–192k 。 128k 为通用默认；音乐或高保真可用 192k ；语音内容可降到 96k 。
   */
  crf: number;

  /***
   *  恒定质量因子（Constant Rate Factor），控制视频质量与体积的平衡。
   *  范围通常 0–51 ：数值越低质量越好、体积越大。 23 是默认均衡值； 18 常被认为“接近无损”； 28 更小体积但质量下降明显。
   *  与 preset 联动：同一 crf 下， preset 越慢压缩效率越高（体积更小）。
   */
  audioBitrateK: number;

  /***
   * MP4 容器写入标志。 +faststart 会把 moov 元数据移到文件开头，便于“边下边播”或快速首帧显示。
   * 对画质无影响，但提升可播放性与用户体验。
   */
  movflags: string;

  /***
   *  帧率同步策略。 cfr 强制恒定帧率（Constant Frame Rate）。
   *  好处：时间戳稳定，有利于“精确裁剪”和进度计算（ out_time_ms 更线性）。
   *  其他选项： vfr （可变帧率）、 passthrough （保持原策略）、 drop / dup （丢帧/补帧以对齐）。
   */
  vsync: string;
}

export interface exportClipVideo { //裁剪视频
  uri: string
  startTime: number
  endTime: number
  duration: number
}

export interface exportJoinVideo { //拼接视频
  uri: string
  duration: number
}

export interface exportJoinVideoOrder { //拼接视频
  uri: string
  duration: number
  order: number
}

export interface exportClipVideoOrder { //裁剪视频
  uri: string
  startTime: number
  endTime: number
  duration: number
  order: number
}

export interface exportPipVideo { //画中画
  isEdit: boolean
  isShape: boolean
  uri: string
  pipFrameList: frameListData[],
  startTime: number
  endTime: number
  duration: number
  keyFrame: image.PixelMap | undefined
  width: number
  height: number
  offsetX: number
  offsetY: number
  offsetPipX: number
  offsetPipY: number
  radiusX: number
  radiusY: number
  srcWidth: number
  srcHeight: number
  xOffsetDistance: number
}

export interface exportSubTitle { //字幕
  url: string
  text: string
  width: number
  height: number
  offsetX: number
  offsetY: number
}

export interface simulatedDetail { //导出视频
  videoFormat: string
  videoResolution: string
  totalDuration: number
  keyFrame: image.PixelMap
  exportClipVideo: exportClipVideoOrder[]
  exportJoinVideo: exportJoinVideoOrder[]
  exportPipVideo: exportPipVideo[]
  exportClipJoinVideo: exportClipVideoOrder[]
  exportSubTitle: exportSubTitle
}

export interface exportVideo { //导出视频
  videoFormat: string
  videoFormatIndex: number
  videoResolution: string
  videoResolutionIndex: number
  totalDuration: number
  keyFrame: string
  basicVideoData: BasicVideoData[]
  exportPipVideo: exportPipVideo[]
  exportSubTitle: exportSubTitle
  editTextSnapList: EditTextSnapModel[]
  isVip: boolean
}

export interface frameListData {
  index: number,
  mPixelMap: image.PixelMap | undefined,
  url: string
}

export interface exportVideoOrder { //导出视频
  videoFormat: string
  videoResolution: string
  totalDuration: number
  keyFrame: image.PixelMap
  exportClipVideo: exportClipVideoOrder[]
  exportJoinVideo: exportJoinVideoOrder[]
  exportPipVideo: exportPipVideo[]
  exportSubTitle: exportSubTitle
}

export interface sortVideoOrder {
  uri: string
  order: number
}

export interface textMarkCmd {
  index: number
  path: string
  scale: string
  overlay: string
  startTime: number
  endTime: number
  angle: number
}

export interface pendingTask {
  resolve: () => void;
  reject: (err: Error) => void;
}

export interface workerReplyVM {
  id: number;
  code: number;
}

export interface workerMsgVM {
  id: number;
  k: 'ffmpeg' | 'clip' | 'merge';
  cmd?: string;
  start?: string | number;
  end?: string | number;
  input?: string;
  output?: string;
  txt?: string;
  out?: string;
}

export interface dataInfo{
  url: string,
  isVip: boolean
}