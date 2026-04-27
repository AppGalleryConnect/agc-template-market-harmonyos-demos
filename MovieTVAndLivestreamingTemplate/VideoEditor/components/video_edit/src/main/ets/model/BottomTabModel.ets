export class BottomNavigationModel {
  index: number = 0;
  title: Resource = $r('app.string.home');
  primaryImage: Resource = $r('app.media.cut_icon');
  selectedImage: Resource = $r('app.media.cut_icon');
}


//常量数据定义基本Tab内容
export const FUNCTION_BUTTON_INFO: BottomNavigationModel[] = [
  {
    index: 0,
    title: $r('app.string.cut'),
    primaryImage: $r('app.media.cut_icon'),
    selectedImage: $r('app.media.cut_icon_sel')
  },
  {
    index: 1,
    title: $r('app.string.pip'),
    primaryImage: $r('app.media.pip_icon'),
    selectedImage: $r('app.media.pip_icon_sel')
  },
  {
    index: 2,
    title: $r('app.string.video_frame_extraction'),
    primaryImage: $r('app.media.video_frame_extraction_icon'),
    selectedImage: $r('app.media.video_frame_extraction_icon_sel')
  },
  {
    index: 3,
    title: $r('app.string.autocue'),
    primaryImage: $r('app.media.ic_autocue'),
    selectedImage: $r('app.media.ic_autocue_sel')
  },
  {
    index: 4,
    title: $r('app.string.add_subtitles'),
    primaryImage: $r('app.media.ic_save_album'),
    selectedImage: $r('app.media.ic_save_album')
  }

]

//常量数据定义弹窗Tab内容
export const FUNCTION_BUTTON_TOAST_INFO: BottomNavigationModel[] = [
  {
    index: 0,
    title: $r('app.string.split'),
    primaryImage: $r('app.media.ic_split'),
    selectedImage: $r('app.media.ic_split')
  },
  {
    index: 1,
    title: $r('app.string.add_picture_in_picture'),
    primaryImage: $r('app.media.ic_add_pic_in_pic'),
    selectedImage: $r('app.media.ic_add_pic_in_pic')
  },
  {
    index: 2,
    title: $r('app.string.set_video_cover'),
    primaryImage: $r('app.media.video_frame_extraction_icon'),
    selectedImage: $r('app.media.video_frame_extraction_icon')
  },
  {
    index: 3,
    title: $r('app.string.save_album'),
    primaryImage: $r('app.media.ic_set_video_cover'),
    selectedImage: $r('app.media.ic_set_video_cover')
  },
  {
    index: 4,
    title: $r('app.string.add_subtitles'),
    primaryImage: $r('app.media.ic_save_album'),
    selectedImage: $r('app.media.ic_save_album')
  }
]