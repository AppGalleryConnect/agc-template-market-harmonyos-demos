import { SongItem } from 'types';

@ObservedV2
export class PlayInfo {
  @Trace status: boolean = false;
  @Trace songList: SongItem[] = [];
  @Trace isPlay: boolean = false;
  @Trace musicIndex: number = 0;
  @Trace currentTime: string = '00:00';
  @Trace progress: number = 0;
  @Trace totalTime: string = '00:00';
  @Trace progressMax: number = 0;
  @Trace pageShowTime: number = 0;
  @Trace url: string = '';
}