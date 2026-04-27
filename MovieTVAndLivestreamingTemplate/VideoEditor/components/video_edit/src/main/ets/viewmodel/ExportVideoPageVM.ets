import { fileUri } from '@kit.CoreFileKit';
import { UIContext } from '@kit.ArkUI';
import { ErrorEvent, MessageEvents, worker } from '@kit.ArkTS';
import fs from '@ohos.file.fs';
import { CODEC_TABLE, RESOLUTION_TABLE } from '../utils/ConstantsUtil';
import {
  exportVideo,
  exportPipVideo,
  exportSubTitle,
  textMarkCmd,
  pendingTask,
  workerReplyVM,
  workerMsgVM,
  BasicVideoData,
  EditTextSnapModel
} from 'video_common';
import {
  msToHms, normalizeError, getMetadataInfo, fsCopy, successSaveWork
} from '../utils/ExportVideoUtil';
import { getVideoData } from '../utils/CommonUtils';
import { VideoSizeData } from '../model/VideoSizeData';

@ObservedV2
export class ExportVideoPageVM {
  private static _instance: ExportVideoPageVM;
  @Trace loading: boolean = false; // 是否加载中
  @Trace exportStatus: string = ''; // 判断导出是否完成 成功’finish‘或失败’unFinish‘
  @Trace bitCodec: string = '' // 视频编码格式
  @Trace bitResolution: string [] = []; // 视频分辨率
  @Trace exportDir: string = '';
  @Trace workListDir: string = '';
  @Trace videoThumbnail: string = '';
  // Worker 子线程句柄与当前执行的 Promise reject，用于取消时快速结束等待
  private ffmpegWorker?: worker.ThreadWorker;
  private workerEntryPath: string = 'entry/ets/workers/FFmPegWorker.ets';
  // 统一的请求/响应路由与取消策略
  private nextMsgId: number = 1;
  private pendingMap: Map<number, pendingTask> = new Map();
  private inFlight: boolean = false;
  private terminateWhenIdle: boolean = false;
  private cancelRequested: boolean = false; // 取消导出标记，阻断后续步骤
  @Trace stopping: boolean = false; // 是否正在停止导出，等待 worker 退出
  // 等待 worker 退出的回调队列，用于避免取消后立即重新进入导致并发执行
  private exitWaiters: (() => void)[] = [];
  @Trace firstW: string = '';
  @Trace firstH: string = '';
  @Trace audioSegPaths: string[] = [];
  stack: NavPathStack | null = null;
  @Trace targetH: string = '';
  @Trace sourceVideoW: number = 0;
  @Trace sourceVideoH: number = 0;
  @Trace containWidth: number = 0;
  @Trace containHeight: number = 0;
  @Trace detail: exportVideo = {
    videoFormat: '',
    videoFormatIndex: 0,
    videoResolution: '',
    videoResolutionIndex: 0,
    totalDuration: 0,
    keyFrame: '',
    basicVideoData: [],
    exportPipVideo: [],
    exportSubTitle: {
      url: '',
      text: '',
      offsetX: 0,
      offsetY: 0,
      width: 0,
      height: 0
    },
    editTextSnapList: [],
    isVip: false
  }

  public static get instance() {
    if (!ExportVideoPageVM._instance) {
      ExportVideoPageVM._instance = new ExportVideoPageVM();
    }
    return ExportVideoPageVM._instance;
  }

  private async doExportAction1(detail: exportVideo, exportDir: string, outputFilePath: string): Promise<string> {
    // 1)、裁剪视频---转换分辨率---抽取音频
    const clipSegPaths: string[] =
      await this.exportClipSegments(detail.basicVideoData, exportDir);
    if (this.cancelRequested) {
      throw new Error('export cancelled');
    }

    // 2)、拼接视频
    if (clipSegPaths?.length && clipSegPaths.length > 1) {
      outputFilePath = await this.exportJoinVideoSegments(clipSegPaths, exportDir);
    } else {
      outputFilePath = clipSegPaths[0];
    }
    if (this.cancelRequested) {
      throw new Error('export cancelled');
    }

    // 3)、添加画中画
    if (detail?.exportPipVideo && detail.exportPipVideo?.length) {
      outputFilePath = await this.exportPipSegments(detail.exportPipVideo, exportDir, outputFilePath);
    }
    if (this.cancelRequested) {
      throw new Error('export cancelled');
    }

    // 4)、添加字幕
    if (detail?.exportSubTitle && detail.exportSubTitle?.url) {
      outputFilePath = await this.exportSubTitleSegments(detail.exportSubTitle, exportDir, outputFilePath)
    }
    if (this.cancelRequested) {
      throw new Error('export cancelled');
    }
    return outputFilePath
  }


