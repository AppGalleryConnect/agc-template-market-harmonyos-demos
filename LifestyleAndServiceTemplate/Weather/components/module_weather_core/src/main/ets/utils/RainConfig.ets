/**
 * 雨量等级：NONE无/LIGHT小雨/MEDIUM中雨/HEAVY大雨
 */
export enum RainLevel {
  NONE = 0,
  LIGHT = 1,
  MEDIUM = 2,
  HEAVY = 3
}

/**
 * RGB颜色值接口
 */
interface RgbColor {
  r: number;
  g: number;
  b: number;
}

/**
 * 雨滴粒子参数配置，根据雨量等级返回对应的发射率、速度、角度等参数
 */
export class RainConfig {
  /**
   * 根据天气描述文字解析雨量等级
   * @param desc 天气描述文字
   * @returns 雨量等级
   */
  static getRainLevel(desc: string): RainLevel {
    if (!desc) {
      return RainLevel.NONE;
    }
    if (desc.includes('大雨') || desc.includes('暴雨') || desc.includes('雷阵雨')) {
      return RainLevel.HEAVY;
    }
    if (desc.includes('中雨') || desc.includes('阵雨')) {
      return RainLevel.MEDIUM;
    }
    if (desc.includes('雨')) {
      return RainLevel.LIGHT;
    }
    return RainLevel.NONE;
  }

  /**
   * 获取粒子发射速率
   * @param level 雨量等级
   * @returns 粒子发射速率
   */
  static getEmitRate(level: RainLevel): number {
    const values = [0, 50, 120, 200];
    return values[level];
  }

  /**
   * 获取粒子生命周期
   * @param level 雨量等级
   * @returns 粒子生命周期（毫秒）
   */
  static getLifetime(level: RainLevel): number {
    const values = [0, 3000, 2000, 1500];
    return values[level];
  }

  /**
   * 获取雨丝下落速度范围
   * @param level 雨量等级
   * @returns 雨丝下落速度范围 [min, max]
   */
  static getParticleFallSpeed(level: RainLevel): [number, number] {
    const values: [number, number][] = [[0, 0], [1200, 1800], [1800, 2600], [2400, 3200]];
    return values[level];
  }

  /**
   * 获取雨丝下落角度范围
   * @param level 雨量等级
   * @returns 雨丝下落角度范围 [min, max]
   */
  static getParticleFallAngle(level: RainLevel): [number, number] {
    const values: [number, number][] = [[0, 0], [89, 91], [88, 92], [86, 94]];
    return values[level];
  }

  /**
   * 获取雨丝加速度范围
   * @param level 雨量等级
   * @returns 雨丝加速度范围 [min, max]
   */
  static getParticleAccSpeed(level: RainLevel): [number, number] {
    const values: [number, number][] = [[0, 0], [100, 200], [150, 300], [200, 400]];
    return values[level];
  }

  /**
   * 获取雨丝加速度角度范围
   * @param level 雨量等级
   * @returns 雨丝加速度角度范围 [min, max]
   */
  static getParticleAccAngle(level: RainLevel): [number, number] {
    const values: [number, number][] = [[0, 0], [89, 91], [88, 92], [86, 94]];
    return values[level];
  }

  /**
   * 获取溅射粒子初速度范围
   * @param level 雨量等级
   * @returns 溅射粒子初速度范围 [min, max]
   */
  static getParticleSplashSpeed(level: RainLevel): [number, number] {
    const values: [number, number][] = [[0, 0], [80, 150], [100, 180], [120, 220]];
    return values[level];
  }

  /**
   * 将十六进制颜色转换为RGB
   * @param hex 十六进制颜色字符串（如 #4F6384）
   * @returns RGB对象
   */
  private static hexToRgb(hex: string): RgbColor {
    const hexValue = hex.replace('#', '');
    const r = parseInt(hexValue.substring(0, 2), 16);
    const g = parseInt(hexValue.substring(2, 4), 16);
    const b = parseInt(hexValue.substring(4, 6), 16);
    const rgb: RgbColor = { r: r, g: g, b: b };
    return rgb;
  }

  /**
   * 计算颜色的相对亮度（基于sRGB）
   * @param hex 十六进制颜色字符串
   * @returns 亮度值 0-1
   */
  private static getBrightness(hex: string): number {
    const rgb = RainConfig.hexToRgb(hex);
    return 0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b;
  }

  /**
   * 根据背景色获取雨滴颜色范围
   * @param backgroundColor 背景颜色（十六进制）
   * @returns 雨滴颜色范围 [minColor, maxColor]
   */
  static getRainColor(backgroundColor: string): [string, string] {
    const brightness = RainConfig.getBrightness(backgroundColor);
    if (brightness > 128) {
      return ['rgb(50, 90, 140)', 'rgb(30, 70, 120)'];
    } else {
      return ['rgb(220, 235, 255)', 'rgb(200, 220, 255)'];
    }
  }

  /**
   * 根据背景色获取溅射颜色范围
   * @param backgroundColor 背景颜色（十六进制）
   * @returns 溅射颜色范围 [minColor, maxColor]
   */
  static getSplashColor(backgroundColor: string): [string, string] {
    const brightness = RainConfig.getBrightness(backgroundColor);
    if (brightness > 128) {
      return ['rgb(70, 100, 150)', 'rgb(100, 130, 180)'];
    } else {
      return ['rgb(180, 210, 240)', 'rgb(230, 245, 255)'];
    }
  }

  /**
   * 获取雨丝不透明度范围
   * @param backgroundColor 背景颜色（十六进制）
   * @returns 雨丝不透明度范围 [min, max]
   */
  static getRainOpacity(backgroundColor: string): [number, number] {
    const brightness = RainConfig.getBrightness(backgroundColor);
    if (brightness > 128) {
      return [0.8, 1.0];
    } else {
      return [0.3, 0.5];
    }
  }

  /**
   * 获取溅射不透明度范围
   * @param backgroundColor 背景颜色（十六进制）
   * @returns 溅射不透明度范围 [min, max]
   */
  static getSplashOpacity(backgroundColor: string): [number, number] {
    const brightness = RainConfig.getBrightness(backgroundColor);
    if (brightness > 128) {
      return [0.9, 1.0];
    } else {
      return [0.6, 0.8];
    }
  }

  /**
   * 获取雨滴尺寸范围
   * @returns 雨滴尺寸范围 [min, max]
   */
  static getRainSize(): [number, number] {
    return [1.5, 24];
  }
}
