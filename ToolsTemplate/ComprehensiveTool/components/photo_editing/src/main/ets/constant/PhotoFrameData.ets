import { PhotoFrameModel } from '../model/PhotoFrameModel';

const frame1 = new PhotoFrameModel($r('app.media.bc_bg_photo_frame_1'), $r('app.media.bc_choose_photo_1'), false);
const frame2 = new PhotoFrameModel($r('app.media.bc_bg_photo_frame_2'), $r('app.media.bc_choose_photo_2'), false);
const frame3 = new PhotoFrameModel($r('app.media.bc_bg_photo_frame_3'), $r('app.media.bc_choose_photo_3'), false);
const frame4 = new PhotoFrameModel($r('app.media.bc_bg_photo_frame_4'), $r('app.media.bc_choose_photo_4'), true);

export const PHOTO_FRAMES: PhotoFrameModel[] = [
  frame1,
  frame2,
  frame3,
  frame4,
];