  private async doExportAction2(detail: exportVideo, exportDir: string, outputFilePath: string): Promise<string> {
    // 5)、添加提词器
    if (detail?.editTextSnapList && detail.editTextSnapList?.length) {
      outputFilePath = await this.exportPrompterSegments1(detail.editTextSnapList, exportDir, outputFilePath)
    }
    if (this.cancelRequested) {
      throw new Error('export cancelled');
    }

    // 6)、转换视频格式
    outputFilePath =
      await this.codeAndAudioSegments(outputFilePath, detail.videoFormat);
    if (this.cancelRequested) {
      throw new Error('export cancelled');
    }
    return outputFilePath
  }

  // 开始执行导出
  async startExport(uiCtx: UIContext, params: exportVideo): Promise<void> {
    // 重置取消标记
    this.cancelRequested = false;
    this.loading = true;
    const detail: exportVideo = params as exportVideo;
    this.detail = detail;
    const exportDir = this.ensureExportDir(uiCtx);
    this.exportDir = exportDir;
    const workListDir = this.ensureWorkListDir(uiCtx);
    this.workListDir = workListDir;
    try {
      // 视频输出路径
      let outputFilePath = '';
      // 获取视频封面图片
      const coverImgFilePath: string = `${this.workListDir}/coverImg.png`;
      if (fs.accessSync(detail.keyFrame)) {
        await fsCopy(detail.keyFrame, coverImgFilePath);
        this.videoThumbnail = fileUri.getUriFromPath(coverImgFilePath);
      }
      // 获取视频编码格式
      let codecArray: string[] = CODEC_TABLE.get(detail.videoFormat) as string[];
      this.bitCodec = codecArray[0];
      // 视频分辨率
      let resolutionArray: string[] = RESOLUTION_TABLE.get(detail.videoResolution) as string[];
      this.bitResolution = resolutionArray;
      let metaRotationData: VideoSizeData = await getVideoData(detail.basicVideoData[0].basicUrl)
      let rotation = metaRotationData.rotation
      let metaInfo = await getMetadataInfo(detail.basicVideoData[0].basicUrl)
      this.firstW = metaInfo.width > metaInfo.height ? this.bitResolution[0] : this.bitResolution[1];
      this.firstH = metaInfo.width > metaInfo.height ? this.bitResolution[1] : this.bitResolution[0];
      if (rotation === '90' || rotation === '270') {
        this.sourceVideoW = metaInfo.height;
        this.sourceVideoH = metaInfo.width;
      } else {
        this.sourceVideoW = metaInfo.width;
        this.sourceVideoH = metaInfo.height;
      }
      this.targetH = this.bitResolution[1];
      outputFilePath = await this.doExportAction1(detail, exportDir, outputFilePath)
      outputFilePath = await this.doExportAction2(detail, exportDir, outputFilePath)

      // 导出成功
      await this.handleExportSuccess(outputFilePath)
    } catch (e) {
      // 导出失败
      await this.handleExportFail();
    }
  }

  // 1)、裁剪视频---转换分辨率---抽取音频
  private async exportClipSegments(
    exportClipVideo: BasicVideoData[],
    exportDir: string,
  ): Promise<string[]> {
    const clipSegPaths: string[] = [];
    const audioSegPaths: string[] = [];
    for (let i = 0; i < (exportClipVideo?.length ?? 0); i++) {
      if (this.cancelRequested) {
        throw new Error('export cancelled');
      }
      const it: BasicVideoData = exportClipVideo[i];
      // 定义裁剪输入、输出路径
      const clipInput = `${exportDir}/clipInput${i}.mp4`;
      const clipOutput = `${exportDir}/clipOutput${i}.mp4`;
      // 定义分辨率转换转换输出路径
      const codeResOutput = `${exportDir}/codeResOutput${i}.mp4`;
      // 定义音频的输出路径
      const audioOutputPath = `${exportDir}/audioOutputPath${i}.m4a`;
      await fsCopy(it.basicUrl, clipInput);

      // a、进行裁剪
      const startTime = msToHms(Math.max(0, it.startTime));
      const endTime = msToHms(Math.max(0, it.endTime));
      let scale = ''
      if (i === 0) {
        if (this.sourceVideoW > this.sourceVideoH) {
          scale =
            `"[0:v]scale=-2:${this.targetH}:force_original_aspect_ratio=decrease:force_divisible_by=2,fps=20,pad=iw:${this.targetH}:(ow-iw)/2:(oh-ih)/2[out]"`
        } else {
          scale =
            `"[0:v]scale=${this.targetH}:-2:force_original_aspect_ratio=decrease:force_divisible_by=2,fps=20,pad=${this.targetH}:ih:(ow-iw)/2:(oh-ih)/2[out]"`
        }
      } else {
        scale =
          `"[0:v]scale=${this.containWidth}:${this.containHeight}:force_original_aspect_ratio=decrease:force_divisible_by=2,fps=20,pad=${this.containWidth}:${this.containHeight}:(ow-iw)/2:(oh-ih)/2[out]"`
      }
      let fullCmd =
        `ffmpeg -y -i ${clipInput} -ss ${startTime} -to ${endTime} -filter_complex ${scale} -map "[out]" -map 0:a -c:v ${this.bitCodec} -video_track_timescale 90000 -c:a aac -b:a 192k -vsync 1 -async 1 ${codeResOutput}`;
      await this.runFfmpegCmdViaWorker(fullCmd);
      if (this.cancelRequested) {
        throw new Error('export cancelled');
      }

      if (i === 0) {
        let metaInfo = await getMetadataInfo(codeResOutput)
        this.containWidth = metaInfo.width;
        this.containHeight = metaInfo.height;
      }
      clipSegPaths.push(codeResOutput);
    }

    return clipSegPaths;
  }

