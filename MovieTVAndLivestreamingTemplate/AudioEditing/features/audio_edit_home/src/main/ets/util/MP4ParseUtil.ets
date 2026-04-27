/** 音频文件完整信息（FFmpeg 风格元数据） */
export interface AudioFileMetadata {
  streams: AudioStream[];
  chapters: Chapter[]; // 章节列表（当前为空数组）
  format: AudioFormatInfo; // 文件格式信息
}

/** 单个音频流详情 */
interface AudioStream {
  index: number;
  codec_name: string; // 编码名称（如 'mp3'）
  codec_long_name: string; // 完整编码名称
  codec_type: 'audio' | 'video' | 'subtitle'; // 流类型（当前为音频）
  codec_time_base: string; // 编码时间基（如 '1/44100'）
  codec_tag_string: string; // 编码标签字符串（如 '[0][0][0][0]'）
  codec_tag: string; // 编码标签（十六进制，如 '0x0000'）
  sample_fmt: 'fltp' | 's16' | 's24' | 'u8' | string; // 采样格式（当前为 fltp）
  sample_rate: string; // 采样率（字符串格式，如 '44100'）
  channels: number; // 声道数（2=立体声）
  channel_layout: 'stereo' | 'mono' | '5.1' | string; // 声道布局
  bits_per_sample: number; // 每采样比特数（MP3 压缩格式通常为 0）
  r_frame_rate: string; // 实时帧率（音频默认 '0/0'）
  avg_frame_rate: string; // 平均帧率（音频默认 '0/0'）
  time_base: string; // 流时间基（如 '1/14112000'）
  start_pts: number; // 起始 PTS 时间戳
  start_time: string; // 起始时间（秒，如 '0.025057'）
  duration_ts: number; // 总时长时间戳
  duration: string; // 总时长（秒，如 '199.627755'）
  bit_rate: string; // 比特率（如 '128000'）
  disposition: StreamDisposition; // 流属性配置
  tags: AudioStreamTags; // 流标签（编码器等）
}

/** 流属性配置（是否默认、歌词、强制等） */
interface StreamDisposition {
  default: 0 | 1;
  dub: 0 | 1;
  original: 0 | 1;
  comment: 0 | 1;
  lyrics: 0 | 1;
  karaoke: 0 | 1;
  forced: 0 | 1;
  hearing_impaired: 0 | 1;
  visual_impaired: 0 | 1;
  clean_effects: 0 | 1;
  attached_pic: 0 | 1;
  timed_thumbnails: 0 | 1;
}

/** 音频流标签 */
interface AudioStreamTags {
  encoder?: string; // 编码器（如 'Lavc58.91'）
}

/** 章节信息（当前为空，预留扩展） */
interface Chapter {}

/** 文件格式信息 */
interface AudioFormatInfo {
  filename: string; // 文件路径+名称（如 '/storage/.../ap1000_us0_pi409_s1114592696.mp3'）
  nb_streams: number; // 流数量（当前为 1）
  nb_programs: number; // 节目数量（音频通常为 0）
  format_name: string; // 格式名称（如 'mp3'）
  format_long_name: string; // 完整格式名称（如 'MP2/3 (MPEG audio layer 2/3)'）
  start_time: string; // 文件起始时间（与流起始时间一致）
  duration: string; // 文件总时长（与流总时长一致）
  size: string; // 文件大小（字节数，如 '3194556'）
  bit_rate: string; // 文件总比特率（如 '128020'）
  probe_score: number; // 探测分数（越高越精准，如 51）
  tags: FormatTags; // 文件格式标签
}

/** 文件格式标签 */
interface FormatTags {
  date?: string; // 日期（如 '2023-05-04'）
  time_reference?: string; // 时间基准（如 '0'）
  encoder?: string; // 格式编码器（如 'Lavf58.45.100'）
}