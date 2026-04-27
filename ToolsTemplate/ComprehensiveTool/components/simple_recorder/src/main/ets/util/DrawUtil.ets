import { fileIo } from '@kit.CoreFileKit';
import { Logger } from '../util/Logger';

// 解析PCM时域数据，提取振幅值（用于绘制波纹图）
export async function parseWavePCM(pcmPath: string): Promise<number[]> {
  const waveData: number[] = [];
  // PCM参数（需与FFmpeg命令输出一致）
  const bitDepth = 16; // 16位
  const bytesPerSample = bitDepth / 8; // 每个采样点2字节

  try {
    // 读取PCM二进制文件
    const file = fileIo.openSync(pcmPath, fileIo.OpenMode.READ_ONLY);
    const buffer = new ArrayBuffer(fileIo.statSync(file.fd).size);
    fileIo.readSync(file.fd, buffer);
    fileIo.closeSync(file);

    // 降采样：若数据量过大（如长音频），每隔N个点取一个值，减少绘制压力
    const downSampleRatio = 160 * 4; // 降采样比例（根据需求调整)


    // 解析每个采样点的振幅值（16位小端有符号整数）
    const dataView = new DataView(buffer);
    for (let i = 0; i < buffer.byteLength; i += bytesPerSample*downSampleRatio) {
      // 读取振幅值（范围：-32768 ~ 32767）
      const amplitude = dataView.getInt16(i, true); // true表示小端序
      waveData.push(amplitude);
    }

    return waveData;
  } catch (e) {
    Logger.error('解析PCM时域数据失败：', JSON.stringify(e));
    return [];
  }
}