  // 2)进行分辨率转换
  private async codeAndResolutionSegments(
    codeResInput: string,
    codeResOutput: string,
    index: number
  ): Promise<string> {
    let scale = ''
    if (index === 0) {
      if (this.sourceVideoW > this.sourceVideoH) {
        scale =
          `"[0:v]scale=-2:${this.targetH}:force_original_aspect_ratio=decrease:force_divisible_by=2,fps=20,pad=iw:${this.targetH}:(ow-iw)/2:(oh-ih)/2[out]"`
      } else {
        scale =
          `"[0:v]scale=${this.targetH}:-2:force_original_aspect_ratio=decrease:force_divisible_by=2,fps=20,pad=${this.targetH}:ih:(ow-iw)/2:(oh-ih)/2[out]"`
      }
    } else {
      scale =
        `"[0:v]scale=${this.containWidth}:${this.containHeight}:force_original_aspect_ratio=decrease:force_divisible_by=2,fps=20,pad=${this.containWidth}:${this.containHeight}:(ow-iw)/2:(oh-ih)/2[out]"`
    }
    let fullCmd =
      `ffmpeg -i ${codeResInput} -c:v ${this.bitCodec} -video_track_timescale 90000 -filter_complex ${scale} -map "[out]" -map 0:a -c:a aac -b:a 192k -vsync 1 -async 1 -y ${codeResOutput}`;
    try {
      await this.runFfmpegCmdViaWorker(fullCmd);
    } catch (err) {
      throw normalizeError(err);
    }
    return codeResOutput;
  }

  // 3)、提取视频中的音频
  private async getAudioSegments(
    audioInputPath: string,
    audioOutputPath: string
  ): Promise<string> {
    let fullCmd = `ffmpeg -i ${audioInputPath} -c:a copy -vn  -y ${audioOutputPath}`
    try {
      await this.runFfmpegCmdViaWorker(fullCmd);
    } catch (err) {
      throw normalizeError(err);
    }
    return audioOutputPath;
  }

