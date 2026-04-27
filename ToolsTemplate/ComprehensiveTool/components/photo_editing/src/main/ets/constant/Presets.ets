import { CustomFilter } from '../model/CustomFilter';

export const PRESETS: CustomFilter[] =
  [
    {
      image: $r('app.media.ic_filter_original'),
      name: '原图', // Original - No change
      blur: 0,
      invert: false,
      colorMatrix: [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false,
      isHot: false,
      isVip: false
    },
    {
      image: $r('app.media.bg_filter1'),
      name: '繁花如梦', // Sunrise - Warm, golden tones, boosted reds and yellows
      blur: 0,
      invert: false,
      colorMatrix: [
        0.95, 0.20, 0.05, 0, 0.07,
        0.05, 0.85, 0.10, 0, 0.05,
        0.00, 0.10, 0.80, 0, 0.04,
        0, 0, 0, 1, 0,
      ],
      brightness: 0.15,
      grayscale: false,
      isHot: true,
      isVip: false
    },
    {
      image: $r('app.media.bg_filter2'),
      name: '美食专属', // Sunset - Deep, rich warm tones, strong reds and oranges
      blur: 0,
      invert: false,
      colorMatrix: [
        0.95, 0.25, 0.05, 0, 0.08,
        0.10, 0.80, 0.10, 0, 0.06,
        0.00, 0.10, 0.75, 0, 0.05,
        0, 0, 0, 1, 0,
      ],
      brightness: 0.2,
      grayscale: false,
      isHot: true,
      isVip: false
    },
    {
      image: $r('app.media.bg_filter3'),
      name: '夏日清凉', // Gentle Amoro - Soft, slightly warm, with a subtle pinkish tint
      blur: 0.1,
      invert: false,
      colorMatrix: [
        0.95, 0.15, 0.05, 0, 0.06,
        0.05, 0.85, 0.10, 0, 0.05,
        0.00, 0.10, 0.80, 0, 0.04,
        0, 0, 0, 1, 0,
      ],
      brightness: 0.05,
      grayscale: false,
      isHot: true,
      isVip: false
    },
    {
      image: $r('app.media.ic_filter_restore'),
      name: '复古', // Antique - Sepia-like, faded, slightly desaturated
      blur: 0,
      invert: false,
      colorMatrix: [
        0.70, 0.25, 0.10, 0, 0.06,
        0.20, 0.65, 0.15, 0, 0.05,
        0.10, 0.20, 0.55, 0, 0.04,
        0, 0, 0, 1, 0,
      ],
      brightness: 0,
      grayscale: false,
      isHot: false,
      isVip: false
    },
    {
      image: $r('app.media.ic_filter_romantic'),
      name: '浪漫', // Romance - Soft, slightly warm, with a subtle pink/red tint
      blur: 0,
      invert: false,
      colorMatrix: [
        0.95, 0.15, 0.15, 0, 0.06,
        0.05, 0.85, 0.20, 0, 0.05,
        0.05, 0.10, 0.80, 0, 0.04,
        0, 0, 0, 1, 0,
      ], // Your original is suitable for Romance.
      brightness: 0.1,
      grayscale: false,
      isHot: false,
      isVip: false
    },
    {
      image: $r('app.media.ic_filter_warm'),
      name: '温暖', // Warm - General warm tint, slightly increased reds and yellows
      blur: 0,
      invert: false,
      colorMatrix: [
        0.95, 0.10, 0.05, 0, 0.05,
        0.05, 0.90, 0.10, 0, 0.05,
        0.00, 0.05, 0.85, 0, 0.03,
        0, 0, 0, 1, 0,
      ], // Your original is good for Warm.
      brightness: 0.1,
      grayscale: false,
      isHot: false,
      isVip: true
    },
  ];