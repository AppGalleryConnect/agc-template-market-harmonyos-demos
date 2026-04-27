// YIN算法
export function yinGuitarTuning(pcmData: Int16Array, sampleRate: number = 44100): number {
  // 数据预处理：16位PCM → 浮点型（归一化到[-1,1]）
  let signal = new Float32Array(pcmData.length);
  for (let i = 0; i < pcmData.length; i++) {
    signal[i] = pcmData[i] / 32768; // 振幅值（范围：-32768 ~ 32767）,用32768更贴近理论范围，误差可忽略
  }

  // 先降噪再低通，平衡高低频特征
  const denoisedSignal = denoiseSignal(signal, 0.01); // 微弱噪声过滤
  signal = lowPassFilter(denoisedSignal, sampleRate, 1400); // 滤除高频杂波（高于E6）

  // 信号帧长
  const frameSize = signal.length;

  // 计算YIN原始差函数（YD）
  const yd = new Float32Array(frameSize);
  for (let tau = 0; tau < frameSize; tau++) {
    let sum = 0;
    // 累加平方差
    for (let i = 0; i < frameSize - tau; i++) {
      const diff = signal[i] - signal[i + tau];
      sum += diff * diff;
    }
    yd[tau] = sum;
  }

  // 计算累积平均归一化差函数（CMND）
  const cmnd = new Float32Array(frameSize);
  cmnd[0] = 1.0; // tau=0时无意义，固定为1
  let cumulativeSum = 0; // 用累积和优化性能，避免重复求和
  for (let tau = 1; tau < frameSize; tau++) {
    cumulativeSum += yd[tau];
    cmnd[tau] = yd[tau] / (cumulativeSum / tau + 1e-6); // 加微小值防除零
  }

  // 周期搜索：适配吉他音域，阈值与CMND量级匹配
  const threshold = 0.1; // 经验阈值（0.08-0.15均可）
  const minFreq = 82.4; // 吉他最低音E2
  const maxFreq = 1318.5; // 吉他最高音E6
  const minTau = Math.floor(sampleRate / maxFreq); // ≈33
  const maxTau = Math.floor(sampleRate / minFreq); // ≈535
  let tau = 0;

  // 找第一个低于阈值的tau（基音周期的起点）
  for (let t = minTau; t < maxTau; t++) {
    if (cmnd[t] < threshold) {
      tau = t;
      // 向后确认极小值（CMND最低的点即真实周期）
      while (tau + 1 < maxTau && cmnd[tau + 1] < cmnd[tau]) {
        tau++;
      }
      break;
    }
  }


  // 未找到有效周期
  if (tau === 0) {
    return 0;
  }

  //  抛物线插值：提升tau精度
  if (tau > 0 && tau < frameSize - 1) {
    const a = cmnd[tau - 1];
    const b = cmnd[tau];
    const c = cmnd[tau + 1];
    tau += 0.5 * (a - c) / (a - 2 * b + c);
  }

  // 6. 计算基频
  const fundamentalFreq = sampleRate / tau;

  // 在计算频率后添加A2弦的特殊处理,去除2倍谐波
  if (Math.abs(fundamentalFreq - 220) < 5) { // 检测到220Hz附近
    const halfTau = tau * 2;
    const halfFreq = sampleRate / halfTau;
    // 如果是110Hz附近的A2
    if (halfFreq > 105 && halfFreq < 115 && cmnd[halfTau.toFixed(0)] < threshold) {
      return Number(halfFreq.toFixed(2));
    }
  }
  // 无效频率置为0，处理NaN
  return fundamentalFreq > 0 ? Number(fundamentalFreq.toFixed(2)) : 0;
}

/**
 * 辅助函数：简单降噪（阈值过滤，消除微弱噪声）
 * @param signal 滤波前信号
 * @param noiseThreshold 噪声阈值（0.01适配吉他音频）
 */
function denoiseSignal(signal: Float32Array, noiseThreshold: number): Float32Array {
  const denoised = new Float32Array(signal.length);
  for (let i = 0; i < signal.length; i++) {
    // 信号绝对值小于阈值，视为噪声，置为0；否则保留原信号
    denoised[i] = Math.abs(signal[i]) < noiseThreshold ? 0 : signal[i];
  }
  return denoised;
}

/**
 * 一阶Butterworth低通滤波（滤除高频杂波，保留吉他全音域）
 * @param signal 滤波前信号
 * @param sampleRate 采样率
 * @param cutoffFreq 截止频率（1400Hz，高于吉他最高E6的1318.5Hz）
 */
function lowPassFilter(signal: Float32Array, sampleRate: number, cutoffFreq: number): Float32Array {
  const filtered = new Float32Array(signal.length);
  const RC = 1 / (2 * Math.PI * cutoffFreq);
  const dt = 1 / sampleRate;
  const alpha = dt / (RC + dt); // 滤波系数，平衡滤波强度与信号延迟

  filtered[0] = signal[0]; // 初始值赋值，避免首帧突变
  for (let i = 1; i < signal.length; i++) {
    filtered[i] = filtered[i - 1] + alpha * (signal[i] - filtered[i - 1]);
  }
  return filtered;
}