  // 4)拼接合成视频
  private async exportJoinVideoSegments(
    exportJoinVideos: string[],
    exportDir: string,
  ): Promise<string> {
    const videoList = exportJoinVideos
    const videoTxt = exportDir + '/video.txt';
    const joinMergeOutput = `${exportDir}/joinMerge.${this.detail.videoFormat}`;
    await this.formatVideo(videoList, exportDir);
    let file: fs.File | undefined = undefined
    try {
      file = await fs.open(videoTxt, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      let videoNum = 0;
      for (let uri of videoList) {
        videoNum++;
        let videoName = 'video' + videoNum.toString() + '.ts';
        let fileContent = 'file \'' + videoName + '\'\n';
        await fs.write(file.fd, fileContent);
      }
      await this.runVideoMultiMergeViaWorker(videoTxt, joinMergeOutput);
      return joinMergeOutput;
    } catch (err) {
      throw normalizeError(err);
    } finally {
      if (file) {
        fs.close(file)
      }
    }
  }

  // 将视频转换成ts文件，为批量合成做准备
  private async formatVideo(videoList: string[], exportDir: string) {
    if (this.cancelRequested) {
      throw new Error('export cancelled');
    }
    let videoNum = 0;
    for (let uri of videoList) {
      if (this.cancelRequested) {
        throw new Error('export cancelled');
      }
      videoNum++;
      let videoTsName = `video${videoNum}.ts`;
      try {
        if (this.cancelRequested) {
          throw new Error('export cancelled');
        }
        let fullCmdTmpTs = `ffmpeg -i ${uri} -c copy -f mpegts ${exportDir}/${videoTsName}`;
        await this.runFfmpegCmdViaWorker(fullCmdTmpTs);
        if (this.cancelRequested) {
          throw new Error('export cancelled');
        }
      } catch (error) {
        throw normalizeError(error);
      }
    }
  }

  // 5)画中画
  private async exportPipSegments(
    exportPipVideo: exportPipVideo[],
    exportDir: string,
    baseVideoPath: string
  ): Promise<string> {
    if (this.cancelRequested) {
      throw new Error('export cancelled');
    }
    // 获取画中画相关信息
    let it: exportPipVideo = exportPipVideo[0];
    let pipUri: string = it.uri

    let minWH = 0;
    if (this.sourceVideoW > this.sourceVideoH) {
      minWH = this.sourceVideoH;
    } else {
      minWH = this.sourceVideoW;
    }
    let scaleWH = Number.parseInt(this.targetH) / minWH;
    let height: number = it.height * scaleWH;
    let width: number = it.width * scaleWH;
    let offsetX: number = it.offsetX; // 数值在0-1之间
    let offsetY: number = it.offsetY; // 数值在0-1之间
    let radiusX: number = it.radiusX; // 系数范围0.1 - 1.0
    let radiusY: number = it.radiusY; // 系数范围0.1 - 1.0

    // 判断画中画是否需要裁剪
    const isEdit: boolean = it.isEdit;
    // 判断画中画是否需要转换成椭圆
    const isShape: boolean = it.isShape;

    // 定义路径
    const pipInputPath = `${exportDir}/pipInput.mp4`
    const pipClipOutputPath = `${exportDir}/pipClipOutput.mp4`;
    const pipMergeOutputPath = `${exportDir}/pipMergeOutput.mp4`;

    // 写入沙箱路径
    if (this.cancelRequested) {
      throw new Error('export cancelled');
    }
    await fsCopy(pipUri, pipInputPath)
    if (this.cancelRequested) {
      throw new Error('export cancelled');
    }

    // a、进行裁剪
    if (isEdit) {
      const startTime = msToHms(Math.max(0, it.startTime));
      const endTime = msToHms(Math.max(0, it.endTime));
      let clipCmd =
        `ffmpeg -y -i ${pipInputPath} -ss  ${startTime} -to ${endTime} -c:v ${this.bitCodec}  ${pipClipOutputPath}`
      await this.runFfmpegCmdViaWorker(clipCmd);
      if (this.cancelRequested) {
        throw new Error('export cancelled');
      }
    }

    // b.添加画中画，判断是否需要椭圆化，isShape为true需要加椭圆，false不需要
    let ffmpegCmd: string = ''
    let pipDuration = it.duration / 1000 // 毫秒转换成秒
    let startFlag = it.xOffsetDistance
    let sigma = 20
    // 椭圆的半轴长度
    const a = (width / 2) * radiusX;
    const b = (height / 2) * radiusY;
    // 模糊扩展
    const expansion = 3 * sigma;
    // 安全边界条件
    const maxPossibleA = (width / 2) - expansion;
    const maxPossibleB = (height / 2) - expansion;
    // 调整后的半轴
    const adjustedA = Math.min(a, maxPossibleA);
    const adjustedB = Math.min(b, maxPossibleB);
    // 调整后的半径系数
    radiusX = (adjustedA * 2) / width;
    radiusY = (adjustedB * 2) / height;
    let time = `:enable='between(t,${startFlag},${pipDuration+ startFlag})'`;
    if (isShape) {
      // 按固定宽高椭圆化
      ffmpegCmd = `ffmpeg -i ${baseVideoPath} -i ${pipClipOutputPath} -filter_complex ` +
        `"[1:v]scale=${width}:${height},format=rgba,setpts=PTS+${startFlag}/TB,split=2[pip1][pip2];` +
        `[pip1]format=gray,geq='if(lt((X-W/2)*(X-W/2)/((W/2)*${radiusX}*(W/2)*${radiusX})+(Y-H/2)*(Y-H/2)/((H/2)*${radiusY}*(H/2)*${radiusY}),1),255,0)'${time}[pip_with_alpha1];` +
        `[pip_with_alpha1]gblur=sigma=${sigma}[alpha_blur1];` +
        `[pip2][alpha_blur1]alphamerge[alpha_blur2];` +
        `[0:v][alpha_blur2]overlay=W*${offsetX}:H*${offsetY}:format=auto${time}" ` +
        `-c:v h264 -y ${pipMergeOutputPath}`;
    } else {
      // 按固定宽高不需要椭圆化
      ffmpegCmd =
        `ffmpeg -i ${baseVideoPath} -i ${pipClipOutputPath} -filter_complex` +
          ` [1:v]scale=${width}:${height},format=rgba,setpts=PTS+${startFlag}/TB[pip];[0:v][pip]overlay=W*${offsetX}:H*${offsetY}:format=auto${time}:alpha=1 -c:v h264 -y ${pipMergeOutputPath}`;
    }
    // 执行合成操作
    await this.runFfmpegCmdViaWorker(ffmpegCmd);
    if (this.cancelRequested) {
      throw new Error('export cancelled');
    }
    return pipMergeOutputPath;
  }

  // 6)、添加字幕
  private async exportSubTitleSegments(
    exportSubTitle: exportSubTitle,
    exportDir: string,
    baseVideoPath: string
  ): Promise<string> {
    let textMarkList: exportSubTitle[] = [exportSubTitle];
    // 定义输出路径
    let subTitleOutputPath = `${exportDir}/subTitleOutput.mp4`;
    let index = 0;
    let cmds: textMarkCmd[] = [];
    for (let textMark of textMarkList) {
      let minWH = 0;
      if (this.sourceVideoW > this.sourceVideoH) {
        minWH = this.sourceVideoH;
      } else {
        minWH = this.sourceVideoW;
      }
      let scaleWH = Number.parseInt(this.targetH) / minWH;
      let width = textMark.width * scaleWH;
      let height = textMark.height * scaleWH;
      let scale = `${width}:${height}`;
      let position = `${textMark.offsetX * scaleWH}:${textMark.offsetY * scaleWH}`;
      let startTime: number = 0
      let endTime: number = this.detail.totalDuration / 1000;
      let angle = 0;
      cmds.push({
        index: ++index,
        path: textMark.url,
        scale: `scale=${scale}`,
        overlay: `overlay=${position}`,
        startTime: startTime,
        endTime: endTime,
        angle: 0
      } as textMarkCmd);
    }
    await this.exportTextMarkSegments(cmds, baseVideoPath, subTitleOutputPath)
    return subTitleOutputPath;
  }

  private async exportPrompterSegments1(
    editTextSnapList: EditTextSnapModel[],
    exportDir: string,
    baseVideoPath: string) : Promise<string> {
    let prompterOutputPath = `${exportDir}/prompterOutput.mp4`;
    let textMarkInfo: EditTextSnapModel = editTextSnapList[0];
    let urlList = textMarkInfo.urlList;
    let snap = `${exportDir}/../../videoAutoCue`;
    let ffmpegCmd =`ffmpeg -framerate 10 -i ${snap}/%04d.png -filter_complex [0:v]split[a][b];[a]palettegen=reserve_transparent=on:stats_mode=diff[p];[b][p]paletteuse -y ${snap}/output.gif`
    try {
      await this.runFfmpegCmdViaWorker(ffmpegCmd);
    } catch (e) {
      throw normalizeError(e);
    }
    let minWH = 0;
    if (this.sourceVideoW > this.sourceVideoH) {
      minWH = this.sourceVideoH;
    } else {
      minWH = this.sourceVideoW;
    }
    let scaleWH = Number.parseInt(this.targetH) / minWH;
    let width = textMarkInfo.width * scaleWH;
    let height = textMarkInfo.height * scaleWH;
    let startTime = textMarkInfo.startTime
    let endTime = textMarkInfo.endTime
    let cmd = `ffmpeg -y -i ${baseVideoPath} -i ${snap}/output.gif -filter_complex ` +
      `[1:v]settb=AVTB,scale=${width}:${height},format=rgba,tpad=stop=-1:stop_mode=clone[gif];` +
      `[0:v][gif]overlay=x='(${textMarkInfo.x}-(overlay_w-${width})/2)*${scaleWH}':y='(${textMarkInfo.y}-(overlay_h-overlay_h/${width}*overlay_w)/2)*${scaleWH}':shortest=1:format=auto:enable='between(t,${startTime},${endTime})' ` +
      `-c:v h264 ${prompterOutputPath}`
    try {
      await this.runFfmpegCmdViaWorker(cmd);
    } catch (e) {
      throw normalizeError(e);
    }
    return prompterOutputPath;
  }

  // 7)、添加提词器
  private async exportPrompterSegments(
    editTextSnapList: EditTextSnapModel[],
    exportDir: string,
    baseVideoPath: string
  ): Promise<string> {

    // 定义输出路径
    let prompterOutputPath = `${exportDir}/prompterOutput.mp4`;
    let textMarkInfo: EditTextSnapModel = editTextSnapList[0];
    let minWH = 0;
    if (this.sourceVideoW > this.sourceVideoH) {
      minWH = this.sourceVideoH;
    } else {
      minWH = this.sourceVideoW;
    }
    let scaleWH = Number.parseInt(this.targetH) / minWH;
    let width = textMarkInfo.width * scaleWH;
    let height = textMarkInfo.height * scaleWH;
    let scale = `${width}:${height}`;
    let position = `${textMarkInfo.x * scaleWH}:${textMarkInfo.y * scaleWH}`;
    let urlList = textMarkInfo.urlList;
    let startTime: number = 0;
    let endTime: number = 0;
    let angle = textMarkInfo.angle;

    let index = 0;
    let cmds: textMarkCmd[] = [];
    for (let url of urlList) {
      startTime = textMarkInfo.startTime + index * 3
      endTime = startTime + 3
      cmds.push({
        index: ++index,
        path: url,
        scale: `scale=${scale}`,
        overlay: `overlay=x='(${textMarkInfo.x}-(overlay_w-${width})/2)*${scaleWH}':y='(${textMarkInfo.y}-(overlay_h-overlay_h/${width}*overlay_w)/2)*${scaleWH}'`,
        startTime: startTime,
        endTime: endTime,
        angle: angle
      } as textMarkCmd);
    }
    prompterOutputPath = await this.exportTextMarkSegments(cmds, baseVideoPath, prompterOutputPath)
    return prompterOutputPath;
  }

  // 执行添加水印
  private async exportTextMarkSegments(
    cmds: textMarkCmd[],
    baseVideoPath: string,
    outputPath: string,
  ): Promise<string> {
    let ffmpegCmd = `ffmpeg -y -i ${baseVideoPath}`;
    ffmpegCmd = ffmpegCmd.concat(this.connectCmd(cmds), ` -c:a copy ${outputPath}`);
    try {
      await this.runFfmpegCmdViaWorker(ffmpegCmd);
    } catch (e) {
      throw normalizeError(e);
    }
    return outputPath
  }

  // 拼接ffmpegCmd参数
  private connectCmd(cmds: textMarkCmd[]) {
    let paths = '';
    let scales = '';
    let overlays = '';
    let rotate = '';
    let rotateCmd = ''
    for (let cmd of cmds) {

      paths += ' -i ' + cmd.path;
      rotate = `${cmd.angle * (Math.PI / 180)}`

      rotateCmd = `rotate=${rotate}:ow=rotw(${rotate}):oh=roth(${rotate}):c=white@0`
      scales += `[${cmd.index}:v]${cmd.scale}[scaled_logo${cmd.index}];`
      scales += `[scaled_logo${cmd.index}]${rotateCmd}[scaled_logo${cmd.index}];`;
      let time = `:enable='between(t,${cmd.startTime},${cmd.endTime})'`;
      // 只有一张图片
      if (cmds.length === 1) {
        overlays = `[0:v][scaled_logo${cmd.index}]${cmd.overlay}${time}`;
      } else if (cmd.index === 1) {
        //第一张图片
        overlays += `[0:v][scaled_logo1]${cmd.overlay}${time}[tmp1];`;
      } else if (cmd.index === cmds.length) {
        // 最后一张图片
        overlays += `[tmp${cmd.index -
          1}][scaled_logo${cmd.index}]${cmd.overlay}${time}`;
      } else {
        overlays += `[tmp${cmd.index -
          1}][scaled_logo${cmd.index}]${cmd.overlay}${time}[tmp${cmd.index}];`;
      }
    }
    let ffmpegCmd = paths + ' -filter_complex ' + scales + overlays;
    return ffmpegCmd;
  }

  // 8)、多个音频合成一个音频
  private async exportJoinAudioSegments(exportDir: string): Promise<string> {
    // 定义输出音频路径
    const joinAudioOutput = `${exportDir}/joinAudio.m4a`;
    if (this.cancelRequested) {
      throw new Error('export cancelled');
    }
    const audioList = this.audioSegPaths ?? [];
    if (!audioList.length) {
      throw new Error('no audio segments');
    }

    // 单段音频：直接拷贝为目标输出
    if (audioList.length === 1) {
      try {
        await fsCopy(audioList[0], joinAudioOutput);
        return joinAudioOutput;
      } catch (err) {
        throw normalizeError(err);
      }
    }

    // 多段音频：使用 ffmpeg concat demuxer 无重编码拼接
    const audioTxt = `${exportDir}/audio.txt`;
    let file: fs.File | undefined = undefined;
    try {
      file = await fs.open(audioTxt, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      for (let p of audioList) {
        const line = `file '${p}'\n`;
        await fs.write(file.fd, line);
      }
      const cmd = `ffmpeg -f concat -safe 0 -i ${audioTxt} -c copy -y ${joinAudioOutput}`;
      await this.runFfmpegCmdViaWorker(cmd);
      return joinAudioOutput;
    } catch (err) {
      throw normalizeError(err);
    } finally {
      if (file) {
        fs.close(file);
      }
    }
  }

  // 9)进行格式转换和增加音频
  private async codeAndAudioSegments(
    videoPath: string,
    videoFormat: string
  ): Promise<string> {
    // 转换后的输出路径
    const outputPath: string = `${this.workListDir}/video.${videoFormat}`;
    let fullCmd =
      `ffmpeg -i ${videoPath} -c copy -y ${outputPath}`
    try {
      await this.runFfmpegCmdViaWorker(fullCmd);
    } catch (e) {
      throw normalizeError(e);
    }
    return outputPath;
  }


  // 目录准备：返回导出目录与输入/输出
  private ensureExportDir(uiCtx: UIContext): string {
    const cacheDir = uiCtx.getHostContext()?.cacheDir;
    // 导出过程中视频的目录
    const exportRoot = cacheDir + '/videoExport';
    // 以同步方法检查文件或目录是否存在
    if (!fs.accessSync(exportRoot)) {
      // 以同步方法创建目录。
      fs.mkdirSync(exportRoot)
    }

    const exportId = new Date().getTime().toString();
    const exportDir = `${exportRoot}/${exportId}`;
    // 以同步方法检查文件或目录是否存在
    if (fs.accessSync(exportDir)) {
      // 删除目录及其所有子目录和文件
      fs.rmdirSync(exportDir)
    }
    // 以同步方法创建目录。
    fs.mkdirSync(exportDir, true)

    return exportDir;
  }

  // 目录准备：返回导出目录与输入/输出
  private ensureWorkListDir(uiCtx: UIContext): string {
    const cacheDir = uiCtx.getHostContext()?.cacheDir;
    // 导出成功后作品的目录
    const workListRoot = cacheDir + '/videoWorkList';
    // 以同步方法检查文件或目录是否存在
    if (!fs.accessSync(workListRoot)) {
      // 以同步方法创建目录。
      fs.mkdirSync(workListRoot)
    }

    const exportId = new Date().getTime().toString();
    const workListDir = `${workListRoot}/${exportId}`;
    // 以同步方法检查文件或目录是否存在
    if (fs.accessSync(workListDir)) {
      // 删除目录及其所有子目录和文件
      fs.rmdirSync(workListDir)
    }
    // 以同步方法创建目录。
    fs.mkdirSync(workListDir, true)

    return workListDir;
  }

  // 导出成功，构建并写入作品数据
  async handleExportSuccess(outputPath: string) {
    // 构建并写入作品数据
    this.exportStatus = 'finish';
    await successSaveWork(outputPath, this.detail, this.videoThumbnail, this.bitCodec);
    this.terminateWorker();
    // 释放导出的沙箱文件资源
    await this.releaseExportCache();
    // 释放编辑视频页传过来的的沙箱文件资源
    await this.releaseEditVideoCache();
    this.loading = false;
  }

  // 导出失败或者终止导出
  async handleExportFail() {
    this.exportStatus = 'unFinish';
    this.terminateWorker();
    this.loading = false;
  }

  // 返回上一层页面
  async backPage() {
    if (!this.loading && this.exportStatus) {
      // 释放导出的沙箱文件资源
      await this.releaseExportCache();
      // 返回视频编辑页面
      this.stack?.pop(this.exportStatus);
    }
  }

  // 释放导出页面的缓存目录
  async releaseExportCache() {
    // 以同步方法检查文件或目录是否存在
    if (fs.accessSync(this.exportDir)) {
      // 删除目录及其所有子目录和文件
      fs.rmdirSync(this.exportDir)
    }
  }

  private releaseEditVideoCacheAction1(detail: exportVideo, candidates: string[]) {
    // 1) 基本视频 basicUrl 列表
    if (detail?.basicVideoData && detail.basicVideoData.length) {
      for (const it of detail.basicVideoData) {
        if (it?.basicUrl) {
          candidates.push(it.basicUrl);
        }
      }
    }

    // 2) 画中画 exportPipVideo uri 列表
    if (detail?.exportPipVideo && detail.exportPipVideo.length) {
      for (const pv of detail.exportPipVideo) {
        if (pv?.uri) {
          candidates.push(pv.uri);
        }
      }
    }

    // 3) 字幕 exportSubTitle url
    if (detail?.exportSubTitle?.url) {
      candidates.push(detail.exportSubTitle.url);
    }
  }

  private releaseEditVideoCacheAction2(detail: exportVideo, candidates: string[]) {
    // 4) 提词器 editTextSnapList 的 urlList
    if (detail?.editTextSnapList && detail.editTextSnapList.length) {
      for (const snap of detail.editTextSnapList) {
        if (snap?.urlList && snap.urlList.length) {
          for (const u of snap.urlList) {
            if (u) {
              candidates.push(u);
            }
          }
        }
      }
    }

    // 逐一删除命中“沙箱路径”的文件
    // for (const p of candidates) {
    //   if (typeof p !== 'string' || p.length === 0) {
    //     continue;
    //   }
    //   if (fs.accessSync(p)) {
    //     try {
    //       fs.unlinkSync(p);
    //     } catch (err) {
    //     }
    //   }
    // }
  }

  // 释放编辑页面传过来的参数中的缓存文件
  async releaseEditVideoCache() {
    try {
      const detail = this.detail;
      const candidates: string[] = [];
      this.releaseEditVideoCacheAction1(detail, candidates)
      this.releaseEditVideoCacheAction2(detail, candidates)
    } catch (e) {
    }
  }


  // 导出结束-失败（再次合成）、成功（去看看）
  exportCompleted(uiCtx: UIContext) {
    if (this.exportStatus === 'finish') {
      // 导出成功：向tab首页发送通知，切换到工作页，在直接返回到tab首页
      uiCtx.getHostContext()?.eventHub.emit('showWorkListTab');
      this.stack?.pop(1);
    } else {
      // 再次导出
      this.startExport(uiCtx, this.detail)
    }
  }

  // ===== Worker 执行封装 =====
  // 注意：所有与 Ffmpeg/MP4Parser 的重任务统一通过 Worker 子线程执行
  // 创建并返回 Worker 实例（若不存在则新建）
  private ensureWorker(): worker.ThreadWorker {
    if (!this.ffmpegWorker) {
      const w = new worker.ThreadWorker(this.workerEntryPath);
      // 错误回调
      w.onerror = (err: ErrorEvent) => {
      };
      // 统一消息回调：路由到对应的挂起任务
      w.onmessage = (e: MessageEvents): void => {
        try {
          const reply = JSON.parse(e.data) as workerReplyVM;
          const pending = this.pendingMap.get(reply.id);
          if (!pending) {
            return;
          }
          this.pendingMap.delete(reply.id);
          this.inFlight = false;
          if (reply.code === 0) {
            pending.resolve();
          } else {
            // MP4Parser/Ffmpeg 失败：code=1 等同于错误，立即中断后续导出
            pending.reject(new Error('Worker task failed, code=' + reply.code));
          }
          // 如果标记了空闲后终止，则在当前任务结束后终止
          if (this.terminateWhenIdle) {
            this.terminateWhenIdle = false;
            this.terminateWorker();
          }
        } catch (err) {
        }
      };
      //  执行w.terminate时会触发退出回调;拒绝所有挂起任务
      w.onexit = (code: number) => {
        this.pendingMap.forEach((pending, id) => {
          pending.reject(new Error('Worker exited while pending, id=' + id));
        });
        this.pendingMap.clear();
        this.inFlight = false;
        // 通知所有等待者：worker 已退出
        const waiters = this.exitWaiters.slice();
        this.exitWaiters = [];
        waiters.forEach(fn => {
          try {
            fn();
          } catch (_) {
          }
        });
      };
      this.ffmpegWorker = w;
    }
    return this.ffmpegWorker!;
  }

  // 停止导出并等待 onexit 完成后再离开页面
  async stopExportAndWait(): Promise<void> {
    // 标记等待停止状态以更新 UI
    this.stopping = true;
    // 标记取消请求，阻断后续步骤执行
    this.cancelRequested = true;
    // 若存在正在执行的任务，标记空闲后终止；否则直接终止
    if (this.ffmpegWorker) {
      if (this.inFlight) {
        this.terminateWhenIdle = true;
      } else {
        this.terminateWorker();
      }
      // 等待 worker 完整退出
      await new Promise<void>((resolve) => {
        this.exitWaiters.push(resolve);
      });
    }
    // 退出后更新状态并返回上一页
    this.exportStatus = 'unFinish';
    this.loading = false;
    this.stopping = false;
    this.backPage();
  }

  // 终止当前 Worker（用于取消导出/失败清理）
  private terminateWorker(): void {
    if (this.ffmpegWorker) {
      // 若当前有任务在执行，标记空闲后终止，避免中途终止导致崩溃
      if (this.inFlight) {
        this.terminateWhenIdle = true;
        return;
      }
      const w = this.ffmpegWorker;
      this.ffmpegWorker = undefined;
      try {
        w.terminate();
      } catch (e) {
      }
    }
  }

  // 通过 Worker 执行 ffmpeg 命令
  private async runFfmpegCmdViaWorker(cmd: string): Promise<void> {
    if (this.cancelRequested) {
      return Promise.reject(new Error('export cancelled'));
    }
    const w = this.ensureWorker();
    return new Promise<void>((resolve, reject) => {
      const id = this.nextMsgId++;
      const task: pendingTask = { resolve, reject };
      this.pendingMap.set(id, task);
      this.inFlight = true;
      // 发送结构化 JSON：包含请求 id
      const msg: workerMsgVM = { id, k: 'ffmpeg', cmd };
      const payload = JSON.stringify(msg);
      w.postMessage(payload);
    });
  }

  // 通过 Worker 执行视频裁剪
  private async runVideoClipViaWorker(
    startTime: string | number,
    endTime: string | number,
    inputLocal: string,
    outputPath: string
  ): Promise<void> {
    if (this.cancelRequested) {
      return Promise.reject(new Error('export cancelled'));
    }
    const w = this.ensureWorker();
    return new Promise<void>((resolve, reject) => {
      const id = this.nextMsgId++;
      const task: pendingTask = { resolve, reject };
      this.pendingMap.set(id, task);
      this.inFlight = true;
      const msg: workerMsgVM = {
        id,
        k: 'clip',
        start: startTime,
        end: endTime,
        input: inputLocal,
        output: outputPath
      };
      const payload = JSON.stringify(msg);
      w.postMessage(payload);
    });
  }

  // 通过 Worker 执行多视频合并
  private async runVideoMultiMergeViaWorker(videoTxtPath: string, outputPath: string): Promise<void> {
    if (this.cancelRequested) {
      return Promise.reject(new Error('export cancelled'));
    }
    const w = this.ensureWorker();
    return new Promise<void>((resolve, reject) => {
      const id = this.nextMsgId++;
      const task: pendingTask = { resolve, reject };
      this.pendingMap.set(id, task);
      this.inFlight = true;
      const msg: workerMsgVM = {
        id,
        k: 'merge',
        txt: videoTxtPath,
        out: outputPath
      };
      const payload = JSON.stringify(msg);
      w.postMessage(payload);
    });
  }
}